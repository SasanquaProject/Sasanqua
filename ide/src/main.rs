use core::Core;
use cui::CUI;
use gui::GUI;

fn main() -> anyhow::Result<()> {
    Core::new()
        .add_subprocess(CUI)
        .add_subprocess(GUI)
        .run()
}
