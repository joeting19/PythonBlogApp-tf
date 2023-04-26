variable "region" {
  type = string
}

variable "resourcegroup" {
  type = string
}

variable "vnetcidr" {
  type = string
}

variable "subncidrs" {
  type = list(any)
}

variable "environment" {
  type = string
}

