use crate::ui::input;

#[derive(Debug, Default)]
pub struct UI {
    // Output
    pub path: String,
}

impl From<input::UI> for UI {
    fn from(input: input::UI) -> Self {
        UI {
            path: input.path,
        }
    }
}

impl UI {
    pub fn set_path<T: Into<String>>(self, path: T) -> UI {
        UI {
            path: path.into(),
        }
    }
}
