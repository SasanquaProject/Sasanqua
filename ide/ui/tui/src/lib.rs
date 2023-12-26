use core::ipc::child::{Sender, Receiver};
use core::command::Command;
use core::Runnable;

pub struct TUI;

impl TUI {
    pub fn new() -> Box<dyn Runnable> {
        Box::new(TUI)
    }
}

impl Runnable for TUI {
    fn run(&self, _: Sender<Command>, _: Receiver<Command>) {
        unimplemented!()
    }
}
