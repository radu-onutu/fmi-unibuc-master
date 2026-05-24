import { Link } from "react-router-dom";
import {
  ArrowRight,
  Bot,
  CalendarDays,
  CheckCircle,
  Clock,
  CreditCard,
  Download,
  FileText,
  Hotel,
  Map,
  MapPinned,
  Plane,
  Presentation,
  ShieldCheck,
  Sparkles,
  Star,
  Users,
  Wallet,
} from "lucide-react";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-sky-50 via-white to-cyan-50 text-slate-900">
      <Navbar />
      <main>
        <Hero />
        <Features />
        <HowItWorks />
        <Architecture />
        <ProjectLinks />
        <Benefits />
        <FinalCTA />
      </main>
      <Footer />
    </div>
  );
}

function Navbar() {
  return (
    <header className="sticky top-0 z-50 border-b border-slate-200/70 bg-white/80 backdrop-blur-xl">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
        <Link to="/" className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-blue-600 text-white shadow-lg shadow-blue-200">
            <Plane size={20} />
          </div>
          <span className="text-xl font-extrabold tracking-tight">
            TravelMate <span className="text-blue-600">AI</span>
          </span>
        </Link>

        <nav className="hidden items-center gap-8 text-sm font-semibold text-slate-600 md:flex">
          <a href="#features" className="hover:text-blue-600">Features</a>
          <a href="#how" className="hover:text-blue-600">How it works</a>
          <a href="#architecture" className="hover:text-blue-600">Architecture</a>
        </nav>

        <Link
          to="/planner"
          className="rounded-full bg-blue-600 px-5 py-2.5 text-sm font-bold text-white shadow-lg shadow-blue-200 transition hover:-translate-y-0.5 hover:bg-blue-700"
        >
          Try MVP
        </Link>
      </div>
    </header>
  );
}

function Hero() {
  return (
    <section className="relative overflow-hidden">
      <div className="absolute -right-28 top-20 h-80 w-80 rounded-full bg-cyan-200/40 blur-3xl" />
      <div className="absolute -left-28 top-60 h-80 w-80 rounded-full bg-blue-200/40 blur-3xl" />

      <div className="mx-auto grid max-w-7xl items-center gap-12 px-6 py-20 lg:grid-cols-2">
        <div>
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-blue-100 bg-white px-4 py-2 text-sm font-semibold text-blue-700 shadow-sm">
            <Sparkles size={16} />
            AI-powered travel planning MVP
          </div>

          <h1 className="text-5xl font-extrabold leading-tight tracking-tight md:text-6xl">
            Plan smarter trips with{" "}
            <span className="bg-gradient-to-r from-blue-600 to-cyan-500 bg-clip-text text-transparent">
              TravelMate AI
            </span>
          </h1>

          <p className="mt-6 max-w-xl text-lg leading-8 text-slate-600">
            TravelMate AI uses multiple AI agents to search flights, compare hotels
            and activities, and generate a personalized day-by-day itinerary based
            on budget, dates, travel style and preferences.
          </p>

          <div className="mt-9 flex flex-col gap-4 sm:flex-row">
            <Link
              to="/planner"
              className="group inline-flex items-center justify-center gap-2 rounded-2xl bg-blue-600 px-7 py-4 font-bold text-white shadow-xl shadow-blue-200 transition hover:-translate-y-1 hover:bg-blue-700"
            >
              Start planning
              <ArrowRight className="transition group-hover:translate-x-1" size={20} />
            </Link>

            <Link
              to="/learn"
              className="inline-flex items-center justify-center rounded-2xl border border-slate-200 bg-white px-7 py-4 font-bold text-slate-700 shadow-sm transition hover:-translate-y-1 hover:border-blue-200 hover:text-blue-700"
            >
              Learn about the project
            </Link>
          </div>

          {/*<div className="mt-8 flex flex-wrap gap-3">*/}
          {/*  <Pill text="Agentic AI" />*/}
          {/*  <Pill text="React + FastAPI" />*/}
          {/*  <Pill text="Startup MVP" />*/}
          {/*</div>*/}
        </div>

        <HeroMockup />
      </div>
    </section>
  );
}

function HeroMockup() {
  return (
    <div className="relative">
      <div className="absolute -right-3 -top-6 animate-bounce rounded-3xl bg-white p-4 shadow-xl">
        <Plane className="text-blue-600" size={34} />
      </div>

      <div className="rounded-[2rem] border border-slate-200 bg-white p-5 shadow-2xl shadow-blue-100 transition hover:-translate-y-2">
        <div className="rounded-[1.5rem] bg-gradient-to-br from-blue-600 to-cyan-500 p-5 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-blue-100">Trip generated</p>
              <h3 className="text-2xl font-bold">Lisbon Cultural Escape</h3>
            </div>
            <CheckCircle className="text-emerald-200" size={36} />
          </div>

          <div className="mt-6 grid gap-3">
            <MiniCard icon={<Plane />} title="Flight found" text="OTP → LIS · 138 EUR" />
            <MiniCard icon={<Hotel />} title="Hotel selected" text="130 EUR/night · 4.0 rating" />
            <MiniCard icon={<MapPinned />} title="Activities planned" text="Museums, landmarks, food spots" />
          </div>
        </div>

        <div className="mt-5 grid gap-3 md:grid-cols-3">
          <TripStep label="Morning" value="Castle tour" />
          <TripStep label="Afternoon" value="Tile museum" />
          <TripStep label="Evening" value="Fado show" />
        </div>
      </div>
    </div>
  );
}

function ProjectLinks() {
  return (
    <section className="mx-auto max-w-7xl px-6 py-8">
      <div className="grid gap-5 md:grid-cols-3">
        <a
          href="https://docs.google.com/document/d/1JoaaLupvtpNr_hZO4vpgytFFFAQ6af2n/edit"
          target="_blank"
          rel="noreferrer"
          className="group rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-100"
        >
          <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-600 group-hover:bg-blue-600 group-hover:text-white">
            <FileText />
          </div>
          <h3 className="text-xl font-bold">Project documentation</h3>
          <p className="mt-2 text-slate-600">
            Download the Business Foundation document.
          </p>
          <p className="mt-4 flex items-center gap-2 font-bold text-blue-600">
            Open documentation <ArrowRight size={18} />
          </p>
        </a>

        <a
          href="https://docs.google.com/presentation/d/1ORC7vxH0xuOYTCjwobiQ1ty2m6fb6IfQnzD7_pbDlug/edit?usp=sharing"
          target="_blank"
          rel="noreferrer"
          className="group rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-100"
        >
          <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-cyan-50 text-cyan-600 group-hover:bg-cyan-600 group-hover:text-white">
            <Presentation />
          </div>
          <h3 className="text-xl font-bold">Pitch presentation</h3>
          <p className="mt-2 text-slate-600">
            Download the funding and user acquisition pitch.
          </p>
          <p className="mt-4 flex items-center gap-2 font-bold text-cyan-600">
            Open pitch <ArrowRight size={18} />
          </p>
        </a>

        <Link
          to="/learn"
          className="group rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-100"
        >
          <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-emerald-600 group-hover:bg-emerald-600 group-hover:text-white">
            <Bot />
          </div>
          <h3 className="text-xl font-bold">Learn about the project</h3>
          <p className="mt-2 text-slate-600">
            See the technical stack, agents, tools and MVP architecture.
          </p>
          <p className="mt-4 flex items-center gap-2 font-bold text-emerald-600">
            Open details <ArrowRight size={18} />
          </p>
        </Link>
      </div>
    </section>
  );
}

function Features() {
  const features = [
    { icon: <Plane />, title: "Flight comparison", text: "Agent 1 searches flight options and prepares them for comparison." },
    { icon: <Hotel />, title: "Accommodation search", text: "Hotels are displayed with estimated price, rating and location details." },
    { icon: <MapPinned />, title: "Activity discovery", text: "The system suggests relevant activities based on the user's travel style." },
    { icon: <CheckCircle />, title: "Optional preferences", text: "Users can mark preferred flights, hotels and activities before itinerary generation." },
    { icon: <CalendarDays />, title: "Day-by-day planning", text: "Agent 2 builds a structured itinerary with morning, afternoon and evening slots." },
    { icon: <Wallet />, title: "Budget awareness", text: "The generated plan considers the user's budget and estimated trip cost." },
  ];

  return (
    <section id="features" className="mx-auto max-w-7xl px-6 py-16">
      <SectionHeader
        eyebrow="Features"
        title="Everything needed for a smart travel planning MVP"
        text="The product combines search, comparison, optional user preferences and AI itinerary generation."
      />

      <div className="mt-10 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {features.map((item) => <InfoCard key={item.title} {...item} />)}
      </div>
    </section>
  );
}

function HowItWorks() {
  const steps = [
    { number: "01", title: "User enters preferences", text: "Destination, airport, dates, budget, party size, travel style and constraints." },
    { number: "02", title: "Agent 1 searches options", text: "Flights, accommodation and activities are collected and displayed in the interface." },
    { number: "03", title: "User marks preferences", text: "Selection is optional. The user can choose preferred offers using a check icon." },
    { number: "04", title: "Agent 2 builds the itinerary", text: "The planner generates a realistic day-by-day trip plan optimized for the selected options." },
  ];

  return (
    <section id="how" className="bg-white py-16">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHeader
          eyebrow="How it works"
          title="From travel idea to complete itinerary"
          text="The user flow is simple enough for a live demo, but complete enough to show the multi-agent logic."
        />

        <div className="mt-10 grid gap-6 lg:grid-cols-4">
          {steps.map((step) => (
            <div key={step.number} className="rounded-3xl border border-slate-200 bg-slate-50 p-6 transition hover:-translate-y-2 hover:bg-white hover:shadow-xl hover:shadow-blue-100">
              <p className="text-4xl font-extrabold text-cyan-500">{step.number}</p>
              <h3 className="mt-4 text-xl font-bold">{step.title}</h3>
              <p className="mt-3 text-sm leading-6 text-slate-600">{step.text}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Architecture() {
  return (
    <section id="architecture" className="mx-auto max-w-7xl px-6 py-16">
      <SectionHeader
        eyebrow="Architecture"
        title="Multi-agent architecture"
        text="The MVP separates frontend, API layer and AI agents so the project is easy to explain and extend."
      />

      <div className="mt-10 rounded-[2rem] border border-slate-200 bg-white p-8 shadow-xl shadow-blue-100">
        <div className="grid items-center gap-5 lg:grid-cols-5">
          <ArchBox icon={<Users />} title="User" text="Travel preferences" />
          <Arrow />
          <ArchBox icon={<Map />} title="React Frontend" text="Form + results UI" />
          <Arrow />
          <ArchBox icon={<Bot />} title="FastAPI Backend" text="REST endpoints" />
        </div>

        <div className="my-8 flex justify-center">
          <div className="h-12 w-1 rounded-full bg-blue-200" />
        </div>

        <div className="grid gap-5 md:grid-cols-2">
          <ArchBox icon={<Plane />} title="Agent 1" text="Search & Compare flights, hotels and activities" />
          <ArchBox icon={<CalendarDays />} title="Agent 2" text="Generate the day-by-day itinerary" />
        </div>
      </div>
    </section>
  );
}

function Benefits() {
  return (
    <section className="bg-gradient-to-br from-blue-600 to-cyan-500 py-16 text-white">
      <div className="mx-auto max-w-7xl px-6">
        <SectionHeader
          light
          eyebrow="Why it matters"
          title="A product idea that is useful, scalable and pitch-friendly"
          text="TravelMate AI demonstrates real product management concepts: MVP, market comparison, monetization and technical feasibility."
        />

        <div className="mt-10 grid gap-5 md:grid-cols-2 lg:grid-cols-4">
          <Benefit icon={<Clock />} text="Saves planning time" />
          <Benefit icon={<Sparkles />} text="Uses Agentic AI" />
          <Benefit icon={<CreditCard />} text="Monetization ready" />
          <Benefit icon={<ShieldCheck />} text="Clear MVP scope" />
        </div>
      </div>
    </section>
  );
}

function FinalCTA() {
  return (
    <section className="mx-auto max-w-7xl px-6 py-16">
      <div className="overflow-hidden rounded-[2rem] bg-gradient-to-r from-slate-900 to-blue-900 p-10 text-white shadow-2xl">
        <div className="grid items-center gap-8 lg:grid-cols-[1fr_auto]">
          <div>
            <h2 className="text-4xl font-extrabold">Ready to plan your next trip?</h2>
            <p className="mt-4 max-w-2xl text-blue-100">
              Try the TravelMate AI MVP and generate an itinerary using real user preferences.
            </p>
          </div>

          <Link to="/planner" className="inline-flex items-center justify-center gap-2 rounded-2xl bg-white px-7 py-4 font-bold text-blue-700 transition hover:-translate-y-1 hover:bg-cyan-50">
            Open planner
            <ArrowRight size={20} />
          </Link>
        </div>
      </div>
    </section>
  );
}

function Testimonials() {
  return null;
}

function Footer() {
  return (
    <footer className="border-t border-slate-200 bg-white">
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-6 py-8 text-sm text-slate-500 md:flex-row md:items-center md:justify-between">
        <p>© 2026 TravelMate AI — University project MVP</p>
        <p>Built with React, FastAPI, CrewAI and OpenAI</p>
      </div>
    </footer>
  );
}

function MiniCard({ icon, title, text }) {
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-white/15 p-3 backdrop-blur">
      <div className="text-white">{icon}</div>
      <div>
        <p className="font-bold">{title}</p>
        <p className="text-sm text-blue-50">{text}</p>
      </div>
    </div>
  );
}

function TripStep({ label, value }) {
  return (
    <div className="rounded-2xl bg-slate-50 p-4">
      <p className="text-xs font-bold uppercase text-blue-600">{label}</p>
      <p className="mt-1 font-semibold">{value}</p>
    </div>
  );
}

function Pill({ text }) {
  return (
    <span className="rounded-full border border-blue-100 bg-white px-4 py-2 text-sm font-semibold text-blue-700 shadow-sm">
      {text}
    </span>
  );
}

function SectionHeader({ eyebrow, title, text, light = false }) {
  return (
    <div className="max-w-3xl">
      <p className={`text-sm font-extrabold uppercase tracking-widest ${light ? "text-cyan-100" : "text-blue-600"}`}>
        {eyebrow}
      </p>
      <h2 className={`mt-3 text-4xl font-extrabold tracking-tight ${light ? "text-white" : "text-slate-900"}`}>
        {title}
      </h2>
      <p className={`mt-4 text-lg leading-8 ${light ? "text-blue-100" : "text-slate-600"}`}>
        {text}
      </p>
    </div>
  );
}

function InfoCard({ icon, title, text }) {
  return (
    <div className="group rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition duration-300 hover:-translate-y-2 hover:border-blue-200 hover:shadow-2xl hover:shadow-blue-100">
      <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-blue-600 transition group-hover:scale-110 group-hover:bg-blue-600 group-hover:text-white">
        {icon}
      </div>
      <h3 className="text-xl font-bold">{title}</h3>
      <p className="mt-3 leading-7 text-slate-600">{text}</p>
    </div>
  );
}

function Benefit({ icon, text }) {
  return (
    <div className="rounded-3xl bg-white/15 p-6 backdrop-blur transition hover:-translate-y-2 hover:bg-white/25">
      <div className="mb-4 text-white">{icon}</div>
      <p className="font-bold">{text}</p>
    </div>
  );
}

function ArchBox({ icon, title, text }) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-slate-50 p-6 text-center transition hover:-translate-y-2 hover:bg-white hover:shadow-xl hover:shadow-blue-100">
      <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-600 text-white">
        {icon}
      </div>
      <h3 className="font-extrabold">{title}</h3>
      <p className="mt-2 text-sm text-slate-500">{text}</p>
    </div>
  );
}

function Arrow() {
  return (
    <div className="hidden justify-center text-blue-300 lg:flex">
      <ArrowRight size={34} />
    </div>
  );
}