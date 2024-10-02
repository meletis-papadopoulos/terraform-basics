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
# One provider "local", the value for this argument is an object
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 1.2.0"
    }
  }
}

// 13. AWS IAM with Terraform

# "resource" -> Block Name
# "aws_iam_user" -> Resource Type (aws=provider, iam_user=resource)
# "admin_user" -> Resource Name
# "name" -> Mandatory Argument (Check TF docs)
# "tags" -> Optional in the form of a 'key-value' map

# main.tf

# provider block
provider "aws" {
  region = "us-west-2"
}

# iam block
resource "aws_iam_user" "admin_user" {
  name = "lucy"
  tags = {
    Description = "Technical Team Leader"
  }
}

# Pass credentials to Terraform, by configuring the AWS CLI on the client where TF is installed
# .aws/credentials
# Use "aws configure" command
# [default]
# aws_access_key_id = AKAI44QH8DHBEXAMPLE
# aws_secret_access_key = je7MtGbClwBF/2tk/h3yCo8...

# Alternatively, pass credentials in the form of environment variables
# Set the region with command line parameter, which allows to remove the "provider" block completely!
# export AWS_ACCESS_KEY_ID=AKAI44QH8DHBEXAMPLE
# export AWS_SECRET_ACCESS_KEY_ID=je7MtGbClwBF/2tk/h3yCo8...
# export AWS_REGION=us-west-2

// 14. IAM Policies with Terraform

# Create IAM policies and attach to users
# All users start with the least privilege in AWS
# To add permissions, attach IAM policies to a user
# Permissions are assigned by the means of a policy 
# document which is in JSON format

# main.tf
resource "aws_iam_user" "admin-user" {
  name = "lucy"
  tags = {
    Description = "Technical Team Leader"
  }
}

resource "aws_iam_policy" "adminUser" {
  name = "AdminUsers"

  # admin-policy.json
  policy = <<EOF
  {
    "Version": "2012-10-17"
    "Statement": [
      {
        "Effect": "Allow"
        "Action": "*"
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_user_policy_attachment" "lucy-admin-access" {
  user = aws_iam_user.admin-user.name
  policy_arn = aws_iam_policy.adminUser.arn
}

# Alternatively, use the following:

# main.tf
resource "aws_iam_user" "admin-user" {
  name = "lucy"
  tags = {
    Description = "Technical Team Leader"
  }
}

resource "aws_iam_policy" "adminUser" {
  name = "AdminUsers"

  # Store "admin-policy.json", in the configuration directory
  # The "file()" function, reads a file and returns its content
  policy = file("admin-policy.json")
}

resource "aws_iam_user_policy_attachment" "lucy-admin-access" {
  user = aws_iam_user.admin-user.name
  policy_arn = aws_iam_policy.adminUser.arn
}

# admin-policy.json
{
  "Version": "2012-10-17"
  "Statement": [
    {
      "Effect": "Allow"
      "Action": "*"
      "Resource": "*"
    }
  ]
}

// 15. Introduction to AWS S3

# Data in AWS is stored in the form of a bucket (S3)
# A bucket can be considered to be a container or directory which stores files
# Everything within a bucket is an object
# Any object in an S3 bucket consists of "Object Data" and "Metadata"
# When a bucket is created and objects are uploaded to it, by default
# AWS provides it the least amount of permissions, meaning no one can
# access the objects in the bucket with the exception of the "bucket owner"
# Access to the bucket and its objects are governed by bucket polices and ACLs
# Bucket policies are permissions granted at a bucket level
# Access Control Lists (ACLs), are more fine-grained access used to define permissions
# at an object level. Just like IAM policies, bucket policies are JSON documents
# and when attached to a bucket, they can either grant or remove access at bucket level!

# https://<bucket_name>.<region>.amazonaws.com (DNS unique name)
# https://all-pets.us-west-1.amazonaws.com (example of bucket called "all-pets")

/*
Object #  Name                  Address
----------------------------------------------------------------------------------
1         pets.json             https://all-pets.us-west-1.amazonaws.com/pets.json
2         dog.jpg               https://all-pets.us-west-1.amazonaws.com/dog.jpg
3         cat.mp4               https://all-pets.us-west-1.amazonaws.com/cat.mp4
4         pictures/cat.jpg      https://all-pets.us-west-1.amazonaws.com/pictures/cat.jpg
5         videos/dog.mp4        https://all-pets.us-west-1.amazonaws.com/videos/dog.mp4
*/

# Bucket Policy (example)
# read-objects.json
{
  "Version": "2012-10-17"
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::all-pets/*",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456123457:user/Lucy"
        ]
      }
    }
  ]
}

// 16. S3 with Terraform

# main.tf
resource "aws_s3_bucket" "finance" {
  bucket = "finance-21092020"
  tags = {
    Description = "Finance and Payroll"
  }
}

resource "aws_s3_bucket_object" "finance-2020" {
  content = "/root/finance/finance-2020.doc"
  key = "finance-2020.doc"
  bucket = aws_s3_bucket.finance.id
}

data "aws_iam_group" "finance-data" {
  group_name = "finance-analysts"
}

resource "aws_s3_bucket_policy" "finance-policy" {
  bucket = aws_s3_bucket.finance.id
  policy = <<EOF
  {
    "Version": "2012-10-17"
    "Statement": [
      {
        "Action": "*",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.finance.id}/*",
        "Principal": {
          "AWS": [
            "${data.aws_iam_group.finance-data.arn}"
          ]
        }
      }
    ]
  }
  EOF
}

// 17. Hands-On DevOps with Vagrant

# main.tf
resource "aws_dynamodb_table" "cars" {
  name = "cars"
  hash_key = "VIN" # Primary Key
  billing_mode = "PAY_PER_REQUEST" # Controls how you are charged for read and write throughput and how you manage capacity
  attribute { # Used to store attributes of the table (i.e. model name, type, manufacturer)
    name = "VIN"
    type = "S" # "S" -> String, "N" -> Number
  }
}

# Insert items into table "cars"
resource "aws_dynamodb_table_item" "car-items" {
  table_name = aws_dynamo_table.cars.name
  hash_key = aws_dynamodb_table.cars.hash_key
  item = <<EOF
  {
    "Manufacturer": {"S": "Toyota"},
    "Make": {"S": "Corolla"},
    "Year": {"N": "2004"},
    "VIN": {"S": "461SL65848Z411439"},
  }
EOF
}

// 18. Remote Backends with S3

# An "S3" bucket will be used to store the remote Terraform state file
# and a DynamoDB table which will be used to implement state locking
# Backend reinitialization required!
# "terraform init", command will initialize the new backend!
# If a local state file exists in the configuration directory,
# the init process provides an option to copy the terraform state file,
# into the remote "S3" backend. Now, it's possible to delete the local state file
# from the configuration directory -> "rm -rf terraform.tfstate"

# main.tf (infrastructure configuration)
resource "local_file" "pet" {
  filename = "/root/pets.txt"
  content = "We love pets!"
}

# terraform.tf (backend configuration)
terraform {
  backend "s3" { # Type of the backend to use (i.e. "S3")
    bucket = "kodekloud-terraform-state-bucket01" # Name of the existing "S3" bucket
    key = "finance/terraform.tfstate" # "S3" object path, where the remote state file should be stored
    region = "us-west-1" # Region where "S3" bucket has been created
    dynamodb_table = "state-locking" # Optionally, provide a DynamoDB table (i.e. "state-locking")
  }
}

// 19. Terraform State Commands

# Syntax: terraform state <subcommand> [options] [args]
# terraform state show aws_s3_bucket.finance

/*
Sub-command
-----------
list
mv
pull
rm
show
*/

# terraform state list [options] [address]
# Will list all resources recorded within the terraform state file
# Will only print the resource address, but no other details about the resource
# "aws_dynamodb_table.cars" -> Resource address
# "aws_s3_bucket.finance-2020922" -> Resource address
terraform state list ->
"aws_dynamodb_table.cars"
"aws_s3_bucket.finance-2020922"

# Pass an additional argument to the "list" command for a matching resource address
terraform state list aws_s3_bucket.finance-2020922 -> "aws_s3_bucket.finance-2020922"

# terraform state show [options] [address]
# Get detailed information about a resource from the state file
# Will show teh attributes of a single resource in the state file
# that matches the given address
terraform state show aws_s3_bucket.finance-2020922

# terraform state move [options] SOURCE DESTINATION
# Used to move items in a Terraform state file
# The items can be moved within the same state file,
# meaning moving a resource from its current resource address to another
# which essentially means renaming a resource
# Or, it moves items from one state file to another state file,
# maintained by a different configuration completely
# Rename "state-locking" to "state-locking-db"
# Manually, rename the resource name in the configuration file (i.e. "main.tf")
# Change: "state-locking" -> "state-locking-db"
terraform state mv aws_dynamodb_table.state-locking aws_dynamodb_table.state-locking-db ->

# main.tf
resource "aws_dynamodb_table" "state-locking" {
  name = "state-locking-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# terraform.tfstate (snippet)
"resources": [
  {
    "mode": "managed",
    "type": "aws_dynamodb_table",
    "name": "state-locking-db" # Changed from "state-locking"
    "provider":
"provider[\"registry.terraform.io/hashicorp/aws\"
]",
...

# terraform state pull [options] SOURCE DESTINATION
# Download and display the remote state on screen
# The output of this command, can be passed to JSON query tools like "jq"
# to filter the required data

# Example: Filter the hash_key used by dynamodb table called "state-locking-db" -> "LockID"
terraform state pull | jq '.resources[] | select(.name == "state-locking-db") | .instances[].attributes.hash_key'

# terraform state rm ADDRESS
# Delete items from the Terraform state file
# Used when you no longer wish to manage one or more resources via the current Terraform configuration and state
# Once the resource is removed from the state file, remove the associated resource block from the configuration file as well!
# A resource removed from a state file, is not actually destroyed from the real world infrastructure, but only removed from TF management!
# "aws_s3_bucket.finance-2020922" -> Resource address
terraform state rm aws_s3_bucket.finance-2020922

// 20. AWS EC2 with Terraform

# main.tf
resource "aws_instance" "webserver" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  tags = {
    Name = "webserver"
    Description = "An Nginx WebServer on Ubuntu"
  }
  # Run script when the webserver instance is launched
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
  key_name = aws_key_pair.web.id # Specify key
}
# Make use of an existing user supplied key pair, used to control login access to EC2 instance
resource "aws_key_pair" "web" {
  public_key = file("/root/.ssh/web.pub") # Read contents of an existing public key "web.pub", which is stored in the local machine
  vpc_security_group_ids = [aws_security_group.ssh-access.id] # Apply AWS Security Group within the resource block for the EC2 instance (specify the ID of the Security Group)
}

# Create AWS Security Group, to provide SSH access
resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  description = "Allow SSH access from the Internet"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output variable
# Get the Public IP address of the webserver instance (use to ssh)
output publicip {
  value = aws_instance.webserver.public_ip
}

# provider.tf
provider "aws" {
  region = "us-west-1"
}

# ssh into the webserver (with private key)
ssh -i /root/.ssh/web ubuntu@3.96.203.171

// 21. Terraform Provisioners

# Provisioners provide a way to carry out tasks (i.e. running commands or scripts on remote resources),
# or, locally on the machine where Terraform is installed

# Run a bash script, after a resource is created ("remote-exec" provisioner)
# Provisioner block is placed within a resource block. For the provisioner to work,
# there should be network connectivity between the local machine and remote instance

# By default, provisioners are run after resources are created (create time provisioner)
# It's possible to run a provisioner before a resource is destroyed (destroy time provisioner)
# Another default behavior of provisioners is that if the command or script, within the provisioner
# fails, the "terraform apply" operation also errors out. Any resource created while the provisioner fails,
# is marked as "tainted" within Terraform. For "terraform apply", operation to not fail and the resource,
# to be created successfully even if the provisioner command/script fails, set the value for "on_failure"
# to "continue"!

# "remote-exec" provisioner
# main.tf
resource "aws_instance" "webserver" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  # Provisioner
  provisioner "remote-exec" {
    inline = [ "sudo apt get update",
               "sudo apt install nginx -y",
               "sudo systemctl enable nginx",
               "sudo systemctl start nginx"
              ]
  }
  connection { # Authentication
    type = "ssh"
    host = self.public_ip # Public IP address for the instance (webserver). Effectively, translate into the public IP address of the provisioned instance
    user = "ubuntu"
    private_key = file("/root/.ssh/web")
  }
  key_name = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.ssh-access.id]
}

resource "aws_key_pair" "web" {
  # Code
}

resource "aws_security_group" "ssh-access" {
  # Code
}

# "local-exec" provisioner
# Used to run tasks on the local machine where TF is running, not on the resource created by TF
# main.tf
resource "aws_instance" "webserver" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.webserver.public_ip} >> /tmp/ips.txt"
  }
  
  provisioner "local-exec" {
    when = destroy # Provisioner should run before a resource is destroyed (destroy-time provisioner)
    command = "echo Instance ${aws_instance.webserver.public_ip} Destroyed! > /tmp/instance_state.txt"
  }
}

# Provisioner (Failure Behavior)

# main.tf
resource "aws_instance" "webserver" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    on_failure = fail # Set to "fail" (default behavior), or "continue" to discard the provisioner failure and provision the resource!  
    command = "echo Instance ${aws_instance.webserver.public_ip} Created! > /temp/instance_state.txt"
  }
  
  provisioner "local-exec" {
    when = destroy # Run provisioner before a resource is destroyed (destroy time provisioner)
    command = "echo Instance ${aws_instance.webserver.public_ip} Destroyed! > /tmp/instance_state.txt"
  }
}

// 22. Considerations with Provisioners

# Only use provisioners that are native to the resource (i.e. "user_data" for AWS EC2)

# main.tf
resource "aws_instance" "webserver" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  tags = {
    Name = "webserver"
    Description = "An NGINX WebServer on Ubuntu"
  }
  user_data = <<-EOF # Native argument to the EC2 resource!
            #!/bin/bash
            sudo apt update -y
            sudo apt-get install nginx -y
            sudo systemctl enable nginx
            sudo systemctl start nginx
            EOF
#  provisioner "remote-exec" {
#    inline = ["echo $(hostname -i) >> /tmp/ips.txt"]
  }
}

// 23. Terraform Taint

# main.tf
resource "aws_instance" "webserver-3" {
  ami = "ami-0edab43b6fa892279"
  instance_type "t2.micro"
  key_name = "ws"
  provisioner "local-exec" {
    command ="echo ${aws_instance.webserver-3.public_ip} > /temp/pub_ip.txt" # Invalid path!
  }
}

# Taint a resource
# When a resource creation fails for any reason, TF marks the resource as tainted
# As a result, TF will attempt to recreate it during the subsequent "terraform apply"
# The resource EC2 instance was successfully provisioned
terraform taint aws_instance.webserver

# Untaint a resource (undo a taint)
# The resource won't be recreated during a subsequent Terraform apply
terraform untaint aws_instance.webserver

// 24. Debugging

# Log Levels
# Use an environment variable called "TF_LOG" and set its value to one of the log levels (i.e. TRACE)
# Syntax: export TF_LOG=<log_level>
export TF_LOG=TRACE

/*
Log Levels
----------
INFO
WARNING
ERROR
DEBUG
TRACE (verbose logging level)
*/

# Use an environment variable called "TF_LOG_PATH" to store logs persistently in a file
# Export logs to a specific path
export TF_LOG_PATH=/tmp/terraform.log

# Disable logging
unset TF_LOG_PATH

// 25. Terraform Import

# Resources may be provisioned outside of Terraform (i.e. Ansible, AWS Management Console)
# To bring resources created outside of Terraform, into its control 


# Write an empty Terraform resource block


# Data Source (Make use of the attributes of the data source)
# This resource itself is not managed by Terraform (data source)

#main .tf
data "aws_instance" "webserver" {
  instance_id = "i-026e13be10d5326f7"
}

output "newserver" {
  value = data.aws_instance.webserver.public_ip
}

# terraform import <resource_type>.<resource_name> <attribute>
# Resource attribute can uniquely identify the resource such as the ID
# "terraform import" does not update the configuration files at all
# It only updates the state file with the details of the infrastructure being imported
# The configuration for the resource being imported, has to be written manually!
# To address this issue and continue with the import, an empty resource block should be written
# Once the resource block is defined, re-run "terraform import, which should go through without errors!
# The resource is now imported into the Terraform state file. Next, define all resource arguments and their values!
# Finally, run "terraform plan" to refresh the state!
terraform import aws_instance.webserver i-026e13be10d5326f7

# main.tf
resource "aws_instance" "webserver-2" {
  # (resource arguments) -> Empty resource block
}

# main.tf (Update)
resource "aws_instance" "webserver-2" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  key_name = "ws"
  vpc_security_group_ids = ["sg-8064fdee"]
}

// 26. Terraform Modules

# Any configuration directory containing a set of configuration files is called a "module"

# Root Module
# main.tf
resource "aws_instance" "webserver" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key
}

# variables.tf
variable "ami" {
  type = string
  default = "ami-0edab43b6fa892279"
  description = "Ubuntu AMI ID in the ca-central-1 region"
}

# Create a configuration file containing a module block
# Provide the path to the "Root module" directory
# "dev-webserver" -> Logical name of the module
# "source" (required argument) -> Path where the child module is stored

# main.tf
module "dev-webserver" {
  source "../aws-instance"
}

// 27. Creating and Using a Module

# Path: /root/terraform-projects/modules/payroll-app (Initially Root module, then becomes child module)

# app_server.tf
resource "aws_instance" "app_server" {
  ami = var.ami
  instance_type = "t2.medium" # Should be a fixed value!
  tags = {
    Name = "${var.app_region}-app-server"
  }
  depends_on = [aws_dynamodb_table.payroll_db,
                aws_s3_bucket.payroll._data
              ]
}

# s3_bucket.tf 
resource "aws_s3_bucket" "payroll_data" {
  bucket = "${var.app_region}-${var.bucket}"
}

# dynamodb_table.tf
resource "aws_dynamodb_table" "payroll_db" {
  name = "user_data" # Should be a fixed value!
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "EmployeeID" # Primary Key -> Should be a fixed value! 

  attribute {
    name = "EmployeeID"
    type = "N"
  }
}

# variables.tf
variable "app_region" {
  type = string
}

variable "bucket" {
  default = "flexit-payroll-alpha-22001c"
}

variable "ami" {
  type = string
}

# Path: /root/terraform-projects/us-payroll-app (Becomes new Root module)
# main.tf
module "us_payroll" {
  source = "../modules/payroll-app"
  app_region = "us-east-1" # Deploy to "us-east-1" region
  ami = "ami-24e140119877avm" # Use custom AMI ID in that region
}

# Optionally, provide a specific value for the bucket argument
# If no value is specified though, it'll take the default value
# set at the module level (i.e. "flexit-payroll-alpha-22001c")

# Path: /root/terraform-projects/uk-payroll-app
# main.tf
module "uk_payroll" {
  source = "../modules/payroll-app"
  app_region = "eu-west-2"
  ami = "ami-35e140119877avm"
}

# provider.tf
provider "aws" {
  region = "eu-west-2"
}

// 28. Using Modules from the Registry

# Local Module
# main.tf
module "dev-webserver" {
  source = "../aws-instance"
  key = "webserver"
}

# To make use of registry modules, change the value of the "source" argument, as the module is no longer local!

# Create a security group that allows inbound SSH (ssh sub-module -> "security-group_ssh")
# To run the a registry module, use "terraform init"
# If the provider plugins have already been downloaded in the configuration directory, use "terraform get",
# which will only download the module from the registry
# Always specify the version of the module, as revisions are made over time
# To create the security group in this module run: "terraform plan && terraform apply"
# main.tf
module "security-group_ssh" {
  source = "terraform-aws-modules/security-group/aws/modules/ssh"
  version = "3.16.0"
  # Insert 2 required variables here...
  vpc_id = "vpc-7d8d215"
  ingress_cidr_blocks = ["10.10.0.0/16"] # List of IP address range, from which SSH is allowed
  name = "ssh-access"
}

// 29. More Terraform Functions

# main.tf
resource "aws_iam_policy" "adminUser" {
  name = "AdminUsers"
  policy = file("admin-policy.json") # Read data from file
}

resource "local_file" "pet" {
  filename = var.filename
  count = length(var.region) # Determine number of elements in list/map
}

# main.tf
resource "local_file" "pet" {
  filename = var.filename
  for_each = toset(var.region) # Convert a "list" into a "set"
}

variable "region" {
  type = list
  default = ["us-east-1",
             "us-esat-1",
             "ca-central-1"]
  description = "A list of AWS Regions"
}

# Terraform interactive console
# Test functions and interpolations
# The interactive console loads the state associated 
# with the configuration directory by default 
terraform console

>file("/root/terraform-projects/main.tf")
>length(var.region) # -> 3
>toset(var.region) # Convert list to set

# Numeric Functions
# variables.tf
variable "num" {
  type = set(number)
  default = [250, 10, 11, 5]
  description = "A set of numbers" 
}

terraform console

> max(-1, 2, -10, 200, -250) # -> 200
> min(-1, 2, -10, 200, -250) # -> -250

# Expand to separate arguments, using the "expansion symbol" -> ..."
> max(var.num...) # -> 250

# Grater than or equal to current argument
> ceil(10.1) # -> 11
> ceil(10.9) # -> 11

# Lesser than or equal to the argument provided
> floor(10.1) # -> 10
> floor(10.9) # -> 10

# String Functions
# variables.tf

# Transform a string to a list of elements using a separator
variable "ami" {
  type = string
  default = "ami-xyz,AMI-ABC,ami-efg"
  description = "A string containing ami ids"
}

terraform console

> split("," "ami-xyz,AMI-ABC,ami-efg") # -> ["ami-xyz","AMI-ABC","ami-efg"] -> List
> split(",", var.ami) # -> ["ami-xyz","AMI-ABC","ami-efg"]

> lower(var.ami) # -> ami-xyz,ami-abc,ami-efg
> upper(var.ami) # -> AMI-XYZ,AMI-ABC,AMI-EFG

# Convert the first letter of each word in a string
> title(var.ami) # -> Ami-Xyz,AMI-ABC,Ami-Efg

# Extract substring from a string with offset and length (can be "0", "8" or "16")
# "offset": Defines the index of the character after which the string should be cut
# "length": Defines the number of characters from the offset to cut and convert to a substring
> substr(var.ami, 0, 7) # -> ami-xyz
> substr(var.ami, 8, 7) # -> AMI-ABC
> substr(var.ami, 16, 7) # -> ami-efg

# Convert a list to string by adding all strings together
> join(",", var.ami) # -> ami-xyz,AMI-ABC,ami-efg (no commas)

# Collection Functions (set, list, map)

terraform console

length(var.ami) # -> 3

# Find index of matching element (2 arguments: list and value of element)
> index("var.ami", "AMI-ABC") # -> 1

# Find element in list located at a specific index
> element(var.ami, 2) # -> ami-efg

# Check if a specific element is present in list (returns true/false)
> contains(var.ami "AMI-ABC") # -> True
> contains(var.ami, "AMI-XYZ") # -> False

# Map Functions
# "ami": Map variable
variable "ami" {
  type = map
  default = {
    "us-east-1" = "ami-xyz",
    "ca-central-1" = "ami-efg",
    "ap-south-1" = "ami-ABC"  
  }
  description = "A map of AMI ID's for specific regions"
}

terraform console

# Convert map to list with just the keys
# Supply map variable as argument
> keys(var.ami) # ->

/*
[
  "ap-south-1",
  "ca-central-1",
  "us-east-1"
]
*/

# Convert map to list with just values
> values(var.ami) # ->

/*
[
  "ami-ABC",
  "ami-efg",
  "ami-xyz"
]
*/

# Look up the value of a specific key in a map
# Takes 2 arguments: map and the key for which to lookup the value
> lookup(var.ami, "ca-central-1") # -> ami-efg

# If the key provided to the function is not available in the map
# an error message will be displayed
> lookup(var.ami, "us-west-2") # -> Error

# Provide a 3rd argument, which is the default value to be returned
# if the provided key in the argument, does not exist in the map
> lookup(var.ami, "us-west-2", "ami-pqr") # -> ami-pqr

// 30. Conditional Expressions

terraform console

# Numeric Operators
> 1 + 2 # -> 3
> 5 - 3 # -> 2
> 2 * 2 # -> 4
> 8 / 2 # -> 4

# Equality Operators
> 8 == 8 # -> true
> 8 == 7 # -> false
> 8 != "8" # -> true

# Comparison Operators
> 5 > 7 # -> false
> 5 > 4 # -> true
> 5 > 5 # -> false
> 5 >=5 # -> true
> 4 < 5 # -> true
> 3 <= 4 # -> true

# Logical Operators
> 8 > 7 && 8 < 10 # -> true
> 8 > 10 && 8 < 10 # -> false
> 8 > 9 || 8 < 10 # -> true

> var.special # -> true
> !var.special # -> false
> !(var.b > 30) # -> true

> var.a > var.b # -> true
> var.a < var.b # -> false
> var.a + var.b # -> 75

# variables.tf
variable "special" {
  type = bool
  default = true
  description = "Set to true to use special characters"
}

variable "b" {
  type = number
  default = 25
}

variable "a" {
  type = number
  default = 50
}

variable "b" {
  type = number
  default = 25
}

# main.tf
# Generate password with at least 8 characters
# "var.length < 8" -> condition to check
# "true" -> "8"
# "false" -> var.length 
resource "random_password" "password-generator" {
  length = var.length < 8 ? 8 : var.length 
}

output password {
  value = random_password.password-generator.result
  description = "The length of the password"
}

# Apply resource
terraform apply -var=length=5 --auto-approve

# Generate password (Bash)
if (${length} -lt 8)
  then
    ${length}=8;
    echo ${length};
  else
    echo ${length};
fi

# Apply resource
terraform init && terraform plan && terraform apply -var=length=5 # -> password: 8 characters
terraform init && terraform plan && terraform apply -var=length=12 # -> password: 12 characters

// 31. Terraform Workspaces (OSS)

# With workspaces it's possible to use the same configuration directory 
# to create multiple infrastructure environments such as "ProjectA" and "ProjectB"

/*
Project Structure
-------------------
Path: /root/terraform-projects/project
variables.tf
main.tf
terraform.tfstate

ProjectA
--------
Region: ca-central-1
AMI: ami-0edab43b6fa892279
Instance Type: t2.micro

ProjectB
--------
Region: ca-central-1
AMI: ami-0c2f25c1f66a1ff4d
Instance Type: t2.micro
*/

# main.tf (Initial phase)
resource "aws_instance" "projectA" {
  ami = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  tags = {
    Name = "ProjectA"
  }
}

# Create workspace
# Once the workspace is created, Terraform switches immediately to it
terraform workspace new ProjectA

# List workspace
# A "*" before the workspace name, means it's the current workspace
terraform workspace list

# main.tf (Updated phase)
resource "aws_instance" "projectA" {
  ami = lookup(var.ami, terraform.workspace)
  instance_type = var.instance_type
  tags = {
    Name = terraform.workspace # Name of current workspace
  }
}

# variables.tf (Updated phase)
variable "region" {
  default = "ca-central-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  type = map
  default = {
    "ProjectA" = "ami-0edab43b6fa892279"
    "ProjectA" = "ami-0c2f25c1f66a1ff4d"
  }
}

# Get current workspace
terraform console

> terraform.workspace # -> "ProjectA"

> lookup(var.ami, terraform.workspace) # -> Get AMI argument (ami-0edab43b6fa892279)

# Create aws instance in ProjectA
terraform plan && terraform apply

# Create aws instance in ProjectB
terraform workspace new ProjectB

terraform plan && terraform apply

# Switch between workspaces
terraform workspace select projectA

# "terraform apply" creates 2 different state files (for each workspace)
# When using workspaces instead of using the default "terraform.tfstate" file,
# in the configuration directory, Terraform stores the state file in a separate
# directory called "terraform.tfstate.d". Inside this directory, we can see another
# directory by the name of each workspace, for which we have at least completed 1
# "terraform apply". Within this directory there would be a "terraform.tfstate" file
# associated with the resources created for that particular workspace
tree terraform.tfstate.d

/*
terraform.tfstate.d # -> Directory Structure
-------------------

terraform.tfstate.d/
|-- ProjectA
|   `-- terraform.tfstate
`-- ProjectB
    `-- terraform.tfstate
    
2 directories, 2 files
*/