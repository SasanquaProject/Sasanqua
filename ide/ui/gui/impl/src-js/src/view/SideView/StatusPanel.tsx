import Box from "@mui/material/Box";
import Alert from "@mui/material/Alert";

export default function StatusPanel() {
    return (
        <Box>
            <h3>Error</h3>
            <Alert severity="success">There are no errors in this project.</Alert>
            <h3>Warning</h3>
            <Alert severity="success">There are no warnings in this project.</Alert>
        </Box>
    );
}
