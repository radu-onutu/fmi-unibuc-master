import { BrowserRouter, Routes, Route } from "react-router-dom";
import LandingPage from "./pages/LandingPage";
import PlannerPage from "./pages/PlannerPage";
import LearnPage from "./pages/LearnPage";
import "./index.css";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/planner" element={<PlannerPage />} />
          <Route path="/learn" element={<LearnPage />} />
      </Routes>
    </BrowserRouter>
  );
}