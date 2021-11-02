variable "subscription_id" {
  type        = string
  description = "This is my subscription id in Azure"
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "environment" {
  type    = string
  default = "public"
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "pull_secret" {
  type = string
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/22"
}

variable "apiserver_visibility" {
  type    = string
  default = "Public"
}

variable "ingress_visibility" {
  type    = string
  default = "Public"
}

variable "pod_cidr" {
  type    = string
  default = "10.128.0.0/14"
}

variable "service_cidr" {
  type    = string
  default = "172.30.0.0/16"

}


variable "master_vm_size" {
  type    = string
  default = "Standard_D8s_v3"
}

variable "worker_vm_size" {
  type    = string
  default = "Standard_D8s_v3"
}

variable "worker_count" {
  type    = number
  default = 3
}

variable "worker_vm_disk_size_gb" {
  type    = string
  default = 128
}

variable "aro_client_id" {
  type    = string
  default = ""
}

variable "aro_client_secret" {
  type    = string
  default = ""
}

variable "domain" {
  type    = string
  default = ""
}
