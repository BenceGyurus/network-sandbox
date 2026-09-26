terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.60.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_host
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}



resource "proxmox_virtual_environment_vm" "frr_vm" {
  node_name = "proxmox"
  name      = "frr-vm"
  vm_id     = 200
  started   = true

  clone {
    vm_id     = 9001
    node_name = "proxmox"
    full      = true
  }

  disk {
    datastore_id = "TB1"
    interface    = "scsi0"
    size         = 20 
  }

  agent{
    enabled = true
  }

  description = "FRR vm to test networking things"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }


  network_device {
    bridge = "vmbr0"
    model  = "virtio"
    vlan_id = 100
  }

  initialization {
  user_account {
    username = var.vm_username
    password = var.vm_password
    keys     = [file(pathexpand("~/.ssh/id_ed25519.pub"))]
  }

  ip_config {
    ipv4 {
      address = "192.168.100.50/24"
      gateway = "192.168.100.1"
    }
  }
}
}

resource "null_resource" "docker_setup_and_run" {
  depends_on = [proxmox_virtual_environment_vm.frr_vm]

  connection {
    type        = "ssh"
    host        = "192.168.100.50"
    user        = "bence"
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
    timeout     = "2m"
  }

  provisioner "remote-exec" {
  inline = [
    "mkdir -p /home/bence/frr/r1",
    "mkdir -p /home/bence/frr/r2",
    "mkdir -p /home/bence/frr/r3",
    "mkdir -p /home/bence/frr/r4",
    "mkdir -p /home/bence/frr/r5",
    "mkdir -p /home/bence/frr/r6",
  ]
  }


  provisioner "file" {
    source      = "${path.module}/../../scripts/docker.sh"
    destination = "/home/bence/install-docker.sh"
  }

  provisioner "file" {
    source      = "${path.module}/../../docker/docker-compose.yml"
    destination = "/home/bence/frr/docker-compose.yml"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/daemons"
    destination = "/home/bence/frr/daemons"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/frr1.conf"
    destination = "/home/bence/frr/r1/frr.conf"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/frr2.conf"
    destination = "/home/bence/frr/r2/frr.conf"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/frr3.conf"
    destination = "/home/bence/frr/r3/frr.conf"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/frr4.conf"
    destination = "/home/bence/frr/r4/frr.conf"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/frr5.conf"
    destination = "/home/bence/frr/r5/frr.conf"
  }

  provisioner "file" {
    source      = "${path.module}/../../configuration/frr6.conf"
    destination = "/home/bence/frr/r6/frr.conf"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo chmod +x /home/bence/install-docker.sh",
    "sudo bash /home/bence/install-docker.sh",
    "cd /home/bence/frr && sudo docker compose up -d"
  ]
  }
}
