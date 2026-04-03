resource "google_apigee_target_server" "cloudrun" {
  name   = "cloudrun-backend"
  env_id = google_apigee_environment.apigee_env.id
  host   = google_compute_address.ilb-ip.address # IP works, DNS doesn't yet
  port   = 443

  s_sl_info {
    enabled                  = true
    ignore_validation_errors = true
  }
  depends_on = [google_compute_address.ilb-ip, google_apigee_environment.apigee_env]
}
