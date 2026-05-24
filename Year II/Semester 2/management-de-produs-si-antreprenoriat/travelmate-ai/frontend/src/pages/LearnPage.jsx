import { Link } from "react-router-dom";
import {
  ArrowLeft,
  Bot,
  Code,
  Database,
  Globe,
  Layers,
  Plane,
  Server,
  Sparkles,
} from "lucide-react";

export default function LearnPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-sky-50 via-white to-cyan-50 text-slate-900">
      <div className="mx-auto max-w-6xl px-6 py-10">
        <Link to="/" className="inline-flex items-center gap-2 font-bold text-blue-600 hover:text-blue-800">
          <ArrowLeft size={18} />
          Back to landing page
        </Link>

        <div className="mt-10 rounded-[2rem] bg-white p-10 shadow-xl shadow-blue-100">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full bg-blue-50 px-4 py-2 text-sm font-bold text-blue-700">
            <Sparkles size={16} />
            Technical project overview
          </div>

          <h1 className="text-5xl font-extrabold">
            How TravelMate AI was built
          </h1>

          <p className="mt-5 max-w-3xl text-lg leading-8 text-slate-600">
            TravelMate AI is an MVP web application based on a multi-agent AI
            architecture. The project combines a React frontend, a FastAPI backend,
            shared Pydantic schemas and AI agents for travel search and itinerary planning.
          </p>
        </div>

        <div className="mt-8 grid gap-6 md:grid-cols-2">
          <TechCard icon={<Code />} title="Frontend" text="React, Vite, Tailwind CSS, React Router and Lucide icons. The frontend includes a landing page, preference form, offer cards, optional selection and itinerary rendering." />
          <TechCard icon={<Server />} title="Backend" text="FastAPI exposes REST endpoints used by the frontend: health check, search, plan and plan-from-search." />
          <TechCard icon={<Bot />} title="Agent 1: Search & Compare" text="The first agent searches flights, accommodation and activities, then returns structured options to the frontend and planner." />
          <TechCard icon={<Plane />} title="Agent 2: Itinerary Planner" text="The second agent receives the search results and builds a day-by-day itinerary optimized for budget, logistics and travel style." />
          <TechCard icon={<Database />} title="Shared schemas" text="Pydantic models define the contract between frontend, backend and agents, including UserPreferences, Agent1Output and Itinerary." />
          <TechCard icon={<Globe />} title="External services" text="The MVP uses OpenAI for LLM-based planning, Travelpayouts for flight data and OpenStreetMap/Overpass for accommodation data." />
        </div>

        <div className="mt-8 rounded-[2rem] bg-gradient-to-r from-blue-600 to-cyan-500 p-8 text-white">
          <div className="flex items-start gap-4">
            <Layers size={38} />
            <div>
              <h2 className="text-3xl font-bold">MVP value</h2>
              <p className="mt-3 max-w-3xl text-blue-50">
                The product demonstrates both business and technical feasibility:
                it has a clear startup idea, a working MVP, a multi-agent AI flow,
                frontend interaction, cost estimation potential and monetization paths.
              </p>
            </div>
          </div>
        </div>

        <div className="mt-8 flex gap-4">
          <Link to="/planner" className="rounded-2xl bg-blue-600 px-6 py-3 font-bold text-white hover:bg-blue-700">
            Open planner
          </Link>
          <a href="/files/documentation.docx" download className="rounded-2xl border border-slate-200 bg-white px-6 py-3 font-bold text-slate-700 hover:bg-slate-50">
            Download documentation
          </a>
          <a href="https://docs.google.com/presentation/d/1ORC7vxH0xuOYTCjwobiQ1ty2m6fb6IfQnzD7_pbDlug/edit?usp=sharing" target="_blank" rel="noreferrer" className="rounded-2xl border border-slate-200 bg-white px-6 py-3 font-bold text-slate-700 hover:bg-slate-50">
            View pitch
          </a>
        </div>
      </div>
    </div>
  );
}

function TechCard({ icon, title, text }) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-100">
      <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-600">
        {icon}
      </div>
      <h3 className="text-xl font-bold">{title}</h3>
      <p className="mt-3 leading-7 text-slate-600">{text}</p>
    </div>
  );
}