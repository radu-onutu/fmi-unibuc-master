import logo from './logo.svg';
import Companies from "./pages/Companies";
import Layout from "./components/Layout";
import Dashboard from "./pages/Dashboard";
import Shipments from "./pages/Shipments";
import Ships from "./pages/Ships";
import Analytics from "./pages/Analytics";
// import Dashboard from "./pages/Companies";
import './App.css';
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { ThemeProvider, createTheme, CssBaseline } from "@mui/material";

const darkTheme = createTheme({
  palette: {
    mode: "dark",
    primary: {
      main: "#1976d2"
    },
    background: {
      default: "#121212",
      paper: "#182029"
    }
  }
});

function App() {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <Router>
        <Routes>
          <Route element={<Layout />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/companies" element={<Companies />} />
            <Route path="/ships" element={<Ships />} />
            <Route path="/shipments" element={<Shipments />} />
            <Route path="/analytics" element={<Analytics />} />
          </Route>
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;