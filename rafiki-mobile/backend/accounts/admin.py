from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ['username', 'email', 'intention', 'is_open_to_chat', 'last_active', 'is_staff']
    list_filter = ['intention', 'is_open_to_chat', 'is_staff']
    search_fields = ['username', 'email']
    fieldsets = UserAdmin.fieldsets + (
        ('Rafiki Profile', {
            'fields': ('bio', 'profile_photo', 'intention', 'is_open_to_chat'),
        }),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Rafiki Profile', {
            'fields': ('intention', 'bio'),
        }),
    )
