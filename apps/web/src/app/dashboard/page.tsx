import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

export default async function DashboardPage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect('/')
  }

  return (
    <main className="mx-auto max-w-4xl p-8">
      <h1 className="text-2xl font-bold">Dashboard</h1>
      <p className="mt-4 text-muted-foreground">Welcome, {user.email}</p>
    </main>
  )
}
