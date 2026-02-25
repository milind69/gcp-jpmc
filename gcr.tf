resource "google_artifact_registry_repository" "my-aft-repo" {
  location = "us-central1"
  repository_id = "my-aft-repo"
  description = "artifact docker repository"
  format = "DOCKER"
}