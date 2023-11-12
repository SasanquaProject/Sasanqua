mod event;
mod ui;

use std::thread;

use slint::Weak;

use event::{generate, pick_folder};
use ui::input;

slint::include_modules!();

macro_rules! callback {
    ($window:ident . $event:ident, $func:path) => {
        let window_weak = $window.as_weak();
        $window.$event(move || {
            let ui = input::UI::from(window_weak.clone());
            let window = window_weak.clone();
            thread::spawn(move || {
                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_generating(true);
                    window.unwrap().set_err_message("".into())
                }));

                let ui = $func(ui);

                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_generating(false);
                    window.unwrap().set_path(ui.path.into());
                    window.unwrap().set_err_message(ui.err_msg.into());
                }));
            });
        });
    };
}

macro_rules! invoke_from_event_loop {
    ($window:expr => $body:tt) => {
        let window = $window.clone();
        slint::invoke_from_event_loop(move || $body(window)).unwrap();
    };
}

fn main() -> anyhow::Result<()> {
    let window = MainWindow::new()?;

    callback!(window.on_pick_folder, pick_folder);
    callback!(window.on_generate, generate);

    window.run()?;
    Ok(())
}
