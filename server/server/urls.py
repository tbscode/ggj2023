from django.contrib import admin
from django.urls import path
from management.api import guest_login, user_login
from django.conf.urls.static import static
from django.conf import settings


urlpatterns = [
    #*static(settings.STATIC_URL, document_root=settings.STATIC_ROOT),
    path('admin/', admin.site.urls),
    path("api/guest_login/", guest_login),
    path("api/user_login/", user_login)
]
