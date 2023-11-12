use std::collections::VecDeque;
use std::fmt::Debug;
use std::sync::{Arc, Mutex};
use std::thread;

pub trait Job<Id>
where
    Self: Debug + Send,
    Id: Debug + Send + Clone,
{
    fn id(&self) -> Id;
    fn process(&self) -> Box<dyn FnMut() -> anyhow::Result<()>>;
}

#[derive(Debug)]
pub enum JobMessage<Id>
where
    Id: Debug + Send + Clone,
{
    Start(Id),
    Finish(Id, anyhow::Result<()>),
}

#[derive(Debug)]
pub struct JobServer<JId>
where
    JId: Debug + Send + Clone,
{
    // Job status
    executing: Option<JId>,
    jqueue: Vec<Box<dyn Job<JId>>>,

    // Message Box
    mqueue: VecDeque<JobMessage<JId>>,
}

// for User impls
impl<JId> JobServer<JId>
where
    JId: Debug + Send + Clone + 'static ,
{
    pub fn new() -> Arc<Mutex<JobServer<JId>>> {
        let server = JobServer {
            executing: None,
            jqueue: vec![],
            mqueue: VecDeque::new(),
        };
        Arc::new(Mutex::new(server))
    }

    pub fn job(server: &Arc<Mutex<JobServer<JId>>>, job: Box<dyn Job<JId>>) {
        {
            let mut server_ref = server.lock().unwrap();
            server_ref.jqueue.push(job);
        }

        JobServer::start(Arc::clone(server));
    }

    pub fn recv(server: &Arc<Mutex<JobServer<JId>>>) -> Option<JobMessage<JId>> {
        let mut server_ref = server.lock().unwrap();
        server_ref.mqueue.pop_front()
    }

    pub fn recv_block(server: &Arc<Mutex<JobServer<JId>>>) -> JobMessage<JId> {
        loop {
            let mut server_ref = server.lock().unwrap();
            if let Some(msg) =  server_ref.mqueue.pop_front() {
                return msg;
            }
        }
    }
}

// for Internal-process impls
impl<JId> JobServer<JId>
where
    JId: Debug + Send + Clone + 'static,
{
    fn start(server: Arc<Mutex<JobServer<JId>>>) {
        let mut server_ref = server.lock().unwrap();

        if server_ref.executing.is_some() {
            return;
        }

        if let Some(func) = server_ref.jqueue.pop() {
            let id = func.id();
            server_ref.mqueue.push_back(JobMessage::Start(id.clone()));
            server_ref.executing = Some(id);

            let server = Arc::clone(&server);
            thread::spawn(move || {
                let result = func.process()();
                JobServer::finish(server, result);
            });
        }
    }

    fn finish(server: Arc<Mutex<JobServer<JId>>>, result: anyhow::Result<()>) {
        {
            let mut server_ref = server.lock().unwrap();
            let id = server_ref.executing.clone().unwrap();
            server_ref.mqueue.push_back(JobMessage::Finish(id, result));
            server_ref.executing = None;
        }

        JobServer::start(server);
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
                thread::sleep(Duration::from_millis(500));
                Ok(())
            })
        }
    }

    #[test]
    fn singlethread() {
        let server = JobServer::new();

        JobServer::job(&server, Box::new(TestJob(0)));
        JobServer::job(&server, Box::new(TestJob(1)));

        for _ in 0..4 {
            JobServer::recv_block(&server);
        }
    }

    #[test]
    fn multithread() {
        let server = JobServer::new();

        for id in 0..5 {
            let server_arc = Arc::clone(&server);
            thread::spawn(move || {
                JobServer::job(&server_arc, Box::new(TestJob(id)));
            });
        }

        for _ in 0..10 {
            JobServer::recv_block(&server);
        }
    }
}
