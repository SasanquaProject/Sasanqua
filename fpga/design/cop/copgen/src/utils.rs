use serde::Serialize;
use tinytemplate::{format_unescaped, TinyTemplate};

pub trait TextGeneratable
where
    Self: Serialize + Sized,
{
    fn gen(self, template: &'static str) -> anyhow::Result<String> {
        let mut tt = TinyTemplate::new();
        tt.set_default_formatter(&format_unescaped);
        tt.add_template("Template", template)?;
        Ok(tt.render("Template", &self)?)
    }
}
