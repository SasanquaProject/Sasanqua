mod parent;
mod child;

pub use parent::Parent;
pub use child::{Child, Sender, Receiver};

#[cfg(test)]
mod test {
    use std::thread;
    use std::time::Duration;

    use rand::prelude::*;

    use super::{Parent, Child};

    #[test]
    fn ipc_1x1() {
        let parent = Parent::new();

        let child = Child::from(&parent);
        thread::spawn(move || {
            child.send(10).unwrap();
        });

        assert!(parent.pop() == 10);
    }

    #[test]
    fn ipc_1x60() {
        let mut rng = rand::thread_rng();

        let parent = Parent::new();

        for id in 1..=60 {
            let wait_msec = rng.gen_range(100..=1000);
            let child = Child::from(&parent);
            thread::spawn(move || {
                thread::sleep(Duration::from_millis(wait_msec));
                child.send(id).unwrap();
            });
        }

        let mut sum = 0;
        for _ in 1..=60 {
            sum += parent.pop();
        }
        assert_eq!(sum, (1+60)*30);
    }
}
