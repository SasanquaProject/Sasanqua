pub use std::thread;

pub use slint::Weak;

pub use crate::ui::{input, output};

#[macro_export]
macro_rules! callback {
    ($window:ident . $event:ident => $func:path) => {
        callback_body!($window, $event, $func, false)
    };

    ($window:ident . $event:ident => $func:path, with animation) => {
        callback_body!($window, $event, $func, true)
    };
}

#[macro_export]
macro_rules! callback_body {
    ($window:ident, $event:ident, $func:path, $animation:expr) => {
        let window_weak = $window.as_weak();
        $window.$event(move || {
            let ui = input::UI::from(window_weak.clone());
            let window = window_weak.clone();
            thread::spawn(move || {
                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_generating($animation);
                    window.unwrap().set_err_message("".into())
                }));

                let old_ui = output::UI::from(ui.clone());
                let new_ui = $func(ui);

                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_generating(false);
                    match new_ui {
                        Ok(ui) => window.unwrap().set_path(ui.path.into()),
                        Err(err) => {
                            window.unwrap().set_path(old_ui.path.into());
                            window.unwrap().set_err_message(err.to_string().into());
                        }
                    }
                }));
            });
        });
    }
}

#[macro_export]
macro_rules! invoke_from_event_loop {
    ($window:expr => $body:tt) => {
        let window = $window.clone();
        slint::invoke_from_event_loop(move || $body(window)).unwrap();
    };
}
