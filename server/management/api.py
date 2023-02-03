from django.conf import settings
from management.models import User


def get_or_create_base_admin():
    user = User.objects.filter(username=settings.BASE_ADMIN_USERNAME)
    if not user.exists():
        user = User.objects.create_superuser(
            number=settings.BASE_ADMIN_USERNAME,
            password=settings.BASE_ADMIN_USER_PASSWORD
        )
    return user
