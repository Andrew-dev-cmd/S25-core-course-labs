resource "yandex_vpc_network" "lab04" {
  name = "lab04-network"
}

resource "yandex_vpc_subnet" "lab04" {
  name           = "lab04-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.lab04.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "lab04-vm"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.lab04.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}
