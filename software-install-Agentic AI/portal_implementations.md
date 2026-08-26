create folder structructure:
npm create vite@latest . -- --template react-ts
y enter

react
typescript
esline

npm install axios react-router-dom recharts lucide-react @tanstack/react-table
npm run dev
http://localhost:5173

2nd terminal portal

npm install axios react-router-dom recharts lucide-react @tanstack/react-table
npm install tailwindcss @tailwindcss/vite
npm install clsx
className={clsx(
  status === "SUCCESS" && "text-green-600",
  status === "FAILED" && "text-red-600"
)}

src/
├── components/
│   └── layout/
│       ├── AdminLayout.tsx
│       ├── Sidebar.tsx
│       └── Topbar.tsx
│
├── pages/
│   ├── Dashboard.tsx
│   ├── Jobs.tsx
│   └── JobDetails.tsx


save chagns ctl+ c and then npm run dev

1.app/routes/dashboard.py
2. main.py
app.include_router(...)
from app.routes.dashboard import router as dashboard_router

app.include_router(dashboard_router)

docker recompose

 software-install-agenticai-api

portal url
 http://127.0.0.1:8000/api/v1/dashboard/summary
 