from django.db import models
from uuid import uuid4

from django.contrib.auth.models import AbstractUser, BaseUserManager


class UserManager(BaseUserManager):
    """
    We overwrite the BaseUserManager so we can: 
    - automaticly create State, Profile, Settings everytime create_user is called
    """

    def _create_user(self, number=None, password=None, **kwargs):

        user = self.model(username=number, number=number, **kwargs)
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

    def create_user(self, number, password, **kwargs):
        return self._create_user(number=number, password=password, **kwargs)

    def create_superuser(self, number, password, **kwargs):
        kwargs["is_staff"] = True
        kwargs["is_superuser"] = True

        user = self._create_user(number=number, password=password, **kwargs)
        return user


class User(AbstractUser):
    """
    The default user model  
    """

    @property
    def settings(self):
        return State.objects.get(user=self)

    objects = UserManager()


class State(models.Model):
    pass
