# Project Tuttwiler - Mission Control Dashboard

## Step 1: Basic Layout Structure ✅

This is the initial implementation with hardcoded data. All components are in place and styled.

## Getting Started

### Install Dependencies
```bash
cd frontend
npm install
```

### Run Development Server
```bash
npm run dev
```

The dashboard will open at `http://localhost:3000`

## What's Included

- ✅ Complete Mission Control layout structure
- ✅ All required sections (Header, Alert Card, Impact Pill, etc.)
- ✅ Hardcoded dummy data (ready to replace with API calls)
- ✅ Basic styling matching prototype design
- ✅ Interactive elements (buttons, checkboxes, radio buttons)

## Next Steps

1. **Step 2:** Enhance styling (already partially done)
2. **Step 3:** Connect to API (replace hardcoded data)
3. **Step 4:** Add full interactivity (save decisions to database)

## File Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── MissionControl.jsx    # Main dashboard component
│   │   └── MissionControl.css    # Dashboard styles
│   ├── App.jsx                    # App wrapper
│   ├── App.css                    # App styles
│   ├── main.jsx                   # Entry point
│   └── index.css                  # Global styles
├── index.html                     # HTML template
├── package.json                   # Dependencies
├── vite.config.js                 # Vite configuration
└── README.md                      # This file
```

## Current Features

- Mission Control header with Quiet Mode toggle
- Alert title, timestamp, and affected function
- Impact pill (RED/YELLOW/GREEN) with description
- "Is This Us?" relevance checkbox
- AI Summary section
- Source & Confidence section
- Safe Action Playbook (numbered list)
- Decision buttons (GO/HOLD/ESCALATE)

All data is currently hardcoded in `MissionControl.jsx` and ready to be replaced with API calls in Step 3.

