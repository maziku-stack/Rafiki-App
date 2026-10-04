from django.urls import path
from .views import ConversationListView, CreateConversationView, MessageListCreateView

urlpatterns = [
    path('conversations/', ConversationListView.as_view(), name='conversations'),
    path('conversations/create/', CreateConversationView.as_view(), name='create_conversation'),
    path('conversations/<int:conversation_id>/messages/', MessageListCreateView.as_view(), name='messages'),
]
