resource "google_artifact_registry_repository" "my-aft-repo" {
  location = "us-central1"
  repository_id = "my-aft-repo"
  description = "artifact docker repository"
  format = "DOCKER"
}


resource "google_cloud_run_v2_service" "my-fastapi-app" {
  name     = "${var.app_name}-app"
  location = "us-central1"
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"
  #ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  template {
      containers {
        name  = "${var.app_name}"
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my-aft-repo.repository_id}/my-fastapi-app:latest"

        ports {
          container_port = 8000
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }
      scaling {
        min_instance_count = 0
        max_instance_count = 2
      }
  }
}


resource "google_cloud_run_v2_service_iam_member" "my-fastapi-app-kooltech" {
  name = google_cloud_run_v2_service.my-fastapi-app.name
  location = "${var.region}"
  project = "${var.project_id}"
  role    = "roles/run.invoker"
  member  = "user:milind@kooltech.xyz"
}  

# to use extenal account 
resource "google_cloud_run_v2_service_iam_member" "my-fastapi-app-external-viewer" {
  name = google_cloud_run_v2_service.my-fastapi-app.name
  location = "${var.region}"
  project = "${var.project_id}"
  role    = "roles/run.viewer"
  member  = "user:kulkarni.milind@gmail.com"
}  

resource "google_cloud_run_v2_service_iam_member" "my-fastapi-app-external-invoker" {
  name = google_cloud_run_v2_service.my-fastapi-app.name
  location = "${var.region}"
  project = "${var.project_id}"
  role    = "roles/run.invoker"
  member  = "user:kulkarni.milind@gmail.com"
}  

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "${var.app_name}-neg"
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.my-fastapi-app.name
  }
}


resource "google_compute_backend_service" "cloud_run_backend_service" {
  name                  = "${var.app_name}-backend"
  project               = var.project_id
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30
  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }
}

# url map
resource "google_compute_url_map" "cloud_run_url_map" {
  name                  = "${var.app_name}-url-map"
  project               = var.project_id
  default_service       = google_compute_backend_service.cloud_run_backend_service.id

}



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



