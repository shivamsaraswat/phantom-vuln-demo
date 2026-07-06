// The app itself: pure JavaScript. Zero Go. Zero esbuild imports.
import { Button, Card } from "@xyz/xy-react";

export default function Home() {
  return (
    <main>
      <Card>
        <h1>Phantom Vulnerability Demo</h1>
        <Button>Where is the Go coming from?</Button>
      </Card>
    </main>
  );
}
