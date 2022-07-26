variable "commit_hash" {}

variable "environment" {
  default = ""
}

variable "terraform_poc_ami" {
  default = ""
}

variable "subnet" {
  default = ""
}

variable "target" {
  default = ""
}

variable "application" {
  default = "terraform-poc"
}
