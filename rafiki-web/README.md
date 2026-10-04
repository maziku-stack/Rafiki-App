# Rafiki Web (React + Django + WebSockets)

## Backend
```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

## Frontend
```bash
cd frontend
npm install
npm run dev
```
