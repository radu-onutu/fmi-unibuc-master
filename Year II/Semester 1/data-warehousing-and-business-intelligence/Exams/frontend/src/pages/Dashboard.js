import { Typography, Grid, Paper } from "@mui/material";

import { useState } from "react";
import { executeOtlpQuery, executeDwQuery, syncWarehouse } from "../apis/api.js";
import { Box, Button, TextField } from "@mui/material";

export default function Dashboard() {
  const [query, setQuery] = useState("");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleOtlpQuery = async () => {
    try {
      setLoading(true);
      const data = await executeOtlpQuery(query);
      setResult(data);
    } catch (err) {
      console.error(err);
      setResult("Error executing OLTP query");
    } finally {
      setLoading(false);
    }
  };

  const handleDwQuery = async () => {
    try {
      setLoading(true);
      const data = await executeDwQuery(query);
      setResult(data);
    } catch (err) {
      console.error(err);
      setResult("Error executing DW query");
    } finally {
      setLoading(false);
    }
  };

  const handleSync = async () => {
    try {
      setLoading(true);
      const data = await syncWarehouse();
      setResult(data);
    } catch (err) {
      console.error(err);
      setResult("Error syncing warehouse");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box p={4}>
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>

      <Paper sx={{ p: 3, mb: 3 }}>
        <TextField
          label="SQL Query"
          multiline
          rows={4}
          fullWidth
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />

        <Box mt={2} display="flex" gap={2}>
          <Button
            variant="contained"
            onClick={handleOtlpQuery}
            disabled={loading}
          >
            Query OLTP
          </Button>

          <Button
            variant="contained"
            color="secondary"
            onClick={handleDwQuery}
            disabled={loading}
          >
            Query DW
          </Button>

          <Button
            variant="outlined"
            onClick={handleSync}
            disabled={loading}
          >
            Sync DW
          </Button>
        </Box>
      </Paper>

      <Paper sx={{ p: 3 }}>
        <Typography variant="h6">Result</Typography>
        <pre style={{ overflowX: "auto" }}>
          {JSON.stringify(result, null, 2)}
        </pre>
      </Paper>
    </Box>
  );
}