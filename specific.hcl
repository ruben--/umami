build "web" {
  base = "node"
  # Umami uses pnpm + a multi-step build (prisma generate, tracker bundle,
  # geo download, next build --turbo). build-docker mirrors what the
  # upstream Dockerfile does and skips the runtime-only check-env /
  # check-db steps. prisma generate reads DATABASE_URL from schema.prisma
  # even though it doesn't connect, so we provide a throwaway URL during
  # the build (same trick as upstream Dockerfile).
  command = "npm install -g pnpm && pnpm install --frozen-lockfile && DATABASE_URL=postgresql://user:pass@localhost:5432/dummy pnpm run build-docker"
}

# Auto-generated session/cookie signing key. Umami requires >=32 chars;
# generated secrets default to 64.
secret "umami_app_secret" {
  generated = true
}

service "web" {
  build   = build.web
  command = "pnpm start"

  endpoint {
    public = true
    health_check {
      path = "/api/heartbeat"
    }
  }

  env = {
    HOSTNAME          = "0.0.0.0"
    PORT              = port
    DATABASE_URL      = postgres.main.url
    DATABASE_TYPE     = "postgresql"
    APP_SECRET        = secret.umami_app_secret
    DISABLE_TELEMETRY = "1"
    NODE_ENV          = "production"
  }

  # Prisma migrations run before the new instance starts; if they fail
  # the deploy aborts (per Specific's pre_deploy semantics).
  pre_deploy {
    command = "pnpm run update-db"
  }

  dev {
    command = "pnpm dev"
  }
}

postgres "main" {}
