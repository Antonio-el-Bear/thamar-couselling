# 🚀 QUICK START - Deploy Thamar Counselling to Production

**Everything is now ready! Follow this quick-start to go live in 60 minutes.**

---

## ⚡ 5-Minute Quick Setup

### 1. Create MongoDB Atlas Database
```bash
# Go to: https://www.mongodb.com/cloud/atlas
# 1. Sign up → Create free cluster (M0)
# 2. Add network access (Allow from anywhere)
# 3. Create database user
# 4. Get connection string like:
mongodb+srv://user:password@cluster0.xxxxx.mongodb.net/thamar_db
```

### 2. Deploy Backend to Heroku (Choose one)

**Option A: Windows PowerShell**
```powershell
# Run this in PowerShell
cd "c:\Users\User\Documents\cloud uko\client_profile\thamar"
.\deploy-heroku.ps1
# Follow prompts to enter MongoDB URI, JWT secret, etc.
```

**Option B: Git Command**
```bash
heroku login
heroku create thamar-counselling-api
heroku config:set MONGODB_URI="mongodb+srv://user:password@cluster..."
heroku config:set JWT_SECRET="your_super_secret_key_here"
git push heroku main
```

### 3. Get Backend URL
```bash
# After deploy, you'll get:
https://thamar-counselling-api.herokuapp.com

# Test it:
https://thamar-counselling-api.herokuapp.com/health
# Should see: {"status":"ok"}
```

### 4. Update Frontend URL
Edit `thamar-counselling.html` at the top of the `<script>` tag:
```javascript
// Change THIS:
const API_BASE_URL = 'http://localhost:5000/api';

// To THIS:
const API_BASE_URL = 'https://thamar-counselling-api.herokuapp.com/api';
```

### 5. Commit & Push
```bash
git add .
git commit -m "Update API URL for production"
git push origin main
```

---

## 📋 What Each File Does

| File | Purpose | When to Use |
|------|---------|------------|
| **SETUP_GUIDES.md** | Step-by-step setup for all 8 deployment steps | First - read this! |
| **PRODUCTION_CHECKLIST.md** | Pre-launch verification checklist | Before going live |
| **SERVICE_CONFIGURATION.md** | Setup guides for Stripe, SendGrid, Twilio, MongoDB | Configuring services |
| **deploy-heroku.ps1** | Automated Heroku deployment (Windows) | One-click deploy |
| **deploy-heroku.sh** | Automated Heroku deployment (Linux/Mac) | One-click deploy |
| **test-api.ps1** | Test all API endpoints | Verify everything works |

---

## 🔧 Current Status

### ✅ Completed
- [x] Backend API (Node.js + Express + MongoDB)
- [x] Frontend booking system (HTML + JavaScript)
- [x] API integration in HTML
- [x] Contact form connected to backend
- [x] Authentication system (JWT)
- [x] Payment processing hooks (Stripe ready)
- [x] Email service configured (SendGrid)
- [x] SMS/WhatsApp ready (Twilio)

### ⏳ Next Steps (for you)
1. [ ] Create MongoDB Atlas cluster
2. [ ] Deploy backend to Heroku
3. [ ] Update API URL in frontend
4. [ ] Setup Stripe account (optional but recommended)
5. [ ] Setup SendGrid email (optional but recommended)
6. [ ] Test booking flow
7. [ ] Deploy frontend (Vercel/Netlify)
8. [ ] Setup custom domain + SSL

---

## 🎯 Testing Before Going Live

### Test 1: Backend Health
```bash
curl https://thamar-counselling-api.herokuapp.com/health
# Should return: {"status":"ok"}
```

### Test 2: Create a Test Booking
1. Open `thamar-counselling.html` in browser
2. Click "✦ Book" button
3. Select service → Select date → Select time → Confirm
4. Enter test email
5. Should see success message

### Test 3: Run Full Test Suite
```powershell
.\test-api.ps1
# When prompted, enter your backend URL:
# https://thamar-counselling-api.herokuapp.com/api
```

---

## 💡 Troubleshooting

### "Cannot connect to API"
- Check backend is deployed: `heroku ps -a thamar-counselling-api`
- Check logs: `heroku logs --tail -a thamar-counselling-api`
- Verify MongoDB connection string is correct
- Ensure frontend URL matches backend CORS settings

### "Booking fails"
- Backend should show error in logs
- Check database connection
- Verify JWT token is valid

### "Email not sending"
- Setup SendGrid first (optional but recommended)
- Verify SendGrid API key in environment variables
- Check logs for SendGrid errors

---

## 📱 Deployment Platforms Supported

✅ **Heroku** (Recommended - easiest)
✅ **Railway.app** (Good alternative)
✅ **DigitalOcean** (More control)
✅ **AWS Elastic Beanstalk** (Enterprise)
✅ **Docker** (Self-hosted)

See `SETUP_GUIDES.md` for detailed instructions for each platform.

---

## 🔐 Production Security

Before going live, ensure:
- [ ] `JWT_SECRET` is a strong random 32+ character string
- [ ] MongoDB user has minimal permissions
- [ ] HTTPS enabled (automatic on Heroku)
- [ ] CORS configured for your domain only
- [ ] Rate limiting enabled
- [ ] Error logs don't expose sensitive data

---

## 📊 Production Checklist

Copy this to your notes and check off as you complete each step:

```
INFRASTRUCTURE
□ MongoDB cluster created and running
□ Heroku app created and deployed
□ Health endpoint responding
□ Environment variables all set
□ Logging working

DATABASE
□ Connection tested from backend
□ Indexes created
□ Backups enabled
□ Network whitelist configured

AUTHENTICATION
□ JWT tokens working
□ Token refresh working
□ Password hashing verified
□ Login/registration tested

BOOKINGS
□ Can create booking
□ Available slots showing
□ Booking confirmation working
□ Time conflicts prevented

NOTIFICATIONS (Optional)
□ SendGrid configured (email)
□ Twilio ready (SMS/WhatsApp)
□ Test email sent
□ Test SMS sent

PAYMENTS (Optional)
□ Stripe account created
□ API keys configured
□ Webhook setup
□ Test payment processed

FRONTEND
□ API URL updated to production
□ Booking modal working
□ Contact form working
□ No console errors

TESTING
□ Health checks passing
□ API endpoints tested
□ Booking flow tested end-to-end
□ Error handling tested

MONITORING
□ Error tracking enabled
□ Logs accessible
□ Uptime monitoring set
□ Performance metrics visible

LAUNCH
□ All tests passing
□ Team trained on procedures
□ Rollback plan ready
□ Support process documented
```

---

## 🚀 Go-Live Commands (Copy & Paste)

### Step 1: Deploy Backend
```bash
# Windows PowerShell
cd "c:\Users\User\Documents\cloud uko\client_profile\thamar"
.\deploy-heroku.ps1

# (Follow the prompts)
```

### Step 2: Test Backend
```bash
curl https://thamar-counselling-api.herokuapp.com/health
```

### Step 3: Update Frontend
```bash
# Edit thamar-counselling.html - change API_BASE_URL to your backend URL
```

### Step 4: Commit & Push
```bash
git add .
git commit -m "Production deployment"
git push origin main
```

### Step 5: Deploy Frontend (Choose one)

**Vercel:**
```bash
npm i -g vercel
vercel --prod
```

**Netlify:**
```bash
npm i -g netlify-cli
netlify deploy --prod --dir=.
```

**GitHub Pages:**
```bash
# Push to gh-pages branch
git checkout -b gh-pages
git push origin gh-pages
```

---

## 📞 Support & Monitoring

### View Backend Logs
```bash
heroku logs --tail -a thamar-counselling-api
```

### Restart Backend
```bash
heroku restart -a thamar-counselling-api
```

### View Database
```bash
# MongoDB Atlas → Clusters → Browse Collections
```

### Check Deployment Status
```bash
heroku status
heroku ps -a thamar-counselling-api
```

---

## 📚 Full Documentation

For complete details, see:
- `SETUP_GUIDES.md` - Full step-by-step setup (60 pages)
- `PRODUCTION_CHECKLIST.md` - Pre-launch checklist
- `SERVICE_CONFIGURATION.md` - Service setup guides
- `backend/API_DOCUMENTATION.md` - API reference (GitHub repo)
- `backend/DEPLOYMENT_GUIDE.md` - Platform-specific deployment

---

## 🎉 You're Ready to Go!

Your Thamar Counselling booking system is **production-ready**:
- ✅ Professional frontend with responsive design
- ✅ Scalable Node.js backend
- ✅ Secure database with MongoDB
- ✅ Payment processing ready (Stripe)
- ✅ Email notifications ready (SendGrid)
- ✅ SMS/WhatsApp ready (Twilio)
- ✅ Multiple deployment options
- ✅ Complete documentation
- ✅ Testing procedures
- ✅ Security hardening

**Everything you need is in place. Let's get this live!** 🚀

---

**Questions?** Check `SETUP_GUIDES.md` Troubleshooting section or view backend logs with `heroku logs --tail`
