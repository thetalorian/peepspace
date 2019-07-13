variable "cluster-name" {
  description = "AWS Tag used to identify EKS components"
  type = "string"
}

variable "wsip" {
  description = "IP Address of an external workstation to allow access"
  type = "string"
}

variable "subnetcount" {
  description = "Number of desired subnets"
  type = "string"
}