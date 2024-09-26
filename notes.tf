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

# Do not refresh the state file every time!
# Rely on the cache attributes Terraform stores
# The execution plan, plots a resource placement
# Use "plan" flag, with all terraform "state" commands (i.e. terraform plan, terraform apply)
terraform plan --refresh=false

// 7. Terraform Commands

# terraform show, print the current state of the infrastructure
# Use the "-json" flag, to print the contents in JSON format
terraform show / terraform show -json

# View a list of all providers used in a configuration directory
terraform providers

# Use the "mirror" subcommand, to copy provider plugins needed for the current configuration, to another directory
terraform providers mirror /root/terraform/new_local_file

# Print all output variables in the configuration directory
terraform output (i.e. content = "We love pets" & pet-name= "huge-owl")

# Print value of a specific variable
terraform output pet-name

# Terraform refresh, is used to sync Terraform, with real world infrastructure
# If there are any changes to a resource created by Terraform, outside its control,
# (i.e. manual update), "terraform refresh", will pick it up and update the state file!
# This reconciliation is useful to determine what action to take during the next apply
# This command will not modify and infrastructure resource, but it will modify the state file
# "terraform refresh", is automatically run by commands such as "terraform plan" & "terraform apply"
# This is done to prior to Terraform generating an execution plan. This can be bypassed by using the
# "-refresh=false" option, with the above commands (terraform plan & terraform apply)
terraform refresh

# Graph, is used to create a visual representation of the dependencies in a Terraform configuration or an execution plan
# This command can be run as soon as the configuration file is ready, even before initializing the configuration directory
# Use a graph visualization software, such as "Graphviz" (i.e. on Ubuntu)
terraform graph
apt update -y
apt install -y graphviz

# Pass the output of the "terraform graph", to the "dot" command
# Open the file via a browser, to view the dependency graph
# The root is the configuration directory, where the configuration for this graph is located
terraform graph | dot -Tsvg > graph.svg

// 8. Mutable vs Immutable Infrastructure

# Terraform uses the immutability approach to provision resources
# Updating (changing) a resource block (i.e. change permissions),
# will result in the original file to be deleted and a new file
# to be created with the updated permission. By default, Terraform
# destroys the resource first, before creating a new one in its place!

// 9. LifeCycle Rules

/*
Order   Option                  Comments
--------------------------------------------------------------------------------------
1       create_before_destroy   Create the resource first and then destroy
2       prevent_destroy         Prevents a resource from being destroyed
3       ignore_changes          Ignore changes to "Resource Attributes" (specific/all)
*/

# main.tf
# Lifecycle rule
# "create_before_destroy" -> Create the new resource before destroying the old
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = "We love pets!"
  file_permission = "0700"

  lifecycle {
    create_before_destroy = true
  }
}

# main.tf
# Lifecycle rule
# "prevent_destroy" -> Prevent resources from being accidentaly deleted!
# When set to "true", Terraform will reject any changes, that will result
# in the resource getting destroyed. However, the resource can still be
# destroyed with "terraform destroy". This rule prevents resource deletion
# from changes made to the configuration and a subsequent apply
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = "We love pets!"
  file_permission = "0700"
 
  lifecycle {
    prevent_destroy = true 
  }
}

# main.tf
# This lifecycle rule when applied will prevent a resource from being updated
# based on a list of attributes defined in the lifecycle block
# The "ignore-case" argument, accepts a list as indicated by the []
# It will accept any valid resource attribute (i.e. tags)
# If a change is made to the tags, a subsequent "terraform apply",
# should now show, there are now changes to apply! Changes made to
# the tags of a server outside of Terraform, are now completely ignored!
# Since "ignore_changes" is a list it's possible to update more elements (i.e. tags, ami)
# It's also possible to place the list with the "all" keyword, if a resource should not be
# modified in case of a change in any of the resource attributes!
resource "aws_instance" "webserver" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  tags = {
    Name = "ProjectA-Webserver"
  }
  lifecycle {
    ignore_changes = ALL
  }
}

// 10. Datasources

# Datasources allow Terraform to read attributes from 
# resources that are provisioned outside its control
# The "dog.txt" file, was provisioned outside Terraform
# To read attributes from a local file called "dogs.txt",
# define a data block within the configuration file
# Data Sources export 2 attributes: "content", "content_base64"

/*
Resource                                     Data Source
-----------------------------------------------------------------------
Keyword: resource                            Keyword: data
Creates, Updates, Destroys Infrastructure    Only Reads Infrastructure
Also called Managed Resources                Also called Data Resources
*/

# main.tf
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = data.local_file.dog.content
  # content = "We love pets!"
}

data "local_file" "dog" {
  filname = "/root/dog.txt"
}

// 11. Meta Arguments

# main.tf
resource "local_file" "pet" {
  filename = var.filename
  content = var.content
  depends_on = [
    random_pet.my-pet
  ]
}

resource "random_pet" "my-pet" {
  prefix = var.prefix
  separator = var.separator
  length = var.length
}

# main.tf
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = "We love pets!"
  file_permission = "0700"

  lifecycle {
    create_before_destroy = true
  }
}

# Count (meta-argument)
# Resources are stored as a "list", not a "map" with "count", meaning resources are identified by their index

# main.tf
resource "local_file" "pet" {
  filename = var.filename[count.index]
  count = length(var.filename) 
}

output "pets" {
  value = local_file.pet
}

# variables.tf
variable "filename" {
  default = [
    "/root/pets.txt" # -> pet[0]
    "/root/dogs.txt" # -> pet[1]
    "/root/cats.txt" # -> pet[2]
  ]
}

# Length Function

/*
variable                                  function          value
-----------------------------------------------------------------
fruits=["apple, "banana", "orange"]       length(fruits)    3
cars=["honda", "bmw", "nissan", "kia"]    length(cars)      4
colors=["red", "purple"]                  length(colors)    2
*/

/*
Resource          Resource Updates                        Action
-----------------------------------------------------------------------------
pet[0]            "/root/pets.txt" -> "/root/dogs.txt"    Destroy and Replace
pet[1]            "/root/dogs.txt" -> "/root/cats.txt"    Destroy and Replace
pet[2]            Does not Exist                          Destroy
*/

# for-each (meta argument)

# main.tf
resource "local_file" "pet" {
  filename = each.value
  for_each = var.filename
}

# variables.tf
# A "set" cannot contain duplicate elements!
variable "filename" {
  type=set(string) # Change variable type to "set"
  default = [
    "/root/pets.txt"
    "/root/dogs.txt"
    "/root/cats.txt"
  ]
}

# Variable type is "list"
# Use built-in function called "toset", which converts variables from a "list" to a "set"

# main.tf
# Resources are stored as a "map", not a "list" with "for_each", meaning resources are identified by the keys (i.e. "/root/cats.txt", "/root/dogs.txt")
resource "local_file" "pet" {
  filename = each.value
  for_each = toset(var.filename)
}

output "pets" {
  value = local_file.pet
}

# variables.tf
variable "filename" {
  type=list(string)
  default = [
    "/root/pets.txt"
    "/root/dogs.txt"
    "/root/cats.txt"
  ]
}

# variables.tf
# Remove "/root/pets.txt" from the list
# Now, when "terraform plan" is run, only "local_file.pet" will be destroyed!
# The other resources will be untouched!
variable "filename" {
  type=list(string)
  default = [
    "/root/dogs.txt"
    "/root/cats.txt"
  ]
}

// 12. Version Constraints

# main.tf
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "1.4.0"
    }
  }
}

resource "local_file" "pet" {
  filename = "/root/pet.txt"
  content = "We love pets!"
}

# main.tf
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "!= 2.0.0" # Do not download this specific version!
    }
  }
}

# main.tf
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "< 1.4.0" # Use a version lower than the one provided!
    }
  }
}

# main.tf
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "> 1.1.0" # Use a version greater than the one provided!
    }
  }
}

# main.tf
# Combine comparison operators, to make use a specific version within a range
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "> 1.2.0, < 2.0.0, != 1.4.0" # Use a version greater than the one provided!
    }
  }
}

# Pessimistic constraint operators
# This operator allows Terraform to download the specific version, 
# or any available incremental version based on the provided value (i.e. 1.2, 1.3 and 1.4) -> Docs
# Link: https://registry.terraform.io/providers/hashicorp/local/latest/docs
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 1.2"
    }
  }
}

# This operator allows Terraform to download the specific version, 
# or any available incremental version based on the provided value (i.e. 1.2.0, 1.2.1 and 1.2.2) -> Docs
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 1.2.0"
    }
  }
}

// 13. 