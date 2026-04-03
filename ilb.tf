
### Private public IP 

resource "google_compute_address" "ilb-ip" {
  name         = "${var.app_name}-internal-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"
  #   subnetwork   = google_compute_subnetwork.ilb_subnet.id # PRIVATE SUBNET consumer_app_subnet
  subnetwork = google_compute_subnetwork.consumer_app_subnet.id # PRIVATE SUBNET consumer_app_subnet
  purpose    = "SHARED_LOADBALANCER_VIP"
}

resource "google_dns_record_set" "ilb-dns" {
  name         = "cloudrun.internal.kooltech.xyz."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.ilb-ip.address]
  project      = var.project_id
  managed_zone = google_dns_managed_zone.internal.name
  depends_on   = [google_compute_address.ilb-ip, google_dns_managed_zone.internal]
}



# # Self-signed cert (replace with proper cert in prod)
# resource "google_compute_region_ssl_certificate" "cert" {
#   name        = "cloudrun-cert"
#   private_key = tls_private_key.key.private_key_pem
#   certificate = tls_self_signed_cert.cert.cert_pem
#   region      = var.region
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "tls_private_key" "key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "tls_self_signed_cert" "cert" {
#   private_key_pem = tls_private_key.key.private_key_pem

#   subject {
#     common_name = "*"
#   }

#   validity_period_hours = 87600

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#   ]
# }


# intenal based cert

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
    common_name = "cloudrun.internal.kooltech.xyz"
  }
  dns_names = ["cloudrun.internal.kooltech.xyz",
  "*.internal.kooltech.xyz"]

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




# url map
resource "google_compute_region_url_map" "cloud_run_url_map" {
  name            = "${var.app_name}-url-map"
  project         = var.project_id
  region          = var.region
  default_service = google_compute_region_backend_service.cloud_run_backend_service.id
}


resource "google_compute_region_target_https_proxy" "https_proxy" {
  name             = "cloudrun-https-proxy"
  project          = var.project_id
  region           = var.region
  url_map          = google_compute_region_url_map.cloud_run_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.cert.id]
}



resource "google_compute_forwarding_rule" "https" {
  name       = "${var.app_name}-https-forwarding-rule"
  project    = var.project_id
  region     = var.region
  target     = google_compute_region_target_https_proxy.https_proxy.id
  ip_address = google_compute_address.ilb-ip.address
  #   network               = google_compute_network.vpc.id           # vpc-consumer
  #   subnetwork            = google_compute_subnetwork.ilb_subnet.id # PRIVATE SUBNET consumer_app_subnet
  network               = google_compute_network.vpc-consumer.id           # vpc-consumer
  subnetwork            = google_compute_subnetwork.consumer_app_subnet.id # PRIVATE SUBNET consumer_app_subnet
  port_range            = "443"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  #load_balancing_scheme = "EXTERNAL_MANAGED"
  #allow_psc_global_access = true
  depends_on = [google_compute_subnetwork.proxy_only_subnet]
}


### port 80

# resource "google_compute_region_target_http_proxy" "http_proxy" {
#   name    = "cloudrun-http-proxy"
#   project = var.project_id
#   region  = var.region
#   url_map = google_compute_region_url_map.cloud_run_url_map.id
# }


# resource "google_compute_forwarding_rule" "http" {
#   name                  = "${var.app_name}-http-forwarding-rule"
#   project               = var.project_id
#   region                = var.region
#   target                = google_compute_region_target_http_proxy.http_proxy.id
#   ip_address            = google_compute_address.ilb-ip.address
#   network               = google_compute_network.vpc.id
#   subnetwork            = google_compute_subnetwork.ilb_subnet.id # PRIVATE SUBNET
#   port_range            = "80"
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   #load_balancing_scheme = "EXTERNAL_MANAGED"
#   #allow_psc_global_access = true
#   depends_on = [google_compute_subnetwork.proxy_only_subnet]
# }

# # testing using curl/postman/bruno
# # curl -k -H "Authorization: Bearer $(gcloud auth print-identity-token)" https://llb-url/

