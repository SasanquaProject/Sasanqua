use std::sync::Arc;
use std::thread;

use command::Command;
use ipc::{Parent, Sender, Receiver};

pub trait Runnable: Send {
    fn run(&self, sender: Sender<Command>, receiver: Receiver<Command>);
}

pub struct Core {
    ipc_parent: Arc<Parent<Command>>,
    subprocesses: Vec<Box<dyn Runnable>>,
}

impl Core {
    pub fn new() -> Self {
        Core {
            ipc_parent: Parent::new(),
            subprocesses: vec![],
        }
    }

    pub fn add_subprocess<T>(mut self, body: T) -> Self
    where
        T: Runnable + 'static,
    {
        self.subprocesses.push(Box::new(body));
        self
    }

    pub fn run(self) -> anyhow::Result<()> {
        // Launch subprocess
        let threads = self
            .subprocesses
            .into_iter()
            .map(|subprocess| {
                let child = self.ipc_parent.spawn_child();
                let sender = Sender::from(&child);
                let receiver = Receiver::from(&child);
                thread::spawn(move || {
                    subprocess.run(sender, receiver);
                })
            })
            .collect::<Vec<_>>();

        // Event loop
        loop {
            // Receive a message
            if let Some(command) = self.ipc_parent.try_pop() {
                let ipc_parent = Arc::clone(&self.ipc_parent);
                thread::spawn(move || {
                    command.exec(ipc_parent);
                });
            }

            // Check subprocess
            if threads.iter().any(|thread| thread.is_finished()) {
                break;
            }
        }

        Ok(())
    }
}
