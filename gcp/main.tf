resource "google_compute_instance" "controller" {
  count = 3
  name  = "controller-${count.index}"
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-1804-lts"
      size  = 100
      type  = "pd-standard"
    }
  }
  can_ip_forward = true
  machine_type   = "n1-standard-1"
  network_interface {
    subnetwork = "${google_compute_subnetwork.kubernetes.name}"
    network_ip = "10.240.0.1${count.index}"
    access_config {
      network_tier = "STANDARD"
    }
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
  tags = ["controller", "kubernetes-the-hard-way"]
  zone = "${var.zone}"
}

resource "google_compute_instance" "worker" {
  count = 3
  name  = "worker-${count.index}"
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-1804-lts"
      size  = 100
      type  = "pd-standard"
    }
  }

  can_ip_forward = true
  machine_type   = "n1-standard-1"
  network_interface {
    subnetwork = "${google_compute_subnetwork.kubernetes.name}"
    network_ip = "10.240.0.2${count.index}"
    access_config {
      network_tier = "STANDARD"
    }
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
  tags = ["worker", "kubernetes-the-hard-way"]
  zone = "${var.zone}"
  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }
}
