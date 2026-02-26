# GCP Infrastructure as Code

This repository contains Terraform configurations for deploying a Cloud Run application on Google Cloud Platform with integrated load balancing, networking, and artifact management.

## Architecture Overview

The infrastructure establishes a secure, scalable deployment with the following components:

- **Cloud Run Service**: Containerized FastAPI application with auto-scaling capabilities
- **External Load Balancer**: HTTPS-based load balancing with SSL/TLS termination
- **VPC Network**: Custom Virtual Private Cloud with multiple specialized subnets
- **Artifact Registry**: Docker image repository for container images
- **Service Accounts**: IAM-managed access controls for secure resource interactions

## Network Architecture

### VPC Configuration
- **Network**: Custom VPC with disabled auto-created subnetworks
- **Region**: us-central1 (centralized deployment region)

### Subnets
1. **App Subnet** (10.0.0.0/24)
   - Primary subnet for application resources
   - Google Private Access enabled

2. **PSC NAT Subnet** (10.2.0.0/28)
   - Dedicated for Private Service Connect
   - Purpose-specific routing configuration

3. **ILB Subnet** (10.3.0.0/28)
   - Internal Load Balancer traffic
   - Regional managed proxy configuration

4. **Proxy-Only Subnet** (10.5.0.0/23)
   - Regional managed proxy traffic
   - Dedicated for load balancer proxies

## Cloud Run Deployment

### Service Configuration
- **Ingress**: Internal Load Balancer only
- **Image Registry**: Artifact Registry (Docker format)
- **Container Port**: 8000
- **Resource Limits**: 1 CPU, 512Mi memory
- **Scaling**: 0-2 instances (auto-scaling enabled)

### Network Endpoint Group
- Serverless endpoint integration
- Direct Cloud Run service routing to load balancer

## Load Balancing

### HTTPS Configuration
- **Certificate**: Self-signed (for development/testing)
- **Port**: 443
- **Scheme**: External Managed Load Balancing
- **URL Mapping**: Path-based routing to Cloud Run backend

### Backend Service
- HTTP/2 protocol support
- Connection draining: 10 seconds
- Request timeout: 30 seconds
- Single backend target: Cloud Run NEG

## Artifact Management

### Artifact Registry
- **Repository**: Docker format container storage
- **Location**: us-central1
- **Purpose**: Store and manage container images for Cloud Run deployments

## Security

### Service Accounts
- Dedicated service account for resource access
- IAM role-based access control
- Editor role for resource management

### IAM Permissions
- Fine-grained service access controls
- User-based authentication and authorization
- External account support for cross-organization access

## Enabled Google Cloud APIs

The following APIs are automatically enabled:
- Cloud Run (`run.googleapis.com`)
- Artifact Registry (`artifactregistry.googleapis.com`)
- Compute Engine (`compute.googleapis.com`)
- API Gateway (`apigee.googleapis.com`)
- Service Networking (`servicenetworking.googleapis.com`)
- VPC Access (`vpcaccess.googleapis.com`)
- Cloud Build (`cloudbuild.googleapis.com`)
- Cloud Functions (`cloudfunctions.googleapis.com`)
- Cloud KMS (`cloudkms.googleapis.com`)
- Kubernetes Engine (`container.googleapis.com`)
- Cloud Resource Manager (`cloudresourcemanager.googleapis.com`)

## Prerequisites

- Terraform >= 7.18.0 (Google provider)
- GCP Project with billing enabled
- Appropriate IAM permissions for infrastructure deployment
- TLS provider for certificate generation

## Configuration

### Required Variables
- `project_id`: GCP project identifier
- `region`: Deployment region (default: us-central1)

### Optional Variables
- `app_name`: Application identifier (default: my-fastapi-app)
- Various CIDR ranges for subnet configuration

## Deployment

1. Configure `terraform.tfvars` with required values
2. Initialize Terraform: `terraform init`
3. Review planned changes: `terraform plan`
4. Apply configuration: `terraform apply`

## File Structure

- `main.tf`: Core VPC and networking resources
- `cloudrun.tf`: Cloud Run service, IAM, and NEG configuration
- `lb.tf`: Load balancer, SSL certificates, and routing
- `gcr.tf`: Artifact Registry setup
- `security.tf`: Service accounts and IAM policies
- `provider.tf`: Terraform and Google provider configuration
- `variables.tf`: Variable definitions and defaults
- `terraform.tfstate*`: State files (version controlled for reference)

## Notes

- SSL certificates are self-signed for development environments
- Replace with production-grade certificates before production deployment
- Organization IAM policy allows all organization members
- Connection to services restricted to internal load balancer only
