use core::ipc::{Sender, Receiver};
use core::command::Command;
use core::Runnable;

pub struct GUI;

impl Runnable for GUI {
    fn run(&self, _: Sender<Command>, _: Receiver<Command>) {
        gui_impl::exec().unwrap();
    }
}
