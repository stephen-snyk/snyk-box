resource "random_id" "namespace2" {
  prefix      = "demo-core-"
  byte_length = 2
}

data "google_compute_image" "image2" {
  family  = "ubuntu-minimal-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "origin2" {
  name         = random_id.namespace2.hex
  machine_type = var.machine_type
  zone         = var.zone2
  tags         = ["http-server", "ssh", "https-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
    }
  }
  
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    preemptible = true
    automatic_restart = false
  }

  metadata_startup_script = data.template_file.server2.rendered

  metadata = {
      cf-terraform = "demo-core-"
      cf-email = var.cloudflare_email
      cf-zone = var.cloudflare_zone
  } 

}


# Renders the data value passed above in metadata_startup_script
data "template_file" "server2" {
  template = file("${path.module}/server.tpl")

  vars = {
    web_zone = var.cloudflare_zone
    account     = var.cloudflare_account_id,
    cf_user  = var.cloudflare_email
    tunnel_id   = cloudflare_argo_tunnel.auto_tunnel2.id,
    tunnel_name = cloudflare_argo_tunnel.auto_tunnel2.name,
    secret      = random_id.argo_secret.b64_std,
    cf_api   = var.cloudflare_token
  }
}

output "public_ip2" {
  value = google_compute_instance.origin2.network_interface[0].access_config[0].nat_ip
}

output "instance_name2" {
    value = random_id.namespace2.hex
}
