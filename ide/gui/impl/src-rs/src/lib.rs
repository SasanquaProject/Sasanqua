#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows",
)]

pub fn exec() -> anyhow::Result<()> {
    tauri::Builder::default()
        .any_thread()
        .run(tauri::generate_context!())?;
    Ok(())
}
