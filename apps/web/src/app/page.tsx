export default function Home() {
  return (
    <main className="flex min-h-[calc(100vh-64px)] flex-col items-center justify-center gap-8 p-8">
      <div className="text-center">
        <h1 className="text-4xl font-bold tracking-tight">Welcome to Foundry</h1>
        <p className="mt-4 text-lg text-muted-foreground">Your AI-native monorepo boilerplate. Start building.</p>
      </div>
      <div className="flex gap-4">
        <a
          href="/dashboard"
          className="rounded-md bg-primary px-6 py-3 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
        >
          Go to Dashboard
        </a>
      </div>
    </main>
  )
}
