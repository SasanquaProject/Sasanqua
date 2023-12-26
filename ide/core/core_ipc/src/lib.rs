pub mod parent;
pub mod child;

pub use child::Child;
pub use parent::Parent;

#[cfg(test)]
mod test {
    use std::thread;
    use std::time::Duration;

    use rand::prelude::*;

    use super::{Parent, Child};

    #[test]
    fn ipc_1x1() {
        let parent = Parent::new();
        let (_, parent_rx) = parent.channel();

        let (child_tx, _) = Child::from(&parent).channel();
        thread::spawn(move || {
            child_tx.send(10).unwrap();
        });

        assert!(parent_rx.pop() == 10);
    }

    #[test]
    fn ipc_1x60() {
        let mut rng = rand::thread_rng();

        let parent = Parent::new();
        let (_, parent_rx) = parent.channel();

        for id in 1..=60 {
            let wait_msec = rng.gen_range(100..=1000);
            let (child_tx, _) = Child::from(&parent).channel();
            thread::spawn(move || {
                thread::sleep(Duration::from_millis(wait_msec));
                child_tx.send(id).unwrap();
            });
        }

        let mut sum = 0;
        for _ in 1..=60 {
            sum += parent_rx.pop();
        }
        assert_eq!(sum, (1+60)*30);
    }
}
