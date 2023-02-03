from django.db import models
from uuid import uuid4

from django.contrib.auth.models import AbstractUser, BaseUserManager


class UserManager(BaseUserManager):
    """
    We overwrite the BaseUserManager so we can: 
    - automaticly create State, Profile, Settings everytime create_user is called
    """

    def _create_user(self, username=None, password=None, **kwargs):

        user = self.model(username=username, **kwargs)
        user.save(using=self._db)

        if password is None:
            password = str(uuid4())
            state = State.objects.create(
                user=user,
                default_password=password
            )
        else:
            state = State.objects.create(
                user=user,
            )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, username, password, **kwargs):
        return self._create_user(username=username, password=password, **kwargs)

    def create_superuser(self, username, password, **kwargs):
        kwargs["is_staff"] = True
        kwargs["is_superuser"] = True

        user = self._create_user(
            username=username, password=password, **kwargs)
        return user


class User(AbstractUser):
    """
    The default user model  
    """

    @property
    def settings(self):
        return State.objects.get(user=self)

    objects = UserManager()
    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=uuid4)


class State(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=uuid4)


class RequestLog(models.Model):
    request_method = models.CharField(max_length=10)
    request_path = models.TextField(null=True, blank=True)
    request_headers = models.TextField(null=True, blank=True)
    request_body = models.TextField(null=True, blank=True)
    request_query_params = models.TextField(null=True, blank=True)
    response_status = models.IntegerField(null=True, blank=True)
    response_headers = models.TextField(null=True, blank=True)
    response_body = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
