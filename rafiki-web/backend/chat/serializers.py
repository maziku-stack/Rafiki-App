from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Conversation, Message
from accounts.serializers import UserSerializer

User = get_user_model()


class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'conversation', 'sender', 'content', 'created_at', 'is_read']
        read_only_fields = ['id', 'sender', 'created_at']


class ConversationSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    other_user = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'participants', 'other_user', 'created_at', 'updated_at', 'last_message']

    def get_last_message(self, obj):
        last = obj.messages.order_by('-created_at').first()
        if last:
            return MessageSerializer(last).data
        return None

    def get_other_user(self, obj):
        request = self.context.get('request')
        if request and request.user:
            other = obj.participants.exclude(id=request.user.id).first()
            if other:
                return UserSerializer(other).data
        return None


class CreateConversationSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()

    def validate_user_id(self, value):
        if not User.objects.filter(id=value).exists():
            raise serializers.ValidationError("User does not exist.")
        return value
