from django.conf import settings
from management.models import User
from django.http import HttpResponse
from uuid import uuid4
from django.contrib.auth import authenticate, login


def guest_login(request):
    username = "guest-" + str(uuid4())
    password = str(uuid4)
    user = User.objects.create(username=username, password=password)
    auth_user = authenticate(username=user.number,
                             password=user.settings.default_password)
    login(request, user=auth_user)
    return HttpResponse(f"Logged in as '{username}'")


def get_or_create_base_admin():
    user = User.objects.filter(username=settings.BASE_ADMIN_USERNAME)
    if not user.exists():
        user = User.objects.create_superuser(
            username=settings.BASE_ADMIN_USERNAME,
            password=settings.BASE_ADMIN_USER_PASSWORD
        )
    return user
