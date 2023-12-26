import { useState } from "react";

import Box from "@mui/material/Box";
import Tabs from "@mui/material/Tabs";
import Tab from "@mui/material/Tab";

import StatusPanel from "./SideView/StatusPanel";

type SideViewProps = {};

export default function SideView(props: SideViewProps) {
    const [tabStat, setTabStat] = useState<number>(0);

    return (
        <Box style={{ overflowY: "auto" }}>
            <Tabs
                value={tabStat}
                onChange={(_, newStat) => setTabStat(newStat)}
                centered
            >
                <Tab label="Design" />
                <Tab label="Synthesize" />
                <Tab label="App" />
                <Tab label="Run" />
            </Tabs>
            <div style={{
                margin: "8px",
                overflowY: "auto"
            }}>
                <StatusPanel />
            </div>
        </Box>
    );
}
