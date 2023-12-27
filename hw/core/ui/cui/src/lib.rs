mod cmd;

pub fn run() -> anyhow::Result<()> {
    cmd::App::run()
}
