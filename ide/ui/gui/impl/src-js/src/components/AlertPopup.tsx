import { useState, useEffect } from "react";

import Alert, { AlertColor } from "@mui/material/Alert";
import AlertTitle from "@mui/material/AlertTitle";

type AlertPopupProps = {
    posX: string,
    posY: string,
    kind: AlertColor,
    message: string,
}

export default function AlertPopup(props: AlertPopupProps) {
    const toTitle = (s: string) => {
        return s.charAt(0).toUpperCase() + s.substring(1);
    };

    const [visible, setVisible] = useState<boolean>(false);
    const [message, setMessage] = useState<string>("");

    useEffect(() => setMessage(props.message), [props.message]);

    useEffect(() => {
        if (message.length > 0) {
            setVisible(true);
            setTimeout(() => setVisible(false), 10000);
        }
    }, [message])

    return (
        <div
            style={{
                position: "absolute",
                left: props.posX,
                top: props.posY,
                zIndex: 9999,
                visibility: (visible ? "visible" : "hidden"),
            }}
        >
            <Alert
                severity={props.kind}
                onClose={() => setVisible(false) }
            >
                <AlertTitle>{toTitle(props.kind)}</AlertTitle>
                {props.message}
            </Alert>
        </div>
    );
}
