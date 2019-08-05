resource "google_compute_network" "kubernetes_the_hard_way" {
  name                    = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
  project                 = "${jsondecode(file("account.json"))["project_id"]}"
}

resource "google_compute_subnetwork" "kubernetes" {
  name          = "kubernetes"
  network       = "${google_compute_network.kubernetes_the_hard_way.name}"
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_address" "kubernetes_the_hard_way" {
  name   = "kubernetes-the-hard-way"
  region = "${var.region}"
}

resource "google_compute_firewall" "kubernetes_the_hard_way_internal" {
  name          = "kubernetes-the-hard-way-allow-internal"
  network       = "${google_compute_network.kubernetes_the_hard_way.name}"
  source_ranges = ["10.200.0.0/16", "10.240.0.0/24"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

resource "google_compute_firewall" "kubernetes_the_hard_way_external" {
  name          = "kubernetes-the-hard-way-allow-external"
  network       = "${google_compute_network.kubernetes_the_hard_way.name}"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = [22, 6443]
  }
}

resource "google_compute_firewall" "kubernetes_the_hard_way_health_check" {
  name          = "kubernetes-the-hard-way-allow-health-check"
  network       = "${google_compute_network.kubernetes_the_hard_way.name}"
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
}

resource "google_compute_http_health_check" "kubernetes" {
  name         = "kubernetes"
  description  = "Kubernetes Health Check"
  request_path = "/healthz"
  host         = "kubernetes.default.svc.cluster.local"
}

resource "google_compute_target_pool" "kubernetes_target_pool" {
  name = "kubernetes-target-pool"

  instances = ["${var.zone}/${google_compute_instance.controller[0].name}",
    "${var.zone}/${google_compute_instance.controller[1].name}",
  "${var.zone}/${google_compute_instance.controller[2].name}"]

  health_checks = [
    "${google_compute_http_health_check.kubernetes.name}",
  ]
}

resource "google_compute_forwarding_rule" "kubernetes_forwarding_rule" {
  name       = "kubernetes-forwarding-rule"
  ip_address = "${google_compute_address.kubernetes_the_hard_way.address}"
  port_range = "6443-6443"
  ports      = []
  region     = "${var.region}"
  target     = "${google_compute_target_pool.kubernetes_target_pool.self_link}"
}

resource "google_compute_route" "kubernetes_route" {
  count       = 3
  name        = "kubernetes-route-10-200-${count.index}-0-24"
  network     = "${google_compute_network.kubernetes_the_hard_way.name}"
  next_hop_ip = "${google_compute_instance.worker[count.index].network_interface.0.network_ip}"
  dest_range  = "${google_compute_instance.worker[count.index].metadata.pod-cidr}"
}
