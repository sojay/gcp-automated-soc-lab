resource "google_compute_instance" "logging" {
  count = var.create_logging_vm ? 1 : 0

  name         = var.logging_vm_name
  machine_type = var.logging_machine_type
  zone         = coalesce(var.logging_zone, "${var.region}-a")
  tags         = concat(var.logging_vm_tags, var.logging_vm_target_tags)

  boot_disk {
    initialize_params {
      image = var.logging_boot_disk_image
      size  = var.logging_boot_disk_size_gb
      type  = var.logging_boot_disk_type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.tools.id
  }

  metadata = {
    enable-oslogin = var.logging_enable_oslogin ? "TRUE" : "FALSE"
  }

  service_account {
    email  = var.logging_service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
