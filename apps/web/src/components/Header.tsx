import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'

export async function Header() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  return (
    <header className="flex h-16 items-center justify-between border-b border-border px-6">
      <Link href="/" className="text-lg font-bold">
        Foundry
      </Link>
      <nav className="flex items-center gap-4">
        {user ? (
          <>
            <Link href="/dashboard" className="text-sm text-muted-foreground hover:text-foreground">
              Dashboard
            </Link>
            <form action="/auth/signout" method="post">
              <button type="submit" className="text-sm text-muted-foreground hover:text-foreground">
                Sign Out
              </button>
            </form>
          </>
        ) : (
          <Link href="/auth/login" className="text-sm text-muted-foreground hover:text-foreground">
            Sign In
          </Link>
        )}
      </nav>
    </header>
  )
}
