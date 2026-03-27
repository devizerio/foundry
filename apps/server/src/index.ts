import 'dotenv/config'
import * as Sentry from '@sentry/node'
import express from 'express'
import cors from 'cors'
import { healthRouter } from './routes/health'

// Initialize Sentry
if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
  })
}

const app = express()
const PORT = process.env.PORT || 3001

// Middleware
app.use(cors({ origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'] }))
app.use(express.json())

// Routes
app.use('/health', healthRouter)

// Sentry error handler (must be after routes)
if (process.env.SENTRY_DSN) {
  Sentry.setupExpressErrorHandler(app)
}

// Global error handler (Express requires all 4 params for error middleware)
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err)
  res.status(500).json({ error: 'Internal server error' })
})

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`)
})

export { app }
