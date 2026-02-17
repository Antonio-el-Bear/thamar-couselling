# Complete Setup & Deployment Guide

**Status:** Step-by-step instructions for production launch  
**Estimated Time:** 60-90 minutes  
**Last Updated:** February 17, 2026

---

## 📍 STEP 1: MongoDB Atlas Setup (5-10 minutes)

### Create MongoDB Atlas Account
1. Go to https://www.mongodb.com/cloud/atlas
2. Click "Sign Up"
3. Use your email: `thamar@counselling.com` (or your email)
4. Verify email

### Create Production Cluster
1. Click "Create" → "Build a cluster"
2. Select **M0 (Free tier)** for testing, or **M2** for production
3. Choose region: **Europe (Frankfurt)** recommended
4. Click "Create Cluster"
5. Wait 5-10 minutes for cluster to initialize

### Configure Network Access
1. Go to Security → Network Access
2. Click "Add IP Address"
3. Click "Allow Access from Anywhere" (for development)
   - ⚠️ For production: Add specific IPs only
4. Click "Confirm"

### Create Database User
1. Go to Security → Database Access
2. Click "Add New Database User"
3. Username: `thamar_user` (or your preference)
4. Password: Generate strong password (save it!)
5. Role: "Read and write to any database"
6. Click "Create User"

### Get Connection String
1. Go to Clusters → Connect
2. Click "Connect your application"
3. Copy the connection string:
   ```
   mongodb+srv://thamar_user:<password>@cluster0.xxxxx.mongodb.net/thamar_db?retryWrites=true&w=majority
   ```
4. ✅ **Save this - you'll need it for Step 2**

---

## 🚀 STEP 2: Deploy Backend to Heroku (10-15 minutes)

### Install Heroku CLI
**Windows:**
```bash
# Download from https://devcenter.heroku.com/articles/heroku-command-line
# Or use Chocolatey:
choco install heroku-cli
```

Verify installation:
```bash
heroku --version
```

### Login to Heroku
```bash
heroku login
```
Opens browser - login with your Heroku account (create one if needed)

### Deploy Application

Navigate to your project:
```bash
cd "c:\Users\User\Documents\cloud uko\client_profile\thamar"
```

Create Heroku app:
```bash
heroku create thamar-counselling-api
```

Add MongoDB (first time setup):
```bash
heroku addons:create mongolab:sandbox
```
OR if using external MongoDB Atlas:

Set environment variables:
```bash
heroku config:set MONGODB_URI="mongodb+srv://thamar_user:PASSWORD@cluster0.xxxxx.mongodb.net/thamar_db?retryWrites=true&w=majority"

heroku config:set JWT_SECRET="your_super_secret_jwt_key_here_min_32_chars"

heroku config:set JWT_EXPIRY="7d"

heroku config:set NODE_ENV="production"

heroku config:set CORS_ORIGIN="https://yourdomain.com,http://localhost:3000"

heroku config:set THERAPIST_EMAIL="thamar@counselling.com"

heroku config:set THERAPIST_PHONE="0659745590"

heroku config:set OPERATING_HOURS_START="09:00"

heroku config:set OPERATING_HOURS_END="18:00"

heroku config:set LUNCH_START="12:00"

heroku config:set LUNCH_END="13:00"

heroku config:set SESSION_DURATION="50"

heroku config:set BUFFER_BETWEEN_SESSIONS="10"

heroku config:set EMAIL_SERVICE="sendgrid"

heroku config:set SENDGRID_API_KEY="SG.xxxxxxxxxxxxx"

heroku config:set STRIPE_SECRET_KEY="sk_test_xxxxx"

heroku config:set STRIPE_PUBLIC_KEY="pk_test_xxxxx"

heroku config:set TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxx"

heroku config:set TWILIO_AUTH_TOKEN="your_auth_token"

heroku config:set TWILIO_PHONE_NUMBER="+1234567890"
```

Deploy code:
```bash
git push heroku main
```

### Verify Deployment
```bash
heroku logs --tail
```

Test the API:
```
https://thamar-counselling-api.herokuapp.com/health
```

You should see: `{"status":"ok"}`

✅ **Backend is now live!**

---

## 🎨 STEP 3: Connect Frontend to Backend (5 minutes)

Update your HTML file with backend URL.

Find this section in `thamar-counselling.html`:
```javascript
// Change this constant to your actual backend URL
const API_BASE_URL = 'http://localhost:5000/api';
```

Replace with your Heroku URL:
```javascript
const API_BASE_URL = 'https://thamar-counselling-api.herokuapp.com/api';
```

### Update CORS in Backend
In your backend's `server.js`, update:
```javascript
const corsOptions = {
  origin: ['https://yourdomain.com', 'http://localhost:3000'],
  credentials: true
};
```

Deploy updated backend:
```bash
git add .
git commit -m "Update CORS for production frontend"
git push heroku main
```

---

## 🧪 STEP 4: Test API Endpoints (10 minutes)

### Test 1: Health Check
```bash
curl https://thamar-counselling-api.herokuapp.com/health
```

### Test 2: Register New User
```bash
curl -X POST https://thamar-counselling-api.herokuapp.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!",
    "name": "Test User"
  }'
```

### Test 3: Login
```bash
curl -X POST https://thamar-counselling-api.herokuapp.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!"
  }'
```

You'll get a response like:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

**Save the token!**

### Test 4: Get Available Slots
```bash
curl https://thamar-counselling-api.herokuapp.com/api/availability/slots/2026-02-18/individual-session \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Test 5: Create Booking
```bash
curl -X POST https://thamar-counselling-api.herokuapp.com/api/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "serviceType": "individual-session",
    "clientType": "new",
    "bookingDate": "2026-02-18",
    "startTime": "10:00",
    "clientEmail": "test@example.com",
    "clientName": "Test Client",
    "notes": "First session"
  }'
```

✅ **All endpoints working? Great! Moving to Step 5**

---

## 💳 STEP 5: Setup Stripe Payment (10 minutes)

### Get Stripe API Keys

1. Go to https://dashboard.stripe.com
2. Create account or login
3. Go to **Developers** → **API Keys**
4. Copy:
   - **Public Key** (starts with `pk_`)
   - **Secret Key** (starts with `sk_`)

### Add to Environment Variables

Backend:
```bash
heroku config:set STRIPE_PUBLIC_KEY="pk_live_xxxx"
heroku config:set STRIPE_SECRET_KEY="sk_live_xxxx"
```

Frontend (in HTML):
```html
<!-- Add this before booking modal script -->
<script src="https://js.stripe.com/v3/"></script>
<script>
  const stripe = Stripe('pk_live_xxxx');
</script>
```

### Test Payment
Use Stripe test card:
```
Card: 4242 4242 4242 4242
Expiry: 12/25
CVC: 123
```

### Webhook Setup (Important!)
1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add Endpoint"
3. Endpoint URL: `https://thamar-counselling-api.herokuapp.com/api/payments/webhook`
4. Events: `payment_intent.succeeded`, `payment_intent.payment_failed`
5. Copy Signing Secret
6. Add to Heroku:
   ```bash
   heroku config:set STRIPE_WEBHOOK_SECRET="whsec_xxx"
   ```

---

## 📧 STEP 6: Setup SendGrid Email (5 minutes)

### Create SendGrid Account
1. Go to https://sendgrid.com
2. Sign up for free account
3. Verify email

### Get API Key
1. Go to Settings → API Keys
2. Click "Create API Key"
3. Name it: `thamar_production`
4. Select **Full Access**
5. Copy the key

### Add to Environment Variables
```bash
heroku config:set SENDGRID_API_KEY="SG.xxxxxxxxxxxxx"
heroku config:set EMAIL_FROM_ADDRESS="bookings@thamarcounselling.com"
```

### Test Email Sending
In your backend `routes/contact.js`, add test endpoint:
```javascript
// Test email
router.post('/test-email', async (req, res) => {
  try {
    const msg = {
      to: 'your-email@gmail.com',
      from: 'bookings@thamarcounselling.com',
      subject: 'Test Email',
      html: '<strong>Backend is working!</strong>'
    };
    await sgMail.send(msg);
    res.json({ message: 'Email sent' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

Deploy and test:
```bash
curl -X POST https://thamar-counselling-api.herokuapp.com/api/contact/test-email
```

---

## 🔗 STEP 7: Connect Everything (5 minutes)

### Update Frontend HTML

Find the booking modal submit handler and update:
```javascript
document.getElementById('confirmBtn').addEventListener('click', async function() {
  const bookingData = {
    serviceType: document.getElementById('serviceType').value,
    clientType: document.getElementById('clientType').value,
    bookingDate: document.getElementById('bookingDate').value,
    startTime: document.getElementById('startTime').value,
    clientEmail: document.getElementById('clientEmail').value,
    clientName: document.getElementById('clientName').value,
    notes: document.getElementById('notes').value || ''
  };

  try {
    const response = await fetch(`${API_BASE_URL}/bookings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getToken()}`
      },
      body: JSON.stringify(bookingData)
    });

    if (!response.ok) throw new Error('Booking failed');
    
    const result = await response.json();
    alert('Booking confirmed! Confirmation sent to ' + bookingData.clientEmail);
    // Close modal and refresh
  } catch (error) {
    alert('Error: ' + error.message);
  }
});
```

### Add Token Management
```javascript
function getToken() {
  return localStorage.getItem('authToken');
}

function setToken(token) {
  localStorage.setItem('authToken', token);
}

function clearToken() {
  localStorage.removeItem('authToken');
}
```

### Add Login/Logout Buttons
```html
<div id="authContainer" style="position: absolute; top: 10px; right: 10px;">
  <button id="loginBtn" onclick="showLogin()" style="padding: 10px 20px;">Login</button>
  <button id="logoutBtn" onclick="logout()" style="padding: 10px 20px; display: none;">Logout</button>
</div>

<script>
function logout() {
  clearToken();
  document.getElementById('loginBtn').style.display = 'block';
  document.getElementById('logoutBtn').style.display = 'none';
  alert('Logged out');
}

function showLogin() {
  const email = prompt('Email:');
  const password = prompt('Password:');
  
  fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  })
  .then(r => r.json())
  .then(data => {
    setToken(data.token);
    document.getElementById('loginBtn').style.display = 'none';
    document.getElementById('logoutBtn').style.display = 'block';
    alert('Logged in!');
  })
  .catch(e => alert('Login failed: ' + e.message));
}
</script>
```

---

## ✅ STEP 8: Final Verification Checklist

### Backend
- [ ] Health endpoint responds
- [ ] Can register new user
- [ ] Can login user
- [ ] Can get available slots
- [ ] Can create booking
- [ ] Database queries working
- [ ] Email sending working
- [ ] Payment endpoint ready

### Frontend
- [ ] Loads without errors
- [ ] Can access booking modal
- [ ] Can login
- [ ] Can select services
- [ ] Can pick dates/times
- [ ] Can submit booking
- [ ] Receives confirmation

### Integration
- [ ] Frontend calls backend API
- [ ] Bookings save to database
- [ ] Emails send to clients
- [ ] Payment processing ready
- [ ] All data persists correctly

---

## 🚨 Troubleshooting

### "Cannot connect to API"
- Check Heroku app is running: `heroku ps -a thamar-counselling-api`
- Check logs: `heroku logs --tail -a thamar-counselling-api`
- Verify CORS settings
- Check frontend API URL is correct

### "MongoDB connection failed"
- Verify connection string is correct
- Check MongoDB Atlas IP whitelist
- Verify database user credentials
- Check MongoDB Atlas cluster is running

### "Email not sending"
- Verify SendGrid API key
- Check email address is verified in SendGrid
- Verify sender email matches SendGrid config
- Check spam folder

### "Payment not processing"
- Verify Stripe keys are correct
- Test with Stripe test card: 4242 4242 4242 4242
- Check Stripe webhook is configured
- Verify webhook secret matches

---

## 📊 Next Steps

1. **Go Live**: Point domain to frontend hosting
2. **Monitor**: Setup error tracking and monitoring
3. **Automate**: Setup automated backups
4. **Scale**: Monitor performance and scale as needed
5. **Improve**: Gather feedback and iterate

---

**Congratulations! Your booking system is now LIVE! 🎉**

For support: Check logs with `heroku logs --tail`
