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
    def state(self):
        return State.objects.get(user=self)

    def join_room(self, room):
        self.state.cur_room = room
        self.state.save()

    def leave_room(self):
        self.state.cur_room.active_players.remove(self)
        self.state.cur_room.save()

        self.state.cur_room = None
        self.state.save()

    objects = UserManager()
    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=uuid4)


class GameRoom(models.Model):

    time = models.DateTimeField(auto_now_add=True)

    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=uuid4)

    active_players = models.ManyToManyField(
        User, related_name="active_players", blank=True, null=True)

    def join_room(self, user):
        self.active_players.add(user)
        self.save()


def get_game_room():
    # For now we have always only one later we can have serveral different ones here
    all_rooms = GameRoom.objects.all()
    if all_rooms.count() == 0:
        room = GameRoom.objects.create()
    else:
        room = GameRoom.objects.all().order_by("time").first()
    return room


class State(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    cur_room = models.ForeignKey(
        GameRoom, on_delete=models.CASCADE, null=True, blank=True)

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
