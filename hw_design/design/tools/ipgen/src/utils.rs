use vfs::VfsPath;

pub fn merge_vfs(dst: &mut VfsPath, dst_dir: &str, src: VfsPath) -> anyhow::Result<()> {
    src.walk_dir()?
        .into_iter()
        .filter_map(|f| f.ok())
        .try_for_each(|f| {
            let path = format!("{}/{}", dst_dir, f.as_str());
            if f.is_file().unwrap() {
                let content = f.read_to_string()?;
                dst.join(path)?
                    .create_file()?
                    .write_all(content.as_bytes())?;
            } else if f.is_dir().unwrap() {
                dst.join(path)?.create_dir()?;
            }
            anyhow::Ok(())
        })
}