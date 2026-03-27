import { describe, it, expect } from 'vitest'
import express from 'express'
import { healthRouter } from './health'

describe('GET /health', () => {
  it('returns ok and timestamp', async () => {
    const app = express()
    app.use('/health', healthRouter)

    const server = app.listen(0)
    const address = server.address()
    const port = typeof address === 'object' && address ? address.port : 0

    try {
      const res = await fetch(`http://localhost:${port}/health`)
      const body = await res.json()

      expect(res.status).toBe(200)
      expect(body.ok).toBe(true)
      expect(body.timestamp).toBeDefined()
    } finally {
      server.close()
    }
  })
})
