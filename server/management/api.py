from django.conf import settings
from management.models import User
from django.http import HttpResponse
from uuid import uuid4
from django.contrib.auth import authenticate, login
from django.http import JsonResponse


def guest_login(request):
    username = "guest-" + str(uuid4())
    password = str(uuid4)
    user = User.objects.create_user(username=username, password=password)
    login(request, user=user)
    return JsonResponse({
        "username": username,
    })


def get_or_create_base_admin():
    user = User.objects.filter(username=settings.BASE_ADMIN_USERNAME)
    if not user.exists():
        user = User.objects.create_superuser(
            username=settings.BASE_ADMIN_USERNAME,
            password=settings.BASE_ADMIN_USER_PASSWORD
        )
    return user
