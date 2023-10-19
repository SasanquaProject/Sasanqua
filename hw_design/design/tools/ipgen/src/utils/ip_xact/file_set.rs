use serde::{Serialize, Deserialize};

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FileSets {
    file_set: Vec<FileSet>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct FileSet {
    name: String,
    file: Vec<File>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct File {
    name: String,
    file_type: String,
}

#[cfg(test)]
mod test {
    use super::FileSets;

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
