# Project Tuttwiler - Mission Control Dashboard

## 🚀 Quick Start (One-Click Launch)

### **Double-Click This File:** `OPEN-DASHBOARD.bat`

This will:
1. ✅ Start the backend API server
2. ✅ Start the frontend dev server  
3. ✅ Open the dashboard in your browser automatically

**That's it!** Your dashboard will open at `http://localhost:3000`

---

## 📁 Project Structure

```
project-tuttwiler-proj-2/
├── backend/              # API server (Node.js/Express)
├── frontend/             # React dashboard
├── OPEN-DASHBOARD.bat    # ⭐ Double-click this to start everything
└── start-all.bat         # Alternative launcher
```

---

## 🎯 How to View the Dashboard

### **Method 1: Use the Launcher (Easiest)** ⭐
1. Double-click `OPEN-DASHBOARD.bat` in the project root folder
2. Wait 5-10 seconds for servers to start
3. Dashboard opens automatically in your browser

### **Method 2: Manual Start**
1. Start backend: `cd backend && node server.js`
2. Start frontend: `cd frontend && npm run dev`
3. Open browser: `http://localhost:3000`

---

## 📝 For Team Collaboration

**To share with teammates:**
1. Push code to GitHub (already done ✅)
2. Teammates should:
   - Clone the repository
   - Run `npm install` in both `backend/` and `frontend/` folders
   - Double-click `OPEN-DASHBOARD.bat` to launch

**Important:** Both servers must be running for the dashboard to work!

---

## 🔧 Setup (First Time Only)

If you haven't installed dependencies yet:

```bash
# Backend dependencies
cd backend
npm install

# Frontend dependencies  
cd ../frontend
npm install
```

---

## 📊 Features

- ✅ Mission Control dashboard with current alerts
- ✅ Alert history with decisions (GO/HOLD/ESCALATE)
- ✅ Impact level indicators (RED/YELLOW/GREEN)
- ✅ Safe action playbooks
- ✅ Source provenance tracking

---

## 🌐 URLs

- **Frontend Dashboard:** http://localhost:3000
- **Backend API:** http://localhost:3001
- **API Health Check:** http://localhost:3001/api/health

---

## ❓ Troubleshooting

**Dashboard shows "Loading..." forever:**
- Make sure backend is running on port 3001
- Check browser console (F12) for errors

**"Cannot connect" errors:**
- Verify both servers are running
- Try restarting both servers

**Port already in use:**
- Stop any other servers using ports 3000 or 3001
- Or change ports in `vite.config.js` (frontend) and `server.js` (backend)

---

## 📚 Documentation

- `backend/README.md` - API documentation
- `frontend/README.md` - Frontend setup
- `backend/SCHEMA_DOCUMENTATION.md` - Database schema

