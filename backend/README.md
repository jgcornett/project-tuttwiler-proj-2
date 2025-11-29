# Project Tuttwiler - Backend API

## Overview

This is the backend API server for Project Tuttwiler's Mission Control Dashboard. It provides REST endpoints to fetch alerts, record decisions, and manage notifications.

## Technology Stack

- **Node.js** with **Express.js** - Web server framework
- **SQLite3** - Database (file-based, no separate server needed)
- **CORS** - Cross-origin resource sharing for frontend

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Database Setup

Make sure you've created the database:

1. Open SQLiteStudio
2. Create `tuttwiler.db` in the `backend` folder
3. Run `schema.sql` to create tables
4. Run `seed-data.sql` to populate with test data

### 3. Start the API Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

The API will start on **http://localhost:3001**

### 4. Test the API

Open your browser or use curl:

```bash
# Health check
curl http://localhost:3001/api/health

# Get all alerts
curl http://localhost:3001/api/alerts

# Get top priority alert
curl http://localhost:3001/api/alerts/priority/top
```

## API Endpoints

### GET `/api/health`
Health check endpoint.

### GET `/api/alerts`
Get all alerts with optional filters (status, impact_level, limit).

### GET `/api/alerts/priority/top`
Get the top priority alert (single-card focus for Mission Control).

### GET `/api/alerts/:id`
Get a single alert with full details (including provenance and safe actions).

### POST `/api/decisions`
Record a GO/HOLD/ESCALATE decision.

### GET `/api/notifications`
Get user notifications.

## Database Schema

See `SCHEMA_DOCUMENTATION.md` for detailed schema documentation.

## Project Structure

```
backend/
├── server.js              # Main API server
├── database.js            # Database connection and helpers
├── schema.sql             # Database schema
├── seed-data.sql          # Test data
├── package.json           # Dependencies
└── README.md              # This file
```
