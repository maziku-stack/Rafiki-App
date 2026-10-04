# Rafiki App - Web (React + Django)

## Purpose
Rafiki means "friend" in Swahili.

Help people who feel alone find others who also want real conversation, share feelings or ideas, and start chatting easily.

## Core Features
- Register / Login
- Set your intention (Feeling lonely, Want deep talk, Share ideas, etc.)
- See people who are open to chat (Instagram-style)
- Start a conversation with one tap
- If no one is available → suggest TikTok & Facebook
- Clean Instagram-inspired UI

## How to Run

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```
