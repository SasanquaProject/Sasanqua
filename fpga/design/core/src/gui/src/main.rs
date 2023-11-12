mod event;

use std::time::Duration;
use std::thread;

use slint::Weak;

use event::{generate, pick_folder};

slint::include_modules!();

macro_rules! callback {
    ($window:ident . $event:ident, $func:path) => {
        let window_weak = $window.as_weak();
        $window.$event(move || {
            let window = window_weak.clone();
            thread::spawn(move || {
                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_generating(true);
                    window.unwrap().set_err_message("".into())
                }));

                thread::sleep(Duration::from_millis(500));

                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    match $func(window.clone()){
                        Ok(_) => {},
                        Err(err) => {
                            let err = format!("Error: {}", err).into();
                            window.unwrap().set_err_message(err);
                        }
                    }
                }));

                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_generating(false);
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
