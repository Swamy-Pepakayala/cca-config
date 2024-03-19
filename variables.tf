#generic vars

variable "location" {
  description = "Location for Cloud Run Service"
  type = string
}

variable "region" {}

variable "project_id" {}


#cloudrun vars
variable "service" {
    description = "Cloud run service name"
    type = string 
}

variable "port" {
  description = "Container Port"
  type = number
}

variable "image"{
  description = "Container image"
  type = string
}
/*
#pubsub vars
variable "sub_names" {
  description = "Name of subscription"
  type = list(string)
}

variable "topic_name" {
  description = "Name of topic"
  type = string
}
*/

##storage vars

variable "storage_class" {
  description = "Bucket storage class."
  type        = string
  default     = "MULTI_REGIONAL"
}

variable "names" {
  description = "Bucket name main suffixes."
  type        = list(string)
  default     = []
}

variable "folders" {
  description = "Map of lowercase unprefixed name => list of top level folder objects."
  type        = map
  default     = {}
}

variable "lifecycle_age" {
  description = "Set lifecycle of objects in buckets."
  type = object({
    delete_age = number
  })
  default = {
    delete_age = 30
  }
}

variable "storage_iam_members" {
  description = "IAM members for each storage."
  type        = map(map(list(string)))
  default     = {}
}

variable "storage_iam_roles" {
  description = "IAM roles for each storage."
  type        = map(list(string))
  default     = {}
}

#svc account variables
variable "sa" {
  type =string
}

variable "sa_dispname" {
  type = string
}

variable "sa_email" {
  type = string
  default = "none"
}

variable "runtime" { 
  type =string
}

