# Generated by Django 5.1 on 2024-10-02 00:49

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='CoachDiscipline',
            fields=[
                ('coach', models.OneToOneField(on_delete=django.db.models.deletion.DO_NOTHING, primary_key=True, serialize=False, to='core.coach')),
            ],
            options={
                'db_table': 'coach_discipline',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='CoachType',
            fields=[
                ('coach_type_id', models.BigIntegerField(primary_key=True, serialize=False)),
                ('coach_type_name', models.CharField(max_length=100)),
                ('coach_type_description', models.CharField(blank=True, max_length=2000, null=True)),
            ],
            options={
                'db_table': 'coach_type',
                'managed': False,
            },
        ),
        migrations.DeleteModel(
            name='AuthGroup',
        ),
        migrations.DeleteModel(
            name='AuthGroupPermissions',
        ),
        migrations.DeleteModel(
            name='AuthPermission',
        ),
        migrations.DeleteModel(
            name='AuthUser',
        ),
        migrations.DeleteModel(
            name='AuthUserGroups',
        ),
        migrations.DeleteModel(
            name='AuthUserUserPermissions',
        ),
        migrations.DeleteModel(
            name='DjangoAdminLog',
        ),
        migrations.DeleteModel(
            name='DjangoContentType',
        ),
        migrations.DeleteModel(
            name='DjangoMigrations',
        ),
        migrations.DeleteModel(
            name='DjangoSession',
        ),
        migrations.AlterModelOptions(
            name='mainuser',
            options={},
        ),
    ]
