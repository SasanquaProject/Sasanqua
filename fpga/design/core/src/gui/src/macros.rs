pub use std::thread;

pub use slint::Weak;

pub use crate::ui::input;

#[macro_export]
macro_rules! callback {
    ($window:ident . $event:ident => $func:path) => {
        let window_weak = $window.as_weak();
        $window.$event(move || {
            let ui = input::UI::from(window_weak.clone());
            let window = window_weak.clone();
            thread::spawn(move || {
                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_err_message("".into())
                }));

                let ui = $func(ui);

                invoke_from_event_loop!(window => (|window: Weak<MainWindow>| {
                    window.unwrap().set_path(ui.path.into());
                    window.unwrap().set_err_message(ui.err_msg.into());
                }));
            });
        });
    };

    ($window:ident . $event:ident => $func:path, with animation) => {
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
    }
}

#[macro_export]
macro_rules! invoke_from_event_loop {
    ($window:expr => $body:tt) => {
        let window = $window.clone();
        slint::invoke_from_event_loop(move || $body(window)).unwrap();
    };
}
