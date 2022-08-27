#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();
    let app = axum::Router::new().route("/healthz", axum::routing::get(healthz));
    let addr = std::net::SocketAddr::from(([0, 0, 0, 0], 10067));
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

// curl -H Content-Type:application/json -d '{"command": "status-get", "service": ["dhcp4"]}' http://localhost:10080/

async fn healthz() -> axum::response::Result<(axum::http::StatusCode, &'static str)> {
    match status_get().await {
        Ok(_) => Ok((axum::http::StatusCode::OK, "ok")),
        Err(e) => {
            log::error!("Error: {e}");
            Ok((axum::http::StatusCode::INTERNAL_SERVER_ERROR, "not ok"))
        }
    }
}

async fn status_get() -> Result<(), anyhow::Error> {
    let payload = serde_json::json!({"command": "status-get", "service": ["dhcp4"]});

    let client = reqwest::Client::new();
    let resp = client
        .post("http://127.0.0.1:10080/")
        .json(&payload)
        .send()
        .await?;

    if resp.status().is_success() {
        let b = resp.json::<serde_json::Value>().await?;
        log::trace!("body: {}", &b);
        Ok(())
    } else {
        log::error!("status not ok: {}", resp.text().await?);
        Err(anyhow::anyhow!("status not ok"))
    }
}
