#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows",
)]

use tauri::{Menu, Submenu, MenuItem};

pub fn exec() -> anyhow::Result<()> {
    // Menu
    let menu = Menu::new()
        .add_native_item(MenuItem::Copy)
        .add_submenu(Submenu::new("Project", Menu::new()))
        .add_submenu(Submenu::new("Settings", Menu::new()))
        .add_submenu(Submenu::new("Help", Menu::new()))
        .add_submenu(Submenu::new("About", Menu::new()));

    // Window
    tauri::Builder::default()
        .any_thread()
        .menu(menu)
        .run(tauri::generate_context!())?;

    Ok(())
}
