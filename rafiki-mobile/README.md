# Rafiki App - Mobile (Flutter + Django)

## Purpose
Rafiki means "friend" in Swahili.

Help people who feel alone find others who also want real conversation, share feelings or ideas, and start chatting easily.

## Core Features
- Register / Login
- Set your intention
- See people open to chat
- Start conversation
- Fallback to TikTok / Facebook when no one is available
- Instagram-style UI/UX

## How to Run

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```
