#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows",
)]

pub fn exec() -> anyhow::Result<()> {
    tauri::Builder::default()
        .run(tauri::generate_context!())?;
    Ok(())
}
