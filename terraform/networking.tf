resource "google_compute_network" "main" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "public_honeypot" {
  name          = var.public_honeypot_subnet_name
  ip_cidr_range = var.public_honeypot_subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
}

resource "google_compute_subnetwork" "tools" {
  name          = var.tools_subnet_name
  ip_cidr_range = var.tools_subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id

  private_ip_google_access = true
}

resource "google_compute_firewall" "cowrie_ssh_public" {
  name      = "${var.vpc_name}-cowrie-ssh-22"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = var.cowrie_allowed_ssh_source_ranges
  target_tags   = var.cowrie_target_tags

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "internal_allow" {
  name      = "${var.vpc_name}-internal-allow"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    var.public_honeypot_subnet_cidr,
    var.tools_subnet_cidr,
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "admin_ssh_restricted" {
  count = length(var.admin_ssh_allowed_source_ranges) > 0 ? 1 : 0

  name      = "${var.vpc_name}-admin-ssh-2022"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 900

  source_ranges = var.admin_ssh_allowed_source_ranges
  target_tags   = var.cowrie_admin_target_tags

  allow {
    protocol = "tcp"
    ports    = ["2022"]
  }
}

resource "google_compute_firewall" "grafana_https_restricted" {
  count = length(var.admin_ssh_allowed_source_ranges) > 0 ? 1 : 0

  name      = "${var.vpc_name}-grafana-https-443"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 950

  source_ranges = var.admin_ssh_allowed_source_ranges
  target_tags   = var.logging_vm_target_tags

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "logging_ingest_from_honeypot" {
  name      = "${var.vpc_name}-logging-ingest-3100"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 960

  source_ranges = [var.public_honeypot_subnet_cidr]
  target_tags   = var.logging_vm_target_tags

  allow {
    protocol = "tcp"
    ports    = ["3100"]
  }
}

resource "google_compute_firewall" "logging_iap_ssh" {
  name      = "${var.vpc_name}-logging-iap-ssh-22"
  network   = google_compute_network.main.name
  direction = "INGRESS"
  priority  = 940

  source_ranges = var.iap_ssh_source_ranges
  target_tags   = var.logging_vm_target_tags

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_router" "nat" {
  name    = "${var.vpc_name}-nat-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "private_egress" {
  name                               = "${var.vpc_name}-private-nat"
  router                             = google_compute_router.nat.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.tools.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
