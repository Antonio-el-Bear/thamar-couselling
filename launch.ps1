# Thamar Counselling - Quick Auto Launch Script
# Run: .\launch.ps1

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "        THAMAR COUNSELLING - QUICK LAUNCH AUTOMATION" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "[STEP 1] Checking prerequisites..." -ForegroundColor Green

$hasGit = (git --version 2>$null)
$hasHeroku = (heroku --version 2>$null)
$hasNode = (node --version 2>$null)

if (-not $hasGit) {
    Write-Host "ERROR: Git not installed" -ForegroundColor Red
    exit 1
}
if (-not $hasHeroku) {
    Write-Host "ERROR: Heroku CLI not installed. Download from https://devcenter.heroku.com/articles/heroku-cli" -ForegroundColor Red
    exit 1
}
if (-not $hasNode) {
    Write-Host "ERROR: Node.js not installed" -ForegroundColor Red
    exit 1
}

Write-Host "OK: All prerequisites found" -ForegroundColor Green
Write-Host ""

# Check Heroku login
Write-Host "[STEP 2] Checking Heroku login..." -ForegroundColor Green
$herokuWhoami = (heroku auth:whoami 2>$null)
if (-not $herokuWhoami) {
    Write-Host "Opening Heroku login..."
    heroku login --interactive
}
Write-Host "OK: Logged in as $herokuWhoami" -ForegroundColor Green
Write-Host ""

# Get configuration
Write-Host "[STEP 3] Getting configuration..." -ForegroundColor Green
$mongoDbUri = Read-Host "Enter MongoDB Atlas connection string (or press Enter to skip)"
if (-not $mongoDbUri) {
    Write-Host "WARNING: MongoDB URI not provided. You'll need to add it manually later." -ForegroundColor Yellow
}

$jwtSecret = Read-Host "Enter JWT Secret (or press Enter to auto-generate)"
if (-not $jwtSecret) {
    $jwtSecret = [Convert]::ToBase64String([guid]::NewGuid().ToByteArray()).Substring(0, 32)
    Write-Host "Generated JWT Secret: $jwtSecret" -ForegroundColor Yellow
}

$frontendUrl = Read-Host "Enter your frontend URL (e.g., your-site.netlify.app)"
Write-Host ""

# Create Heroku app
Write-Host "[STEP 4] Setting up Heroku app..." -ForegroundColor Green
$appName = "thamar-counselling-api"

$appExists = (heroku apps:info $appName -a $appName 2>$null)
if (-not $appExists) {
    Write-Host "Creating Heroku app: $appName..."
    heroku create $appName
} else {
    Write-Host "App already exists: $appName" -ForegroundColor Yellow
}

# Set environment variables
Write-Host "Setting environment variables..."
if ($mongoDbUri) {
    heroku config:set MONGODB_URI="$mongoDbUri" -a $appName
}
heroku config:set JWT_SECRET="$jwtSecret" -a $appName
if ($frontendUrl) {
    heroku config:set FRONTEND_URL="https://$frontendUrl" -a $appName
}

Write-Host "OK: Heroku app configured" -ForegroundColor Green
Write-Host ""

# Deploy to Heroku
Write-Host "[STEP 5] Deploying backend to Heroku..." -ForegroundColor Green
git remote remove heroku 2>$null
git remote add heroku "https://git.heroku.com/$appName.git"
git push heroku main --force

Write-Host "OK: Backend deployed!" -ForegroundColor Green
Write-Host ""

# Update frontend
Write-Host "[STEP 6] Updating frontend API URL..." -ForegroundColor Green
$htmlFile = "thamar-counselling.html"
if (Test-Path $htmlFile) {
    $content = Get-Content $htmlFile -Raw
    $oldUrl = "const API_BASE_URL = 'http://localhost:5000/api'"
    $newUrl = "const API_BASE_URL = 'https://$appName.herokuapp.com/api'"
    
    if ($content -match [regex]::Escape($oldUrl)) {
        $content = $content -replace [regex]::Escape($oldUrl), $newUrl
        Set-Content $htmlFile $content -Encoding UTF8
        Write-Host "Updated API URL to: $newUrl" -ForegroundColor Green
    } else {
        Write-Host "API URL might already be configured" -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: $htmlFile not found!" -ForegroundColor Red
}

Write-Host ""

# Commit changes
Write-Host "[STEP 7] Pushing changes to GitHub..." -ForegroundColor Green
git add thamar-counselling.html
git commit -m "Auto-launch: Update backend API URL for production" 2>$null
git push origin main

Write-Host "OK: Changes pushed" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                    SUCCESS! DEPLOYMENT COMPLETE!" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$herokuUrl = "https://$appName.herokuapp.com"

Write-Host "BACKEND:" -ForegroundColor Green
Write-Host "  URL: $herokuUrl" -ForegroundColor Yellow
Write-Host "  Status: DEPLOYED" -ForegroundColor Green
Write-Host ""

Write-Host "FRONTEND:" -ForegroundColor Green
Write-Host "  Status: Ready to deploy to Netlify/Vercel/GitHub Pages" -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. Deploy frontend:" -ForegroundColor White
Write-Host "     GitHub: Go to Settings -> Pages -> Enable GitHub Pages" -ForegroundColor Gray
Write-Host "     Netlify: Visit app.netlify.com, connect your GitHub repo" -ForegroundColor Gray
Write-Host "     Vercel: Visit vercel.com, import your GitHub repo" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Test backend: $herokuUrl/health" -ForegroundColor White
Write-Host ""
Write-Host "  3. Full documentation: Read QUICK_LAUNCH.md" -ForegroundColor White
Write-Host ""

Write-Host "DEBUGGING:" -ForegroundColor Cyan
Write-Host "  View logs: heroku logs --tail -a $appName" -ForegroundColor Gray
Write-Host ""

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "                   Your site is ready to launch!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
