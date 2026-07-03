import { Link } from "react-router-dom";
import { AppBar, Toolbar, Typography, Box, IconButton, Avatar } from "@mui/material";
import DirectionsBoatIcon from "@mui/icons-material/DirectionsBoat";
import NotificationsIcon from "@mui/icons-material/Notifications";

export default function Navbar() {
  return (
    <AppBar position="static" elevation={2}>
      <Toolbar>

        {/* Logo / App Title */}
        <DirectionsBoatIcon sx={{ mr: 2 }} />
        <Typography variant="h6" sx={{ flexGrow: 1 }}>
          Maritime DW-BI System
        </Typography>

        {/* Navigation Links */}
        <Box sx={{ display: "flex", gap: 3 }}>
          <Link to="/" style={{ color: "inherit", textDecoration: "none" }}>
            Dashboard
          </Link>
          <Link to="/companies" style={{ color: "inherit", textDecoration: "none" }}>
            Companies
          </Link>
          <Link to="/ships" style={{ color: "inherit", textDecoration: "none" }}>
            Ships
          </Link>
          <Link to="/shipments" style={{ color: "inherit", textDecoration: "none" }}>
            Shipments
          </Link>
          {/* <Link to="/etl" style={{ color: "inherit", textDecoration: "none" }}>
            ETL
          </Link> */}
          <Link to="/analytics" style={{ color: "inherit", textDecoration: "none" }}>
            Analytics
          </Link>
        </Box>  

      </Toolbar>
    </AppBar>
  );
}
