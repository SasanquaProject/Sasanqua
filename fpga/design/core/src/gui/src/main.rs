slint::include_modules!();

fn main() -> anyhow::Result<()> {
    MainWindow::new()?.run()?;
    Ok(())
}
