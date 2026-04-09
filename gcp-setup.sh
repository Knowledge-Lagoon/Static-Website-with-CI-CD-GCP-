#!/bin/bash

# GCP Setup Script for Static Website CI/CD
set -e

echo "================================"
echo "GCP Static Website Setup"
echo "================================"
echo ""

# Input
read -p "Enter GCP Project ID: " PROJECT_ID
read -p "Enter bucket name (e.g., my-website): " BUCKET_NAME
read -p "Service account name (default: github-actions): " SA_NAME
SA_NAME=${SA_NAME:-github-actions}

# Set project
gcloud config set project $PROJECT_ID

# Create bucket
echo "Creating bucket..."
gsutil mb gs://$BUCKET_NAME/ || true

# Create service account
echo "Creating service account..."
gcloud iam service-accounts create $SA_NAME \
  --display-name="GitHub Actions" || true

SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# Grant permissions
echo "Granting permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/storage.admin" \
  --quiet

# Create key
echo "Creating service account key..."
gcloud iam service-accounts keys create sa-key.json \
  --iam-account=$SA_EMAIL

# Encode key
ENCODED_KEY=$(base64 -w 0 < sa-key.json)

# Enable static hosting
echo "Enabling static website hosting..."
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME/

# Output
echo ""
echo "✅ Setup Complete!"
echo ""
echo "Add these GitHub Secrets:"
echo "  GCP_PROJECT_ID=$PROJECT_ID"
echo "  GCS_BUCKET_NAME=$BUCKET_NAME"
echo "  GCP_SA_KEY=$ENCODED_KEY"
echo ""
echo "Website: https://storage.googleapis.com/$BUCKET_NAME/index.html"
echo ""

# Cleanup
rm sa-key.json
