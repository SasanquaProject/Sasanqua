use serde::{Deserialize, Serialize};
use vfs::VfsPath;

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FileSets {
    file_set: Vec<FileSet>,
}

impl FileSets {
    pub fn new() -> Self {
        FileSets { file_set: vec![] }
    }

    pub fn add_file_set(mut self, file_set: FileSet) -> Self {
        self.file_set.push(file_set);
        self
    }
}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct FileSet {
    name: String,
    file: Vec<File>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct File {
    name: String,
    file_type: String,
}

impl FileSet {
    pub fn new<S: Into<String>>(name: S) -> Self {
        FileSet {
            name: name.into(),
            file: vec![],
        }
    }

    pub fn add_file<S: Into<String>>(mut self, name: S, file_type: S) -> Self {
        let name = name.into();
        let file_type = file_type.into();

        self.file.push(File { name, file_type });

        self
    }

    pub fn add_files<S: Into<String>>(
        mut self,
        fs: &VfsPath,
        file_type: S,
    ) -> anyhow::Result<Self> {
        let file_type = file_type.into();
        let files = fs
            .walk_dir()?
            .into_iter()
            .filter_map(|f| f.ok())
            .map(|f| File {
                name: f.as_str().to_string(),
                file_type: file_type.clone(),
            });

        self.file.extend(files.into_iter());

        Ok(self)
    }
}

#[cfg(test)]
mod test {
    use super::{FileSet, FileSets};

    #[test]
    fn serialize() {
        let file_sets = FileSets::new()
            .add_file_set(
                FileSet::new("fileSet1")
                    .add_file("a.v", "verilogSource")
                    .add_file("b.v", "verilogSource"),
            )
            .add_file_set(
                FileSet::new("fileSet2")
                    .add_file("a.v", "verilogSource")
                    .add_file("b.v", "verilogSource"),
            );

        assert!(quick_xml::se::to_string(&file_sets).is_ok());
    }

    #[test]
    fn deserialize() {
        let sample = r#"
            <?xml version="1.0" encoding="UTF-8"?>
            <spirit:fileSets>
                <spirit:fileSet>
                    <spirit:name>xilinx_verilogsynthesis_view_fileset</spirit:name>
                    <spirit:file>
                        <spirit:name>../../../../design/src/mem/axi/cache.v</spirit:name>
                        <spirit:fileType>verilogSource</spirit:fileType>
                    </spirit:file>
                    <spirit:file>
                        <spirit:name>../../../../design/src/core/components/pipeline/check.v</spirit:name>
                        <spirit:fileType>verilogSource</spirit:fileType>
                    </spirit:file>
                    <spirit:file>
                        <spirit:name>../../../../design/src/peripherals/clint.v</spirit:name>
                        <spirit:fileType>verilogSource</spirit:fileType>
                    </spirit:file>
                </spirit:fileSet>
                <spirit:fileSet>
                    <spirit:name>bd_tcl_view_fileset</spirit:name>
                    <spirit:file>
                        <spirit:name>bd/bd.tcl</spirit:name>
                        <spirit:fileType>tclSource</spirit:fileType>
                    </spirit:file>
                </spirit:fileSet>
            </spirit:fileSets>
        "#;

        let res = quick_xml::de::from_str::<FileSets>(sample);
        println!("{:?}", res);
        assert!(res.is_ok());
    }
}
