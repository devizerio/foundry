import { describe, it, expect, vi } from 'vitest'

// Mock the server-side supabase client
vi.mock('@/lib/supabase/server', () => ({
  createClient: vi.fn().mockResolvedValue({
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: null } }),
    },
  }),
}))

describe('Header', () => {
  it('module can be imported', async () => {
    // Server components can't be rendered in vitest easily,
    // so we just verify the module imports correctly
    const mod = await import('./Header')
    expect(mod.Header).toBeDefined()
  })
})
