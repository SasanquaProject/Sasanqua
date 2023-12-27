fn main() {
    #[cfg(feature = "cui")]
    {
        cui::run().unwrap();
    }
    #[cfg(feature = "gui")]
    {
        gui::run().unwrap();
    }
}
