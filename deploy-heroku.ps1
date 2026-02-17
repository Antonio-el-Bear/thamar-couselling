# Heroku Deployment Script for Thamar Counselling API (Windows PowerShell)
# Run this script to deploy the backend to Heroku

Write-Host "🚀 Starting Heroku Deployment..." -ForegroundColor Green
Write-Host ""

# Check if Heroku CLI is installed
try {
    $herokuVersion = heroku --version 2>$null
    Write-Host "✅ Heroku CLI found: $herokuVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Heroku CLI is not installed." -ForegroundColor Red
    Write-Host "Install from: https://devcenter.heroku.com/articles/heroku-command-line" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in
try {
    $whoami = heroku auth:whoami 2>$null
    Write-Host "✅ Logged in as: $whoami" -ForegroundColor Green
}
catch {
    Write-Host "📝 Opening Heroku login..." -ForegroundColor Yellow
    heroku login
}

Write-Host ""
Write-Host "📦 Creating Heroku application..." -ForegroundColor Green

# Create app if it doesn't exist
try {
    $appInfo = heroku apps:info -a thamar-counselling-api 2>$null
    Write-Host "✅ App 'thamar-counselling-api' already exists" -ForegroundColor Green
}
catch {
    Write-Host "Creating new app..." -ForegroundColor Yellow
    heroku create thamar-counselling-api
    Write-Host "✅ App created successfully" -ForegroundColor Green
}

Write-Host ""
Write-Host "🗄️  Setting environment variables..." -ForegroundColor Green
Write-Host ""

# MongoDB URI
$mongodbUri = Read-Host "Enter MongoDB Atlas connection string"
heroku config:set MONGODB_URI="$mongodbUri" -a thamar-counselling-api
Write-Host "✅ MongoDB URI set" -ForegroundColor Green

# JWT Secret
$jwtSecret = Read-Host "Enter JWT Secret (min 32 characters)"
heroku config:set JWT_SECRET="$jwtSecret" -a thamar-counselling-api
Write-Host "✅ JWT Secret set" -ForegroundColor Green

# Basic settings
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
Write-Host "✅ Operating hours and session settings configured" -ForegroundColor Green

# CORS
Write-Host ""
$frontendUrl = Read-Host "Enter frontend domain (e.g., https://yourdomain.com)"
heroku config:set CORS_ORIGIN="$frontendUrl,http://localhost:3000" -a thamar-counselling-api
Write-Host "✅ CORS configured" -ForegroundColor Green

# Email setup
Write-Host ""
$sendgridKey = Read-Host "Enter SendGrid API Key (or press Enter to skip)"
if ($sendgridKey) {
    heroku config:set SENDGRID_API_KEY="$sendgridKey" -a thamar-counselling-api
    heroku config:set EMAIL_FROM_ADDRESS="bookings@thamarcounselling.com" -a thamar-counselling-api
    Write-Host "✅ SendGrid configured" -ForegroundColor Green
}

# Payment setup
Write-Host ""
$stripePublic = Read-Host "Enter Stripe Public Key (or press Enter to skip)"
if ($stripePublic) {
    heroku config:set STRIPE_PUBLIC_KEY="$stripePublic" -a thamar-counselling-api
    Write-Host "✅ Stripe Public Key set" -ForegroundColor Green
}

$stripeSecret = Read-Host "Enter Stripe Secret Key (or press Enter to skip)"
if ($stripeSecret) {
    heroku config:set STRIPE_SECRET_KEY="$stripeSecret" -a thamar-counselling-api
    Write-Host "✅ Stripe Secret Key set" -ForegroundColor Green
}

$stripeWebhook = Read-Host "Enter Stripe Webhook Secret (or press Enter to skip)"
if ($stripeWebhook) {
    heroku config:set STRIPE_WEBHOOK_SECRET="$stripeWebhook" -a thamar-counselling-api
    Write-Host "✅ Stripe Webhook Secret set" -ForegroundColor Green
}

# SMS Setup (optional)
Write-Host ""
$twilioSid = Read-Host "Enter Twilio Account SID (or press Enter to skip)"
if ($twilioSid) {
    heroku config:set TWILIO_ACCOUNT_SID="$twilioSid" -a thamar-counselling-api
    Write-Host "✅ Twilio Account SID set" -ForegroundColor Green
}

$twilioToken = Read-Host "Enter Twilio Auth Token (or press Enter to skip)"
if ($twilioToken) {
    heroku config:set TWILIO_AUTH_TOKEN="$twilioToken" -a thamar-counselling-api
    Write-Host "✅ Twilio Auth Token set" -ForegroundColor Green
}

$twilioPhone = Read-Host "Enter Twilio Phone Number (or press Enter to skip)"
if ($twilioPhone) {
    heroku config:set TWILIO_PHONE_NUMBER="$twilioPhone" -a thamar-counselling-api
    Write-Host "✅ Twilio Phone Number set" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ All environment variables set" -ForegroundColor Green
Write-Host ""
Write-Host "🚢 Deploying to Heroku..." -ForegroundColor Green

# Deploy
git add .
git commit -m "Deploy to Heroku - $(Get-Date)" -ErrorAction SilentlyContinue
git push heroku main:main -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    git push heroku master:main
}

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Checking app status..." -ForegroundColor Yellow

heroku ps -a thamar-counselling-api

Write-Host ""
Write-Host "📋 Logs Command (run in terminal):" -ForegroundColor Yellow
Write-Host "   heroku logs --tail -a thamar-counselling-api" -ForegroundColor Cyan
Write-Host ""

Write-Host "🧪 Testing application..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

$appInfo = heroku apps:info -a thamar-counselling-api
$appUrl = $appInfo | Select-String "Web URL.*:" | ForEach-Object { ($_ -split '\s+')[2] }

if ($appUrl) {
    $healthCheck = Invoke-WebRequest -Uri "$appUrl/health" -ErrorAction SilentlyContinue
    if ($healthCheck.StatusCode -eq 200) {
        Write-Host "✅ Health check passed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 Your backend is live at:" -ForegroundColor Green
        Write-Host "   $appUrl" -ForegroundColor Cyan
    }
    else {
        Write-Host "⚠️  Health check failed. Check logs with:" -ForegroundColor Yellow
        Write-Host "   heroku logs --tail -a thamar-counselling-api" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "📝 Configuration saved. View/modify with:" -ForegroundColor Yellow
Write-Host "   heroku config -a thamar-counselling-api" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Copy the backend URL from above" -ForegroundColor White
Write-Host "2. Update frontend API_BASE_URL in HTML file" -ForegroundColor White
Write-Host "3. Test API endpoints" -ForegroundColor White
Write-Host "4. Deploy frontend to production" -ForegroundColor White
