# Generated by Django 4.1.2 on 2023-02-04 02:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('management', '0004_alter_gameroom_active_players'),
    ]

    operations = [
        migrations.AddField(
            model_name='state',
            name='key',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]
