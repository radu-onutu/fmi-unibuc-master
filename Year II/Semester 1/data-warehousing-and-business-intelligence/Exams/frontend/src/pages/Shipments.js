import { useState, useEffect } from "react";
import {
  Typography,
  Paper,
  Grid,
  TextField,
  Button,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody
} from "@mui/material";

import { executeOtlpQuery, executeDwQuery } from "../apis/api.js";

export default function Shipments() {
  const [shipments, setShipments] = useState([]);
  const [form, setForm] = useState({
    ship_id: "",
    departure_time: "",
    arrival_time: "",
    teu_utilized: "",
    cargo_tonnage: "",
    crew_count: "",
    fuel_consumed: "",
    distance_nm: "",
    port_fees: ""
  });

  useEffect(() => {
    const fetchCompanies = async () => {
      try {
        const result = await executeDwQuery("SELECT * FROM fact_shipments");
        // Backend returns { message: rows }
        setShipments(result.message || []);
      } catch (err) {
        console.error("Error fetching ships:", err);
      }
    };

  fetchCompanies();
  }, []);
  

  const handleSubmit = async (e) => {
    e.preventDefault();

    // const dep = new Date(form.departure_time);
    // const arr = new Date(form.arrival_time);
    // const duration = (arr - dep) / (1000 * 60 * 60);

    const query = `INSERT INTO shipments (
            ship_id, berth_id, departure_port_id, arrival_port_id, 
            voyage_number, departure_date, arrival_date, 
            distance_nm, transport_type, status, is_international
        ) VALUES (
            '${form.ship_id}',
            '${form.berth_id || "NULL"}',
            '${form.departure_port_id || "NULL"}',
            '${form.arrival_port_id || "NULL"}',
            '${form.voyage_number || "NULL"}',
            TO_TIMESTAMP('${form.departure_time}', 'YYYY-MM-DD"T"HH24:MI'),
            TO_TIMESTAMP('${form.arrival_time}', 'YYYY-MM-DD"T"HH24:MI'),
            '${form.distance_nm || "NULL"}',
            '${form.transport_type || "NULL"}',
            '${form.status || "NULL"}',
            '${form.is_international || "NULL"}'
        )`;

      try{
        await executeOtlpQuery(query);
        alert("Shipment recorded successfully");
      } catch (err) {
        console.error("Error recording shipment:", err);
        alert("Error recording shipment");
      }
  };

  return (
    <>
      <Typography variant="h4" gutterBottom>
        Record Shipment
      </Typography>

      {/* <Paper sx={{ p: 3, mb: 4 }}>
        <form onSubmit={handleSubmit}>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <TextField
                label="Ship ID"
                fullWidth
                value={form.ship_id}
                onChange={e => setForm({ ...form, ship_id: e.target.value })}
              />
            </Grid>

            <Grid item xs={12} md={6}>
              <TextField
                type="datetime-local"
                label="Departure Time"
                InputLabelProps={{ shrink: true }}
                fullWidth
                value={form.departure_timestamp}
                onChange={e => setForm({ ...form, departure_time: e.target.value })}
              />
            </Grid>

            <Grid item xs={12} md={6}>
              <TextField
                type="datetime-local"
                label="Arrival Time"
                InputLabelProps={{ shrink: true }}
                fullWidth
                value={form.arrival_timestamp}
                onChange={e => setForm({ ...form, arrival_time: e.target.value })}
              />
            </Grid>

            {[
              ["TEU Utilized", "teu_utilized"],
              ["Departure Port ID", "departure_port_id"],
              ["Arrival Port ID", "arrival_port_id"],
              ["Voyage Number", "voyage_number"],
              ["Cargo Tonnage", "cargo_tonnage"],
              ["Crew Count", "crew_count"],
              ["Fuel Consumed", "fuel_consumed"],
              ["Distance (NM)", "distance_nm"],
              ["Port Fees", "port_fees"]
            ].map(([label, key]) => (
              <Grid item xs={12} md={4} key={key}>
                <TextField
                  label={label}
                  type="number"
                  fullWidth
                  value={form[key]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })}
                />
              </Grid>
            ))}

            <Grid item xs={12}>
              <Button variant="contained" type="submit">
                Save Shipment
              </Button>
            </Grid>
          </Grid>
        </form>
      </Paper> */}

      <Typography variant="h6" gutterBottom>
        Shipment History
      </Typography>

      <Paper>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Ship</TableCell>
              <TableCell>Duration (h)</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {shipments.map(s => (
              <TableRow key={s.id}>
                <TableCell>{s.id}</TableCell>
                <TableCell>{s.ship_id}</TableCell>
                <TableCell>{s.voyage_duration_hours?.toFixed(2)}</TableCell>
                <TableCell>{s.status_id}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Paper>
    </>
  );
}
