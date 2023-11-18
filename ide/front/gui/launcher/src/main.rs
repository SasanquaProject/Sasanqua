use ui::*;

fn main() -> anyhow::Result<()> {
    MainWindow::new()?.run()?;
    Ok(())
}
