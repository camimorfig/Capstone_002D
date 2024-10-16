# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from .managers import MainUserManager 



class Admin(models.Model):
    admin_id = models.CharField(primary_key=True, max_length=20)
    admin_name = models.CharField(max_length=50)
    admin_img = models.BinaryField(blank=True, null=True)
    user = models.ForeignKey('MainUser', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'admin'


class Attendance(models.Model):
    attendance_id = models.BigAutoField(primary_key=True)
    attendance_status = models.CharField(max_length=20)
    attendance_date = models.DateField()
    attendace_comments = models.CharField(max_length=200, blank=True, null=True)
    player = models.ForeignKey('Player', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'attendance'


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255, blank=True, null=True)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128, blank=True, null=True)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150, blank=True, null=True)
    first_name = models.CharField(max_length=150, blank=True, null=True)
    last_name = models.CharField(max_length=150, blank=True, null=True)
    email = models.CharField(max_length=254, blank=True, null=True)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class Coach(models.Model):
    coach_id = models.CharField(primary_key=True, max_length=20)
    coach_name = models.CharField(max_length=50)
    coach_img = models.BinaryField(blank=True, null=True)
    user = models.ForeignKey('MainUser', models.DO_NOTHING, related_name='coach')  # Añadir related_name
    coach_type = models.ForeignKey('CoachType', models.DO_NOTHING)
    disciplines = models.ManyToManyField('Discipline', through='CoachDiscipline', related_name='coaches')

    class Meta:
        managed = False
        db_table = 'coach'





class Contact(models.Model):
    contact_id = models.BigAutoField(primary_key=True)
    contact_name = models.CharField(max_length=50)
    contact_email = models.CharField(max_length=50)
    contact_description = models.CharField(max_length=100)
    admin = models.ForeignKey(Admin, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'contact'

class CoachDiscipline(models.Model):
    coach = models.ForeignKey(Coach, models.DO_NOTHING)
    discipline = models.ForeignKey('Discipline', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'coach_discipline'
        unique_together = (('coach', 'discipline'),)


class CoachType(models.Model):
    coach_type_id = models.BigIntegerField(primary_key=True)
    coach_type_name = models.CharField(max_length=100)
    coach_type_description = models.CharField(max_length=2000, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'coach_type'

class Discipline(models.Model):
    discipline_id = models.BigAutoField(primary_key=True)
    discipline_name = models.CharField(max_length=50)
    discipline_description = models.CharField(max_length=500)
    galery_img = models.BinaryField(blank=True, null=True)
    
    class Meta:
        managed = False
        db_table = 'discipline'


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200, blank=True, null=True)
    action_flag = models.IntegerField()
    change_message = models.TextField(blank=True, null=True)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100, blank=True, null=True)
    model = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255, blank=True, null=True)
    name = models.CharField(max_length=255, blank=True, null=True)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField(blank=True, null=True)
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class EliteAthlete(models.Model):
    elite_athlete_id = models.BigAutoField(primary_key=True)
    elite_athlete_name = models.CharField(max_length=100)
    elite_athlete_headquarters = models.CharField(max_length=50, blank=True, null=True)
    elite_athlete_descipline = models.CharField(max_length=30)
    elite_athlete_description = models.CharField(max_length=100)
    elite_athlete_img = models.BinaryField(blank=True, null=True)
    elite_athlete_career = models.CharField(max_length=30)
    player_status = models.CharField(max_length=30)

    class Meta:
        managed = False
        db_table = 'elite_athlete'


class Events(models.Model):
    events_id = models.BigAutoField(primary_key=True)
    events_name = models.CharField(max_length=50)
    events_status = models.CharField(max_length=50)
    events_start = models.DateField()
    events_end = models.DateField()
    events_description = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'events'


class Galery(models.Model):
    galery_id = models.BigAutoField(primary_key=True)
    galery_img = models.BinaryField()
    galery_status = models.CharField(max_length=50)
    galery_description = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'galery'


class GamePosition(models.Model):
    game_position_id = models.BigAutoField(primary_key=True)
    game_position_name = models.CharField(max_length=50)

    class Meta:
        managed = False
        db_table = 'game_position'


class MainUser(AbstractBaseUser, PermissionsMixin):
    user_id = models.BigAutoField(primary_key=True)
    email = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=100) 
    user_type = models.CharField(max_length=50)


    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    last_login = models.DateTimeField(null=True, blank=True)
    date_joined = models.DateTimeField(auto_now_add=True)

    objects = MainUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['user_type']

    class Meta:
        managed = False  
        db_table = 'Main_user'  

    def __str__(self):
        return self.email


class News(models.Model):
    news_id = models.BigAutoField(primary_key=True)
    news_name = models.CharField(max_length=50)
    news_status = models.CharField(max_length=50)
    news_description = models.CharField(max_length=500, blank=True, null=True)
    news_date = models.DateField()
    news_img = models.BinaryField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'news'


class Player(models.Model):
    player_id = models.BigAutoField(primary_key=True)
    player_rut = models.CharField(max_length=13)
    player_name = models.CharField(max_length=50)
    player_last_name = models.CharField(max_length=50)
    player_headquarters = models.CharField(max_length=50, blank=True, null=True)
    player_career = models.CharField(max_length=30)
    player_img = models.ImageField(upload_to='player_images/', null=True, blank=True)    
    player_status = models.CharField(max_length=30)
    discipline = models.ForeignKey(Discipline, models.DO_NOTHING)
    game_position = models.ForeignKey(GamePosition, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'player'


class Statistic(models.Model):
    statistic_id = models.BigAutoField(primary_key=True)
    player = models.ForeignKey(Player, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'statistic'


class TeamRoster(models.Model):
    team_roster_id = models.BigAutoField(primary_key=True)
    team_roster_date = models.DateField()
    player = models.ForeignKey(Player, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'team_roster'
