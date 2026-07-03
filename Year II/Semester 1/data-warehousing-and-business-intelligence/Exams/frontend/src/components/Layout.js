import { Toolbar, Container } from "@mui/material";
import { Outlet } from "react-router-dom";
import Navbar from "./Navbar";
import { ThemeProvider, createTheme, CssBaseline } from "@mui/material";

const navbarTheme = createTheme({
  palette: {
    mode: "dark",
    primary: {
      main: "#1976d2"
    },
    background: {
      default: "#091c2b",
      paper: "#0c2742"
    }
  }
});

export default function Layout() {
  return (
    <>
    <ThemeProvider theme={navbarTheme}>
          <CssBaseline />
      <Navbar />
    </ThemeProvider>

      {/* spacing below fixed AppBar */}
      <Toolbar />

      <Container maxWidth="lg" sx={{ mt: 2 }}>
        <Outlet />
      </Container>
    </>
  );
}
