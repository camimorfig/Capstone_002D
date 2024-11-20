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
    path('gestion_noticias/', gestion_noticias, name='gestion_noticias'),   
    path('asistencia_admin/', asistencia_admin, name='asistencia_admin'),   
    path('perfil_jugadores/', perfil_jugadores, name='perfil_jugadores'),   
    path('perfil_jugadores/crear_perfil/', crear_perfil_Jugador, name='crear_perfil_Jugador'),   
    path('asistencia_entrenador/', asistencia_entrenador, name='asistencia_entrenador'),   
    path('asistencia_entrenador/tomar_asistencia/', tomar_asistencia, name='tomar_asistencia'),   
    path('gestion_disciplina/', gestion_disciplina, name='gestion_disciplina'),
    path('update_discipline/', update_discipline, name='update_discipline'),
    path('gestion_galeria/', gestion_galeria, name='gestion_galeria'),   
    path('jugadores/', jugadores_por_disciplina, name='jugadores_por_disciplina'),   
    path('grafico/', grafico, name='grafico'),   
    path('administrador/solicitud_jugador/', solicitud_jugador, name='solicitud_jugador'),  
    path('selecciones/', selecciones, name='selecciones'),  
    path('<str:disciplina>/<str:seccion>/', disciplina_view, name='disciplina_view'),
    path('administrador/aceptar-solicitud/<int:id>/', aceptar_solicitud, name='aceptar_solicitud'),
    path('talento/', talento, name="talento"),
    path('listado_galeria_disciplina/', gestion_galeria_disciplina_por_disciplina, name="gestion_galeria_disciplina_por_disciplina"),

    path('gestion_eventos/', gestion_eventos, name='gestion_eventos'),
    path('gestionar_periodos/', gestionar_periodos, name='gestionar_periodos'),

    path('gestion_Jugador_elite/', gestion_Jugador_elite, name='gestion_Jugador_elite'),   



]