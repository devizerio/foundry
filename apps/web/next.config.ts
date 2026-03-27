import type { NextConfig } from 'next'
import { resolve } from 'path'
import { withPostHogConfig } from '@posthog/nextjs-config'

const nextConfig: NextConfig = {
  turbopack: {
    root: resolve(process.cwd(), '../..'),
  },
  transpilePackages: ['@foundry/shared'],
  async rewrites() {
    return [
      {
        source: '/ingest/static/:path*',
        destination: 'https://eu-assets.i.posthog.com/static/:path*',
      },
      {
        source: '/ingest/:path*',
        destination: 'https://eu.i.posthog.com/:path*',
      },
    ]
  },
  skipTrailingSlashRedirect: true,
}

const posthogApiKey = process.env.POSTHOG_PERSONAL_API_KEY
const posthogProjectId = process.env.POSTHOG_PROJECT_ID

export default posthogApiKey && posthogProjectId
  ? withPostHogConfig(nextConfig, {
      personalApiKey: posthogApiKey,
      projectId: posthogProjectId,
      host: 'https://eu.posthog.com',
      sourcemaps: {
        deleteAfterUpload: true,
      },
    })
  : nextConfig
