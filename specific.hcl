# Auto-generated session/cookie signing key. Umami requires >=32 chars;
# generated secrets default to 64.
secret "umami_app_secret" {
  generated = true
}

service "web" {
  # Upstream Umami's official multi-arch image. Bundles the Next.js
  # standalone build, Prisma client, tracker script, geo data, and an
  # entrypoint (start-docker) that applies migrations on boot before
  # starting the server.
  image   = "ghcr.io/umami-software/umami:latest"
  command = "pnpm start-docker"

  endpoint {
    public = true
    health_check {
      path = "/api/heartbeat"
    }
  }

  env = {
    PORT              = port
    DATABASE_URL      = postgres.main.url
    APP_SECRET        = secret.umami_app_secret
    DISABLE_TELEMETRY = "1"
  }
}

postgres "main" {}
