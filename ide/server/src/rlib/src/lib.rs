use std::fmt::Debug;
use std::sync::{Arc, Mutex};
use std::thread;

pub trait Job<T>
where
    Self: Debug + Send,
    T: Debug + Send + Clone,
{
    fn id(&self) -> T;
    fn process(&self) -> Box<dyn FnMut() -> anyhow::Result<()>>;
}

#[derive(Debug)]
pub struct JobServer<T>
where
    T: Debug + Send + Clone,
{
    executing: Option<T>,
    queue: Vec<Box<dyn Job<T>>>,
}

// for User impls
impl<T> JobServer<T>
where
    T: Debug + Send + Clone + 'static ,
{
    pub fn new() -> Arc<Mutex<JobServer<T>>> {
        let server = JobServer {
            executing: None,
            queue: vec![],
        };
        Arc::new(Mutex::new(server))
    }

    pub fn job(server: &Arc<Mutex<JobServer<T>>>, job: Box<dyn Job<T>>) {
        {
            let mut server_ref = server.lock().unwrap();
            server_ref.queue.push(job);
        }

        JobServer::start(&server);
    }

    pub fn wait(server: &Arc<Mutex<JobServer<T>>>) {
        loop {
            let server_ref = server.lock().unwrap();
            if server_ref.executing.is_none() {
                break;
            }
        }
    }
}

// for Internal-process impls
impl<T> JobServer<T>
where
    T: Debug + Send + Clone + 'static,
{
    fn start(server: &Arc<Mutex<JobServer<T>>>) {
        let mut server_ref = server.lock().unwrap();

        if server_ref.executing.is_some() {
            return;
        }

        if let Some(func) = server_ref.queue.pop() {
            server_ref.executing = Some(func.id().clone());

            let server = Arc::clone(&server);
            thread::spawn(move || {
                let result = func.process()();
                JobServer::finish(server, result);
            });
        }
    }

    fn finish(server: Arc<Mutex<JobServer<T>>>, _: anyhow::Result<()>) {
        {
            let mut server_ref = server.lock().unwrap();
            server_ref.executing = None;
        }

        JobServer::start(&server);
    }
}

#[cfg(test)]
mod test {
    use std::thread;
    use std::time::Duration;
    use std::sync::Arc;

    use crate::{JobServer, Job};

    #[derive(Debug)]
    struct TestJob(i32);

    impl Job<i32> for TestJob {
        fn id(&self) -> i32 {
            self.0
        }

        fn process(&self) -> Box<dyn FnMut() -> anyhow::Result<()>> {
            Box::new(move || {
                thread::sleep(Duration::from_secs(1));
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
