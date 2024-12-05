# GCP Infrastructure Deployment with Terraform and Shell Script

This repository provides an automated solution for deploying infrastructure on Google Cloud Platform (GCP) using **Terraform** and a **Shell script**. The solution creates and configures essential GCP resources like App Engine, Cloud SQL, Cloud Storage Buckets, VPC, Subnets, and Firewall rules, and deploys a Docker containerized backend application to App Engine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **[Google Cloud Platform Account](https://cloud.google.com/)**: A GCP account with appropriate permissions to create and manage resources.
- **[Terraform](https://www.terraform.io/downloads.html)**: Infrastructure as Code (IaC) tool used to define and provision the infrastructure.
- **[Google Cloud SDK](https://cloud.google.com/sdk/docs/install)**: Command-line interface to interact with GCP services.
- **[Docker](https://www.docker.com/get-started)**: To build and push Docker images to Google Container Registry.
- **gcloud CLI authenticated**: Ensure your Google Cloud account is authenticated using:
  
  ```bash
  gcloud auth login

.
├── main.tf                 # Terraform main configuration file
├── variables.tf            # Terraform variable definitions
├── outputs.tf              # Terraform output values
├── terraform.tfvars        # Terraform variable file (can be dynamically created via shell)
└── deploy.sh               # Shell script to automate the process
Setup and Configuration
Step 1: Configure Environment Variables
Before running the shell script, set up your GCP project and resource configurations inside the deploy.sh script.

PROJECT_ID: Your GCP project ID.
REGION: The region where you want to deploy the resources.
DB_HOST: The Cloud SQL instance's internal hostname.
DB_USER: The database username.
DB_PASSWORD: The database password.
DB_NAME: The name of your database.
Example:


# GCP Project ID and other environment variables
PROJECT_ID="your-project-id"
REGION="us-central1"
DB_HOST="my-sql-instance.us-central1.c.project-id.internal"
DB_USER="root"
DB_PASSWORD="your-password"
DB_NAME="my-database"
Step 2: Modify Terraform Configuration Files
main.tf
This file contains the main Terraform configuration to define the resources you want to create, such as VPC, Cloud SQL, App Engine, etc.

variables.tf
This file defines input variables for Terraform, such as project_id, region, db_host, etc.

Example:

output "frontend_url" {
  value = google_storage_bucket.frontend_bucket.website[0].main_page_suffix
}

output "backend_url" {
  value = google_app_engine_flexible_app_version.backend_app.default_url
}
Step 3: Run the Shell Script
The deploy.sh script automates the entire process, including creating the terraform.tfvars file dynamically from the shell script variables, initializing Terraform, and applying the configuration.

Running the Shell Script
Make sure you have set up the necessary environment variables as described in Step 1.
Run the shell script to deploy the infrastructure:
```
    bash deploy.sh
The script will:

Authenticate with Google Cloud using gcloud auth login.
Create a terraform.tfvars file dynamically using the values from the script.
Initialize Terraform using terraform init.
Apply the Terraform configuration using terraform apply.
Step 4: Verify the Deployment
Once the script finishes running, Terraform will output the URLs for your deployed resources (e.g., frontend and backend services). Example output:


frontend_url = "gs://my-frontend-bucket/index.html"
backend_url = "https://my-backend-service-dot-my-project-id.appspot.com"
Step 5: Clean Up Resources
If you want to delete the resources deployed by Terraform, you can run the following command:


terraform destroy
This will remove all the resources created by the Terraform plan.