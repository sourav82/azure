variable "subscription_id" {
  description = "ID of the subscription"
  default = ""
}

variable "tenant_id" {
  description = "Id of the tenant id"
  default = ""
}

variable "client_id" {
  description = "Id of the client id"
  default = ""
}

variable "client_secret" {
  description = "Id of the client"
  default = ""
}

variable "hub_vnet_name" {
  description = "Name of the vnet to create"
  default     = "hubvnet"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "test"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "uksouth"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["subnet1", "subnet2", "subnet3"]
}

variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = "map"

  default = {
    subnet1 = "nsgid1"
    subnet3 = "nsgid3"
  }
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}

variable "username" {
	description = "Default user name to vm"
        default = "ubuntu"
}

variable "password" {
	description = "Default password for vm"
	default = "Passw0rd123456789#"
}
variable "vmsize" {
	description = "Default vm size"
	default = ""
}