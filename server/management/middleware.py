import json
from django.conf import settings
from django.db import models
from management.models import RequestLog


class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.ignored_routes = getattr(settings, "LOGGING_IGNORED_ROUTES", [])
        self.ignored_params = getattr(settings, "LOGGING_IGNORED_PARAMS", [])

    def __call__(self, request):
        # Check if the current route should be ignored
        if request.path in self.ignored_routes:
            return self.get_response(request)

        # Log the request
        request_log = RequestLog()
        request_log.request_method = request.method
        request_log.request_path = request.path
        request_log.request_headers = json.dumps(dict(request.headers))
        request_log.request_body = request.body

        # Mask the ignored params in query_params
        query_params = request.GET.dict()
        for param in self.ignored_params:
            if param in query_params:
                query_params[param] = "******"
        request_log.request_query_params = json.dumps(query_params)
        request_log.save()

        # Get the response
        response = self.get_response(request)

        # Log the response
        request_log.response_status = response.status_code
        request_log.response_headers = json.dumps(dict(response.headers))
        try:
            request_log.response_body = response.content
        except:
            request_log.response_body = "coudn't extract body"
        request_log.save()

        return response
