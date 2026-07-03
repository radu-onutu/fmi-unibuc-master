import { Box, Typography, Grid, Card, CardContent } from "@mui/material";
import { BarChart, LineChart, ChartsTooltip } from "@mui/x-charts";
import { fact_shipments, dim_ships } from "../mock/dummyData.js";
import { useState, useEffect } from "react";
import { executeOtlpQuery, executeDwQuery } from "../apis/api.js";

export default function Analytics() {
  const [teuPerShip, setTeuPerShip] = useState([]);
  const [cargoOverTime, setCargoOverTime] = useState([]);
  const [costPerRoute, setCostPerRoute] = useState([]);
  const [delaysPerRoute, setDelaysPerRoute] = useState([]);

  useEffect(() => {
    fetchAnalytics();
  }, []);

  async function fetchAnalytics() {
    try {
      const teuResult = await executeDwQuery(`
        SELECT 
            s.ship_name,
            NVL(SUM(f.teu_utilized), 0) AS total_teu
        FROM fact_shipments f
        JOIN dim_ships s ON f.ship_id = s.id
        GROUP BY s.ship_name
        ORDER BY total_teu DESC
      `);

      const teuRows = teuResult.message || [];

      setTeuPerShip(
        teuRows.map(r => ({
          label: r.ship_name ?? "Unknown",
          value: Number(r.total_teu ?? 0)
        }))
      );

      const cargoResult = await executeDwQuery(`
        SELECT 
            t.year,
            t.month,
            NVL(SUM(f.cargo_tonnage), 0) AS total_tonnage
        FROM fact_shipments f
        JOIN dim_time t ON f.departure_time_id = t.id
        GROUP BY t.year, t.month
        ORDER BY t.year, t.month
      `);

      const cargoRows = cargoResult.message || [];

      setCargoOverTime(
        cargoRows.map(r => ({
          label: `${r.year}-${String(r.month).padStart(2, '0')}`,
          value: Number(r.total_tonnage ?? 0)
        }))
      );

      const costResult = await executeDwQuery(`
        SELECT 
            vp.is_international,
            NVL(SUM(f.port_fees), 0) AS total_cost
        FROM fact_shipments f
        JOIN dim_voyage_profiles vp ON f.voyage_profile_id = vp.id
        GROUP BY vp.is_international
        ORDER BY vp.is_international
      `);

      const costRows = costResult.message || [];

      setCostPerRoute(
        costRows.map(r => ({
          label: r.is_international === 1 ? "International" : "Domestic",
          value: Number(r.total_cost ?? 0)
        }))
      );

      const delayResult = await executeDwQuery(`
        SELECT 
            dd.dock_name || ' → ' || ad.dock_name AS route,
            NVL(COUNT(*), 0) AS delayed_count
        FROM fact_shipments f
        JOIN dim_docks dd ON f.departure_dock_id = dd.id
        JOIN dim_docks ad ON f.arrival_dock_id = ad.id
        JOIN dim_status st ON f.status_id = st.id
        WHERE st.status_type = 'Delayed'
        GROUP BY dd.dock_name, ad.dock_name
        ORDER BY delayed_count DESC
      `);

      const delayRows = delayResult.message || [];

      setDelaysPerRoute(
        delayRows.map(r => ({
          label: r.route ?? "Unknown",
          value: Number(r.delayed_count ?? 0)
        }))
      );

      console.log("TEU result:", teuResult);
      console.log("Cargo result:", cargoResult);
      console.log("Cost result:", costResult);
      console.log("Delay result:", delayResult);

    } catch (err) {
      console.error("Analytics error:", err);
    }

  }
  

  return (
    <div style={{ padding: "2rem" }}>
      <h2>Analytics Dashboard</h2>

      {/* TEU per Ship */}
      <div style={{ height: 400, marginBottom: 60 }}>
        <h3>Total TEU per Ship</h3>
        <BarChart
          xAxis={[{ scaleType: "band", data: teuPerShip.map(d => d.label) }]}
          series={[{ data: teuPerShip.map(d => d.value), label: "TEU" }]}
          height={350}
        />
      </div>

      {/* Cargo Over Time */}
      <div style={{ height: 400, marginBottom: 60 }}>
        <h3>Cargo Tonnage Over Time</h3>
        <LineChart
          xAxis={[{ scaleType: "point", data: cargoOverTime.map(d => d.label) }]}
          series={[{ data: cargoOverTime.map(d => d.value), label: "Tonnage" }]}
          height={350}
        />
      </div>

      {/* Cost per Route */}
      <div style={{ height: 400, marginBottom: 60 }}>
        <h3>Total Port Fees per Route</h3>
        <BarChart
          xAxis={[{ scaleType: "band", data: costPerRoute.map(d => d.label) }]}
          series={[{ data: costPerRoute.map(d => d.value), label: "Port Fees" }]}
          height={350}
        />
      </div>

      {/* Delays per Route */}
      <div style={{ height: 400 }}>
        <h3>Delayed Shipments per Route</h3>
        <BarChart
          xAxis={[{ scaleType: "band", data: delaysPerRoute.map(d => d.label) }]}
          series={[{ data: delaysPerRoute.map(d => d.value), label: "Delays" }]}
          height={350}
        />
      </div>
    </div>
  );
}
