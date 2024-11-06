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
    attendance_date = models.DateField()
    attendance_comments = models.CharField(max_length=200, blank=True, null=True)
    creation_timestamp = models.DateTimeField(blank=True, null=True)
    player = models.ForeignKey('Player', models.DO_NOTHING)
    discipline = models.ForeignKey('Discipline', models.DO_NOTHING)
    status = models.ForeignKey('AttendanceStatus', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'attendance'


class AttendanceStatus(models.Model):
    status_id = models.BigAutoField(primary_key=True)
    status_name = models.CharField(max_length=20)
    status_description = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'attendance_status'


class Coach(models.Model):
    coach_id = models.CharField(primary_key=True, max_length=20)
    coach_name = models.CharField(max_length=100)
    coach_img = models.BinaryField(blank=True, null=True)
    user = models.ForeignKey('MainUser', models.DO_NOTHING, related_name='coach')
    coach_type = models.ForeignKey('CoachType', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'coach'


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


class Contact(models.Model):
    contact_id = models.BigAutoField(primary_key=True)
    contact_name = models.CharField(max_length=50)
    contact_email = models.CharField(max_length=50)
    contact_description = models.CharField(max_length=2000)
    admin = models.ForeignKey(Admin, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'contact'


class Discipline(models.Model):
    discipline_id = models.BigAutoField(primary_key=True)
    discipline_name = models.CharField(max_length=50)
    discipline_description = models.CharField(max_length=500)
    galery_img = models.BinaryField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'discipline'


class Events(models.Model):
    events_id = models.AutoField(primary_key=True)
    events_name = models.CharField(max_length=50)
    events_status = models.CharField(max_length=50)
    events_start = models.DateTimeField(null=True, blank=True)
    events_end = models.DateTimeField(null=True, blank=True)
    events_description = models.CharField(max_length=100, null=True, blank=True)
    events_type = models.CharField(max_length=50)
    events_recurring = models.IntegerField(null=True, blank=True)
    discipline = models.ForeignKey('Discipline', models.DO_NOTHING, null=True, blank=True)

    class Meta:
        db_table = 'events'


class GaleryDiscipline(models.Model):
    galery_dis_id = models.BigAutoField(primary_key=True)
    galery_dis_img = models.BinaryField()
    galery_dis_status = models.FloatField()
    galery_dis_tag = models.CharField(max_length=50, blank=True, null=True)
    galery_dis_date = models.DateField(blank=True, null=True)
    discipline = models.ForeignKey(Discipline, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'galery_discipline'


class GaleryFront(models.Model):
    galery_front_id = models.BigAutoField(primary_key=True)
    galery_front_img = models.BinaryField()
    galery_front_status = models.FloatField()
    galery_front_title = models.CharField(max_length=100, blank=True, null=True)
    galery_front_description = models.CharField(max_length=200, blank=True, null=True)
    galery_front_place = models.CharField(max_length=200, blank=True, null=True)
    galery_front_date = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'galery_front'


class GaleryGeneral(models.Model):
    galery_gen_id = models.BigAutoField(primary_key=True)
    galery_gen_img = models.BinaryField()
    galery_gen_tag = models.CharField(max_length=50, blank=True, null=True)
    galery_gen_status = models.FloatField()
    galery_gen_date = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'galery_general'


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
    news_tag = models.CharField(max_length=50)

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
    player_img = models.BinaryField(blank=True, null=True)
    player_status = models.CharField(max_length=30)
    player_horary = models.CharField(max_length=30)
    player_birthday = models.DateField()
    discipline = models.ForeignKey(Discipline, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'player'


class Requests(models.Model):
    request_id = models.BigAutoField(primary_key=True)
    coach_name = models.CharField(max_length=100)
    player_rut = models.CharField(max_length=13)
    player_name = models.CharField(max_length=50)
    player_last_name = models.CharField(max_length=50)
    discipline_name = models.CharField(max_length=50)
    player_headquarters = models.CharField(max_length=50, blank=True, null=True)
    player_career = models.CharField(max_length=30)
    request_status = models.CharField(max_length=30)
    request_date = models.DateField()
    coach = models.ForeignKey(Coach, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'requests'


class Statistic(models.Model):
    statistic_id = models.BigAutoField(primary_key=True)
    player = models.ForeignKey(Player, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'statistic'


class StatusType(models.Model):
    status_id = models.BigIntegerField(primary_key=True)
    status_type_name = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'status_type'


class TeamRoster(models.Model):
    team_roster_id = models.BigAutoField(primary_key=True)
    team_roster_date = models.DateField()
    player = models.ForeignKey(Player, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'team_roster'
