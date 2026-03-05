



import {
  to = google_compute_address.alb-ip
  id = "projects/mpk-project-id/regions/us-central1/addresses/my-fastapi-app-alb-ip"
}



import {
  to = google_service_account.apigee-cloud-runnersa
  id = "projects/mpk-project-id/serviceAccounts/apigee-cloud-runnersa@mpk-project-id.iam.gserviceaccount.com"
}

import {
  to = google_service_account.producer-service-account
  id = "projects/mpk-project-id/serviceAccounts/producer-project-sa@mpk-project-id.iam.gserviceaccount.com"
}

import {
  to = google_compute_region_network_endpoint_group.cloud_run_neg
  id = "projects/mpk-project-id/regions/us-central1/networkEndpointGroups/my-fastapi-app-neg"
 }

# import {
#   to = google_compute_region_backend_service.cloud_run_backend_service
#   id = "projects/mpk-project-id/regions/us-central1/backendServices/my-fastapi-app-backend"
# }

# import {
#   to = google_compute_region_url_map.cloud_run_url_map
#   id = "projects/mpk-project-id/regions/us-central1/urlMaps/my-fastapi-app-url-map"
# }
     

import {
    to = google_compute_region_ssl_certificate.alb-cert
    id = "projects/mpk-project-id/regions/us-central1/sslCertificates/alb-cert"
}



# import {
#     to = google_compute_region_ssl_certificate.cert
#     id = "projects/mpk-project-id/regions/us-central1/sslCertificates/cloudrun-cert"
# }

import {
    to  = google_compute_network.vpc-consumer
    id = "projects/mpk-project-id/global/networks/vpc-consumer"
}

import {
    to  = google_compute_network.vpc
    id = "projects/mpk-project-id/global/networks/vpc-producer"
}

# import {
#     to  = google_compute_address.apigee-range
#     id = "projects/mpk-project-id/global/addresses/my-fastapi-app-apigee-range"
# }

import {
    to  = google_compute_subnetwork.app_subnet
    id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-subnet"
}

import {
  to = google_compute_subnetwork.consumer_app_subnet
  id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-consumer-subnet"
}

import {
    to = google_compute_subnetwork.psc_nat
    id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-psc-nat-subnet"
}

import {
    to = google_compute_subnetwork.ilb_subnet
    id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-ilb-subnet"
}

import {
    to = google_compute_subnetwork.proxy_only_subnet
    id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-proxy-only-subnet"
}

import {
    to = google_compute_subnetwork.psc_consumer_subnet
    id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-psc-consumer-subnet"
}

import {
    to = google_compute_subnetwork.alb_proxy_only_subnet
    id = "projects/mpk-project-id/regions/us-central1/subnetworks/my-fastapi-app-alb-proxy-only-subnet"
}

import {
    to = google_apigee_organization.apigee_org
    id = "projects/mpk-project-id/apigee/organizations/mpk-apigee-org"
}