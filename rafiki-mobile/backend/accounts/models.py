from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    INTENTION_CHOICES = [
        ('lonely', 'Feeling lonely'),
        ('deep_talk', 'Want deep talk'),
        ('share_ideas', 'Share ideas'),
        ('casual_chat', 'Casual chat'),
        ('need_support', 'Need support'),
    ]
    bio = models.TextField(blank=True, max_length=300)
    profile_photo = models.ImageField(upload_to='profiles/', blank=True, null=True)
    intention = models.CharField(max_length=20, choices=INTENTION_CHOICES, default='lonely')
    is_open_to_chat = models.BooleanField(default=True)
    last_active = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.username
