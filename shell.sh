#!/bin/bash

# Exit the script if any command fails
set -e

# GCP Project ID and other environment variables
PROJECT_ID="flutter-sl-poc-21aa3"
REGION="us-central1"
DB_HOST="my-sql-instance.us-central1.c.project-id.internal"
DB_USER="root"
DB_PASSWORD="your-password"
DB_NAME="my-database"

# Step 1: Authenticate with Google Cloud
echo "Authenticating with Google Cloud..."
# gcloud auth login
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION


echo "Creating terraform.tfvars file..."
cat > test.tfvars <<EOL
project_id = "$PROJECT_ID"
region     = "$REGION"
db_host    = "$DB_HOST"
db_user    = "$DB_USER"
db_password = "$DB_PASSWORD"
db_name    = "$DB_NAME"
EOL

### create gcr repo 
# gcloud artifacts repositories create my-backend-repo --repository-format=docker --location=us-central1
# Step 3: Build the Backend Docker Image
echo "Building Docker image for the backend..."
# docker build -t gcr.io/$PROJECT_ID/my-backend-image -f backend/Dockerfile .

gcloud auth configure-docker us-central1-docker.pkg.dev
# Step 4: Push the Docker Image to Google Container Registry
echo "Pushing Docker image to Google Container Registry..."
# docker push gcr.io/$PROJECT_ID/my-backend-image

# Step 5: Deploy the Backend to Google App Engine
# echo "Deploying backend to Google App Engine..."
# gcloud app browse  # This will open the deployed app in your default browser.
cd terraform
echo "Initializing Terraform..."
# gcloud auth application-default login
terraform init

echo "Applying Terraform configuration..."
terraform plan -var-file="../test.tfvars"
# terraform apply -var-file="test.tfvars"

# # Step 6: Deploy the Frontend to Google Cloud Storage
# echo "Deploying frontend to Google Cloud Storage..."

# # Upload frontend files to the bucket (adjust the path to your actual index.html)
# gsutil cp index.html gs://$CLOUD_STORAGE_BUCKET_NAME

# # Step 7: Output the deployed URLs
# echo "Deployment complete!"

# # Output Frontend URL
# FRONTEND_URL="http://$CLOUD_STORAGE_BUCKET_NAME.storage.googleapis.com/index.html"
# echo "Frontend URL: $FRONTEND_URL"

# # Output Backend URL (App Engine URL)
# BACKEND_URL="https://$PROJECT_ID.appspot.com"
# echo "Backend URL: $BACKEND_URL"
