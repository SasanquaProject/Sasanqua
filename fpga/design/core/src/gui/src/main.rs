mod event;

use event::generate;

slint::include_modules!();

fn main() -> anyhow::Result<()> {
    let window = MainWindow::new()?;

    let window_weak = window.as_weak();
    window.on_generate(move || {
        let core = window_weak.clone().into();
        match generate::generate(core) {
            Ok(_) => {},
            Err(_) => {},
        }
    });

    window.run()?;
    Ok(())
}
