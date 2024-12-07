# GCP Infrastructure Deployment with Terraform and Shell Script

This repository provides an automated solution for deploying infrastructure on Google Cloud Platform (GCP) using **Terraform** and a **Shell script**. The solution creates and configures essential GCP resources like App Engine, Cloud SQL, Cloud Storage Buckets, VPC, Subnets, and Firewall rules, and deploys a Docker containerized backend application to App Engine.
The frontend is deployed on static gcs bucket.

Steps to execute:
1. create a file with name service-account.json with the access to above resources.
2. Update these variable in deploy.sh.
```
# GCP Project ID and other environment variables
PROJECT_ID="robust-muse-443819-r2"
REGION="us-central1"
DB_HOST="my-sql-instance.us-central1.c.project-id.internal"
DB_USER="root"
DB_PASSWORD="your-password"
DB_NAME="users"
CLOUD_STORAGE_BUCKET_NAME="frontend-bucket-xyztr"
```
3. command to run
```
  bash deploy.sh
```
This will create image and deploy
backend: App engine
frontend: static on gcs bucket
db : mysql


LINK:
1. frontend: http://frontend-bucket-xyztr.storage.googleapis.com/index.html
2. backend: https://robust-muse-443819-r2.uc.r.appspot.com/users
