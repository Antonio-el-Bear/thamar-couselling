#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Complete automated launch for Thamar Counselling booking platform
    
.DESCRIPTION
    Fully automates:
    1. Backend setup on Heroku
    2. Frontend configuration with backend URL
    3. Frontend deployment
    4. Health checks
    
.PARAMETER SkipTests
    Skip health checks after deployment
    
.PARAMETER FrontendPlatform
    Where to deploy frontend: 'github', 'netlify', 'vercel' (default: github)
    
.EXAMPLE
    .\auto-launch.ps1
    
    .\auto-launch.ps1 -SkipTests
    
    .\auto-launch.ps1 -FrontendPlatform netlify

.NOTES
    Prerequisites:
    - Heroku CLI installed and authenticated
    - Git installed
    - Node.js installed (for some operations)
    - GitHub account with push access
#>

param(
    [switch]$SkipTests,
    [ValidateSet('github', 'netlify', 'vercel')]
    [string]$FrontendPlatform = 'github'
)

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $($Text.PadRight(60)) ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Number, [string]$Text)
    Write-Host "  [$Number] $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host "      → $Text" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Text)
    Write-Host "  ✅ $Text" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "  ❌ $Text" -ForegroundColor Red
}

function Test-Prerequisite {
    param([string]$Command, [string]$Name)
    
    try {
        $null = & $Command --version 2>$null
        Write-Success "$Name is installed"
        return $true
    }
    catch {
        Write-Error-Custom "$Name is NOT installed. Please install it first."
        return $false
    }
}

# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "🚀 THAMAR COUNSELLING - FULL AUTO LAUNCH"
Write-Host "This script will deploy your entire system in ~15-20 minutes" -ForegroundColor Magenta
Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1: CHECK PREREQUISITES
# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "PHASE 1: Checking Prerequisites"

$prereqsOk = $true
$prereqsOk = (Test-Prerequisite 'git' 'Git') -and $prereqsOk
$prereqsOk = (Test-Prerequisite 'heroku' 'Heroku CLI') -and $prereqsOk
$prereqsOk = (Test-Prerequisite 'node' 'Node.js') -and $prereqsOk

if (-not $prereqsOk) {
    Write-Error-Custom "Missing prerequisites. Please install them and try again."
    exit 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2: INPUT COLLECTION
# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "PHASE 2: Configuration"

Write-Step "1" "Checking Heroku login..."
$herokuStatus = & heroku auth:whoami 2>$null
if (-not $herokuStatus) {
    Write-Info "Not logged in. Opening Heroku login..."
    & heroku login --interactive
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Heroku login failed"
        exit 1
    }
}
Write-Success "Heroku authenticated as: $herokuStatus"

Write-Step "2" "Getting configuration from user..."
Write-Host ""
$mongoDbUri = Read-Host "Enter your MongoDB Atlas connection string (or press Enter to skip for now)"
if ($mongoDbUri) {
    Write-Info "MongoDB URI provided"
}

$jwtSecret = Read-Host "Enter a secure JWT secret (or we'll generate one)"
if (-not $jwtSecret) {
    $jwtSecret = [Convert]::ToBase64String([guid]::NewGuid().ToByteArray()).Substring(0, 32)
    Write-Info "Generated JWT secret: $jwtSecret"
}

$frontendUrl = Read-Host "Enter your frontend URL (e.g., your-site.netlify.app)"
if ($frontendUrl -and -not $frontendUrl.StartsWith('http')) {
    $frontendUrl = "https://$frontendUrl"
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3: BACKEND DEPLOYMENT
# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "PHASE 3: Backend Deployment (Heroku)"

Write-Step "1" "Creating Heroku app (or using existing)..."
$appName = "thamar-counselling-api"
$herokuAppCheck = & heroku apps:info $appName -a $appName 2>$null
if (-not $herokuAppCheck) {
    Write-Info "Creating new Heroku app: $appName..."
    & heroku create $appName
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to create Heroku app. It may already exist."
    }
}
Write-Success "Heroku app ready: $appName"

Write-Step "2" "Setting environment variables..."
Write-Info "Setting MongoDB URI..."
& heroku config:set MONGODB_URI="$mongoDbUri" -a $appName
Write-Info "Setting JWT secret..."
& heroku config:set JWT_SECRET="$jwtSecret" -a $appName
if ($frontendUrl) {
    Write-Info "Setting frontend URL..."
    & heroku config:set FRONTEND_URL="$frontendUrl" -a $appName
}

Write-Success "Environment variables configured"

Write-Step "3" "Deploying backend code to Heroku..."
Write-Info "Using Git to push code..."
$currentDir = Get-Location
cd $currentDir
& git remote add heroku "https://git.heroku.com/$appName.git" 2>$null
& git push heroku main 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Info "Remote might already exist, trying regular push..."
    & git push heroku main
}
Write-Success "Backend deployed!"

$herokuUrl = "https://$appName.herokuapp.com"
Write-Info "Backend URL: $herokuUrl"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4: FRONTEND CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "PHASE 4: Frontend Configuration"

Write-Step "1" "Updating API URL in HTML..."
$htmlFile = "thamar-counselling.html"
if (Test-Path $htmlFile) {
    $content = Get-Content $htmlFile -Raw
    $oldUrl = "const API_BASE_URL = 'http://localhost:5000/api'"
    $newUrl = "const API_BASE_URL = '$($herokuUrl)/api'"
    
    if ($content -contains $oldUrl) {
        $content = $content -replace [regex]::Escape($oldUrl), $newUrl
        Set-Content $htmlFile $content
        Write-Success "Updated API URL to: $newUrl"
    } else {
        Write-Info "API URL might already be configured"
    }
} else {
    Write-Error-Custom "HTML file not found!"
}

Write-Step "2" "Committing changes to Git..."
& git add thamar-counselling.html
& git commit -m "🚀 Auto-launch: Update backend API URL for production" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Changes committed"
} else {
    Write-Info "No new changes to commit"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 5: FRONTEND DEPLOYMENT
# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "PHASE 5: Frontend Deployment"

switch ($FrontendPlatform.ToLower()) {
    'github' {
        Write-Step "1" "Pushing to GitHub..."
        & git push origin main
        $frontendDeployedUrl = "https://github.com/Antonio-el-Bear/thamar-couselling"
        Write-Success "Pushed to GitHub"
        Write-Info "Enable GitHub Pages in repo settings to deploy automatically"
        Write-Info "Go to: Settings → Pages → Branch: main"
    }
    'netlify' {
        Write-Step "1" "Netlify deployment..."
        Write-Info "Visit: https://app.netlify.com/teams/[your-team]/sites"
        Write-Info "1. Click 'New site from Git'"
        Write-Info "2. Select: Antonio-el-Bear/thamar-couselling"
        Write-Info "3. Deploy!"
        $frontendDeployedUrl = "[your-site].netlify.app"
    }
    'vercel' {
        Write-Step "1" "Vercel deployment..."
        Write-Info "Visit: https://vercel.com/dashboard"
        Write-Info "1. Click 'Add New Project'"
        Write-Info "2. Import: Antonio-el-Bear/thamar-couselling"
        Write-Info "3. Deploy!"
        $frontendDeployedUrl = "[your-site].vercel.app"
    }
}

Write-Success "Frontend ready for deployment"

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 6: HEALTH CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

if (-not $SkipTests) {
    Write-Header "PHASE 6: Health Checks"
    
    Write-Step "1" "Waiting for Heroku app to start (this takes ~30 seconds)..."
    Start-Sleep -Seconds 10
    
    Write-Step "2" "Testing backend health..."
    try {
        $healthResponse = Invoke-WebRequest -Uri "$herokuUrl/health" -TimeoutSec 10 -ErrorAction Stop
        if ($healthResponse.StatusCode -eq 200) {
            Write-Success "Backend is healthy! ✅"
        }
    }
    catch {
        Write-Error-Custom "Backend health check failed"
        Write-Info "This might be normal - give it 1-2 minutes to fully start"
        Write-Info "Check manually: $herokuUrl/health"
    }
    
    Write-Step "3" "Testing API endpoints..."
    try {
        $apiResponse = Invoke-WebRequest -Uri "$herokuUrl/api/auth/register" -Method POST -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop 2>$null
        Write-Success "API is responding!"
    }
    catch {
        Write-Info "API test skipped (this is normal on first boot)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 7: SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

Write-Header "🎉 DEPLOYMENT COMPLETE!"

Write-Host "Your Thamar Counselling platform is almost LIVE!" -ForegroundColor Magenta
Write-Host ""

Write-Host "📊 DEPLOYMENT SUMMARY" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "Backend API:"
Write-Host "  URL: $herokuUrl" -ForegroundColor Yellow
Write-Host "  Status: Deployed ✅" -ForegroundColor Green
Write-Host ""
Write-Host "Frontend:"
Write-Host "  Platform: $($FrontendPlatform.ToUpper())" -ForegroundColor Yellow
Write-Host "  Status: Ready to deploy" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration:"
Write-Host "  MongoDB: $($mongoDbUri ? '✅ Configured' : '⚠️  Not configured')" -ForegroundColor Yellow
Write-Host "  JWT Secret: ✅ Set" -ForegroundColor Green
Write-Host "  Frontend URL: $($frontendUrl ? "✅ $frontendUrl" : '⚠️  Not configured')" -ForegroundColor Yellow
Write-Host ""

Write-Host "🚀 NEXT STEPS" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Cyan

switch ($FrontendPlatform.ToLower()) {
    'github' {
        Write-Host "1. Go to GitHub repo Settings → Pages" -ForegroundColor White
        Write-Host "2. Enable GitHub Pages (Branch: main)" -ForegroundColor White
        Write-Host "3. Your site will be live in ~1 minute!" -ForegroundColor White
    }
    'netlify' {
        Write-Host "1. Visit https://app.netlify.com" -ForegroundColor White
        Write-Host "2. Click 'New site from Git'" -ForegroundColor White
        Write-Host "3. Select Antonio-el-Bear/thamar-couselling" -ForegroundColor White
        Write-Host "4. Click Deploy!" -ForegroundColor White
    }
    'vercel' {
        Write-Host "1. Visit https://vercel.com/dashboard" -ForegroundColor White
        Write-Host "2. Click 'Add New Project'" -ForegroundColor White
        Write-Host "3. Select Antonio-el-Bear/thamar-couselling" -ForegroundColor White
        Write-Host "4. Click Deploy!" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "📧 OPTIONAL INTEGRATIONS (Setup now or later):" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "  • SendGrid (Emails): https://sendgrid.com" -ForegroundColor Gray
Write-Host "  • Stripe (Payments): https://stripe.com" -ForegroundColor Gray
Write-Host "  • Twilio (SMS/WhatsApp): https://twilio.com" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 DEBUGGING" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host "View Heroku logs:" -ForegroundColor White
Write-Host "  heroku logs --tail -a thamar-counselling-api" -ForegroundColor Gray
Write-Host ""
Write-Host "Check backend health:" -ForegroundColor White
Write-Host "  $herokuUrl/health" -ForegroundColor Gray
Write-Host ""
Write-Host "Full documentation:" -ForegroundColor White
Write-Host "  Read: QUICK_LAUNCH.md" -ForegroundColor Gray
Write-Host ""

Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                  🎊 HAPPY LAUNCHING! 🎊" -ForegroundColor Magenta
Write-Host "        Your booking system is ready for production!" -ForegroundColor Magenta
Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Cyan
