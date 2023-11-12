use std::fmt::Debug;

pub trait Job<Id>
where
    Self: Debug + Send,
    Id: Debug + Send + Clone,
{
    fn id(&self) -> Id;
    fn process(&self) -> Box<dyn FnMut() -> anyhow::Result<Vec<u8>>>;
}
