import { useState, useEffect, use } from "react";
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

// import { dim_shipping_companies } from "../mock/dummyData";
import { executeOtlpQuery, executeDwQuery } from "../apis/api.js";

export default function Companies() {
  const [companies, setCompanies] = useState([]);
  
  const [form, setForm] = useState({
    company_name: "",
    scac_code: "",
    imo_company_code: "",
    country_of_origin: ""
  });

  useEffect(() => {
    const fetchCompanies = async () => {
      try {
        const result = await executeDwQuery("SELECT * FROM dim_shipping_companies");
        // Backend returns { message: rows }
        setCompanies(result.message || []);
      } catch (err) {
        console.error("Error fetching ships:", err);
      }
    };

  fetchCompanies();
  }, []);

  // send insert query with executeOtlpQuery
  const handleInsert = async () => {
    const query = `
      INSERT INTO shipments_companies (name, scac_code, imo_company_num, country_of_origin) 
      VALUES (
        '${form.company_name}',
        '${form.scac_code}',
        '${form.imo_company_num}',
        '${form.country_of_origin}'
      )
    `; 
    try {
      await executeOtlpQuery(query);
      alert("Company inserted successfully");
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <>
      <Typography variant="h4" gutterBottom>
        Shipping Companies
      </Typography>

      <Paper sx={{ p: 3, mb: 4 }}>
        <form onSubmit={handleInsert}>
          <Grid container spacing={2}>
            {[
              ["Company Name", "company_name"],
              ["SCAC Code", "scac_code"],
              ["IMO Company Code", "imo_company_num"],
              ["Country", "country_of_origin"]
            ].map(([label, key]) => (
              <Grid item xs={12} md={6} key={key}>
                <TextField
                  label={label}
                  fullWidth
                  value={form[key]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })}
                />
              </Grid>
            ))}

            <Grid item xs={12}>
              <Button variant="contained" type="submit" onClick={handleInsert}>
                Add Company
              </Button>
            </Grid>
          </Grid>
        </form>
      </Paper>

      <Typography variant="h6" gutterBottom>
        Company List
      </Typography>

      <Paper>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>SCAC</TableCell>
              <TableCell>IMO Code</TableCell>
              <TableCell>Country</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {companies.map(c => (
              <TableRow key={c.id}>
                <TableCell>{c.company_name}</TableCell>
                <TableCell>{c.scac_code}</TableCell>
                <TableCell>{c.imo_company_code}</TableCell>
                <TableCell>{c.country_of_origin}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Paper>
    </>
  );
}
