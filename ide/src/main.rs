use core::Core;

fn main() -> anyhow::Result<()> {
    let subprocesses = [
        #[cfg(feature = "cui")]
        cui::CUI::new(),
        #[cfg(feature = "tui")]
        tui::TUI::new(),
        #[cfg(feature = "gui")]
        gui::GUI::new(),
    ];
    Core::from(subprocesses).run()
}
