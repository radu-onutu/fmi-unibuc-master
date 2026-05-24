import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import {
  Plane,
  Hotel,
  MapPinned,
  CalendarDays,
  Sparkles,
  CheckCircle,
  RotateCcw,
  Send,
} from "lucide-react";
import { searchOffers, generatePlan } from "../api";
import "../index.css";

const initialForm = {
  destination: "Lisbon",
  start_date: "2026-06-01",
  end_date: "2026-06-05",
  budget_eur: 1500,
  party_size: 2,
  travel_style: "cultural",
  departure_airport: "OTP",
  constraints: "",
};

export default function PlannerPage() {
  const [form, setForm] = useState(initialForm);
  const [errors, setErrors] = useState({});
  const [searchResults, setSearchResults] = useState(null);
  const [itinerary, setItinerary] = useState(null);
  const [selected, setSelected] = useState({
    flights: [],
    accommodations: [],
    activities: [],
  });
  const [loadingSearch, setLoadingSearch] = useState(false);
  const [loadingPlan, setLoadingPlan] = useState(false);
  const [apiError, setApiError] = useState("");

  const preferences = useMemo(() => ({
    destination: form.destination.trim(),
    start_date: form.start_date,
    end_date: form.end_date,
    budget_eur: Number(form.budget_eur),
    party_size: Number(form.party_size),
    travel_style: form.travel_style,
    departure_airport: form.departure_airport.trim().toUpperCase(),
    constraints: form.constraints
      ? form.constraints.split(",").map((x) => x.trim()).filter(Boolean)
      : [],
  }), [form]);

  function validateForm() {
    const newErrors = {};

    if (!form.destination.trim()) newErrors.destination = "Destination is required.";

    if (!form.departure_airport.trim()) {
      newErrors.departure_airport = "Departure airport is required.";
    } else if (!/^[A-Z]{3}$/i.test(form.departure_airport.trim())) {
      newErrors.departure_airport = "Airport must be a 3-letter IATA code, e.g. OTP.";
    }

    if (!form.start_date) newErrors.start_date = "Start date is required.";
    if (!form.end_date) newErrors.end_date = "Return date is required.";

    if (form.start_date && form.end_date && form.end_date < form.start_date) {
      newErrors.end_date = "Return date cannot be earlier than start date.";
    }

    if (!form.budget_eur || Number(form.budget_eur) <= 0) {
      newErrors.budget_eur = "Budget must be greater than 0.";
    }

    if (Number(form.budget_eur) > 50000) {
      newErrors.budget_eur = "Budget is too high for this demo.";
    }

    if (!form.party_size || Number(form.party_size) < 1) {
      newErrors.party_size = "Party size must be at least 1.";
    }

    if (Number(form.party_size) > 10) {
      newErrors.party_size = "Maximum party size is 10.";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }

  async function handleSearch(e) {
    e.preventDefault();
    if (!validateForm()) return;

    setApiError("");
    setItinerary(null);
    setSearchResults(null);
    setSelected({ flights: [], accommodations: [], activities: [] });
    setLoadingSearch(true);

    try {
      const data = await searchOffers(preferences);
      setSearchResults(data);
    } catch (err) {
      setApiError(err.response?.data?.detail || "Search failed. Please try again.");
    } finally {
      setLoadingSearch(false);
    }
  }

  function toggleSelection(type, id) {
    setSelected((prev) => {
      const exists = prev[type].includes(id);
      return {
        ...prev,
        [type]: exists
          ? prev[type].filter((itemId) => itemId !== id)
          : [...prev[type], id],
      };
    });
  }

  function buildPreferredSearchResults() {
    if (!searchResults) return null;

    return {
      flights:
        selected.flights.length > 0
          ? searchResults.flights.filter((x) => selected.flights.includes(x.id))
          : searchResults.flights,
      accommodations:
        selected.accommodations.length > 0
          ? searchResults.accommodations.filter((x) => selected.accommodations.includes(x.id))
          : searchResults.accommodations,
      activities:
        selected.activities.length > 0
          ? searchResults.activities.filter((x) => selected.activities.includes(x.id))
          : searchResults.activities,
    };
  }

  async function handleGeneratePlan() {
    if (!validateForm()) return;

    setApiError("");
    setLoadingPlan(true);

    try {
      const filteredResults = buildPreferredSearchResults();
      const data = await generatePlan(preferences, filteredResults);
      setItinerary(data);
    } catch (err) {
      setApiError(err.response?.data?.detail || "Itinerary generation failed. Please try again.");
    } finally {
      setLoadingPlan(false);
    }
  }

  function handleReset() {
    setForm(initialForm);
    setErrors({});
    setSearchResults(null);
    setItinerary(null);
    setApiError("");
    setSelected({ flights: [], accommodations: [], activities: [] });
  }

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <Hero />

      <main className="mx-auto grid max-w-7xl items-start gap-8 px-6 py-10 lg:grid-cols-[420px_1fr]">
        <TravelForm
          form={form}
          setForm={setForm}
          errors={errors}
          onSubmit={handleSearch}
          loading={loadingSearch}
          onReset={handleReset}
        />

        <section className="space-y-6">
          {apiError && (
            <div className="rounded-2xl border border-red-200 bg-red-50 p-4 text-red-700">
              {apiError}
            </div>
          )}

          {!searchResults && !loadingSearch && <EmptyState />}

          {loadingSearch && (
            <LoadingState text="Agent 1 is searching flights, accommodation and activities..." />
          )}

          {searchResults && (
            <SearchResults
              results={searchResults}
              selected={selected}
              onToggle={toggleSelection}
              onGeneratePlan={handleGeneratePlan}
              loadingPlan={loadingPlan}
            />
          )}

          {loadingPlan && (
            <LoadingState text="Agent 2 is building your day-by-day itinerary..." />
          )}

          {itinerary && <ItineraryView itinerary={itinerary} />}
        </section>
      </main>
    </div>
  );
}

function Hero() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-sky-950 via-blue-900 to-cyan-700 text-white">
      <div className="paper-plane-wrapper">
        <Send className="paper-plane-icon" size={70} />
      </div>

      <div className="mx-auto max-w-7xl px-6 py-16">
        <div className="max-w-3xl">
          <div className="mb-4 inline-flex items-center gap-2 rounded-full bg-white/10 px-4 py-2 text-sm">
            <Sparkles size={16} />
            Agentic AI Travel Planner
          </div>

          <h1 className="text-5xl font-bold tracking-tight">
            <Link
              to="/"
              className="text-cyan-300 transition hover:text-cyan-200 hover:underline focus:outline-none focus-visible:ring-2 focus-visible:ring-cyan-300 rounded"
              aria-label="TravelMate AI — back to home"
            >
              TravelMate AI
            </Link>
          </h1>

          <p className="mt-5 text-lg text-blue-50">
            Smart travel planning powered by AI agents: compare flights, hotels and
            activities, then generate a complete day-by-day itinerary.
          </p>

          <div className="mt-8 flex flex-wrap gap-3">
            <Badge text="Step 1: Search & Compare" />
            <Badge text="Step 2: Itinerary Planner" />
          </div>
        </div>
      </div>
    </section>
  );
}

function Badge({ text }) {
  return (
    <span className="rounded-full bg-white px-4 py-2 text-sm font-semibold text-blue-900">
      {text}
    </span>
  );
}

function TravelForm({ form, setForm, errors, onSubmit, loading, onReset }) {
  function update(field, value) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  return (
    <form
      onSubmit={onSubmit}
      className="self-start rounded-3xl bg-white p-6 shadow-xl"
    >
      <h2 className="mb-6 text-2xl font-bold">Travel preferences</h2>

      <Input label="Destination" value={form.destination} error={errors.destination} onChange={(v) => update("destination", v)} />

      <Input
        label="Departure airport"
        value={form.departure_airport}
        error={errors.departure_airport}
        onChange={(v) => update("departure_airport", v.toUpperCase())}
        placeholder="OTP"
      />

      <div className="grid grid-cols-2 gap-4">
        <Input type="date" label="Start date" value={form.start_date} error={errors.start_date} onChange={(v) => update("start_date", v)} />
        <Input type="date" label="Return date" value={form.end_date} error={errors.end_date} onChange={(v) => update("end_date", v)} />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <Input type="number" label="Budget EUR" value={form.budget_eur} error={errors.budget_eur} onChange={(v) => update("budget_eur", v)} min="1" />
        <Input type="number" label="Party size" value={form.party_size} error={errors.party_size} onChange={(v) => update("party_size", v)} min="1" max="10" />
      </div>

      <label className="mb-4 block">
        <span className="mb-1 block text-sm font-semibold">Travel style</span>
        <select
          value={form.travel_style}
          onChange={(e) => update("travel_style", e.target.value)}
          className="w-full rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-blue-500"
        >
          <option value="relaxed">Relaxed</option>
          <option value="cultural">Cultural</option>
          <option value="foodie">Foodie</option>
          <option value="adventure">Adventure</option>
          <option value="mixed">Mixed</option>
        </select>
      </label>

      <Input
        label="Constraints"
        placeholder="vegetarian, museums, low budget"
        value={form.constraints}
        onChange={(v) => update("constraints", v)}
      />

      <button
        disabled={loading}
        className="mt-4 w-full rounded-xl bg-blue-700 px-5 py-3 font-bold text-white hover:bg-blue-800 disabled:opacity-60"
      >
        {loading ? "Searching offers..." : "Search offers"}
      </button>

      <button
        type="button"
        onClick={onReset}
        className="mt-3 flex w-full items-center justify-center gap-2 rounded-xl border border-slate-200 px-5 py-3 font-bold text-slate-700 hover:bg-slate-50"
      >
        <RotateCcw size={18} />
        Reset
      </button>
    </form>
  );
}

function Input({ label, value, onChange, error, type = "text", placeholder = "", min, max }) {
  return (
    <label className="mb-4 block">
      <span className="mb-1 block text-sm font-semibold">{label}</span>
      <input
        type={type}
        value={value}
        min={min}
        max={max}
        placeholder={placeholder}
        onChange={(e) => onChange(e.target.value)}
        className={`w-full rounded-xl border px-4 py-3 outline-none focus:border-blue-500 ${
          error ? "border-red-400" : "border-slate-200"
        }`}
      />
      {error && <p className="mt-1 text-sm text-red-600">{error}</p>}
    </label>
  );
}

function EmptyState() {
  return (
    <div className="rounded-3xl border border-dashed border-slate-300 bg-white p-10 text-center">
      <MapPinned className="mx-auto mb-4 text-blue-700" size={44} />
      <h3 className="text-xl font-bold">Complete the form</h3>
      <p className="mt-2 text-slate-600">
        Your search results and generated itinerary will appear here.
      </p>
    </div>
  );
}

function LoadingState({ text }) {
  return (
    <div className="rounded-3xl bg-white p-8 text-center shadow-xl">
      <div className="mx-auto mb-4 h-10 w-10 animate-spin rounded-full border-4 border-blue-100 border-t-blue-700" />
      <p className="font-semibold text-slate-700">{text}</p>
    </div>
  );
}

function SearchResults({ results, selected, onToggle, onGeneratePlan, loadingPlan }) {
  const selectedCount =
    selected.flights.length + selected.accommodations.length + selected.activities.length;

  return (
    <div className="rounded-3xl bg-white p-6 shadow-xl">
      <div className="mb-6 flex flex-col justify-between gap-4 lg:flex-row lg:items-center">
        <div>
          <h2 className="text-2xl font-bold">Results</h2>
          <p className="mt-1 text-sm text-slate-500">
            Click the check icon to mark preferred flights, hotels or activities. Selection is optional.
          </p>
          <p className="mt-1 text-sm font-semibold text-blue-700">
            Selected preferences: {selectedCount}
          </p>
        </div>

        <button
          onClick={onGeneratePlan}
          disabled={loadingPlan || !results.flights?.length}
          className="rounded-xl bg-cyan-600 px-5 py-3 font-bold text-white hover:bg-cyan-700 disabled:opacity-60"
        >
          {loadingPlan ? "Generating..." : "Generate itinerary"}
        </button>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Stat icon={<Plane />} label="Flights" value={results.flights?.length || 0} />
        <Stat icon={<Hotel />} label="Hotels" value={results.accommodations?.length || 0} />
        <Stat icon={<MapPinned />} label="Activities" value={results.activities?.length || 0} />
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-3">
        <SelectableList
          title="Flights"
          items={results.flights}
          type="flights"
          selectedIds={selected.flights}
          onToggle={onToggle}
          renderItem={(item) => (
            <>
              <p className="font-bold">{item.airline}</p>
              <p className="text-sm text-slate-600">
                {item.outbound.departure_airport} → {item.outbound.arrival_airport}
              </p>
              <p className="text-sm font-semibold">{item.total_price_eur} EUR</p>
            </>
          )}
        />

        <SelectableList
          title="Hotels"
          items={results.accommodations}
          type="accommodations"
          selectedIds={selected.accommodations}
          onToggle={onToggle}
          renderItem={(item) => (
            <>
              <p className="font-bold">{item.name}</p>
              <p className="text-sm text-slate-600">{item.address}</p>
              <p className="text-sm font-semibold">
                {item.price_per_night_eur} EUR/night · ⭐ {item.rating}
              </p>
            </>
          )}
        />

        <SelectableList
          title="Activities"
          items={results.activities}
          type="activities"
          selectedIds={selected.activities}
          onToggle={onToggle}
          renderItem={(item) => (
            <>
              <p className="font-bold">{item.name}</p>
              <p className="text-sm text-slate-600">{item.category}</p>
              <p className="text-sm font-semibold">
                {item.price_eur} EUR · ⭐ {item.rating}
              </p>
            </>
          )}
        />
      </div>
    </div>
  );
}

function SelectableList({ title, items = [], type, selectedIds, onToggle, renderItem }) {
  return (
    <div>
      <h3 className="mb-3 font-bold">{title}</h3>

      <div className="max-h-96 space-y-3 overflow-auto pr-2">
        {items?.length === 0 && (
          <p className="text-sm text-slate-500">No results available.</p>
        )}

        {items?.slice(0, 12).map((item) => {
          const isSelected = selectedIds.includes(item.id);

          return (
            <div
              key={item.id}
              className={`relative rounded-2xl border p-4 transition ${
                isSelected
                  ? "border-emerald-300 bg-emerald-50"
                  : "border-slate-100 bg-slate-50"
              }`}
            >
              <button
                type="button"
                onClick={() => onToggle(type, item.id)}
                className="absolute right-3 top-3 rounded-full bg-white p-1 shadow-sm hover:scale-110"
              >
                <CheckCircle
                size={18}
                className={
                  isSelected
                    ? "fill-emerald-200 text-emerald-500"
                    : "text-slate-400"
                }
              />
              </button>

              <div className="pr-8">{renderItem(item)}</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function Stat({ icon, label, value }) {
  return (
    <div className="rounded-2xl bg-slate-50 p-4">
      <div className="mb-2 text-blue-700">{icon}</div>
      <div className="text-3xl font-bold">{value}</div>
      <div className="text-sm text-slate-500">{label}</div>
    </div>
  );
}

function ItineraryView({ itinerary }) {
  const summary = itinerary.trip_summary;

  return (
    <div className="rounded-3xl bg-white p-6 shadow-xl">
      <div className="mb-6 flex items-center gap-3">
        <CalendarDays className="text-blue-700" />
        <div>
          <h2 className="text-2xl font-bold">Final itinerary</h2>
          <p className="text-slate-600">
            Estimated cost: {summary?.total_estimated_cost_eur} EUR
          </p>
        </div>
      </div>

      <div className="space-y-5">
        {itinerary.days?.map((day) => (
          <div key={day.day_number} className="rounded-2xl border border-slate-200 p-5">
            <h3 className="text-xl font-bold">
              Day {day.day_number} · {day.date}
            </h3>

            <p className="mt-1 text-slate-600">{day.summary}</p>

            <div className="mt-4 grid gap-3 md:grid-cols-3">
              <Slot title="Morning" slot={day.morning} />
              <Slot title="Afternoon" slot={day.afternoon} />
              <Slot title="Evening" slot={day.evening} />
            </div>

            {day.transport?.length > 0 && (
              <div className="mt-4 rounded-xl bg-slate-50 p-3 text-sm">
                <p className="font-bold">Transport:</p>
                {day.transport.map((t, index) => (
                  <p key={index}>
                    {t.from_location} → {t.to_location}: {t.mode}, {t.duration_minutes} min, {t.cost_eur} EUR
                  </p>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function Slot({ title, slot }) {
  return (
    <div className="rounded-xl bg-slate-50 p-4">
      <p className="mb-2 text-sm font-bold text-blue-700">{title}</p>

      {slot ? (
        <>
          <p className="font-bold">{slot.activity_name}</p>
          <p className="text-sm text-slate-600">{slot.address}</p>
          <p className="mt-2 text-sm">
            {slot.start_time} - {slot.end_time} · {slot.cost_eur} EUR
          </p>
        </>
      ) : (
        <p className="text-sm text-slate-500">Free time / relaxation</p>
      )}
    </div>
  );
}