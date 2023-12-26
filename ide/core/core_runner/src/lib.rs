use std::sync::Arc;
use std::time::Duration;
use std::thread;

use command::Command;
use ipc::{Parent, child};

pub trait Runnable: Send {
    fn run(&self, tx: child::Sender<Command>, rx: child::Receiver<Command>);
}

pub struct Core {
    ipc_parent: Arc<Parent<Command>>,
    subprocesses: Vec<Box<dyn Runnable>>,
}

impl<const N: usize> From<[Box<dyn Runnable>; N]> for Core {
    fn from(subprocesses: [Box<dyn Runnable>; N]) -> Self {
        Core {
            ipc_parent: Parent::new(),
            subprocesses: subprocesses.into(),
        }
    }
}

impl Core {
    pub fn run(self) -> anyhow::Result<()> {
        assert!(self.subprocesses.len() > 0);

        // Launch subprocess
        let threads = self
            .subprocesses
            .into_iter()
            .map(|subprocess| {
                let (tx, rx) = self.ipc_parent.spawn_child().channel();
                thread::spawn(move || subprocess.run(tx, rx) )
            })
            .collect::<Vec<_>>();

        // Event loop
        let (tx, rx) = self.ipc_parent.channel();
        loop {
            // Receive a message
            if let Some(command) = rx.try_pop() {
                let tx = tx.clone();
                thread::spawn(move || command.exec(tx) );
            }

            // Check subprocess
            if threads.iter().any(|thread| thread.is_finished()) {
                break;
            }

            thread::sleep(Duration::from_millis(10));
        }

        Ok(())
    }
}
