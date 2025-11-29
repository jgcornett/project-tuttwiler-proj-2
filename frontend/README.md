# Project Tuttwiler - Frontend Dashboard

## Quick Start

### Option 1: Double-Click to Start (Easiest) ⭐

1. **From the project root**, double-click: `start-all.bat`
   - This starts both backend and frontend automatically
   - Opens in separate windows
   - Dashboard opens at http://localhost:3000

### Option 2: Start Separately

**Start Backend:**
- Double-click: `backend/start-backend.bat`
- Or run: `cd backend && node server.js`

**Start Frontend:**
- Double-click: `frontend/start-frontend.bat`
- Or run: `cd frontend && npm run dev`

### Option 3: Manual Start

```bash
# Terminal 1 - Backend
cd backend
node server.js

# Terminal 2 - Frontend
cd frontend
npm run dev
```

## Viewing the Dashboard

**Open in browser:** http://localhost:3000

The `index.html` file is automatically served by the dev server at this URL.

## Important Notes

- **You cannot double-click `index.html` directly** - React apps need a development server to run
- **Both servers must be running:**
  - Backend on port 3001 (for API)
  - Frontend on port 3000 (for the dashboard)
- The `start-all.bat` script handles everything automatically

## Troubleshooting

**Dashboard shows "Loading..." forever:**
- Make sure backend API is running on port 3001
- Check browser console for errors (F12)

**"Cannot connect" errors:**
- Verify both servers are running
- Try restarting both servers
