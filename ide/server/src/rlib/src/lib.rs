use std::fmt::Debug;
use std::sync::{Arc, Mutex};
use std::thread;

pub trait Job
where
    Self: Debug + Send,
{
    fn process(&self) -> Box<dyn FnMut() -> anyhow::Result<()>>;
}

#[derive(Debug)]
pub struct JobServer {
    executing: bool,
    queue: Vec<Box<dyn Job>>,
}

// for User impls
impl JobServer {
    pub fn new() -> Arc<Mutex<JobServer>> {
        let server = JobServer {
            executing: false,
            queue: vec![],
        };
        Arc::new(Mutex::new(server))
    }

    pub fn job(server: &Arc<Mutex<JobServer>>, job: Box<dyn Job>) {
        {
            let mut server_ref = server.lock().unwrap();
            server_ref.queue.push(job);
        }

        JobServer::start(&server);
    }

    pub fn wait(server: &Arc<Mutex<JobServer>>) {
        loop {
            let server_ref = server.lock().unwrap();
            if !server_ref.executing {
                break;
            }
        }
    }
}

// for Internal-process impls
impl JobServer {
    fn start(server: &Arc<Mutex<JobServer>>) {
        let mut server_ref = server.lock().unwrap();

        if server_ref.executing {
            return;
        }

        if let Some(func) = server_ref.queue.pop() {
            server_ref.executing = true;

            let server = Arc::clone(&server);
            thread::spawn(move || {
                let result = func.process()();
                JobServer::finish(server, result);
            });
        }
    }

    fn finish(server: Arc<Mutex<JobServer>>, _: anyhow::Result<()>) {
        {
            let mut server_ref = server.lock().unwrap();
            server_ref.executing = false;
        }

        JobServer::start(&server);
    }
}

#[cfg(test)]
mod test {
    use std::io::{stdout, Write};
    use std::thread;
    use std::time::Duration;
    use std::sync::Arc;

    use crate::{JobServer, Job};

    #[derive(Debug)]
    struct TestJob(i32);

    impl Job for TestJob {
        fn process(&self) -> Box<dyn FnMut() -> anyhow::Result<()>> {
            let id = self.0;
            Box::new(move || {
                print!("Hi! I'm ... ");
                stdout().flush().unwrap();
                thread::sleep(Duration::from_secs(1));
                println!("TestJob {} !!!", id);

                Ok(())
            })
        }
    }

    #[test]
    fn test() {
        println!("### Simple ###");
        simple();
        println!("##############\n");

        println!("### Multithread ###");
        new_job_by_multithread();
        println!("###################\n");
    }

    fn simple() {
        let server = JobServer::new();
        JobServer::job(&server, Box::new(TestJob(0)));
        JobServer::job(&server, Box::new(TestJob(1)));
        JobServer::wait(&server);
    }

    fn new_job_by_multithread() {
        let server = JobServer::new();

        let server_arc = Arc::clone(&server);
        thread::spawn(move || {
            JobServer::job(&server_arc, Box::new(TestJob(0)));
        });

        let server_arc = Arc::clone(&server);
        thread::spawn(move || {
            JobServer::job(&server_arc, Box::new(TestJob(1)));
        });

        thread::sleep(Duration::from_millis(500));
        JobServer::wait(&server);
    }
}
