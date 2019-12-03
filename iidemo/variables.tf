variable "hub_rg_name" {
  description = "Defaulr name for hub resource group"
  default = "RES-NR-CORE"
}
variable "spoke_rg_name"{
  description = "Default name for spoke resource group"
  default = "RES-II-DEMO"
}
variable "location" {
  description = "Default region in Azure"
  default = "UK South"
}
variable "ads-datamart-db-name" {
  description = "Default database ad mart name"
  default = "ADS_Data_Mart"
}
variable "ads-foundation-db-name" {
  description = "Default name for foundation databse"
  default = "ADS_Foundation"
}
