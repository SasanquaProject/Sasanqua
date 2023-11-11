mod event;

use event::generate;

slint::include_modules!();

macro_rules! callback {
    ($window:ident . $event:ident, $func:path) => {
        let window_weak = $window.as_weak();
        $window.$event(move || { $func(window_weak.clone()).unwrap() } );
    };
}

fn main() -> anyhow::Result<()> {
    let window = MainWindow::new()?;

    callback!(window.on_generate, generate::generate);

    window.run()?;
    Ok(())
}
