#!/bin/bash

# GCP Setup Script for Linux Academy Labs (Limited Permissions)
set -e

echo "================================"
echo "GCP Static Website Setup"
echo "Linux Academy Labs Edition"
echo "================================"
echo ""

# Get project ID from current config
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
  read -p "Enter GCP Project ID: " PROJECT_ID
  gcloud config set project $PROJECT_ID
fi

echo "Using Project: $PROJECT_ID"
echo ""

# Generate unique bucket name
BUCKET_NAME="kl-website-$(date +%s)"

read -p "Enter bucket name (or press Enter for default: $BUCKET_NAME): " CUSTOM_BUCKET
if [ ! -z "$CUSTOM_BUCKET" ]; then
  BUCKET_NAME=$CUSTOM_BUCKET
fi

echo ""
echo "Creating Cloud Storage bucket: gs://$BUCKET_NAME/"
gcloud storage buckets create gs://$BUCKET_NAME \
  --location=us \
  --uniform-bucket-level-access

echo "✅ Bucket created successfully"
echo ""

# Enable static website hosting
echo "Enabling static website hosting..."
gcloud storage buckets update gs://$BUCKET_NAME \
  --web-main-page-suffix=index.html \
  --web-error-page=404.html

echo "✅ Static website hosting enabled"
echo ""

# Make bucket publicly readable (for static hosting)
echo "Setting bucket permissions for public access..."
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME || \
  echo "⚠️  Note: Public access may require admin approval in this lab environment"

echo ""
echo "================================"
echo "✅ Setup Complete!"
echo "================================"
echo ""
echo "📦 Bucket Name: $BUCKET_NAME"
echo "🌐 Website URL: https://storage.googleapis.com/$BUCKET_NAME/index.html"
echo ""
echo "📝 Next Steps:"
echo "1. Upload index.html:"
echo "   gcloud storage cp index.html gs://$BUCKET_NAME/"
echo ""
echo "2. Verify deployment:"
echo "   gcloud storage ls gs://$BUCKET_NAME/"
echo ""
echo "3. View your website:"
echo "   Open: https://storage.googleapis.com/$BUCKET_NAME/index.html"
echo ""
