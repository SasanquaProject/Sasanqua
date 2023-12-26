use std::collections::VecDeque;
use std::fmt::Debug;
use std::sync::{Arc, Mutex};

use super::Child;

pub struct Parent<M>
where
    Self: Send + Sync,
    M: Debug + Send + Sync + Clone,
{
    children: Mutex<Vec<Arc<Child<M>>>>,
    received_msgs: Mutex<VecDeque<M>>,
}

impl<M> Parent<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub fn new() -> Arc<Self> {
        let parent = Parent {
            children: Mutex::new(vec![]),
            received_msgs: Mutex::new(VecDeque::new()),
        };
        Arc::new(parent)
    }

    pub fn spawn_child(self: &Arc<Self>) -> Arc<Child<M>> {
        let child = Child::from(self);

        self.children
            .lock()
            .as_mut()
            .unwrap()
            .push(Arc::clone(&child));

        child
    }

    pub(super) fn receive(self: &Arc<Self>, msg: M) {
        self.received_msgs
            .lock()
            .unwrap()
            .push_back(msg);
    }

    pub fn channel(self: &Arc<Self>) -> (Sender<M>, Receiver<M>) {
        (Sender::from(self), Receiver::from(self))
    }
}

pub struct Sender<M>(Arc<Parent<M>>)
where
    Self: Send + Sync,
    M: Debug + Send + Sync + Clone;

impl<M> From<&Arc<Parent<M>>> for Sender<M>
where
    M: Debug + Send + Sync + Clone,
{
    fn from(base: &Arc<Parent<M>>) -> Self {
        Sender(Arc::clone(base))
    }
}

impl<M> Clone for Sender<M>
where
    M: Debug + Send + Sync + Clone,
{
    fn clone(&self) -> Self {
        Sender(Arc::clone(&self.0))
    }
}

impl<M> Sender<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub fn send(&self, msg: M) -> anyhow::Result<()> {
        self.0
            .children
            .lock()
            .unwrap()
            .iter()
            .for_each(|child| child.receive(msg.clone()));
        Ok(())
    }
}

pub struct Receiver<M>(Arc<Parent<M>>)
where
    Self: Send + Sync,
    M: Debug + Send + Sync + Clone;

impl<M> From<&Arc<Parent<M>>> for Receiver<M>
where
    M: Debug + Send + Sync + Clone,
{
    fn from(base: &Arc<Parent<M>>) -> Self {
        Receiver(Arc::clone(base))
    }
}

impl<M> Receiver<M>
where
    M: Debug + Send + Sync + Clone,
{
    pub fn pop(&self) -> M {
        loop {
            if self.0.received_msgs.lock().unwrap().len() > 0 {
                break;
            }
        }

        self.0
            .received_msgs
            .lock()
            .unwrap()
            .pop_front()
            .unwrap()
    }

    pub fn try_pop(&self) -> Option<M> {
        self.0
            .received_msgs
            .lock()
            .unwrap()
            .pop_front()
    }
}
