variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}


variable "proxmox_host" {
  description = "Proxmox host URL"
  type        = string
}


variable "vm_username" {
  description = "VM username"
  type        = string
}


variable "vm_password" {
  description = "VM password"
  type        = string
  sensitive   = true
}

variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
}