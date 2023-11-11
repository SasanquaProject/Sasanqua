use slint::Weak;
use rfd::FileDialog;

use crate::MainWindow;

pub fn pick_folder(window: Weak<MainWindow>) -> anyhow::Result<()> {
    match FileDialog::new().pick_folder() {
        Some(dir) => {
            let dir = dir.to_str().unwrap();
            window.unwrap().set_path(dir.into());
        }
        None => {}
    }

    Ok(())
}
