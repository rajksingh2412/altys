# GCP Infrastructure Deployment with Terraform and Shell Script

This repository provides an automated solution for deploying infrastructure on Google Cloud Platform (GCP) using **Terraform** and a **Shell script**. The solution creates and configures essential GCP resources like App Engine, Cloud SQL, Cloud Storage Buckets, VPC, Subnets, and Firewall rules, and deploys a Docker containerized backend application to App Engine.
The frontend is deployed on static gcs bucket.

Steps to execute:
1. create a file with name service-account.json with the access to above resources.
2. command to run
```
  bash shell.sh
```
This will create image and deploy
backend: App engine
frontend: static on gcs bucket
db : mysql


LINK:
frontend: http://frontend-bucket-xyztr.storage.googleapis.com/index.html
backend: https://robust-muse-443819-r2.uc.r.appspot.com/users
