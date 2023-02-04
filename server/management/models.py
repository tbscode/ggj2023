import random
from django.db import models
from uuid import uuid4
from secrets import token_hex

from django.contrib.auth.models import AbstractUser, BaseUserManager


def rand_string():
    return token_hex(16)


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
        if not self.state.cur_room:
            self.state.cur_room = room
            self.state.save()
            return True
        else:
            if self in room.active_players.all():
                return False  # alreay joined
            else:
                self.state.cur_room = room
                self.state.save()
                return True

    def leave_room(self):
        self.state.cur_room.active_players.remove(self)
        self.state.cur_room.old = True
        self.state.cur_room.save()

        self.state.cur_room = None
        self.state.save()

    objects = UserManager()
    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=token_hex)


PLAYERS_PER_ROOM = 2
SPAWNS = {
    "red": {
        0: (204, -142),
        1: (249, -112),
        2: (329, -94),
        3: (381, -142),
    },
    "blue": {
        0: (957, -140),
        1: (1005, -123),
        2: (1088, -120),
        3: (1121, -160)
    },
}


def random_spawn(team):
    # TODO make this acually random
    return SPAWNS[team][0]


MAXIMUM_TREE_XP = 100000.0

MAX_X = -404.0
MAP_Y = -181.0
SCALE = 3.012
MAP_WIDTH = 728.0 * SCALE
MAP_HEIGHT = 421.0 * SCALE


def random_map_position():
    return (random.uniform(MAX_X, MAX_X + MAP_WIDTH), random.uniform(MAP_Y, MAP_Y + MAP_HEIGHT))


AMOUNT_OF_WATER_RESOVOIRS = 20
AMOUNT_OF_GROWTH_RESOVOIRS = 20
AMOUNT_OF_BONES = 10
AMOUNT_OF_STONES = 10

WATER_XP_RANGE = (1000.0, 10000.0)

GROTH_FACTOR_RANGE = (1.02, 1.6)


def generate_game_map():
    map_objects = []
    for i in range(AMOUNT_OF_WATER_RESOVOIRS):
        x, y = random_map_position()
        map_objects.append({
            "type": "water",
            "xp": random.uniform(*WATER_XP_RANGE),
            "position": [x, y]
        })

    for i in range(AMOUNT_OF_GROWTH_RESOVOIRS):
        x, y = random_map_position()
        map_objects.append({
            "type": "growth",
            "grow": random.uniform(*GROTH_FACTOR_RANGE),
            "position": [x, y]
        })

    for i in range(AMOUNT_OF_BONES):
        x, y = random_map_position()
        map_objects.append({
            "type": "bone",
            "position": [x, y]
        })

    for i in range(AMOUNT_OF_STONES):
        x, y = random_map_position()
        map_objects.append({
            "type": "stone",
            "position": [x, y]
        })

    return map_objects


class GameRoom(models.Model):

    time = models.DateTimeField(auto_now_add=True)

    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=rand_string)

    active_players = models.ManyToManyField(
        User, related_name="active_players", blank=True, null=True)

    blue_team = models.ManyToManyField(
        User, related_name="blue_team", blank=True, null=True)

    red_team = models.ManyToManyField(
        User, related_name="red_team", blank=True, null=True)

    map = models.JSONField(default=generate_game_map, blank=True, null=True)

    old = models.BooleanField(default=False)

    blue_tree_xp = models.FloatField(default=0)
    red_tree_xp = models.FloatField(default=0)

    def join_room(self, user):
        self.active_players.add(user)
        team = ""
        if self.red_team.count() < self.blue_team.count():
            team = "red"
            self.red_team.add(user)
        else:
            team = "blue"
            self.blue_team.add(user)
        self.save()
        spawn = random_spawn(team)
        return team, spawn

    def is_room_full(self):
        return self.active_players.count() >= PLAYERS_PER_ROOM


def get_game_room():
    # For now we have always only one later we can have serveral different ones here
    all_rooms = GameRoom.objects.all()
    if all_rooms.count() == 0:
        room = GameRoom.objects.create()
    else:
        room = GameRoom.objects.all().order_by("-time").first()
        print("TBS foll or old", room.is_room_full(), room.old, room.hash)
        if room.is_room_full() or room.old:
            room = GameRoom.objects.create()
    return room


class State(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)

    cur_room = models.ForeignKey(
        GameRoom, on_delete=models.CASCADE, null=True, blank=True)

    hash = models.CharField(max_length=100, blank=True,
                            unique=True, default=uuid4)

    key = models.CharField(max_length=100, blank=True, null=True)


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
