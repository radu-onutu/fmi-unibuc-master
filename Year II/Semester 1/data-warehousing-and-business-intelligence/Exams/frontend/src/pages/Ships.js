import { useEffect, useState } from "react";

import { executeOtlpQuery, executeDwQuery } from "../apis/api.js";

import {
  Typography,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  Paper
} from "@mui/material";

export default function Ships() {
  const [ships, setShips] = useState([]);
  const [open, setOpen] = useState(false);

  const [form, setForm] = useState({
    company_id: "",
    imo_number: "",
    ship_name: "",
    build_year: "",
    teu_capacity: "",
    gross_tonnage: "",
    fuel_type: ""
  });

  // Fetch ships on page load
  useEffect(() => {
    const fetchShips = async () => {
      try {
        const result = await executeDwQuery("SELECT * FROM dim_ships");
        // Backend returns { message: rows }
        setShips(result.message || []);
      } catch (err) {
        console.error("Error fetching ships:", err);
      }
    };

    fetchShips();
  }, []);

  const handleAddShip = async () => {
    const query = `
      INSERT INTO ships (imo_number, ship_name, build_year, teu_capacity, gross_tonnage, tank_capacity, fuel_type)
      VALUES (
        '${form.imo_number}',
        '${form.ship_name}', 
        '${form.build_year}',
        '${form.teu_capacity}',
        '${form.gross_tonnage}',
        '${form.tank_capacity}',
        '${form.fuel_type}'
      )
    `;
    try {
      executeOtlpQuery(query);
      alert("Ship added successfully");
      setOpen(false);
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <>
      <Typography variant="h4" gutterBottom>
        Ships
      </Typography>

      <Paper>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>IMO</TableCell>
              <TableCell>Company ID</TableCell>
              <TableCell>Build Year</TableCell>
              <TableCell>TEU</TableCell>
              <TableCell>Gross Tonnage</TableCell>
              <TableCell>Fuel</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {ships.map(ship => (
              <TableRow key={ship.id}>
                <TableCell>{ship.ship_name}</TableCell>
                <TableCell>{ship.imo_number}</TableCell>
                <TableCell>{ship.company_id}</TableCell>
                <TableCell>{ship.build_year}</TableCell>
                <TableCell>{ship.teu_capacity}</TableCell>
                <TableCell>{ship.gross_tonnage}</TableCell>
                <TableCell>{ship.fuel_type}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Paper>

      <Dialog open={open} onClose={() => setOpen(false)}>
        <DialogTitle>Add New Ship</DialogTitle>
        <DialogContent
          sx={{ display: "flex", flexDirection: "column", gap: 2, mt: 1 }}
        >
          <TextField
            label="Ship Name"
            value={form.ship_name}
            onChange={e => setForm({ ...form, ship_name: e.target.value })}
          />

          <TextField
            label="IMO Number"
            value={form.imo_number}
            onChange={e => setForm({ ...form, imo_number: e.target.value })}
          />

          <TextField
            label="Build Year"
            type="number"
            value={form.build_year}
            onChange={e => setForm({ ...form, build_year: e.target.value })}
          />

          <TextField
            label="TEU Capacity"
            type="number"
            value={form.teu_capacity}
            onChange={e => setForm({ ...form, teu_capacity: e.target.value })}
          />

          <TextField
            label="Gross Tonnage"
            type="number"
            value={form.gross_tonnage}
            onChange={e => setForm({ ...form, gross_tonnage: e.target.value })}
          />

          <TextField
            label="Tank Capacity"
            type="number"
            value={form.tank_capacity}
            onChange={e => setForm({ ...form, tank_capacity: e.target.value })}
          />

          <TextField
            label="Fuel Type"
            value={form.fuel_type}
            onChange={e => setForm({ ...form, fuel_type: e.target.value })}
          />
        </DialogContent>

        <DialogActions>
          <Button onClick={() => setOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleAddShip}>
            Save
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
}
