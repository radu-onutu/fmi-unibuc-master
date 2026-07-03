import { createTheme } from "@mui/material/styles";

const theme = createTheme({
  palette: {
    primary: {
      main: "#0D47A1", // deep ocean blue
    },
    secondary: {
      main: "#00838F", // teal maritime accent
    },
  },
  typography: {
    fontFamily: "Roboto, sans-serif",
  },
});

export default theme;