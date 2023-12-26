import { useState } from "react";

import { AlertColor } from "@mui/material/Alert";

import Split from "react-split";

import SideView from "../view/SideView";
import StatusView from "../view/StatusView";
import AlertPopup from "../components/AlertPopup";
import DesignView from "../view/DesignView";

export default function App() {
    const [status, setStatus] = useState<[AlertColor, string]>(["success", "Hello, world!"]);

    return (<>
        <Split
            className="split-flex"
            gutterSize={5}
            sizes={[50, 50]}
            direction="horizontal"
        >
            <DesignView />
            <Split
                gutterSize={5}
                sizes={[60, 40]}
                direction="vertical"
                style={{ height: "100vh" }}
            >
                <SideView />
                <StatusView />
            </Split>
        </Split>
        <AlertPopup
            posX="10px"
            posY="calc(100vh - 92px)"
            kind={status[0]}
            message={status[1]}
        />
    </>);
}
