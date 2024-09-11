#----------------------
# 共通
#----------------------

variable "project" {
  description = "The name of this project"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "image-key-pair" {
  description = "Key Pair for Image"
  type        = string
}