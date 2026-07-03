import { Grid, Paper, Typography } from "@mui/material";

const metrics = [
  { label: "Total Companies", value: 42 },
  { label: "Active Vessels", value: 128 },
  { label: "Shipments This Month", value: 356 },
  { label: "Pending Invoices", value: 18 }
];

export default function DashboardCards() {
  return (
    <Grid container spacing={3}>
      {metrics.map((metric, index) => (
        <Grid item xs={12} sm={6} md={3} key={index}>
          <Paper
            sx={{
              p: 3,
              textAlign: "center",
              transition: "0.2s",
              "&:hover": {
                boxShadow: 6
              }
            }}
          >
            <Typography variant="h6" color="text.secondary">
              {metric.label}
            </Typography>
            <Typography variant="h4" sx={{ mt: 1 }}>
              {metric.value}
            </Typography>
          </Paper>
        </Grid>
      ))}
    </Grid>
  );
}
