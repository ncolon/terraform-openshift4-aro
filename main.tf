provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  environment     = var.environment
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  prefix = "${var.cluster_name}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.region
}

resource "azurerm_virtual_network" "network" {
  name                = "${local.prefix}-vnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "masters" {
  name                 = "${local.prefix}-master-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 1, 0)]
  service_endpoints = [
    "Microsoft.ContainerRegistry"
  ]
  enforce_private_link_service_network_policies = true
}

resource "azurerm_subnet" "workers" {
  name                 = "${local.prefix}-worker-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 1, 1)]
  service_endpoints = [
    "Microsoft.ContainerRegistry"
  ]
}


resource "null_resource" "deploy_aro" {
  provisioner "local-exec" {
    command = <<EOF
az aro create \
  --resource-group ${azurerm_resource_group.rg.name} \
  --name ${local.prefix} \
  --vnet ${azurerm_virtual_network.network.name} \
  --master-subnet ${azurerm_subnet.masters.name} \
  --worker-subnet ${azurerm_subnet.workers.name} \
  --pull-secret @${var.pull_secret} \
  --apiserver-visibility ${var.apiserver_visibility} \
  --ingress-visibility ${var.ingress_visibility} \
  --pod-cidr ${var.pod_cidr} \
  --service-cidr ${var.service_cidr} \
  --master-vm-size ${var.master_vm_size} \
  --worker-vm-size ${var.worker_vm_size} \
  --worker-count ${var.worker_count} \
  --worker-vm-disk-size-gb ${var.worker_vm_disk_size_gb} \
  --client-id ${var.aro_client_id == "" ? var.client_id : var.aro_client_id} \
  --client-secret ${var.aro_client_secret == "" ? var.client_secret : var.aro_client_secret} %{if var.domain != ""} --domain ${var.domain}%{endif}
EOF
  }
}


resource "null_resource" "destroy_aro" {
  triggers = {
    resource_group_name = azurerm_resource_group.rg.name
    cluster_name        = local.prefix
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
if az aro list --resource-group ${self.triggers.resource_group_name} | grep ${self.triggers.cluster_name}; then
  az aro delete -y \
    --resource-group ${self.triggers.resource_group_name} \
    --name ${self.triggers.cluster_name}
fi
EOF
  }
}
