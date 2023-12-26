import Box from "@mui/material/Box";

type DesignViewProps = {};

export default function DesignView(props: DesignViewProps) {
    return (
        <Box style={{ overflowY: "auto" }}>
            <h1>Design View</h1>
            <p>This is sample text.</p>
        </Box>
    );
}
