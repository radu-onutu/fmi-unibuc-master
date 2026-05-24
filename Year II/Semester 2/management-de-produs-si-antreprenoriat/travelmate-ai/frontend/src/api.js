import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";

export async function searchOffers(preferences) {
  const response = await axios.post(`${API_BASE_URL}/search`, preferences);
  return response.data;
}

export async function generatePlan(preferences, searchResults) {
  const response = await axios.post(`${API_BASE_URL}/plan-from-search`, {
    prefs: preferences,
    search_results: searchResults,
  });
  return response.data;
}