use std::marker::PhantomData;

use crate::profile::CopProfile;

pub trait CopImplTemplateStatus {}

pub type CopImpl = CopImplTemplate<AllFilled>;

pub struct CopImplTemplate<S: CopImplTemplateStatus> {
    status: PhantomData<S>,
    pub check: String,
    pub ready: String,
    pub exec: String,
}

pub struct Init;

impl CopImplTemplateStatus for Init {}

impl<P: CopProfile> From<&P> for CopImplTemplate<Init> {
    fn from(_: &P) -> Self {
        CopImplTemplate {
            status: PhantomData,
            check: "".to_string(),
            ready: "".to_string(),
            exec: "".to_string(),
        }
    }
}

impl CopImplTemplate<Init> {
    pub fn set_ready<T>(self, program: T) -> CopImplTemplate<ReadyFilled>
    where
        T: Into<String>,
    {
        CopImplTemplate {
            status: PhantomData,
            check: self.check,
            ready: program.into(),
            exec: self.exec,
        }
    }

    pub fn set_exec<T>(self, program: T) -> CopImplTemplate<ExecFilled>
    where
        T: Into<String>,
    {
        CopImplTemplate {
            status: PhantomData,
            check: self.check,
            ready: self.ready,
            exec: program.into(),
        }
    }
}

pub struct ReadyFilled;

impl CopImplTemplateStatus for ReadyFilled {}

impl CopImplTemplate<ReadyFilled> {
    pub fn set_exec<T>(self, program: T) -> CopImplTemplate<AllFilled>
    where
        T: Into<String>,
    {
        CopImplTemplate {
            status: PhantomData,
            check: self.check,
            ready: self.ready,
            exec: program.into(),
        }
    }
}

pub struct ExecFilled;

impl CopImplTemplateStatus for ExecFilled {}

impl CopImplTemplate<ExecFilled> {
    pub fn set_ready<T>(self, program: T) -> CopImplTemplate<AllFilled>
    where
        T: Into<String>,
    {
        CopImplTemplate {
            status: PhantomData,
            check: self.check,
            ready: program.into(),
            exec: self.exec,
        }
    }
}

pub struct AllFilled;

impl CopImplTemplateStatus for AllFilled {}

impl CopImplTemplate<AllFilled> {
    // ...
}

#[cfg(test)]
mod tests {
    use crate::profile::{CopImpl, CopImplTemplate, CopProfile, OpCode};

    pub struct TestCop;

    impl CopProfile for TestCop {
        fn opcodes(&self) -> Vec<(&'static str, OpCode)> {
            vec![]
        }

        fn body(&self) -> CopImpl {
            CopImplTemplate::from(&TestCop)
                .set_ready("Ready")
                .set_exec("Exec")
        }
    }

    #[test]
    fn fill_template_1() {
        let template = CopImplTemplate::from(&TestCop)
            .set_ready("Ready")
            .set_exec("Exec");
        assert_eq!(template.ready, "Ready");
        assert_eq!(template.exec, "Exec");
    }

    #[test]
    fn fill_template_2() {
        let template = CopImplTemplate::from(&TestCop)
            .set_exec("Exec")
            .set_ready("Ready");
        assert_eq!(template.ready, "Ready");
        assert_eq!(template.exec, "Exec");
    }
}
