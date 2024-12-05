# Configure the GCP provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a Virtual Private Cloud (VPC)
resource "google_compute_network" "app_network" {
  name                   = "app-vpc"
  auto_create_subnetworks = "false"
}

# Create two subnets: one for the application and one for the database
resource "google_compute_subnetwork" "app_subnet" {
  name          = "app-subnet"
  region        = var.region
  network       = google_compute_network.app_network.name
  ip_cidr_range = "10.0.1.0/24"  # Define subnet CIDR range for app
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db-subnet"
  region        = var.region
  network       = google_compute_network.app_network.name
  ip_cidr_range = "10.0.2.0/24"  # Define subnet CIDR range for database
}

# Cloud SQL for MySQL
resource "google_sql_database_instance" "mysql_instance" {
  name             = "my-sql-instance"
  database_version = "MYSQL_5_7"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      authorized_networks {
        name  = "public-access"
        value = "0.0.0.0/0"
      }
      ipv4_enabled = true
    }
  }
}

# Cloud Storage bucket for frontend
resource "google_storage_bucket" "frontend_bucket" {
  name     = "my-frontend-bucket"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Firewall rules for allowing HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.app_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http-server"]
}

# App Engine service for backend
resource "google_app_engine_application" "default" {
  location_id = "us-central"
}

resource "google_app_engine_flexible_app_version" "backend_app" {
  service     = "default"
  version_id  = "v1"
  runtime     = "custom"  # Using custom Docker runtime

  # Specify the command to run when the container starts
  entrypoint {
    shell = "python app.py"
  }

  # Environment variables for the application
  env_variables = {
    DB_HOST     = var.db_host
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DB_NAME     = var.db_name
  }

  deployment {
    container {
      image = "gcr.io/${var.project_id}/my-backend-image"  # Custom Docker image
    }
  }

  liveness_check {
    path= "/users"
  }

  # Readiness check block (minimal config, you can leave the path blank or set it to an always-responding endpoint)
  readiness_check {
    path= "/users"
  }
  manual_scaling {
    instances = 1  # Number of instances to run
  }
}

# Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "my_backend_repo" {
  repository_id = "my-backend-repo"
  location      = "us-central1"
  format        = "DOCKER"
  project       = var.project_id
}

output "frontend_url" {
  value = google_storage_bucket.frontend_bucket.website[0].main_page_suffix
}

output "backend_url" {
  value = "https://${google_app_engine_application.default.default_hostname}"
}

