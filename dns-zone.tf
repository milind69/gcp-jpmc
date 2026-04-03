resource "google_dns_managed_zone" "internal" {
  name       = "intenal-kooltech"
  dns_name   = "internal.kooltech.xyz."
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
    networks {
      network_url = google_compute_network.vpc-consumer.id
    }
  }
}

resource "google_dns_policy" "inbound_forwarding" {
  name                      = "apigee-inbound-dns"
  enable_inbound_forwarding = true

  networks {
    network_url = google_compute_network.vpc-consumer.id
  }
}

resource "google_service_networking_peered_dns_domain" "apigee_dns_peering" {
  name       = "apigee-dns-peering"
  network    = google_compute_network.vpc-consumer.name
  dns_suffix = "internal.kooltech.xyz."
  service    = "servicenetworking.googleapis.com"
  project    = "mpk-project-id"
  depends_on = [google_dns_managed_zone.internal]
}
