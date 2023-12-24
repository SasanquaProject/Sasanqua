use ipc::parent::Sender;

#[derive(Debug, Clone)]
pub enum Command {
    Duumy(String),
}

impl Command {
    pub fn exec(self, _: Sender<Command>) {
        // ...
    }
}
