# Configure the GCP provider
provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("../delta-wonder-443918-h2-d14114f4e354.json")
}

terraform {
  required_providers {
    mysql = {
      source  = "terraform-providers/mysql"
      version = "~> 1.9"  # Adjust based on the version you're using
    }
  }
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

resource "google_sql_database" "database1" {
  name     = "users"
  instance = google_sql_database_instance.mysql_instance.name
}

resource "google_sql_user" "mysql_user" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql_instance.name
  password = var.db_password
}

provider "mysql" {
  endpoint = google_sql_database_instance.mysql_instance.ip_address[0].ip_address
  username = google_sql_user.mysql_user.name
  password = google_sql_user.mysql_user.password

}

# Creating a table
resource "mysql_database" "database1" {
  name = google_sql_database.database1.name
}

resource "null_resource" "create_table" {
  provisioner "local-exec" {
    command = <<EOT
    mysql -h ${google_sql_database_instance.mysql_instance.ip_address} -u ${var.db_user} -p${var.db_password} -e "CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100));"
    EOT
  }

  depends_on = [mysql_database.database1]
}


# Cloud Storage bucket for frontend
resource "google_storage_bucket" "frontend_bucket" {
  name     = "my-frontend-bucket"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
  origin          = ["https://my-frontend-bucket.storage.googleapis.com"]  # Replace with your frontend URL
  response_header = ["Content-Type", "Authorization"]
  method          = ["GET", "POST", "PUT", "DELETE"]
  max_age_seconds = 3600
  }
}


resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  bucket = google_storage_bucket.frontend_bucket.name
  source = "./../index.html"  # Path to your local file
}


resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.frontend_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"  # Grants read access to everyone
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
  service     = "backend"
  version_id  = "v1"
  runtime     = "custom"  # Using custom Docker runtime

  # Specify the command to run when the container starts
  entrypoint {
    shell = "python app.py"
  }

  # Environment variables for the application
  env_variables = {
    DB_HOST     = google_sql_database_instance.mysql_instance.ip_address[0].ip_address
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

output "frontend_url" {
  value = google_storage_bucket.frontend_bucket.website[0].main_page_suffix
}

output "backend_url" {
  value = "https://${google_app_engine_application.default.default_hostname}"
}

