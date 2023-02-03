if True:
    # Ugly hack to make autoformatter shut up
    import os
    from django.core.asgi import get_asgi_application

    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'server.settings')

    application = get_asgi_application()

from management.consumer import GameConsumer
from django.urls import path
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import re_path, path
import os


http_routes = [re_path(r"", application)]


application = ProtocolTypeRouter({
    "http": URLRouter(http_routes),
    'websocket': AuthMiddlewareStack(
        URLRouter([
            path('ws/game/', GameConsumer.as_asgi()),
        ])
    ),
})
