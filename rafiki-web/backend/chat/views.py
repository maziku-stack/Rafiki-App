from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from .models import Conversation, Message
from .serializers import (
    ConversationSerializer, MessageSerializer, CreateConversationSerializer
)

User = get_user_model()


class ConversationListView(generics.ListAPIView):
    serializer_class = ConversationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Conversation.objects.filter(
            participants=self.request.user
        ).order_by('-updated_at')

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context


class CreateConversationView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CreateConversationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        other_user_id = serializer.validated_data['user_id']
        other_user = User.objects.get(id=other_user_id)

        if other_user == request.user:
            return Response(
                {"detail": "Cannot create conversation with yourself."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check existing conversation between the two users
        existing = Conversation.objects.filter(
            participants=request.user
        ).filter(
            participants=other_user
        ).first()

        if existing:
            return Response(
                ConversationSerializer(existing, context={'request': request}).data
            )

        conversation = Conversation.objects.create()
        conversation.participants.add(request.user, other_user)
        return Response(
            ConversationSerializer(conversation, context={'request': request}).data,
            status=status.HTTP_201_CREATED
        )


class MessageListCreateView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        conversation_id = self.kwargs['conversation_id']
        return Message.objects.filter(
            conversation_id=conversation_id,
            conversation__participants=self.request.user
        ).order_by('created_at')

    def perform_create(self, serializer):
        conversation = Conversation.objects.get(
            id=self.kwargs['conversation_id'],
            participants=self.request.user
        )
        serializer.save(sender=self.request.user, conversation=conversation)
        # Touch updated_at
        conversation.save()
