import { describe, it, expect } from 'vitest'
import { APP_NAME, DEFAULT_PORT } from './index'

describe('shared exports', () => {
  it('exports APP_NAME', () => {
    expect(APP_NAME).toBe('Foundry')
  })

  it('exports DEFAULT_PORT', () => {
    expect(DEFAULT_PORT.web).toBe(3000)
    expect(DEFAULT_PORT.server).toBe(3001)
  })
})
