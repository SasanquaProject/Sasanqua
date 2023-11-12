use std::collections::VecDeque;
use std::fmt::Debug;
use std::sync::{Arc, Mutex};
use std::thread;

use serde::Deserialize;

use job::Job;

#[derive(Debug)]
pub enum JobMessage<Id>
where
    Id: Debug + Send + Clone,
{
    Start(Id),
    Finish(Id, anyhow::Result<Vec<u8>>),
}

impl<JId> JobMessage<JId>
where
    JId: Debug + Send + Clone,
{
    pub fn into<T>(self) -> Option<(JId, anyhow::Result<T>)>
    where
        T: for<'a> Deserialize<'a>,
    {
        if let JobMessage::Finish(id, result) = self {
            match result {
                Ok(result) => {
                    let result = rmp_serde::from_slice(&result).unwrap();
                    Some((id, Ok(result)))
                }
                Err(err) => Some((id, Err(err))),
            }
        } else {
            None
        }
    }
}

#[derive(Debug)]
pub struct JobServer<Ctx, JId>
where
    Ctx: Debug + Send + Clone,
    JId: Debug + Send + Clone,
{
    // Context
    ctx: Ctx,

    // Job status
    executing: Option<JId>,
    jqueue: Vec<Box<dyn Job<Ctx, JId>>>,

    // Message Box
    mqueue: VecDeque<JobMessage<JId>>,
}

// for User impls
impl<Ctx, JId> JobServer<Ctx, JId>
where
    Ctx: Debug + Send + Clone + 'static,
    JId: Debug + Send + Clone + 'static,
{
    pub fn new(ctx: Ctx) -> Arc<Mutex<JobServer<Ctx, JId>>> {
        let server = JobServer {
            ctx,
            executing: None,
            jqueue: vec![],
            mqueue: VecDeque::new(),
        };
        Arc::new(Mutex::new(server))
    }

    pub fn job(server: &Arc<Mutex<JobServer<Ctx, JId>>>, job: Box<dyn Job<Ctx, JId>>) {
        {
            let mut server_ref = server.lock().unwrap();
            server_ref.jqueue.push(job);
        }

        JobServer::start(Arc::clone(server));
    }

    pub fn recv(server: &Arc<Mutex<JobServer<Ctx, JId>>>) -> Option<JobMessage<JId>> {
        let mut server_ref = server.lock().unwrap();
        server_ref.mqueue.pop_front()
    }

    pub fn recv_block(server: &Arc<Mutex<JobServer<Ctx, JId>>>) -> JobMessage<JId> {
        loop {
            let mut server_ref = server.lock().unwrap();
            if let Some(msg) = server_ref.mqueue.pop_front() {
                return msg;
            }
        }
    }
}

// for Internal-process impls
impl<Ctx, JId> JobServer<Ctx, JId>
where
    Ctx: Debug + Send + Clone + 'static,
    JId: Debug + Send + Clone + 'static,
{
    fn start(server: Arc<Mutex<JobServer<Ctx, JId>>>) {
        let mut server_ref = server.lock().unwrap();

        if server_ref.executing.is_some() {
            return;
        }

        if let Some(func) = server_ref.jqueue.pop() {
            let id = func.id();
            server_ref.mqueue.push_back(JobMessage::Start(id.clone()));
            server_ref.executing = Some(id);

            let ctx = server_ref.ctx.clone();

            let server = Arc::clone(&server);
            thread::spawn(move || {
                let result = func.process()(ctx);
                JobServer::finish(server, result);
            });
        }
    }

    fn finish(server: Arc<Mutex<JobServer<Ctx, JId>>>, result: anyhow::Result<Vec<u8>>) {
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
    use std::sync::Arc;
    use std::thread;
    use std::time::Duration;

    use job::Job;

    use crate::{JobMessage, JobServer};

    #[derive(Debug)]
    struct TestJob(i32);

    impl Job<&'static str, i32> for TestJob {
        fn id(&self) -> i32 {
            self.0
        }

        fn process(&self) -> Box<dyn FnMut(&'static str) -> anyhow::Result<Vec<u8>>> {
            let id = self.id();
            Box::new(move |name| {
                thread::sleep(Duration::from_millis(500));

                let result = format!("Success: Job {} {}", name, id);
                let result = rmp_serde::to_vec(&result).unwrap();

                Ok(result)
            })
        }
    }

    #[test]
    fn singlethread() {
        let server = JobServer::<&'static str, _>::new("Test");

        JobServer::job(&server, Box::new(TestJob(0)));
        JobServer::job(&server, Box::new(TestJob(1)));

        for _ in 0..4 {
            if let msg @ JobMessage::Finish(..) = JobServer::recv_block(&server) {
                let (id, result) = msg.into::<String>().unwrap();
                assert_eq!(format!("Success: Job Test {}", id), result.unwrap());
            }
        }
    }

    #[test]
    fn multithread() {
        let server = JobServer::<&'static str, _>::new("Test");

        for id in 0..5 {
            let server_arc = Arc::clone(&server);
            thread::spawn(move || {
                JobServer::job(&server_arc, Box::new(TestJob(id)));
            });
        }

        for _ in 0..10 {
            if let msg @ JobMessage::Finish(..) = JobServer::recv_block(&server) {
                let (id, result) = msg.into::<String>().unwrap();
                assert_eq!(format!("Success: Job Test {}", id), result.unwrap());
            }
        }
    }
}
