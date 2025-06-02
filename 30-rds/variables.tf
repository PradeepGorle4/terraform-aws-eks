variable "common_tags" {
    default = {
        project = "expense"
        environment = "dev"
        terraform =  true
    }
}

variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "zone_id" {
  default = "Z06129073VKNR32VJP87F"
}

variable "domain_name" {
    default = "pradeepdevops.online"
}