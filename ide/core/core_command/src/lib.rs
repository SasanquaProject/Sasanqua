use std::sync::Arc;

use ipc::Parent;

#[derive(Debug, Clone)]
pub enum Command {
    Duumy(String),
}

impl Command {
    pub fn exec(self, _: Arc<Parent<Command>>) {
        // ...
    }
}
