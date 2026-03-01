
# Self-signed cert (replace with proper cert in prod)
resource "google_compute_region_ssl_certificate" "cert" {
  name        = "cloudrun-cert"
  private_key = tls_private_key.key.private_key_pem
  certificate = tls_self_signed_cert.cert.cert_pem
  region      = var.region
  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name = "*"
  }

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
### enable this for public LB
# 
# resource "google_compute_address" "ilb-ip" {
#   name         = "${var.app_name}-ip"
#   project      = var.project_id
#   region       = var.region
#   address_type = "EXTERNAL"
# }

### Private public IP 

resource "google_compute_address" "ilb-ip" {
  name         = "${var.app_name}-internal-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.ilb_subnet.id # PRIVATE SUBNET
  purpose      = "SHARED_LOADBALANCER_VIP"
}




resource "google_compute_region_target_https_proxy" "https_proxy" {
  name             = "cloudrun-https-proxy"
  project          = var.project_id
  region           = var.region
  url_map          = google_compute_region_url_map.cloud_run_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.cert.id]
}


resource "google_compute_forwarding_rule" "https" {
  name                  = "${var.app_name}-https-forwarding-rule"
  project               = var.project_id
  region                = var.region
  target                = google_compute_region_target_https_proxy.https_proxy.id
  ip_address            = google_compute_address.ilb-ip.address
  network               = google_compute_network.vpc.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id # PRIVATE SUBNET
  port_range            = "443"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  #load_balancing_scheme = "EXTERNAL_MANAGED"
  #allow_psc_global_access = true
  depends_on = [google_compute_subnetwork.proxy_only_subnet]
}


output "ilb_ip" {
  value = google_compute_address.ilb-ip.address
}
# # testing using curl/postman/bruno
# # curl -k -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
# #   https://llb-url/

