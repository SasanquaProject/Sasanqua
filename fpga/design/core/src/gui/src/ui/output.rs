use crate::ui::input;

#[derive(Debug, Default)]
pub struct UI {
    // Output
    pub path: String,

    // Error
    pub err_msg: String,
}

impl From<input::UI> for UI {
    fn from(input: input::UI) -> Self {
        UI {
            path: input.path,
            err_msg: "".to_string(),
        }
    }
}

impl UI {
    pub fn set_path<T: Into<String>>(self, path: T) -> UI {
        UI {
            path: path.into(),
            err_msg: self.err_msg,
        }
    }

    pub fn set_err(self, err: anyhow::Error) -> UI {
        UI {
            path: self.path,
            err_msg: err.to_string(),
        }
    }
}
