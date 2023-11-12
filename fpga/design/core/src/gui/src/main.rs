mod event;
mod ui;
mod macros;

use event::{generate, pick_folder};
use macros::*;

slint::include_modules!();

fn main() -> anyhow::Result<()> {
    let window = MainWindow::new()?;

    callback!(window.on_pick_folder => pick_folder);
    callback!(window.on_generate => generate, with animation);

    window.run()?;
    Ok(())
}
