use std::io::Write;
use std::io;

use core::ipc::{Sender, Receiver};
use core::command::Command;
use core::Runnable;

pub struct CUI;

impl Runnable for CUI {
    fn run(&self, sender: Sender<Command>, _: Receiver<Command>) {
        loop {
            print!(">> ");
            io::stdout().flush().unwrap();

            let mut line = String::new();
            io::stdin().read_line(&mut line).unwrap();

            sender.send(Command::Duumy(line)).unwrap();

            println!("");
        }
    }
}
