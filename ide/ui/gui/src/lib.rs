use core::ipc::child::{Sender, Receiver};
use core::command::Command;
use core::Runnable;

pub struct GUI;

impl GUI {
    pub fn new() -> Box<dyn Runnable> {
        Box::new(GUI)
    }
}

impl Runnable for GUI {
    fn run(&self, _: Sender<Command>, _: Receiver<Command>) {
        gui_impl::exec().unwrap();
    }
}
