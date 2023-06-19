# Providers utiliser pour Proxmox => Telmate
# Déclaration du fournisseur Proxmox utilisé et sa version

terraform {
    required_providers {
        proxmox =  {
        source = "Telmate/proxmox"
        version = "2.9.14"
        }
    }
}

# Informations de connexion Provider utiliser pour la connexion au proxmox
# Configuration des paramètres de connexion au serveur Proxmox

provider "proxmox" {
    pm_api_url = "https://192.168.1.35:8006/api2/json"
    pm_api_token_id= "tristan@pve!token"
    pm_api_token_secret= "bc75b797-e757-4e7d-abf7-dc1108ac36c7"
    #pm_tls_insecure = true  //for Proxmox self-signed certificate WUI
}

# Déclaration des noms des machines virtuelles
# Variable contenant une liste de noms de machines virtuelles

variable "vm_names" {
  type    = list(string)
  default = ["robot1", "robot2", "robot3"]
}

# clonage et déploiement des machines virtuelles
# Ressource pour cloner et déployer les machines virtuelles

resource "proxmox_vm_qemu" "vms" {
  count = length(var.vm_names)  # Crée une instance de la ressource pour chaque élément de la liste vm_names

  name        = var.vm_names[count.index]  # Nom de la machine virtuelle
  target_node = "srv1-home"                 # Node cible pour le déploiement

  clone       = "sauv2"                     # Nom du clone à créer

  # Autres paramètres de configuration de la VM...

  disk {
    size    = "20G"                          # Taille du disque de la VM
    type    = "scsi"                         # Type de disque
    storage = "local-lvm"                    # Stockage Proxmox à utiliser (remplacez par le nom approprié)
  }

  memory = "8192"                            # Quantité de mémoire RAM allouée à la VM
  cores  = 2                                 # Nombre de cœurs de processeur à allouer

  network {
    model  = "virtio"                         # Modèle de carte réseau virtuelle
    bridge = "vmbr0"                          # Bridge réseau Proxmox à utiliser
    #dhcp   = true                            # Utiliser DHCP pour l'adresse IP de la VM
  }

  connection {
    type        = "ssh"                        # Type de connexion SSH
    user        = "root"                       # Nom d'utilisateur SSH
    host        = "null"                       # Adresse IP de la VM (à remplacer par l'adresse IP réelle)
    private_key = file("C:/Users/trist/.ssh/id_rsa")  # Chemin vers la clé privée SSH
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y git-all",              # Installer git
      "sudo apt update && apt upgrade",                # Mettre à jour le système
      "sudo mkdir -p /repos/my_repo.git",              # Créer un répertoire de dépôt
      "cd repos/my_repo.git",                          # Se déplacer dans le répertoire de dépôt
      "sudo git init --bare"                           # Initialiser un dépôt Git vide
    ]
