
from django.shortcuts import render
from django.urls import reverse
from django.db import connection
from django.contrib.auth.views import LoginView
from .forms import CustomLoginForm
from django.http import HttpResponseForbidden
from django.contrib.auth import login
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages 
from django.views.generic import TemplateView
from .models import Coach, Admin, Discipline, Player, Galery
import oracledb
import cx_Oracle
import base64
import json
from django.shortcuts import get_object_or_404



###########  views de Templates  ###########
def index(request):
    data = {
        'galeria_pf':listado_galeria_portada()
        }
    return render (request, 'core/index.html', data)


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


def disciplina_view(request, disciplina, seccion):
    disciplina_obj = get_object_or_404(Discipline, discipline_name__iexact=disciplina)
    
    if seccion == "acerca":
        # En este caso, mostramos la información básica de la disciplina
        context = {
            'disciplina': disciplina_obj,
            'seccion': seccion,
        }
        
    elif seccion == "plantel":
      # Recuperar jugadores relacionados con esta disciplina
        jugadores = Player.objects.filter(discipline=disciplina_obj)
        
        # Lista para almacenar jugadores con sus imágenes en base64
        jugadores_con_imagenes = []
        for jugador in jugadores:
            if jugador.player_img:  # Verifica que haya una imagen
                # Codifica la imagen en base64 sin usar .read()
                imagen_base64 = base64.b64encode(jugador.player_img.read()).decode('utf-8')
                jugadores_con_imagenes.append({
                    'jugador': jugador,
                    'imagen_base64': imagen_base64
                })
        
        context = {
            'disciplina': disciplina_obj,
            'seccion': seccion,
            'jugadores_con_imagenes': jugadores_con_imagenes,
        }

    elif seccion == "galeria":
        # Recuperar las imágenes de la galería relacionadas con esta disciplina
        imagenes = Galery.objects.filter(galery_description__icontains=disciplina_obj.discipline_name)
        context = {
            'disciplina': disciplina_obj,
            'seccion': seccion,
            'imagenes': imagenes,
        }

    else:
        # Si la sección no es válida, podemos redirigir o mostrar un error
        return render(request, 'core/error.html', {'mensaje': 'Sección no encontrada'})

    # Renderizar la plantilla dinámica
    return render(request, 'core/disciplinas/disciplina_template.html', context)


###################### COACH ######################
class CoachDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/entrenador/entrenador.html'

    def dispatch(self, request, *args, **kwargs):


        if request.user == 'AnonymousUser':
            return HttpResponseForbidden("Debes tener una sesion iniciada para poder entrar.")

        elif request.user.user_type != 'coach01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")

        return super().dispatch(request, *args, **kwargs)


@login_required
def perfil_jugadores(request):
    # Verificar si el usuario tiene entrenadores asociados
    if not hasattr(request.user, 'coach'):
        return HttpResponseForbidden("El usuario no está asociado a ningún entrenador.")

    # Obtener el ID del entrenador autenticado, asegurando que hay uno asociado
    entrenador = request.user.coach.first()  # Si hay múltiples entrenadores, obtén el primero

    if not entrenador:
        return HttpResponseForbidden("No hay entrenadores asociados a este usuario.")

    # Obtener el ID del entrenador
    entrenador_id = entrenador.coach_id

    # Llamar al procedimiento almacenado para listar las disciplinas del entrenador
    disciplinas = listado_disciplinas_por_entrenador(entrenador_id)

    data = {
        'disciplinas': disciplinas
    }

    return render(request, 'intranet/entrenador/perfil_jugadores.html', data)

@login_required
def crear_perfil_Jugador(request):

    # Verificar si el usuario tiene entrenadores asociados
    if not hasattr(request.user, 'coach'):
        return HttpResponseForbidden("El usuario no está asociado a ningún entrenador.")

    # Obtener el ID del entrenador autenticado, asegurando que hay uno asociado
    entrenador = request.user.coach.first()  # Si hay múltiples entrenadores, obtén el primero

    if not entrenador:
        return HttpResponseForbidden("No hay entrenadores asociados a este usuario.")

    # Obtener el ID del entrenador
    entrenador_id = entrenador.coach_id

    # Llamar al procedimiento almacenado para listar las disciplinas del entrenador
    disciplinas = listado_disciplinas_por_entrenador(entrenador_id)

    data = {
        'disciplinas': disciplinas
    }


    if request.method == 'POST':
        # Obtener los datos del formulario
        imagen = request.FILES.get('imagen').read()
        if not imagen:
            data['mensaje_error'] = ["Debes subir una imagen para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        rut = request.POST.get('rut')
        if not rut:
            data['mensaje_error'] = ["Debes ingresar un Rut para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        nombre = request.POST.get('nombre')
        if not nombre:
            data['mensaje_error'] = ["Debes ingresar un Nombre para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        apellido = request.POST.get('apellido')
        if not apellido:
            data['mensaje_error'] = ["Debes ingresar un Apellido para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        headquarters = request.POST.get('headquarters')
        if not headquarters:
            data['mensaje_error'] = ["Debes ingresar una Sede para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        career = request.POST.get('career')
        if not career:
            data['mensaje_error'] = ["Debes ingresar una Carrera para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        discipline_id = request.POST.get('disciplina')
        if not discipline_id:
            data['mensaje_error'] = ["Debes ingresar una Disciplina para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)


     #  position_id = request.POST.get('position_id')

        # Guardar el jugador en la base de datos
        salida = guardar_jugador(rut, nombre, apellido, headquarters, career, imagen, discipline_id)

        if salida == 1:
            data['mensaje_exito'] = ["Jugador registrado correctamente."]
        else:
            data['mensaje_error'] = ["No se ha podido registrar. ERROR."]


    return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)


def asistencia_entrenador(request):
    data = {


    }

    return render (request, 'intranet/entrenador/asistencia_entrenador.html', data)


def tomar_asistencia(request):
    return render (request, 'intranet/entrenador/tomar_asistencia.html')


def jugadores_por_disciplina(request):
    
    disciplina = request.GET.get('disciplina') 
    print(disciplina)
    data = { 
        'jugadores':listado_jugador_por_disciplinas(disciplina)

    }

    return render (request, 'intranet/entrenador/obtener_datos_entrenador.html', data)


def grafico(request):
    return render (request, 'intranet/entrenador/grafico.html')


#####################################################


###################### ADMIN ######################
class AdminDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/administrador/administrador.html'

    def dispatch(self, request, *args, **kwargs):


        if request.user == 'AnonymousUser':
            return HttpResponseForbidden("Debes tener una sesion iniciada para poder entrar.")

        elif request.user.user_type != 'admin01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")

        return super().dispatch(request, *args, **kwargs)


def crear_perfil_entrenador(request):
    data = {
        'disciplinas': listado_disciplinas(),
        'tipo_entrenador': listado_tipo_entrenador(),
    }

    if request.method == 'POST':
        # Obtener los datos del formulario
        rut = request.POST.get('rut')
        nombre = request.POST.get('nombre')
        apellido = request.POST.get('apellido')
        tipo_entrenador = int(request.POST.get('tipo_entrenador')) 
        email = request.POST.get('email')
        imagen = request.FILES.get('imagen').read() if request.FILES.get('imagen') else None
        disciplinas_seleccionadas = request.POST.getlist('lista_de_disciplina')


        # Validaciones
        if not rut:
            data['mensaje_error'] = ["Debes ingresar un Rut para registrar un entrenador."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)
        if not nombre:
            data['mensaje_error'] = ["Debes ingresar un Nombre para registrar un entrenador."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)
        if not apellido:
            data['mensaje_error'] = ["Debes ingresar un Apellido para registrar un entrenador."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)
        if not tipo_entrenador:
            data['mensaje_error'] = ["Debes ingresar un Tipo de Entrenador para registrar un entrenador."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)
        if not email:
            data['mensaje_error'] = ["Debes ingresar un Email para registrar un entrenador."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)
        if not disciplinas_seleccionadas:
            data['mensaje_error'] = ["Debes seleccionar al menos una disciplina."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)

        disciplinas_seleccionadas = [int(disciplina) for disciplina in disciplinas_seleccionadas]


        # Generar contraseña
        nombre_concatenado = apellido[:2]
        rut_extracto = rut.split('-')[0]
        resultado_pass = nombre_concatenado.lower() + rut_extracto
        hashed_password = make_password(resultado_pass)


        # Llamar a la función para guardar el entrenador
        salida = guardar_entrenador(
            rut, 
            nombre, 
            apellido, 
            imagen, 
            tipo_entrenador, 
            email, 
            hashed_password,  
            disciplinas_seleccionadas 
        )

        # Manejar el resultado de salida
        if salida == 1:
            data['mensaje_exito'] = ["Entrenador registrado correctamente."]
        
        elif salida == -1:
            data['mensaje_error'] = ["Rut ya registrado. No es posible registrar al Entrenador."]

        elif salida == -2:
            data['mensaje_error'] = ["Email ya registrado. No es posible registrar al Entrenador."]

        else:
            data['mensaje_error'] = ["No se ha podido Registrar al entrenador. ERROR."]

    return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)


def crear_noticias(request):
    return render (request, 'intranet/administrador/crear_noticias.html')


def subir_imagen(request):

    data = {
        'disciplinas': listado_disciplinas()  # Asumiendo que existe una función para listar disciplinas
    }

    if request.method == 'POST':
        imagen = request.FILES.get('imagen').read()
        if not imagen:
            data['mensaje_error'] = ["Debes subir una imagen para registrar una galería."]
            return render(request, 'intranet/crear_galeria.html', data)
 
        discipline_id = request.POST.get('discipline_id')
        if not discipline_id:
            data['mensaje_error'] = ["Debes ingresar una disciplina para la galería."]
            return render(request, 'intranet/crear_galeria.html', data)

        galery_description = request.POST.get('galery_description')
        if not galery_description:
            data['mensaje_error'] = ["Debes ingresar una descripción para la galería."]
            return render(request, 'intranet/crear_galeria.html', data)

        portada = request.POST.get('portada')
        if portada == "on":
            portada = 1
        elif portada == None:
            portada = 0


        # Guardar la galería en la base de datos
        salida = guardar_galeria(imagen, portada, galery_description, discipline_id)

        if salida == 1:
            data['mensaje_exito'] = ["Imagen registrada correctamente."]
        else:
            data['mensaje_error'] = ["No se ha podido registrar la galería. ERROR."]

    
    return render (request, 'intranet/administrador/subir_imagen.html', data)


def asistencia_admin(request):
    return render (request, 'intranet/administrador/asistencia_admin.html')


def gestion_galeria(request):
    return render (request, 'intranet/administrador/gestion_galeria.html')


def solicitud_jugador(request):
    return render (request, 'intranet/administrador/solicitud_jugador.html')



#####################################################


##################  LOGIN  ##########################
class CustomLoginView(LoginView):
    form_class = CustomLoginForm
    template_name = 'registration/login.html'

    def form_invalid(self, form):
        messages.error(self.request, "Credenciales incorrectas. Por favor, intenta de nuevo.")
        return super().form_invalid(form)


@login_required  
def profile_redirect(request):
    user = request.user
    if user.user_type == 'coach01': 
        return redirect('entrenador_dashboard')  # Redirigir a la página del entrenador
    elif user.user_type == 'admin01':
        return redirect('admin_dashboard')  # Redirigir a la página del administrador
    else:
        return redirect('index')  

 

#####################################################


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

    lista = []
    for fila in out_cur: 
        lista.append(fila)

    return lista


def listado_tipo_entrenador():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_COACH_TYPE", [out_cur])

    lista= []
    for fila in out_cur: 
        lista.append(fila)

    return lista


def guardar_entrenador(rut, nombre, apellido, imagen, tipo_entrenador, email, password, disciplinas_lista):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    disciplinas_json = json.dumps(disciplinas_lista)
    
    try:
        cursor.callproc('SP_CREATE_COACH_USER', [
            rut, 
            nombre, 
            apellido, 
            imagen, 
            tipo_entrenador, 
            email, 
            password, 
            disciplinas_json,  # Pasar el JSON de disciplinas
            salida
        ])
    except Exception as e:
        print(f'Error al ejecutar el procedimiento almacenado: {str(e)}')
        return 0

    return salida.getvalue()


def guardar_jugador(rut, nombre, apellido, headquarters, career, imagen, discipline_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_PLAYER', [
        rut, nombre, apellido, headquarters, career, imagen, discipline_id, salida
    ])

    return salida.getvalue()


def guardar_galeria(imagen, portada, galery_description, discipline_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_GALERY', [
        imagen, 
        portada, 
        galery_description, 
        discipline_id,

        salida
    ])

    return salida.getvalue()


def listado_galeria_portada():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("sp_list_images_front_page", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[1].read()), 'utf-8'),    
            
        }

        lista.append(data)

    return lista


def listado_disciplinas_por_entrenador(id_entrenador):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_DISCIPLINE_FOR_COACH", [out_cur, id_entrenador])

    lista = []
    for fila in out_cur: 
        lista.append(fila)

    return lista


def listado_jugador_por_disciplinas(id_disciplina):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_PLAYERS_FOR_DISCIPLINE", [out_cur, id_disciplina])

    lista = []
    for fila in out_cur: 
        lista.append(fila)

    return lista

####################################################
