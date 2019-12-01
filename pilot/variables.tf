variable "hub_rg_name" {
  description = "Defaulr name for hub resource group"
  default = "RES-NR-CORE"
}
variable "spoke_rg_name"{
  description = "Default name for spoke resource group"
  default = "RES-IIDST-DEMO"
}
variable "location" {
  description = "Default region in Azure"
  default = "UK South"
}
variable "hub_vnet_name" {
  description = "Default name for hub vnet"
  default = "VNET-CORE"
}
variable "spoke_track_vnet_name" {
  description = "Default name for spoke vnet for track"
  default = "VNET-DEMO-TRAK"
}
variable "core_vnet_address_space" {
  description = "Default address space for core hub vnet"
  default = ["10.180.0.0/16"]
}
variable "track_vnet_address_space" {
  description = "Default address space for track vnet"
  default = ["10.181.0.0/16"]
}
variable "track_vm_nic_name" {
  description = "Default name for track vm nic"
  default = "tracknic001"
}
variable "track_vm_name" {
  description = "Virtual machine name for track"
  default = "AZ01DST001"
}
variable "track_vm_size" {
  description = "Size of VM"
  default = "Standard_DS1_v2"
}
