#!/bin/bash
# Heroku Deployment Script for Thamar Counselling API
# Run this script to deploy the backend to Heroku

set -e

echo "🚀 Starting Heroku Deployment..."
echo ""

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew tap heroku/brew && brew install heroku
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl https://cli-assets.heroku.com/install.sh | sh
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "Please install from: https://devcenter.heroku.com/articles/heroku-command-line"
        exit 1
    fi
fi

echo "✅ Heroku CLI found"
echo ""

# Check if user is logged in
if ! heroku auth:whoami &> /dev/null; then
    echo "📝 You're not logged in. Opening login page..."
    heroku login
fi

echo ""
echo "📦 Creating Heroku application..."

# Create app if it doesn't exist
if heroku apps:info -a thamar-counselling-api &> /dev/null; then
    echo "✅ App 'thamar-counselling-api' already exists"
else
    heroku create thamar-counselling-api
    echo "✅ App created successfully"
fi

echo ""
echo "🗄️  Setting environment variables..."

# MongoDB URI
read -p "Enter MongoDB Atlas connection string: " MONGODB_URI
heroku config:set MONGODB_URI="$MONGODB_URI" -a thamar-counselling-api

# JWT Secret
read -p "Enter JWT Secret (min 32 characters): " JWT_SECRET
heroku config:set JWT_SECRET="$JWT_SECRET" -a thamar-counselling-api

heroku config:set JWT_EXPIRY="7d" -a thamar-counselling-api
heroku config:set NODE_ENV="production" -a thamar-counselling-api
heroku config:set THERAPIST_EMAIL="thamar@counselling.com" -a thamar-counselling-api
heroku config:set THERAPIST_PHONE="0659745590" -a thamar-counselling-api

# Operating hours
heroku config:set OPERATING_HOURS_START="09:00" -a thamar-counselling-api
heroku config:set OPERATING_HOURS_END="18:00" -a thamar-counselling-api
heroku config:set LUNCH_START="12:00" -a thamar-counselling-api
heroku config:set LUNCH_END="13:00" -a thamar-counselling-api

# Session settings
heroku config:set SESSION_DURATION="50" -a thamar-counselling-api
heroku config:set BUFFER_BETWEEN_SESSIONS="10" -a thamar-counselling-api

# CORS
read -p "Enter frontend domain (e.g., https://yourdomain.com): " FRONTEND_URL
heroku config:set CORS_ORIGIN="$FRONTEND_URL,http://localhost:3000" -a thamar-counselling-api

# Email setup
echo ""
read -p "Enter SendGrid API Key (leave blank to skip): " SENDGRID_API_KEY
if [ ! -z "$SENDGRID_API_KEY" ]; then
    heroku config:set SENDGRID_API_KEY="$SENDGRID_API_KEY" -a thamar-counselling-api
    heroku config:set EMAIL_FROM_ADDRESS="bookings@thamarcounselling.com" -a thamar-counselling-api
fi

# Payment setup
echo ""
read -p "Enter Stripe Public Key (leave blank to skip): " STRIPE_PUBLIC_KEY
if [ ! -z "$STRIPE_PUBLIC_KEY" ]; then
    heroku config:set STRIPE_PUBLIC_KEY="$STRIPE_PUBLIC_KEY" -a thamar-counselling-api
fi

read -p "Enter Stripe Secret Key (leave blank to skip): " STRIPE_SECRET_KEY
if [ ! -z "$STRIPE_SECRET_KEY" ]; then
    heroku config:set STRIPE_SECRET_KEY="$STRIPE_SECRET_KEY" -a thamar-counselling-api
fi

read -p "Enter Stripe Webhook Secret (leave blank to skip): " STRIPE_WEBHOOK_SECRET
if [ ! -z "$STRIPE_WEBHOOK_SECRET" ]; then
    heroku config:set STRIPE_WEBHOOK_SECRET="$STRIPE_WEBHOOK_SECRET" -a thamar-counselling-api
fi

# SMS Setup (optional)
echo ""
read -p "Enter Twilio Account SID (leave blank to skip): " TWILIO_ACCOUNT_SID
if [ ! -z "$TWILIO_ACCOUNT_SID" ]; then
    heroku config:set TWILIO_ACCOUNT_SID="$TWILIO_ACCOUNT_SID" -a thamar-counselling-api
fi

read -p "Enter Twilio Auth Token (leave blank to skip): " TWILIO_AUTH_TOKEN
if [ ! -z "$TWILIO_AUTH_TOKEN" ]; then
    heroku config:set TWILIO_AUTH_TOKEN="$TWILIO_AUTH_TOKEN" -a thamar-counselling-api
fi

read -p "Enter Twilio Phone Number (leave blank to skip): " TWILIO_PHONE_NUMBER
if [ ! -z "$TWILIO_PHONE_NUMBER" ]; then
    heroku config:set TWILIO_PHONE_NUMBER="$TWILIO_PHONE_NUMBER" -a thamar-counselling-api
fi

echo ""
echo "✅ Environment variables set"
echo ""
echo "🚢 Deploying to Heroku..."

# Deploy
git add .
git commit -m "Deploy to Heroku - $(date)" || true
git push heroku main:main || git push heroku master:main

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Checking app status..."

heroku ps -a thamar-counselling-api

echo ""
echo "📋 Viewing logs..."
echo "Command: heroku logs --tail -a thamar-counselling-api"
echo ""

echo "🧪 Testing health endpoint..."
sleep 5

APP_URL=$(heroku apps:info -a thamar-counselling-api | grep "Web URL" | awk '{print $3}')

if curl -s "$APP_URL/health" | grep -q "ok"; then
    echo "✅ Health check passed!"
    echo ""
    echo "🎉 Your backend is live at: $APP_URL"
else
    echo "⚠️  Health check failed. Checking logs..."
    heroku logs --tail -a thamar-counselling-api --lines=50
fi

echo ""
echo "📝 Configuration saved. You can view/modify with:"
echo "   heroku config -a thamar-counselling-api"
echo ""
echo "🚀 Deployment complete!"
