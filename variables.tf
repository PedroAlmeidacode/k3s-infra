# --- root/variables.tf ---
variable "aws_region" {
  default = "eu-west-3"
}

variable "access_ip" {
  type = string
}


# -- database ---

variable "dbname" {
  type = string
}

variable "dbpassword" {
  type      = string
  sensitive = true
}

variable "dbuser" {
  type      = string
  sensitive = true
}