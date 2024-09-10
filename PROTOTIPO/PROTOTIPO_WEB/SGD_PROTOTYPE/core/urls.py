from django.urls import path
from.views import index, contacto, eventos, galeria, nosotros, noticias, CustomLoginView, CoachDashboardView, AdminDashboardView, profile_redirect, crear_perfil_entrenador

urlpatterns = [
    path('', index, name="index"),
    path('contacto/', contacto, name="contacto"),
    path('eventos/', eventos, name="eventos"),
    path('galeria/', galeria, name="galeria"),
    path('nosotros/', nosotros, name="nosotros"),
    path('noticias/', noticias, name="noticias"),
    path('login/', CustomLoginView.as_view(), name="login"),

    path('entrenador/', CoachDashboardView.as_view() , name="entrenador_dashboard"),
    path('administrador/', AdminDashboardView.as_view() , name="admin_dashboard"),
    path('accounts/profile/', profile_redirect, name='profile'),

    path('crear_perfil_entrenador/', crear_perfil_entrenador, name='crear_perfil_entrenador'),   
    
]