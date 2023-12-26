import Box from "@mui/material/Box";

type StatusViewProps = {};

export default function StatusView(props: StatusViewProps) {
    return (
        <Box style={{ overflowY: "auto" }}>
            <h1>Status View</h1>
            <p>This is sample text.</p>
        </Box>
    );
}
