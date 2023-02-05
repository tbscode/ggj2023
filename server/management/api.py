from django.conf import settings
from management.models import User
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from uuid import uuid4
from django.contrib.auth import authenticate, login
from django.http import JsonResponse
from management.models import generate_game_map
import json


def guest_login(request):
    username = "guest-" + str(uuid4())
    password = str(uuid4())
    user = User.objects.create_user(username=username, password=password)
    user.state.key = password
    user.state.save()
    login(request, user=user)
    return JsonResponse({
        "username": username,
        "key": password,
        "map": generate_game_map()
    })


@csrf_exempt
def user_login(request):
    assert request.method == "POST"
    try:
        data = json.loads(request.body)
        user = authenticate(
            request, username=data["username"], password=data["password"])
        login(request, user=user)
    except:
        request.method = "GET"
        return guest_login(request)

    return JsonResponse({
        "username": data['username'],
        "key": data['password'],
        "map": generate_game_map()
    })


def get_or_create_base_admin():
    user = User.objects.filter(username=settings.BASE_ADMIN_USERNAME)
    if not user.exists():
        user = User.objects.create_superuser(
            username=settings.BASE_ADMIN_USERNAME,
            password=settings.BASE_ADMIN_USER_PASSWORD
        )
    return user
