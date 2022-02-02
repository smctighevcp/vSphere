provider "vsphere" {
  vsphere_server = "vm-vcsa-01.smt-lab.local"
  user           = "smt-lab.local\\stephan"
  password       = "VMware123!"
}
data "vsphere_datacenter" "datacenter" {
  name = "dc-smt-01"
}
data "vsphere_distributed_virtual_switch" "vds" {
  name          = "vDS-Workload-Networks"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
resource "vsphere_distributed_port_group" "pg20" {
  name                            = "dvPG-Guest-VM-1"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vds.id
  number_of_ports                 = 8
  vlan_id                         = 20
}
resource "vsphere_distributed_port_group" "pg21" {
  name                            = "dvPG-Guest-VM-2"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vds.id
  number_of_ports                 = 8
  vlan_id                         = 21
}
resource "vsphere_distributed_port_group" "pg25" {
  name                            = "dvPG-Secure-VM-1"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vds.id
  number_of_ports                 = 8
  vlan_id                         = 25
}
