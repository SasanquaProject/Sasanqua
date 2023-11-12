use rfd::FileDialog;

use crate::ui::{input, output};

pub fn pick_folder(input: input::UI) -> anyhow::Result<output::UI> {
    match FileDialog::new().pick_folder() {
        Some(dir) => {
            let dir = dir.to_str().unwrap();
            Ok(output::UI::from(input).set_path(dir))
        }
        None => {
            Ok(output::UI::from(input))
        }
    }
}
