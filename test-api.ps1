# API Testing Script for Thamar Counselling Backend
# Use this to test all API endpoints

Write-Host "🧪 Thamar Counselling API Testing Suite" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$apiUrl = Read-Host "Enter API URL (e.g., https://thamar-counselling-api.herokuapp.com/api)"

# Trim trailing slash if present
$apiUrl = $apiUrl.TrimEnd('/')

Write-Host ""
Write-Host "🔍 Running API Tests..." -ForegroundColor Green
Write-Host ""

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$($apiUrl.Replace('/api', ''))/health" -ErrorAction Stop
    Write-Host "✅ Health Check Passed" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Health Check Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Register New User
Write-Host "Test 2: Register New User" -ForegroundColor Yellow
$testEmail = "test_$(Get-Random)@example.com"
$registerBody = @{
    email = $testEmail
    password = "TestPassword123!"
    name = "Test User"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/auth/register" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $registerBody `
        -ErrorAction Stop
    
    $userObject = $response.Content | ConvertFrom-Json
    $userId = $userObject.user.id
    Write-Host "✅ Registration Successful" -ForegroundColor Green
    Write-Host "User ID: $userId" -ForegroundColor Cyan
    Write-Host "Email: $testEmail" -ForegroundColor Cyan
}
catch {
    if ($_.Exception.Response.StatusCode -eq "Conflict") {
        Write-Host "⚠️  User already exists (this is okay for testing)" -ForegroundColor Yellow
    }
    else {
        Write-Host "❌ Registration Failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 3: Login
Write-Host "Test 3: Login" -ForegroundColor Yellow
$loginBody = @{
    email = $testEmail
    password = "TestPassword123!"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/auth/login" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $loginBody `
        -ErrorAction Stop
    
    $loginObject = $response.Content | ConvertFrom-Json
    $token = $loginObject.token
    
    Write-Host "✅ Login Successful" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Login Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Note: Make sure user exists. Try registration first." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test 4: Get User Profile
Write-Host "Test 4: Get User Profile" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/users/profile" `
        -Method GET `
        -Headers @{"Authorization" = "Bearer $token"} `
        -ErrorAction Stop
    
    $profileObject = $response.Content | ConvertFrom-Json
    Write-Host "✅ Profile Retrieved" -ForegroundColor Green
    Write-Host "Name: $($profileObject.name)" -ForegroundColor Cyan
    Write-Host "Email: $($profileObject.email)" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Profile Retrieval Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Get Available Slots
Write-Host "Test 5: Get Available Slots" -ForegroundColor Yellow
$bookingDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/availability/slots/$bookingDate/individual-session" `
        -Method GET `
        -Headers @{"Authorization" = "Bearer $token"} `
        -ErrorAction Stop
    
    $slotsObject = $response.Content | ConvertFrom-Json
    Write-Host "✅ Available Slots Retrieved" -ForegroundColor Green
    Write-Host "Date: $bookingDate" -ForegroundColor Cyan
    Write-Host "Number of slots: $($slotsObject.slots.Count)" -ForegroundColor Cyan
    
    if ($slotsObject.slots.Count -gt 0) {
        Write-Host "First slot: $($slotsObject.slots[0])" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "❌ Slots Retrieval Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Create Booking
Write-Host "Test 6: Create Booking" -ForegroundColor Yellow
$bookingBody = @{
    serviceType = "individual-session"
    clientType = "new"
    bookingDate = $bookingDate
    startTime = "10:00"
    clientEmail = "client_$(Get-Random)@example.com"
    clientName = "Test Client"
    notes = "Test booking from API test"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/bookings" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $token"
        } `
        -Body $bookingBody `
        -ErrorAction Stop
    
    $bookingObject = $response.Content | ConvertFrom-Json
    $bookingId = $bookingObject._id
    
    Write-Host "✅ Booking Created Successfully" -ForegroundColor Green
    Write-Host "Booking ID: $bookingId" -ForegroundColor Cyan
    Write-Host "Service: $($bookingObject.serviceType)" -ForegroundColor Cyan
    Write-Host "Date: $($bookingObject.bookingDate)" -ForegroundColor Cyan
    Write-Host "Time: $($bookingObject.startTime)" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Booking Creation Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 7: Get Bookings
Write-Host "Test 7: Get User Bookings" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/bookings" `
        -Method GET `
        -Headers @{"Authorization" = "Bearer $token"} `
        -ErrorAction Stop
    
    $bookingsObject = $response.Content | ConvertFrom-Json
    Write-Host "✅ Bookings Retrieved" -ForegroundColor Green
    Write-Host "Total bookings: $($bookingsObject.bookings.Count)" -ForegroundColor Cyan
    
    if ($bookingsObject.bookings.Count -gt 0) {
        Write-Host "Latest booking:" -ForegroundColor Cyan
        Write-Host "  ID: $($bookingsObject.bookings[0]._id)" -ForegroundColor White
        Write-Host "  Status: $($bookingsObject.bookings[0].status)" -ForegroundColor White
    }
}
catch {
    Write-Host "❌ Bookings Retrieval Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 8: Contact Form
Write-Host "Test 8: Contact Form Submission" -ForegroundColor Yellow
$contactBody = @{
    name = "Test Contact"
    email = "contact_$(Get-Random)@example.com"
    phone = "1234567890"
    message = "This is a test message from API testing script"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/contact" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $contactBody `
        -ErrorAction Stop
    
    Write-Host "✅ Contact Form Submitted" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Contact Form Submission Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "=========================================" -ForegroundColor Green
Write-Host "✅ API Testing Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "- ✅ Health check: Verify backend is running" -ForegroundColor White
Write-Host "- ✅ Registration: Create test user accounts" -ForegroundColor White
Write-Host "- ✅ Login: Authenticate and get JWT token" -ForegroundColor White
Write-Host "- ✅ Profile: Retrieve user information" -ForegroundColor White
Write-Host "- ✅ Availability: Find available time slots" -ForegroundColor White
Write-Host "- ✅ Bookings: Create and retrieve appointments" -ForegroundColor White
Write-Host "- ✅ Contact: Submit contact form" -ForegroundColor White
Write-Host ""
Write-Host "If all tests passed, your backend is ready for production! 🚀" -ForegroundColor Green
