# Supabase
NEXT_PUBLIC_SUPABASE_URL={{ op://Foundry/Supabase/url }}
NEXT_PUBLIC_SUPABASE_ANON_KEY={{ op://Foundry/Supabase/anon-key }}

# Site URL (required in production)
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# PostHog (optional in dev)
NEXT_PUBLIC_POSTHOG_KEY={{ op://Foundry/PostHog/public-key }}
POSTHOG_PERSONAL_API_KEY={{ op://Foundry/PostHog/personal-api-key }}
POSTHOG_PROJECT_ID={{ op://Foundry/PostHog/project-id }}

# Sentry (optional in dev)
NEXT_PUBLIC_SENTRY_DSN={{ op://Foundry/Sentry/web-dsn }}
