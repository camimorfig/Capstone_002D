from django.urls import path
from django.contrib.auth import views as auth_views

from.views import *


urlpatterns = [
    path('', index, name="index"),
    path('contacto/', contacto, name="contacto"),
    path('eventos/', eventos, name="eventos"),
    path('galeria/', galeria, name="galeria"),
    path('nosotros/', nosotros, name="nosotros"),
    path('noticias/', noticias, name="noticias"),
    path('login/', CustomLoginView.as_view(), name="login"),
    path('accounts/logout/', auth_views.LogoutView.as_view(), name='logout'),

    path('entrenador/', CoachDashboardView.as_view() , name="entrenador_dashboard"),
    path('administrador/', AdminDashboardView.as_view() , name="admin_dashboard"),
    path('accounts/profile/', profile_redirect, name='profile'),

    path('crear_perfil_entrenador/', crear_perfil_entrenador, name='crear_perfil_entrenador'),   
    path('crear_noticias/', crear_noticias, name='crear_noticias'),   
    path('asistencia_admin/', asistencia_admin, name='asistencia_admin'),   
    path('perfil_jugadores/', perfil_jugadores, name='perfil_jugadores'),   
    path('perfil_jugadores/crear_perfil/', crear_perfil_Jugador, name='crear_perfil_Jugador'),   
    path('asistencia_entrenador/', asistencia_entrenador, name='asistencia_entrenador'),   
    path('asistencia_entrenador/tomar_asistencia/', tomar_asistencia, name='tomar_asistencia'),   
    
    path('gestion_galeria/subir_imagen/', subir_imagen, name='subir_imagen'),   
    path('gestion_galeria/', gestion_galeria, name='gestion_galeria'),   
    path('jugadores/', jugadores_por_disciplina, name='jugadores_por_disciplina'),   

    path('grafico/', grafico, name='grafico'),   
    path('solicitud_jugador/', solicitud_jugador, name='solicitud_jugador'),  


    path('<str:disciplina>/<str:seccion>/', disciplina_view, name='disciplina_view'),


]