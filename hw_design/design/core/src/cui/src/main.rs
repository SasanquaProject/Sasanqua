mod cmd;

fn main() -> anyhow::Result<()> {
    cmd::App::run()
}
