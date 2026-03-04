resource "google_service_account" "producer-service-account" {
  account_id   = "producer-project-sa"
  display_name = "producer-project-sa"
  project      = var.project_id
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_iam_member" "producer-project-sa-editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.producer-service-account.email}"
  lifecycle {
    prevent_destroy = true
  }
}
