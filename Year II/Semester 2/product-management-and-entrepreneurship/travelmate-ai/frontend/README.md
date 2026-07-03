# TravelMate AI — Frontend

React + Vite + Tailwind UI for the TravelMate AI planner. Talks to the
FastAPI backend (`backend/api.py`) via `src/api.js`.

## Stack

- React 18 + React Router 7
- Vite 7 (dev server + build)
- Tailwind CSS 3
- Axios for the API client
- `lucide-react` for icons

## Pages

- `src/pages/LandingPage.jsx` — marketing/landing page
- `src/pages/PlannerPage.jsx` — the actual planner UI (calls `/search` then `/plan-from-search`)
- `src/pages/LearnPage.jsx` — info / docs page

## Local dev

```bash
cd frontend
npm install
npm run dev          # http://localhost:5173
```

The API client reads `VITE_API_BASE_URL` (default `http://localhost:8000`).
To point at a non-local backend, create `frontend/.env.local`:

```
VITE_API_BASE_URL=https://your-backend.example.com
```

Make sure the backend is running (`uvicorn backend.api:app --reload` from
the repo root) before using the planner page.

## Build

```bash
npm run build        # outputs dist/
npm run preview      # serve the production build locally
```

## Deployment

Auto-deploys to Azure Static Web Apps via
`.github/workflows/azure-static-web-apps.yml` on every push to `main`. No
manual command needed — `git push` ships it.
