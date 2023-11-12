use std::fmt::Debug;

pub trait Job<Ctx, Id>
where
    Self: Debug + Send,
    Ctx: Debug + Send + Clone,
    Id: Debug + Send + Clone,
{
    fn id(&self) -> Id;
    fn process(&self) -> Box<dyn FnMut(Ctx) -> anyhow::Result<Vec<u8>>>;
}
