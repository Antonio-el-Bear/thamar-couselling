# 🔧 Service Configuration Guides

## 💳 Stripe Configuration

### Step 1: Create Stripe Account
1. Go to https://stripe.com
2. Click "Sign Up"
3. Fill in business details
4. Verify email

### Step 2: Get API Keys
1. Dashboard → Developers → API Keys
2. You'll see two keys:
   - **Publishable Key** (starts with `pk_`)
   - **Secret Key** (starts with `sk_`)

**For Development (Testing):**
```
Publishable: pk_test_xxxxxxxxxxxxx
Secret: sk_test_xxxxxxxxxxxxx

Test Card: 4242 4242 4242 4242
Expiry: Any future date (e.g., 12/25)
CVC: Any 3 digits (e.g., 123)
```

**For Production (Live):**
```
Publishable: pk_live_xxxxxxxxxxxxx
Secret: sk_live_xxxxxxxxxxxxx
```

### Step 3: Setup Webhook
1. Developers → Webhooks
2. Click "Add Endpoint"
3. Endpoint URL: `https://your-backend.herokuapp.com/api/payments/webhook`
4. Select Events:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.refunded`
5. Click "Add Endpoint"
6. Copy the `Webhook Signing Secret` (starts with `whsec_`)

### Step 4: Add to Environment
```bash
heroku config:set STRIPE_PUBLIC_KEY="pk_test_xxxxx"
heroku config:set STRIPE_SECRET_KEY="sk_test_xxxxx"
heroku config:set STRIPE_WEBHOOK_SECRET="whsec_xxxxx"
```

### Testing Payments
```bash
# Use test card 4242 4242 4242 4242
# Payment should show in Stripe Dashboard
```

---

## 📧 SendGrid Configuration

### Step 1: Create SendGrid Account
1. Go to https://sendgrid.com
2. Sign up for free account
3. Verify email

### Step 2: Create API Key
1. Settings → API Keys
2. Click "Create API Key"
3. Name: `thamar_production`
4. Select: **Full Access**
5. Copy the key (you can only see it once!)

### Step 3: Setup Sender Authentication
1. Settings → Sender Authentication
2. Click "Create" (Single Sender or Domain)
3. For Single Sender:
   - Email: `bookings@thamarcounselling.com`
   - Name: `Thamar Counselling`
   - Reply to: Your email
4. Click "Create"
5. Verify in your email

### Step 4: Verify Domain (Recommended)
1. Settings → Sender Authentication
2. Click "Domain Authentication"
3. Enter your domain: `thamarcounselling.com`
4. Add DNS records (CNAME records provided)
5. Wait for verification

### Step 5: Add to Environment
```bash
heroku config:set SENDGRID_API_KEY="SG.xxxxxxxxxxxxx"
heroku config:set EMAIL_FROM_ADDRESS="bookings@thamarcounselling.com"
```

### Test Email Sending
```javascript
// In backend routes/contact.js
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

const msg = {
  to: 'your-email@gmail.com',
  from: process.env.EMAIL_FROM_ADDRESS,
  subject: 'Test Email',
  html: '<strong>Test email from Thamar!</strong>'
};

sgMail.send(msg);
```

### Email Templates
Create templates in SendGrid Dashboard → Marketing → Email Templates

```html
<!-- Booking Confirmation Template -->
<h1>Hi {{clientName}}</h1>
<p>Your booking has been confirmed!</p>
<p><strong>Date:</strong> {{bookingDate}}</p>
<p><strong>Time:</strong> {{startTime}}</p>
<p><strong>Service:</strong> {{serviceType}}</p>
<p>For any changes, reply to this email.</p>
```

---

## 📱 Twilio Configuration (SMS/WhatsApp)

### Step 1: Create Twilio Account
1. Go to https://www.twilio.com
2. Sign up for free account
3. Verify phone number (you'll receive SMS)

### Step 2: Get Credentials
1. Console → Account
2. Copy:
   - **Account SID** (starts with `AC`)
   - **Auth Token**

### Step 3: Get Phone Numbers
**For SMS:**
1. Phone Numbers → Buy a Number
2. Search for number (choose country)
3. Capabilities: SMS
4. Purchase

**For WhatsApp:**
1. Messaging → Try it Out → WhatsApp
2. Follow setup wizard
3. Get WhatsApp number

### Step 4: Setup Webhooks
For incoming SMS/WhatsApp messages:
1. Phone Numbers → Manage Numbers
2. Select number
3. Configure → Incoming Messages
4. Webhook URL: `https://your-backend.herokuapp.com/api/messages/webhook`

### Step 5: Add to Environment
```bash
heroku config:set TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxx"
heroku config:set TWILIO_AUTH_TOKEN="your_auth_token_here"
heroku config:set TWILIO_PHONE_NUMBER="+1234567890"
```

### Send Test SMS
```javascript
const twilio = require('twilio');
const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

client.messages.create({
  body: 'Hello from Thamar Counselling!',
  from: process.env.TWILIO_PHONE_NUMBER,
  to: '+1234567890'
});
```

### Send WhatsApp Message
```javascript
client.messages.create({
  body: 'Hello! Your booking confirmed for tomorrow at 10am',
  from: 'whatsapp:+14155552671', // Twilio WhatsApp number
  to: 'whatsapp:+1234567890'
});
```

---

## 📊 MongoDB Atlas Configuration

### Step 1: Create Account
1. Go to https://www.mongodb.com/cloud/atlas
2. Sign up with email
3. Verify email

### Step 2: Create Cluster
1. Click "Build a cluster"
2. Choose Free tier (M0)
3. Select region: **Europe (Frankfurt)**
4. Click "Create Cluster"
5. Wait 5-10 minutes

### Step 3: Network Access
1. Security → Network Access
2. "Add IP Address"
3. For testing: "Allow Access from Anywhere"
4. For production: Add specific IPs
5. Confirm

### Step 4: Database User
1. Security → Database Access
2. "Add New Database User"
3. Username: `thamar_user`
4. Password: Generate strong one (copy it!)
5. Role: "Read and write to any database"
6. Create User

### Step 5: Get Connection String
1. Clusters → "Connect"
2. "Connect your application"
3. Copy MongoDB URI:
```
mongodb+srv://thamar_user:PASSWORD@cluster0.xxxxx.mongodb.net/thamar_db?retryWrites=true&w=majority
```

**Replace PASSWORD with your actual password!**

### Step 6: Add to Backend
```bash
heroku config:set MONGODB_URI="mongodb+srv://thamar_user:PASSWORD@cluster0.xxxxx.mongodb.net/thamar_db?retryWrites=true&w=majority"
```

### Backup Strategy
1. Clusters → Backups
2. Enable automatic backups
3. Set backup window: 2:00 AM - 6:00 AM UTC
4. Retention: 30 days

### Monitoring
1. Metrics → Database Metrics
2. Monitor:
   - Operation count
   - Storage size
   - Network I/O
   - Query performance

---

## 🔐 Environment Variables Checklist

```bash
# Core
NODE_ENV=production
PORT=5000

# Database
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/db

# JWT
JWT_SECRET=your_super_secret_key_min_32_chars_here
JWT_EXPIRY=7d

# API
CORS_ORIGIN=https://yourdomain.com,http://localhost:3000
FRONTEND_URL=https://yourdomain.com

# Therapist Info
THERAPIST_EMAIL=thamar@counselling.com
THERAPIST_PHONE=0659745590

# Operating Hours
OPERATING_HOURS_START=09:00
OPERATING_HOURS_END=18:00
LUNCH_START=12:00
LUNCH_END=13:00
SESSION_DURATION=50
BUFFER_BETWEEN_SESSIONS=10

# Email (SendGrid)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxx
EMAIL_FROM_ADDRESS=bookings@thamarcounselling.com

# Payment (Stripe)
STRIPE_PUBLIC_KEY=pk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx

# SMS (Twilio - Optional)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

---

## ✅ Verification Checklist

### Stripe
- [ ] Account created and verified
- [ ] API keys copied
- [ ] Webhook configured
- [ ] Test payment successful
- [ ] Keys added to Heroku

### SendGrid
- [ ] Account created and verified
- [ ] API key created
- [ ] Sender email verified
- [ ] Domain authenticated (optional but recommended)
- [ ] Test email sent
- [ ] Key added to Heroku

### Twilio (Optional)
- [ ] Account created
- [ ] Phone number purchased
- [ ] Credentials copied
- [ ] Webhook configured
- [ ] Test message sent
- [ ] Credentials added to Heroku

### MongoDB
- [ ] Cluster created
- [ ] User created
- [ ] Connection string copied
- [ ] Network access configured
- [ ] Connection tested
- [ ] URI added to Heroku

### Backend
- [ ] All env variables set
- [ ] Health endpoint working
- [ ] API endpoints responding
- [ ] Database connected
- [ ] Emails sending
- [ ] Payments ready

---

## 🚨 Troubleshooting

### "Unauthorized" from Stripe
- Check API key is correct
- Verify key hasn't been revoked
- Test with test key first

### "Invalid API Key" from SendGrid
- Regenerate API key
- Check for typos
- Key might be expired

### "Network unreachable" for MongoDB
- Check IP whitelist in MongoDB Atlas
- Add your Heroku IP
- Verify connection string

### "CORS error" in browser
- Update CORS_ORIGIN with correct domain
- Restart backend: `heroku restart -a thamar-counselling-api`

---

**All services configured? You're ready to go live! 🚀**
