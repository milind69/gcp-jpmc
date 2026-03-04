

# output "apigee_instance_host" {
#   description = "apigee instance host"
#   value       = google_apigee_instance.apigee_instance.host
# }

# output "apigee_instance_id" {
#   value = google_apigee_instance.apigee_instance
# }
# output "psc_service_attachment" {
#   value = google_compute_service_attachment.ilb-psc-attachement
# }

# output "alb_ip" {
#   value = google_compute_address.alb-ip.address
# }

# output "ilb_ip" {
#   value = google_compute_address.ilb-ip.address
# }

# output "cloud-run" {
#   value = google_cloud_run_v2_service.my-fastapi-app
# }


output "apigee_psc_service_attachment" {
  description = "Use this host in Apigee target endpoint"
  value       = google_apigee_endpoint_attachment.apigee-psc-attachement.host
}
