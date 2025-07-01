npm create vite@latest dashboard -- --template react-ts
cd dashboard

npm install
npm install tailwindcss @tailwindcss/vite

echo '@import "tailwindcss";' > src/index.css

cat > tsconfig.json <<'EOF'
{
  "files": [],
  "references": [
    {
      "path": "./tsconfig.app.json"
    },
    {
      "path": "./tsconfig.node.json"
    }
  ],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
EOF

sed 's@/\*.*\*/@@g' tsconfig.app.json | jq '.compilerOptions.baseUrl = "." | .compilerOptions.paths = {"@/*": ["./src/*"]}' > tmp && mv tmp tsconfig.app.json

npm install -D @types/node

cat > vite.config.ts <<'EOF'
import path from "path"
import tailwindcss from "@tailwindcss/vite"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
})
EOF

npm install react-router-dom

npx shadcn@latest init
npx shadcn@latest add button

cat > src/App.tsx << 'EOF'
import { Button } from "@/components/ui/button"

function App() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center">
      <Button>Click me</Button>
    </div>
  )
}

export default App
EOF

#npm run dev
