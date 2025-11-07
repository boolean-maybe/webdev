#!/usr/bin/env zsh

if [ -z "$1" ]; then
  echo "Error: Project name is required"
  echo "Usage: $0 <project-name>"
  exit 1
fi

# Create project root directory
mkdir -p $1
cd $1

# Create frontend in subdirectory
echo "No" | npm create vite@latest frontend -- --template react-ts
cd frontend

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

npx shadcn@latest init -d -y
npx shadcn@latest add button -y -o

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

# Navigate back to project root
cd ..

# Create backend directory and setup Express server
mkdir -p backend
cd backend

# Create package.json
cat > package.json <<'EOF'
{
  "name": "backend",
  "version": "1.0.0",
  "type": "module",
  "description": "Minimal Node.js backend to serve frontend",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node --watch server.js"
  },
  "dependencies": {
    "express": "^5.0.1"
  }
}
EOF

# Create server.js
cat > server.js <<'EOF'
import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8081;

// Serve static files from the frontend dist directory
const frontendDistPath = join(__dirname, '../frontend/dist');
app.use(express.static(frontendDistPath));

// Handle client-side routing - serve index.html for all non-static routes
app.use((req, res) => {
  res.sendFile(join(frontendDistPath, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
EOF

# Install backend dependencies
npm install

# Navigate back to project root
cd ..

echo ""
echo "✅ Frontend created in ./frontend/"
echo "✅ Backend created in ./backend/"
echo "📁 Project structure:"
echo "   $1/"
echo "   ├── frontend/  (React + Vite + Tailwind + shadcn/ui)"
echo "   └── backend/   (Express server to serve frontend)"
echo ""
echo "To run frontend: cd frontend && npm run dev"
echo "To run backend: cd backend && npm run dev"
echo ""
echo "💡 Backend serves the built frontend from frontend/dist"
echo "   Build frontend first: cd frontend && npm run build"
echo "   Then run backend: cd backend && npm start"
