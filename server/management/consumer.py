from channels.generic.websocket import AsyncWebsocketConsumer
import json
from management.models import GameRoom, get_game_room
from asgiref.sync import sync_to_async


def list_active_players(room):
    return [player.username for player in room.active_players.all()]


class GameConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        print("CONNECT ATTEMPTED")
        if self.scope["user"].is_anonymous:
            # Reject the connection for anonymous users
            print("FAILED causee ANONYMOUS")
            await self.close()
        else:
            print("AUTHENTICATED USER CONNECTED!")
            print("USERNAME", self.scope["user"].username)
            user = self.scope["user"]
            room = await sync_to_async(get_game_room)()
            team, spawn = await sync_to_async(room.join_room)(user)
            await sync_to_async(user.join_room)(room)
            print("MAKING GROUP", room.hash)
            await self.channel_layer.group_add(room.hash, self.channel_name)
            await self.accept()
            await self.send(text_data=json.dumps({
                'event': 'connected',
                'group': room.hash,
                'team': team,
                'spawn': spawn,
                'active_players': await sync_to_async(list_active_players)(room),
            }))
            await self.channel_layer.group_send(room.hash, {
                'type': 'user_joined',
                'data': {
                    'username': user.username
                }
            })

            # Is that room full now
            is_full = await sync_to_async(room.is_room_full)()
            print("checking if room is full")
            if is_full:
                print("ROOM IS FULL")
                await self.channel_layer.group_send(room.hash, {
                    'type': 'room_full',
                    'data': {}
                })

    async def user_joined(self, event):
        await self.send(text_data=json.dumps({
            'event': 'user_joined',
            **event['data'],
        }))

    async def room_full(self, event):
        await self.send(text_data=json.dumps({
            'event': 'game_start',
            **event['data'],
        }))

    async def disconnect(self, close_code):
        user = self.scope["user"]
        await sync_to_async(user.leave_room)()

    async def broadcast_message(self, event):
        if self.scope['user'].username != event['data']['username']:
            await self.send(text_data=json.dumps({
                'event': 'broadcast_message',
                **event['data'],
            }))

    async def receive(self, bytes_data):
        print("RECEIVED message", bytes_data.decode())
        data = await sync_to_async(bytes_data.decode)()
        try:
            print("Trying to json data")
            data = await sync_to_async(json.loads)(data)
            print("GOT", data)
        except:
            return
        if data['type'] == "simple":
            await self.channel_layer.group_send(data['group'], {
                'type': 'broadcast_message',
                'data': data
            })
