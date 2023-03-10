# Generated by Django 4.1.2 on 2023-02-04 14:42

from django.db import migrations, models
import secrets


class Migration(migrations.Migration):

    dependencies = [
        ('management', '0006_gameroom_old'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='hash',
            field=models.CharField(blank=True, default=secrets.token_hex, max_length=100, unique=True),
        ),
    ]
