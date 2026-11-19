//! FediFinance HTTP API (skeleton).

/// Name of the application, reported by the binary and later by the health endpoint.
pub const APP_NAME: &str = "FediFinance";

/// Returns the banner printed at startup.
pub fn banner() -> String {
    format!("{APP_NAME} API {}", env!("CARGO_PKG_VERSION"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn banner_contains_name_and_version() {
        let banner = banner();
        assert!(banner.starts_with(APP_NAME));
        assert!(banner.ends_with(env!("CARGO_PKG_VERSION")));
    }
}
