#Providers
provider "vsphere" {
  vsphere_server       = "vcsa-fqdn"
  user                 = "domain\\username"
  password             = "password!"
  allow_unverified_ssl = false
}
#Tag categories
resource "vsphere_tag_category" "costcentre" {
  name        = "costcentre"
  description = "Managed by Terraform"
  cardinality = "MULTIPLE"
  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}
resource "vsphere_tag_category" "environment" {
  name        = "environment"
  description = "Managed by Terraform"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}
resource "vsphere_tag_category" "nsx-tier" {
  name        = "nsx-tier"
  description = "Managed by Terraform"
  cardinality = "MULTIPLE"
  associable_types = [
    "VirtualMachine"
  ]
}
# #Tags
#Local values
locals {
  costcentre_tags  = ["0001", "0002", "0003", "0004"]
  environment_tags = ["production", "pre-production", "test", "development"]
  nsx_tier_tags    = ["web", "app", "data"]
}
#Resources
resource "vsphere_tag" "costcentre-tags" {
  for_each    = toset(local.costcentre_tags)
  name        = each.key
  category_id = vsphere_tag_category.costcentre.id
  description = "Managed by Terraform"
}
resource "vsphere_tag" "environment-tags" {
  for_each    = toset(local.environment_tags)
  name        = each.key
  category_id = vsphere_tag_category.environment.id
  description = "Managed by Terraform"
}
resource "vsphere_tag" "nsx-tier-tags" {
  for_each    = toset(local.nsx_tier_tags)
  name        = each.key
  category_id = vsphere_tag_category.nsx-tier.id
  description = "Managed by Terraform"
}
