╔════════════════════════════════════════════════════════════════════════════╗
║              🚀 THAMAR COUNSELLING - MANUAL LAUNCH GUIDE                    ║
║                         Follow These 5 Easy Steps                           ║
╚════════════════════════════════════════════════════════════════════════════╝

⏱️ TIME NEEDED: 20-30 minutes total


═══════════════════════════════════════════════════════════════════════════════
🔧 STEP 1: INSTALL HEROKU CLI (5 minutes)
═══════════════════════════════════════════════════════════════════════════════

1. Download Heroku CLI from:
   https://devcenter.heroku.com/articles/heroku-cli

2. Choose "Windows" and download the installer

3. Run the installer and complete the installation

4. Close and reopen PowerShell

5. Verify installation by running:
   heroku --version

   Should show: heroku/7.x.x or higher


═══════════════════════════════════════════════════════════════════════════════
🔗 STEP 2: SETUP HEROKU BACKEND (10 minutes)
═══════════════════════════════════════════════════════════════════════════════

1. Open PowerShell and go to your project folder:
   cd "c:\Users\User\Documents\cloud uko\client_profile\thamar"

2. Login to Heroku:
   heroku login --interactive

   (This will open a browser window - log in with your Heroku account)

3. Create your Heroku app:
   heroku create thamar-counselling-api

   (If the name is taken, use: heroku create)

4. Get your MongoDB connection string:
   → Go to MongoDB Atlas: https://www.mongodb.com/cloud/atlas
   → Sign up (free) and create a cluster
   → Click "Connect" → "Connect your application"
   → Copy the connection string
   → Replace PASSWORD with your database password

5. Set environment variables in Heroku:
   
   heroku config:set MONGODB_URI="mongodb+srv://username:password@cluster.mongodb.net/thamar"
   
   heroku config:set JWT_SECRET="your-secret-key-here-make-it-random"
   
   heroku config:set FRONTEND_URL="https://your-site-url.netlify.app"

6. Deploy your backend:
   git push heroku main

   (Wait for deployment to complete - ~2 minutes)

7. Check if backend is live:
   heroku open

   You should see your API homepage


═══════════════════════════════════════════════════════════════════════════════
✏️ STEP 3: UPDATE FRONTEND (2 minutes)
═══════════════════════════════════════════════════════════════════════════════

1. Open thamar-counselling.html in a text editor

2. Find this line (around line 1050):
   const API_BASE_URL = 'http://localhost:5000/api';

3. Replace with your Heroku app name:
   const API_BASE_URL = 'https://thamar-counselling-api.herokuapp.com/api';

   (If you used a different app name, replace accordingly)

4. Save the file (Ctrl+S)

5. Commit to GitHub:
   git add thamar-counselling.html
   git commit -m "Update API URL for production"
   git push origin main


═══════════════════════════════════════════════════════════════════════════════
🌐 STEP 4: DEPLOY FRONTEND (5 minutes)
═══════════════════════════════════════════════════════════════════════════════

Choose ONE option below:

┌─ OPTION A: GitHub Pages (Easiest, Free) ──────────────────────────┐
│                                                                   │
│ 1. Go to your GitHub repo:                                       │
│    https://github.com/Antonio-el-Bear/thamar-couselling         │
│                                                                   │
│ 2. Click Settings (top right)                                    │
│                                                                   │
│ 3. Scroll down to "GitHub Pages"                                 │
│                                                                   │
│ 4. Under "Source", select: main branch                           │
│                                                                   │
│ 5. Click Save                                                    │
│                                                                   │
│ 6. Wait 1-2 minutes                                              │
│                                                                   │
│ 7. Your site is at:                                              │
│    https://antonio-el-bear.github.io/thamar-couselling          │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ OPTION B: Netlify (Recommended, Very Easy) ──────────────────────┐
│                                                                   │
│ 1. Go to: https://app.netlify.com                                │
│                                                                   │
│ 2. Sign up with your GitHub account                              │
│                                                                   │
│ 3. Click "New site from Git"                                     │
│                                                                   │
│ 4. Select GitHub and authorize                                   │
│                                                                   │
│ 5. Choose repo: Antonio-el-Bear/thamar-couselling               │
│                                                                   │
│ 6. Branch: main                                                  │
│                                                                   │
│ 7. Click "Deploy site"                                           │
│                                                                   │
│ 8. Wait 2-3 minutes                                              │
│                                                                   │
│ 9. Your site URL will appear (like: xxx.netlify.app)            │
│                                                                   │
│ 10. UPDATE your Heroku config:                                   │
│     heroku config:set FRONTEND_URL="https://xxx.netlify.app"    │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ OPTION C: Vercel (Also Great) ───────────────────────────────────┐
│                                                                   │
│ 1. Go to: https://vercel.com                                     │
│                                                                   │
│ 2. Sign up with GitHub                                           │
│                                                                   │
│ 3. Click "New Project"                                           │
│                                                                   │
│ 4. Import: Antonio-el-Bear/thamar-couselling                    │
│                                                                   │
│ 5. Click "Deploy"                                                │
│                                                                   │
│ 6. Wait 2-3 minutes                                              │
│                                                                   │
│ 7. Your site URL will appear (like: xxx.vercel.app)             │
│                                                                   │
│ 8. UPDATE your Heroku config:                                    │
│    heroku config:set FRONTEND_URL="https://xxx.vercel.app"      │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
✅ STEP 5: TEST EVERYTHING (5 minutes)
═══════════════════════════════════════════════════════════════════════════════

1. Check backend is working:
   
   Open in browser:
   https://thamar-counselling-api.herokuapp.com/health
   
   You should see: {"status":"ok"}

2. Open your frontend website:
   
   Use the URL from your chosen platform above
   (GitHub Pages, Netlify, or Vercel)

3. Click the "🚀 Launch Site" button

4. Try booking a consultation:
   - Select a service
   - Pick a date and time
   - Enter your email and name
   - Click "Confirm Booking"
   - You should see a success message

5. If something doesn't work:
   
   a) Check browser console (F12)
   b) Check Heroku logs:
      heroku logs --tail -a thamar-counselling-api
   c) Make sure API URL is correct in HTML file


═══════════════════════════════════════════════════════════════════════════════
🎉 YOU'RE DONE!
═══════════════════════════════════════════════════════════════════════════════

Your Thamar Counselling booking site is now LIVE! 🚀

What you can do now:
  ✅ Accept real bookings from clients
  ✅ View booking requests
  ✅ Send emails to clients (if SendGrid is configured)
  ✅ Process payments (if Stripe is configured)
  ✅ Send SMS/WhatsApp (if Twilio is configured)


═══════════════════════════════════════════════════════════════════════════════
📋 ADD-ONS (Optional but Recommended)
═══════════════════════════════════════════════════════════════════════════════

After your site is live, you can add:

1. EMAIL NOTIFICATIONS (SendGrid)
   - Clients get confirmation emails
   - You get notified of new bookings
   - Takes 5 minutes to setup

2. PAYMENT PROCESSING (Stripe)
   - Accept credit card payments
   - Process deposits or full payments
   - Takes 5 minutes to test

3. SMS/WHATSAPP (Twilio)
   - Send text message reminders
   - WhatsApp booking confirmations
   - Takes 5 minutes to setup

See: SERVICE_CONFIGURATION.md for details on each


═══════════════════════════════════════════════════════════════════════════════
🐛 TROUBLESHOOTING
═══════════════════════════════════════════════════════════════════════════════

Problem: "Cannot connect to API"
Solution: 
  1. Check API URL is correct in HTML file
  2. Make sure it says: https://thamar-counselling-api.herokuapp.com/api
  3. Test in browser: https://thamar-counselling-api.herokuapp.com/health

Problem: "Heroku app creation failed"
Solution:
  1. The app name might already exist
  2. Run: heroku create [any-unique-name-here]
  3. Then update the API URL in your HTML file

Problem: "Bookings aren't saving"
Solution:
  1. Check MongoDB is configured correctly
  2. Run: heroku config -a thamar-counselling-api
  3. Verify MONGODB_URI is set
  4. Check MongoDB Atlas has network access enabled

Problem: "Frontend is blank"
Solution:
  1. Press F12 to open browser console
  2. Look for red error messages
  3. Usually means API_BASE_URL is wrong in HTML

Problem: "Still having issues?"
Solution:
  1. Read: QUICK_LAUNCH.md (this file)
  2. Read: SETUP_GUIDES.md (detailed instructions)
  3. Read: README_COMPLETE.md (system architecture)


═══════════════════════════════════════════════════════════════════════════════
📞 QUICK COMMANDS REFERENCE
═══════════════════════════════════════════════════════════════════════════════

Download Heroku CLI:
  https://devcenter.heroku.com/articles/heroku-cli

Check if Heroku is installed:
  heroku --version

Login to Heroku:
  heroku login --interactive

Create Heroku app:
  heroku create thamar-counselling-api

View environment variables:
  heroku config -a thamar-counselling-api

Set environment variable:
  heroku config:set MONGODB_URI="mongodb+srv://..." -a thamar-counselling-api

Deploy (after git push):
  git push heroku main

View live URL:
  heroku open -a thamar-counselling-api

View logs:
  heroku logs --tail -a thamar-counselling-api

Restart app:
  heroku restart -a thamar-counselling-api

Destroy app (careful!):
  heroku apps:destroy -a thamar-counselling-api


═══════════════════════════════════════════════════════════════════════════════

Need MongoDB Atlas free tier?
  Go to: https://www.mongodb.com/cloud/atlas
  Click: "Start Free"
  Create free M0 cluster (~5 minutes)
  Get connection string and use above

Need Heroku account?
  Go to: https://www.heroku.com
  Click: "Sign up"
  Free tier includes 1000 dyno hours per month

═══════════════════════════════════════════════════════════════════════════════
                    Follow the 5 steps above to launch!
═══════════════════════════════════════════════════════════════════════════════
