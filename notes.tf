### Kodekloud Notes ###

// 1. Using Input Variables

# variables.tf
variable "filename" {
  default = "/root/pets.txt"
}

variable "content" {
  default = "We love pets!"
}

variable "prefix" {
  default = "Mrs"
}

variable "separator" {
  default = "."
}

variable "length" {
  default = "1"
}

# Use variables within "main.tf" file
# Replace the argument values, with the variable names prefixed with "var"

# main.tf
resource "local_file" "pet" {
  filename = var.filename
  content  = var.content
}

resource "random_pet" "my-pet" {
  prefix    = var.prefix
  separator = var.separator
  length    = var.length
}

# AWS EC2 instance

# main.tf
resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
}

# variables.tf
variable "ami" {
  default = "ami-0edab43b6fa892279"
}

variable "instance_type" {
  default = "t2.micro"
}

// 2. Understanding the Variable Block

# List values are index-based

# variables.tf
variable "prefix" {
  default = ["Mr", "Mrs", "Sir"]
  type    = list(any)
}

# main.tf
resource "random_pet" "my-pet" {
  prefix = var.prefix[0] # First element of the above list
}

# A map is data represented in the format of key-value pairs

# variables.tf
variable "file-content" {
  type = map(any)
  default = {
    "statement1" = "We love pets!"
    "statement2" = "We love animals!"
  }
}

# Get the value of the second key ("statement2")
# main.tf
resource "local_file" "my-pet" {
  filename = "/root/pets.txt"
  content  = var.file-content["statement2"]
}

# Combine type constraints

# variables.tf
variable "prefix" {
  default = ["Mr", "Mrs", "Sir"]
  type    = list(string) # List of string elements
}

variable "prefix" {
  default = [1, 2, 3]
  type    = list(number) # List of number elements
}

# Same is true for maps

# variables.tf
variable "cats" {
  default = {
    "color" = "brown"
    "name"  = "bella"
  }
  type = map(string)
}

variable "pet_count" {
  default = {
    "dogs"     = 3
    "cats"     = 1
    "goldfish" = 2
  }
  type = map(number)
}

# A set cannot have duplicate elements like a list

# variables.tf
variable "prefix" {
  default = ["Mr", "Mrs", "Sir"]
  type    = set(string)
}

variable "fruit" {
  default = ["apple", "banana"]
  type    = set(string)
}

variable "age" {
  default = [10, 12, 15]
  type    = set(number)
}

# Objects (complex data structures)
# Combine all above variable types

# variables.tf
variable "bella" {
  type = object({
    name         = string
    color        = string
    age          = number
    food         = list(string)
    favorite_pet = bool
  })
  # Default values assigned to "bella" variable
  default = {
    name         = "bella"
    color        = "brown"
    age          = 7
    food         = ["fish", "chicken", "turkey"]
    favorite_pet = true
  }
}

# Tuples are similar to lists and consist of a sequence of elements
# Lists use elements of the same variable type (i.e. string, number)
# Tuples, different elements of different variable types can be used

# variables.tf
variable "kitty" {
  type    = tuple([string, number, bool])
  default = ["cat", 7, true]
}

// 3. Using Variables (input) in Terraform

# Command Line Flags

# Use "-var" flag
terraform apply -var "filename=/root/pets.txt" -var "content=We love pets!" -var "prefix=Mrs" -var "separator="." -var "length=2"

# Environment Variables
# Prefix variable name with "TF_VAR_"
export TF_VAR_filename="/root/pets.txt"
export TF_VAR_content="We love pets!"
export TF_VAR_prefix="Mrs"
export TF_VAR_separator="."
export TF_VAR_length="2"

terraform apply

# Variable Definition Files (must end in "".tfvars", or ".tfvars.json")
# Variable definition files if named: "terraform.tfvars", or "terraform.tfvars.json", or
# any other name ending with "*.auto.tfvars", or "*.auto.tfvars.json", will be automatically
# loaded by Terraform

# terraform.tfvars
filename = "/root/pets.txt"
content = "We love pets!"
prefix = "Mrs"
separator = "."
length = "2"

terraform apply

# Parse any other filename (other the above), (i.e. variables.tfvars),
# with a command line flag called "-var-file"
terraform apply -var-file variables.tfvars

# Variable Definition Precedence
# Use multiple ways to assign values to the same variable

# main.tf
resource "local_file" "pet" {
  filename = var.filename
}

# variables.tf
variable "filename" {
  type = string
}

# Examples
export TF_VAR_filename="/root/cats.txt"

# terraform.tfvars
filename = "/root/pets.txt"

# variables.auto.tfvars
filename = "/root/mypet.txt"

# Command line flag
terraform apply -var "filename=/root/best-pet.txt"

# Precedence (order):

# Order       Option
# ---------------------------------------------------
# 1           Environment Variables
# 2           terraform.tfvars
# 3           *.auto.tfvars (alphabetical order)
# 4           -var, or -var-file (command-line flags)

// 4. Resource Attributes

# Implicit Dependency

# main.tf
resource "local_file" "pet" {
  filename = var.filename
  content = "My favorite pet is ${random_pet.my-pet.id}" # Implicit Dependency
}

resource "random_pet" "my-pet" {
  prefix = var.prefix
  separator = var.separator
  length = var.length
}

# Attribute Reference:
# The following attributes are supported: "id" -> (string) The random pet name
# Syntax: <Resource_Type><Resource_Name><Attribute> (i.e. "random_pet.my-pet.id")
terraform apply -> # (i.e. "My favorite pet is Mr. Bull!" # forces replacement)

# Explicit Dependency

# main.tf
resource "local_file" "pet" {
  filename = "var.filename"
  content = "My favorite pet is Mr.Cat"

  depends_on = [ # Explicit Dependency
    random_pet.my_pet
  ]
}

resource "random_pet" "my-pet" {
  prefix = "var.prefix"
  separator = var.separator
  length = var.length
}

// 5. Output Variables

# Used to store the value of an expression in Terraform
# Quickly display details about a provisioned resource on screen,
# or, to feed the output variable(s) to other IaC tools (i.e. Ansible)
# for configuration management and testing
# When "terraform apply" is run, output variables are printed on the screen

# main.tf
resource "local_file" "pet" {
  filename = "var.filename"
  content = "My favorite pet is ${random_pet.my-pet.id}"
}

resource "random_pet" "my-pet" {
  prefix = var.prefix
  separator = var.separator
  length = var.length
}

output "pet-name" {
  value = random_pet.my-pet.id
  description = "Record the value of pet ID generated by the random_pet resource" # -> ${random_pet.my-pet.id}"
}

# Syntax for output variables
output "<variable_name>" {
  value = "variable_value" # -> reference expression
  <arguments>
}

# variables.tf
variable "filename" {
  default = "/root/pets.txt"
}

variable "content" {
  default = "We love pets!"
}

variable "prefix" {
  default = "Mrs"
}

variable "separator" {
  default = "."
}

variable "length" {
  default = "1"
}

# Once the resource is created, use "terraform output",
# to print the value of the output variable(s)
terraform output (.i.e. pet-name = Mrs.gibbon)
terraform output pet-name (i.e. Mrs.gibbon)

// 6. Terraform State

# Don't refresh state file every time!
# Use with all terraform "state" commands (i.e. terraform plan)
terraform plan --refresh=false

