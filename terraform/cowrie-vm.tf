data "google_compute_address" "cowrie_external_ip" {
  count = var.cowrie_reserved_external_ip_name == null ? 0 : 1

  name   = var.cowrie_reserved_external_ip_name
  region = var.region
}

resource "google_compute_instance_template" "cowrie" {
  name_prefix  = "${var.vpc_name}-cowrie-"
  machine_type = var.cowrie_machine_type
  region       = var.region

  tags = concat(
    var.cowrie_vm_tags,
    var.cowrie_admin_target_tags,
    var.cowrie_attach_honeypot_tag ? var.cowrie_target_tags : []
  )

  disk {
    source_image = var.cowrie_boot_disk_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.cowrie_boot_disk_size_gb
    disk_type    = var.cowrie_boot_disk_type
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_honeypot.id

    dynamic "access_config" {
      for_each = var.cowrie_enable_public_ip ? [1] : []
      content {
        nat_ip = var.cowrie_reserved_external_ip_name == null ? null : data.google_compute_address.cowrie_external_ip[0].address
      }
    }
  }

  metadata = merge(
    {
      enable-oslogin = var.cowrie_enable_oslogin ? "TRUE" : "FALSE"
      startup-script = <<-EOT
        #!/bin/bash
        set -euo pipefail

        if grep -qE '^#?Port ' /etc/ssh/sshd_config; then
          sed -i -E 's/^#?Port .*/Port ${var.cowrie_admin_ssh_port}/' /etc/ssh/sshd_config
        else
          echo 'Port ${var.cowrie_admin_ssh_port}' >> /etc/ssh/sshd_config
        fi

        if grep -qE '^#?PasswordAuthentication ' /etc/ssh/sshd_config; then
          sed -i -E 's/^#?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
        else
          echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
        fi

        systemctl restart ssh || systemctl restart sshd

        if [ "${var.cowrie_enable_bootstrap}" = "true" ]; then
          if ! command -v docker >/dev/null 2>&1; then
            apt-get update
            apt-get install -y docker.io
            systemctl enable --now docker
          fi

          install -d -m 0755 /opt/cowrie/etc /opt/cowrie/var
          docker rm -f cowrie >/dev/null 2>&1 || true
          docker pull ${var.cowrie_container_image}
          docker run -d --name cowrie \
            --restart unless-stopped \
            -p ${var.cowrie_container_host_port}:2222 \
            -v /opt/cowrie/etc:/cowrie/cowrie-git/etc \
            -v /opt/cowrie/var:/cowrie/cowrie-git/var \
            ${var.cowrie_container_image}
        fi
      EOT
    },
    var.cowrie_admin_ssh_public_key != "" ? {
      ssh-keys = "${var.cowrie_admin_ssh_username}:${trimspace(var.cowrie_admin_ssh_public_key)}"
    } : {}
  )

  service_account {
    email  = var.cowrie_service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

resource "google_compute_instance_from_template" "cowrie" {
  count = var.create_cowrie_vm ? 1 : 0

  name                     = var.cowrie_vm_name
  zone                     = coalesce(var.cowrie_zone, "${var.region}-a")
  source_instance_template = google_compute_instance_template.cowrie.id

  can_ip_forward = false

  lifecycle {
    prevent_destroy = false
  }
}
