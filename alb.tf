# resource "google_compute_address" "alb-ip" {
#   name         = "${var.app_name}-alb-ip"
#   project      = var.project_id
#   region       = var.region
#   address_type = "EXTERNAL"
# }

# resource "google_compute_region_network_endpoint_group" "alb-apigee-neg" {
#   name                  = "${var.app_name}-alb-apigee-neg"
#   project               = var.project_id
#   region                = var.region
#   network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
#   psc_target_service    = google_apigee_instance.apigee_instance.service_attachment
#   network               = google_compute_network.vpc-consumer.id
#   subnetwork            = google_compute_subnetwork.consumer_app_subnet.id

# }

# # backend service 
# resource "google_compute_region_backend_service" "alb_apigee_psc_backend_service" {
#   name                            = "${var.app_name}-alb-apigee-psc-backend"
#   project                         = var.project_id
#   region                          = var.region
#   protocol                        = "HTTPS"
#   load_balancing_scheme           = "EXTERNAL_MANAGED"
#   connection_draining_timeout_sec = 10
#   timeout_sec                     = 30
#   backend {
#     group           = google_compute_region_network_endpoint_group.alb-apigee-neg.id
#     capacity_scaler = 1.0
#   }
#   log_config {
#     enable      = true
#     sample_rate = 1.0
#   }
# }



# resource "google_compute_region_ssl_certificate" "alb-cert" {
#   name        = "alb-cert"
#   private_key = tls_private_key.alb-key.private_key_pem
#   certificate = tls_self_signed_cert.alb-cert.cert_pem
#   region      = var.region
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "tls_private_key" "alb-key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "tls_self_signed_cert" "alb-cert" {
#   private_key_pem = tls_private_key.alb-key.private_key_pem

#   subject {
#     common_name = "api.kooltech.xyz"
#   }

#   validity_period_hours = 87600

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#   ]
# }

# resource "google_compute_region_url_map" "alb-url-map" {
#   name            = "${var.app_name}-alb-url-map"
#   project         = var.project_id
#   region          = var.region
#   default_service = google_compute_region_backend_service.alb_apigee_psc_backend_service.id

# }

# resource "google_compute_region_target_https_proxy" "alb-https-proxy" {
#   name             = "alb-https-proxy"
#   project          = var.project_id
#   url_map          = google_compute_region_url_map.alb-url-map.id
#   region           = var.region
#   ssl_certificates = [google_compute_region_ssl_certificate.alb-cert.id]
# }

# resource "google_compute_forwarding_rule" "alb-forwarding-rule" {
#   name                  = "${var.app_name}-alb-forwarding-rule"
#   project               = var.project_id
#   region                = var.region
#   target                = google_compute_region_target_https_proxy.alb-https-proxy.id
#   ip_address            = google_compute_address.alb-ip.address
#   port_range            = "443"
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   network               = google_compute_network.vpc-consumer.id
#   depends_on            = [google_compute_subnetwork.proxy_only_subnet]
# }
