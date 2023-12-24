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

    pub fn send(self: &Arc<Self>, msg: M) -> anyhow::Result<()> {
        self.children
            .lock()
            .unwrap()
            .iter()
            .for_each(|child| child.receive(msg.clone()));
        Ok(())
    }

    pub(super) fn receive(self: &Arc<Self>, msg: M)  {
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
