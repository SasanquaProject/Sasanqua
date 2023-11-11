mod event;

use event::{generate, pick_folder};

slint::include_modules!();

macro_rules! callback {
    ($window:ident . $event:ident, $func:path) => {
        let window_weak = $window.as_weak();
        $window.$event(move || {
            window_weak.unwrap().set_err_message("".into());
            match $func(window_weak.clone()){
                Ok(_) => {},
                Err(err) => {
                    let err = format!("Error: {}", err).into();
                    window_weak.unwrap().set_err_message(err);
                }
            }
        });
    };
}

fn main() -> anyhow::Result<()> {
    let window = MainWindow::new()?;

    callback!(window.on_pick_folder, pick_folder);
    callback!(window.on_generate, generate);

    window.run()?;
    Ok(())
}
