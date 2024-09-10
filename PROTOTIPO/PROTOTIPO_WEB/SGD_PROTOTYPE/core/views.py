from django.shortcuts import render
from django.urls import reverse
from django.db import connection
import base64
from django.contrib.auth.views import LoginView
from .forms import CustomLoginForm

from django.http import HttpResponseForbidden

from django.contrib.auth import login
from django.shortcuts import redirect

from django.contrib.auth.decorators import login_required

from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic import TemplateView
from .models import Coach, Admin
import oracledb




###########  views de Templates  ###########
def index(request):
    return render (request, 'core/index.html')

def contacto(request):

    data = {

    }

    if request.method == 'POST':
        nombre= request.POST.get('nombre')
        email= request.POST.get('email')
        descripcion= request.POST.get('descripcion')
        salida = guardar_contacto(nombre,email,descripcion)

        if salida == 1:
            data['mensaje'] = 'guardado correctamente'
        else:
            data['mensaje'] = 'no se ha podido guardar. ERROR.'            

    return render (request, 'core/contacto.html',data)

def eventos(request):
    return render (request, 'core/eventos.html')

def galeria(request):
    return render (request, 'core/galeria.html')


def nosotros(request):
    data = {
        'entrenadores':listado_entrenadores()
        }
    return render (request, 'core/nosotros.html', data)

def noticias(request):
    return render (request, 'core/noticias.html')

def entrenador(request):
    return render (request, 'intranet/entrenador/entrenador.html')
    
def administrador(request):
    return render (request, 'intranet/administrador/administrador.html')

def crear_perfil_entrenador(request):
    data = {
        'disciplinas':listado_disciplinas(),
        'tipo_entrenador':listado_tipo_entrenador()

    }

    return render (request, 'intranet/administrador/crear_perfil_entrenador.html',data)


class CoachDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/entrenador/entrenador.html'

    def dispatch(self, request, *args, **kwargs):


        if request.user == 'AnonymousUser':
            return HttpResponseForbidden("Debes tener una sesion iniciada para poder entrar.")

        elif request.user.user_type != 'coach01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")

        return super().dispatch(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        entrenador = Coach.objects.get(user=self.request.user)
        
        # Pasamos el nombre al contexto
        context['nombre_entrenador'] = entrenador.coach_name
        
        return context


class AdminDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/administrador/administrador.html'

    def dispatch(self, request, *args, **kwargs):


        if request.user == 'AnonymousUser':
            return HttpResponseForbidden("Debes tener una sesion iniciada para poder entrar.")

        elif request.user.user_type != 'admin01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")

        return super().dispatch(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        admin = Admin.objects.get(user=self.request.user)
        
        # Pasamos el nombre al contexto
        context['nombre_admin'] = admin.admin_name
        
        return context    



############################################



##################  LOGIN  ##########################

class CustomLoginView(LoginView):
    form_class = CustomLoginForm
    template_name = 'registration/login.html' 




@login_required  # Asegúrate de que solo usuarios autenticados accedan a esta vista
def profile_redirect(request):
    user = request.user
    if user.user_type == 'coach01': 
        return redirect('entrenador_dashboard')  # Redirigir a la página del entrenador
    elif user.user_type == 'admin01':
        return redirect('admin_dashboard')  # Redirigir a la página del administrador
    else:
        return redirect('index')  
    
############################################


###########  Procedimientos Almacenados  ###########

def listado_entrenadores():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_COACH", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[0].read()), 'utf-8')
        }
        
        lista.append(data)

    return lista

def guardar_contacto(nombre,email,descripcion):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)
    
    cursor.callproc('SP_CREATE_CONTACT',[nombre,email,descripcion, salida])
    
    return salida.getvalue()
   

def listado_disciplinas():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_DISCIPLINE", [out_cur])

    lista_disciplina = []
    for fila in out_cur: 
        lista_disciplina.append(fila)

    return lista_disciplina

def listado_tipo_entrenador():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_COACH_TYPE", [out_cur])

    lista_tipo_entrenador = []
    for fila in out_cur: 
        lista_tipo_entrenador.append(fila)

    return lista_tipo_entrenador



####################################################