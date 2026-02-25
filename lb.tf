
# Self-signed cert (replace with proper cert in prod)
resource "google_compute_ssl_certificate" "cert" {
  name        = "cloudrun-cert"
  private_key = tls_private_key.key.private_key_pem
  certificate = tls_self_signed_cert.cert.cert_pem
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

resource "google_compute_target_https_proxy" "https_proxy" {
  name = "cloudrun-https-proxy"
  project = "${var.project_id}"
  url_map = google_compute_url_map.cloud_run_url_map.id
  ssl_certificates = [google_compute_ssl_certificate.cert.id]
  
}


resource "google_compute_global_address" "default" {
  name         = "${var.app_name}-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
}
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.app_name}-https-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_address            = google_compute_global_address.default.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}



# # testing using curl
# # curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
# #   https://llburl/

