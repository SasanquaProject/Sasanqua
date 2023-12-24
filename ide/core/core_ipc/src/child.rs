use std::collections::VecDeque;
use std::fmt::Debug;
use std::sync::{Arc, Mutex};

use super::Parent;

pub struct Child<M>
where
    Self: Send + Sync,
    M: Debug + Send + Sync + Clone,
{
    parent: Mutex<Arc<Parent<M>>>,
    received_msgs: Mutex<VecDeque<M>>,
}

impl<M> Child<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub(super) fn from(parent: &Arc<Parent<M>>) -> Arc<Self> {
        let child = Child {
            parent: Mutex::new(Arc::clone(parent)),
            received_msgs: Mutex::new(VecDeque::new()),
        };
        Arc::new(child)
    }
}

impl<M> Child<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub fn send(self: &Arc<Self>, msg: M) -> anyhow::Result<()> {
        self.parent
            .lock()
            .unwrap()
            .receive(msg);
        Ok(())
    }

    pub(super) fn receive(self: &Arc<Self>, msg: M) {
        self.received_msgs
            .lock()
            .unwrap()
            .push_back(msg);
    }

    pub fn pop(self: &Arc<Self>) -> M {
        loop {
            if self.received_msgs.lock().unwrap().len() > 0 {
                break;
            }
        }

        self.received_msgs
            .lock()
            .unwrap()
            .pop_front()
            .unwrap()
    }

    pub fn try_pop(self: &Arc<Self>) -> Option<M> {
        self.received_msgs
            .lock()
            .unwrap()
            .pop_front()
    }
}

pub struct Sender<M>(Arc<Child<M>>)
where
    Self: Send + Sync,
    M: Debug + Send + Sync + Clone;

impl<M> From<&Arc<Child<M>>> for Sender<M>
where
    M: Debug + Send + Sync + Clone,
{
    fn from(base: &Arc<Child<M>>) -> Self {
        Sender(Arc::clone(base))
    }
}

impl<M> Sender<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub fn send(&self, msg: M) -> anyhow::Result<()> {
        self.0.send(msg)
    }
}

pub struct Receiver<M>(Arc<Child<M>>)
where
    Self: Send + Sync,
    M: Debug + Send + Sync + Clone;

impl<M> From<&Arc<Child<M>>> for Receiver<M>
where
    M: Debug + Send + Sync + Clone,
{
    fn from(base: &Arc<Child<M>>) -> Self {
        Receiver(Arc::clone(base))
    }
}

impl<M> Receiver<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub fn pop(&self) -> M {
        self.0.pop()
    }

    pub fn try_pop(&self) -> Option<M> {
        self.0.try_pop()
    }
}
