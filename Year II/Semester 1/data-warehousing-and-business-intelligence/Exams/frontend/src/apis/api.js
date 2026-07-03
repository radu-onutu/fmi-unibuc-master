import axios from "axios";

const api = axios.create({
  baseURL: "http://localhost:3001",
  headers: {
    "Content-Type": "application/json"
  }
});

// OLTP query
export const executeOtlpQuery = async (query) => {
  const response = await api.post("/otlp", { query });
  return response.data;
};

// DW query
export const executeDwQuery = async (query) => {
  const response = await api.post("/dw", { query });
  return response.data;
};

// Sync
export const syncWarehouse = async () => {
  const response = await api.get("/sync");
  return response.data;
};
