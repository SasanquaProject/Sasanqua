slint::slint! {
    export component MainWindow inherits Window {
        width: 128px;
        height: 128px;

        Text {
            text: "hello world";
            color: green;
        }
    }
}

fn main() -> anyhow::Result<()> {
    MainWindow::new()?.run()?;
    Ok(())
}
