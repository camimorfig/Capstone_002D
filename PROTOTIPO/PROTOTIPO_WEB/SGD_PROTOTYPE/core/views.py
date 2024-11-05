
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
from .models import *
import oracledb
import cx_Oracle
import base64
import json
from django.shortcuts import get_object_or_404
from django.core.paginator import Paginator
from django.http import Http404
from datetime import date, datetime



###########  views de Templates  ###########
def index(request):
    
    data = {
        
        'disciplinas': listado_disciplinas(), 
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
            data['mensaje_exito'] = ['Guardado correctamente']
        else:
            data['mensaje_error'] = ['No se ha podido guardar. ERROR.']            

    return render (request, 'core/contacto.html',data)


def eventos(request):
    return render (request, 'core/eventos.html')


def galeria(request):
    galeria = listado_galeria_general()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(galeria, 9)
        galeria = paginator.page(page)
    except:
        raise Http404            


    data = {
    'entity':galeria,
    'paginator': paginator
    }   


    return render (request, 'core/galeria.html', data)


def nosotros(request):
    data = {
        'entrenadores':listado_entrenadores()
        }
    return render (request, 'core/nosotros.html', data)


def noticias(request):
    data = {
    'noticias': listado_noticias()
    }
    return render (request, 'core/noticias.html', data)


def disciplina_view(request, disciplina, seccion):
    disciplina_obj = get_object_or_404(Discipline, discipline_name__iexact=disciplina)
    
    if seccion == "acerca":
        # En este caso, mostramos la información básica de la disciplina
        data = {
            'disciplina': disciplina_obj,
            'seccion': seccion,
        }
        
    elif seccion == "plantel":
      # Recuperar jugadores relacionados con esta disciplina
        jugadores = Player.objects.filter(discipline=disciplina_obj, player_status = 1)
        
        # Lista para almacenar jugadores con sus imágenes en base64
        jugadores_listo = []
        for jugador in jugadores:
            if jugador.player_img:  # Verifica que haya una imagen
                # Codifica la imagen en base64 sin usar .read()
                imagen_base64 = base64.b64encode(jugador.player_img.read()).decode('utf-8')
                jugadores_listo.append({
                    'jugador': jugador,
                    'imagen_base64': imagen_base64
                })
            else:
                jugadores_listo.append({
                    'jugador': jugador,
                    'imagen_base64': None
                })
        
        data = {
            'disciplina': disciplina_obj,
            'seccion': seccion,
            'jugadores': jugadores_listo,
        }

    elif seccion == "galeria":
        # Recuperar las imágenes de la galería relacionadas con esta disciplina
        imagenes = listado_galeria_discipline(disciplina_obj.discipline_id)
        data = {
            'disciplina': disciplina_obj,
            'seccion': seccion,
            'imagenes': imagenes,
        }

    else:
        # Si la sección no es válida, podemos redirigir o mostrar un error
        return render(request, 'core/error.html', {'mensaje': 'Sección no encontrada'})

    # Renderizar la plantilla dinámica
    return render(request, 'core/disciplinas/disciplina_template.html', data)


def selecciones(request):

    data = {
        'disciplinas':listado_disciplinas()
        }  

    return render (request, 'core/selecciones.html', data)


def talento(request):
    data = {
        }
    return render (request, 'core/talento.html', data)


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

    if not hasattr(request.user, 'coach'):
        return HttpResponseForbidden("El usuario no está asociado a ningún entrenador.")

    entrenador = request.user.coach.first()  

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
        salida = guardar_jugador(rut, nombre, apellido, headquarters, career, imagen, discipline_id, entrenador_id)

        if salida == 1:
            data['mensaje_exito'] = ["Solicitud de Creación de Jugador enviada correctamente."]
        elif salida == -1:
            data['mensaje_error'] = ["Rut ya registrado. Cambie el rut o contacto con el administrador  ."] 
        else:
            data['mensaje_error'] = ["No se ha podido registrar. ERROR."]


    return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

@login_required
def asistencia_entrenador(request):
    if not hasattr(request.user, 'coach'):
        return HttpResponseForbidden("El usuario no está asociado a ningún entrenador.")

    entrenador = request.user.coach.first()  

    if not entrenador:
        return HttpResponseForbidden("No hay entrenadores asociados a este usuario.")

    # Obtener el ID del entrenador
    entrenador_id = entrenador.coach_id

    # Llamar al procedimiento almacenado para listar las disciplinas del entrenador
    disciplinas = listado_disciplinas_por_fechahoy_con_entrenador(entrenador_id)

    data = {
        'disciplinas': disciplinas
    }

    return render (request, 'intranet/entrenador/asistencia_entrenador.html', data)


def tomar_asistencia(request):
    discipline_id = request.GET.get('disciplina_id')

    if not discipline_id:
        messages.error(request, 'Disciplina no especificada')
        return redirect('asistencia_entrenador')


    try:
        discipline_id = int(discipline_id)

        # Obtener jugadores
        jugadores = listado_jugadores_por_disciplina(discipline_id)
        if not jugadores:
            messages.warning(request, 'No hay jugadores registrados en esta disciplina')
            return redirect('asistencia_entrenador')

        # Procesar POST
        if request.method == 'POST':
            print("Procesando POST para asistencia")  # Debug
            success_count = 0
            error_count = 0
            
            for jugador in jugadores:
                player_id = jugador['id']
                estado = request.POST.get(f'estado_{player_id}')
                comentario = request.POST.get(f'comentario_{player_id}', '')
                
                print(f"Procesando jugador {player_id}: estado={estado}")  # Debug
                
                if estado:  # Solo procesar si se seleccionó un estado
                    result = registrar_asistencia(
                        player_id=player_id,
                        discipline_id=discipline_id,
                        status=estado,
                        comments=comentario
                    )
                    
                    if result == 1:
                        success_count += 1
                        print(f"Asistencia registrada exitosamente para jugador {player_id}")
                    else:
                        error_count += 1
                        print(f"Error al registrar asistencia para jugador {player_id}")
            
            if error_count == 0 and success_count > 0:
                messages.success(request, f'Asistencia registrada correctamente para {success_count} jugadores')
                return redirect('asistencia_entrenador')
            elif error_count > 0:
                messages.error(request, f'Hubo errores al registrar {error_count} asistencias')
            else:
                messages.warning(request, 'No se seleccionó ningún estado de asistencia')
        
        context = {
            'jugadores': jugadores,
            'disciplina_id': discipline_id,
            'fecha_actual': date.today()
        }
                
    except Exception as e:
        print(f"Error en tomar_asistencia: {str(e)}")
        messages.error(request, f'Error: {str(e)}')
        return redirect('asistencia_entrenador')

    return render(request, 'intranet/entrenador/tomar_asistencia.html', context)



@login_required
def jugadores_por_disciplina(request):
    
    disciplina = request.GET.get('disciplina') 
    data = { 
        'jugadores':listado_jugador_por_disciplinas(disciplina),


    }

    return render (request, 'intranet/entrenador/obtener_datos_entrenador.html', data)

@login_required
def grafico(request):
    return render (request, 'intranet/entrenador/grafico.html')


###################### ADMIN ######################
class AdminDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/administrador/administrador.html'

    def dispatch(self, request, *args, **kwargs):


        if request.user == 'AnonymousUser':
            return HttpResponseForbidden("Debes tener una sesion iniciada para poder entrar.")

        elif request.user.user_type != 'admin01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")

        return super().dispatch(request, *args, **kwargs)

@login_required
def crear_perfil_entrenador(request):
    data = {
        'disciplinas': listado_disciplinas(),
        'tipo_entrenador': listado_tipo_entrenador(),
        'entrenadores':listado_entrenadores()

    }

    if request.method == 'POST':
        # Obtener los datos del formulario
        rut = request.POST.get('rut')
        nombre = request.POST.get('nombre')
        apellido = request.POST.get('apellido')
        tipo_entrenador = int(request.POST.get('tipo_entrenador')) 
        email = request.POST.get('email')

        if 'img' in request.FILES:
            imagen_file = request.FILES['img']
            imagen = imagen_file.read()
        else:
            data['mensaje_error'] = ["Debes subir una imagen para registrar al entrenador."]
            return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)

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
            data['entrenadores'] = listado_entrenadores()

        
        elif salida == -1:
            data['mensaje_error'] = ["Rut ya registrado. No es posible registrar al Entrenador."]

        elif salida == -2:
            data['mensaje_error'] = ["Email ya registrado. No es posible registrar al Entrenador."]

        else:
            data['mensaje_error'] = ["No se ha podido Registrar al entrenador. ERROR."]

    return render(request, 'intranet/administrador/crear_perfil_entrenador.html', data)

@login_required
def crear_noticias(request):

    data = {
        'noticias': listado_noticias()

    }

    if request.method == 'POST':
        if 'form_crear' in request.POST:
            if 'img' in request.FILES:
                imagen_file = request.FILES['img']
                img_noticia = imagen_file.read()
            else:

                data['mensaje_error'] = ["Debes subir una imagen para la noticia."]
                return render(request, 'intranet/crear_galeria.html', data)
    
            nombre_noticia = request.POST.get('nombre')
            if not nombre_noticia:
                data['mensaje_error'] = ["Debes ingresar un nombre para la noticia."]
                return render(request, 'intranet/crear_galeria.html', data)

            descripcion_noticia = request.POST.get('descripcion')
            if not descripcion_noticia:
                data['mensaje_error'] = ["Debes ingresar una descripción para la noticia."]
                return render(request, 'intranet/crear_galeria.html', data)

            etiqueta = request.POST.get('etiqueta')
            if not etiqueta:
                data['mensaje_error'] = ["Debes ingresar una etiqueta para la noticia."]
                return render(request, 'intranet/crear_galeria.html', data)

            # Guardar la galería en la base de datos
            salida = guardar_noticias(nombre_noticia, descripcion_noticia, img_noticia, etiqueta)

            if salida == 1:
                data['mensaje_exito'] = ["Imagen registrada correctamente."]
                data['noticias'] = listado_noticias()
            else:
                data['mensaje_error'] = ["No se ha podido registrar la galería. ERROR."]



        elif 'form_editar' in request.POST:
            id_noticias = request.POST.get('id')

            if id_noticias:
                noticia = get_object_or_404(News, news_id=id_noticias)

                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    img_noticia = imagen_file.read()  # Nueva imagen
                else:
                    img_noticia = noticia.news_img  # Imagen actual de la BD

                # Obtener otros campos del formulario
                nombre_noticia = request.POST.get('titulo')
                etiqueta = request.POST.get('etiqueta')
                descripcion_noticia = request.POST.get('descripcion')
                fecha_noticia = request.POST.get('fecha')

                salida = editar_noticias(id_noticias, nombre_noticia, descripcion_noticia, fecha_noticia, img_noticia, etiqueta)

                if salida == 1:
                    data['mensaje_exito'] = ["Noticia actualizada correctamente."]
                    data['noticias'] = listado_noticias()
                else:
                    data['mensaje_error'] = ["No se ha podido actualizar la noticia. ERROR."]

            else:
                data['mensaje_error'] = ["No se ha proporcionado un ID para la noticia a editar."]

        elif 'form_eliminar' in request.POST:
            id_noticias = request.POST.get('id')
                
            salida = eliminar_noticias(id_noticias)
            if salida == 1:
                data['mensaje_exito'] = ["Noticia eliminada correctamente."]
                data['noticias'] = listado_noticias()
            else:
                data['mensaje_error'] = ["No se ha podido eliminar la noticia. ERROR."]
        
        elif 'form_cacelar' in request.POST:
            
            return redirect('crear_noticias')  # Redirige para evitar reenvío de formulario en recarga


        


    return render (request, 'intranet/administrador/crear_noticias.html', data)


@login_required
def asistencia_admin(request):
    return render (request, 'intranet/administrador/asistencia_admin.html')


@login_required
def gestion_galeria_disciplina_por_disciplina(request):
    discipline_id = request.GET.get('disciplina')

    data = {
        'galeria_disciplina': listado_galeria_discipline(discipline_id)

    }
    
    return render(request, 'intranet/administrador/listar_galeria_disciplina.html', data)


@login_required
def gestion_galeria(request):


    disciplinas = listado_disciplinas()

    disciplina_seleccionada = None
    imagenes_disciplinas = []

    print(listado_galeria_discipline(6))

    if request.method == 'POST':
        discipline_id = request.POST.get('disciplina')
        if discipline_id:
            # Recuperar los jugadores asociados a esta disciplina
            imagenes_disciplinas = listado_galeria_discipline(discipline_id)  # Ajusta según tu modelo

    data = {
        'disciplinas': disciplinas,
        'galeria': listado_galeria_general(),
        'disciplina_seleccionada': disciplina_seleccionada,
        'galeria_disciplina' : imagenes_disciplinas,
    }


    if request.method == 'POST':

        publicar_en = request.POST.get('publicar_en')
        if publicar_en == 'galeria-general':

            if 'imagen' in request.FILES:
                imagen_file = request.FILES['imagen']
                imagen = imagen_file.read()
            else:
                data['mensaje_error'] = ["Debes subir una imagen para publicar en la galería general."]
                return render (request, 'intranet/administrador/gestion_galeria.html', data)
            
            etiqueta = request.POST.get('etiqueta')
            if not etiqueta:
                data['mensaje_error'] = ["Debes ingresar una etiqueta para publicar en la galería general."]
                return render (request, 'intranet/administrador/gestion_galeria.html', data)

            # Guardar la imagen en la galeria general de la base de datos
            salida = guardar_galeria_general(imagen, etiqueta)

            if salida == 1:
                data['mensaje_exito'] = ["Imagen registrada correctamente en galeria general."]
            else:
                data['mensaje_error'] = ["No se ha podido registrar la imagen. ERROR."]

        elif publicar_en == 'galeria-disciplina':
            
            if 'imagen' in request.FILES:
                imagen_file = request.FILES['imagen']
                imagen = imagen_file.read()
            else:
                data['mensaje_error'] = ["Debes subir una imagen para publicar en la galeria de disciplina."]
                return render (request, 'intranet/administrador/gestion_galeria.html', data)
            
            discipline_id = request.POST.get('discipline_id')
            if not discipline_id:
                data['mensaje_error'] = ["Debes ingresar una Disciplina para registrar una imagen en la galeria de disciplina."]
                return render (request, 'intranet/administrador/gestion_galeria.html', data)

            etiqueta = request.POST.get('etiqueta')
            if not etiqueta:
                data['mensaje_error'] = ["Debes ingresar una etiqueta para publicar en la galeria de disciplina."]
                return render (request, 'intranet/administrador/gestion_galeria.html', data)

            salida = guardar_galeria_disciplina(imagen, discipline_id, etiqueta)

            if salida == 1:
                data['mensaje_exito'] = ["Imagen registrada correctamente en galeria de disciplina."]
                data['galeria'] = listado_galeria_general()

            else:
                data['mensaje_error'] = ["No se ha podido registrar la imagen. ERROR."]


    return render (request, 'intranet/administrador/gestion_galeria.html', data)

@login_required
def solicitud_jugador(request):

    data = {
        'solicitud': listado_solicitud(),
        'contacto': listado_contacto()

    }
    return render (request, 'intranet/administrador/solicitud_jugador.html', data)



def aceptar_solicitud(request, id):
    
    data = {

    }
    
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()
    salida = cursor.var(oracledb.NUMBER)
     
    cursor.callproc('sp_acept_request', [id, salida])
    
    salida_final = salida.getvalue()
    if salida_final == 1:
        data = {    'mensaje_exito': "Solicitud aceptada exitosamente.",
                    'solicitud': listado_solicitud(), } 
        return render(request, 'intranet/administrador/solicitud_jugador.html', data)

    elif salida_final == 0:
        data['mensaje_error'] = ["Error en la BD."]
        return render(request, 'intranet/administrador/solicitud_jugador.html', data)       
    else:
        data['mensaje_error'] = ["No se pudo procesar la solicitud."]
        return render(request, 'intranet/administrador/solicitud_jugador.html', data)


def gestion_disciplina(request):
    disciplinas = listado_disciplinas()
    disciplina_seleccionada = None
    jugadores = []

    if request.method == 'POST':
        discipline_id = request.POST.get('disciplina')
        if discipline_id:
            disciplina_seleccionada = Discipline.objects.get(discipline_id=discipline_id)
            # Recuperar los jugadores asociados a esta disciplina
            jugadores = Player.objects.filter(discipline=disciplina_seleccionada)  # Ajusta según tu modelo

    context = {
        'disciplinas': disciplinas,
        'disciplina_seleccionada': disciplina_seleccionada,
        'jugadores': jugadores,
    }
    return render(request, 'intranet/administrador/gestion_disciplina.html', context)


def update_discipline(request):
    discipline_id = request.POST.get('discipline_id')
    discipline = get_object_or_404(Discipline, discipline_id=discipline_id)

    try:
        if 'title' in request.POST:
            discipline.discipline_name = request.POST['title']
        if 'description' in request.POST:
            discipline.discipline_description = request.POST['description']
        if 'image' in request.FILES:
            discipline.discipline_image = request.FILES['image']

        discipline.save()

        return JsonResponse({
            'success': True,
            'image_url': discipline.discipline_image.url if discipline.discipline_image else None
        })
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': str(e)
        }, status=400)


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
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[3].read()), 'utf-8')
        }
        
        lista.append(data)

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


def guardar_jugador(rut, nombre, apellido, headquarters, career, imagen, discipline_id, entrenador_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_PLAYER', [   rut, nombre, apellido, headquarters, career, imagen, discipline_id, entrenador_id, salida])

    return salida.getvalue()


def guardar_galeria_general(imagen, etiqueta):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_GALERY_GENERAL', [
        imagen, 
        etiqueta,
        salida
    ])

    return salida.getvalue()


def guardar_galeria_disciplina(imagen, discipline_id, etiqueta):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_GALERY_DISCIPLINE', [
        imagen,
        etiqueta,
        discipline_id, 

        salida
    ])

    return salida.getvalue()    


def listado_galeria_portada():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("sp_list_images_front", [out_cur])

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


def guardar_noticias(nombre_noticia, descripcion_noticia, img_noticia, etiqueta):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_NEWS', [
        nombre_noticia,
        descripcion_noticia,
        img_noticia,
        etiqueta,
        salida
    ])

    return salida.getvalue()

                    
def editar_noticias(id_noticia, nombre_noticia, descripcion_noticia, fecha_noticia, img_noticia, etiqueta):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_EDIT_NEWS', [
        id_noticia,
        nombre_noticia,
        descripcion_noticia,
        fecha_noticia,
        img_noticia,
        etiqueta,
        salida
    ])

    return salida.getvalue()


def eliminar_noticias(id_noticia):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_DELETE_NEWS', [
        id_noticia,
        salida
    ])

    return salida.getvalue()


def listado_noticias():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("sp_list_news", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[5].read()), 'utf-8'),        
        }

        lista.append(data)

    return lista


def listado_galeria_general():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("sp_list_images_general", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[1].read()), 'utf-8'),    
            
        }

        lista.append(data)

    return lista


def listado_galeria_discipline(disciplina_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("sp_list_images_discipline", [out_cur, disciplina_id])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[1].read()), 'utf-8'),    
            
        }

        lista.append(data)

    return lista


def listado_solicitud():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("sp_list_request", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            
        }

        lista.append(data)

    return lista


def listado_contacto():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_CONTACT", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            
        }

        lista.append(data)

    return lista


def listado_jugadores_por_disciplina(discipline_id):
    try:
        django_cursor = connection.cursor()
        out_cur = django_cursor.connection.cursor()
        # Ejecutar el procedimiento
        django_cursor.callproc("SP_LIST_PLAYERS_FOR_DISCIPLINE", [out_cur, str(discipline_id)])
        
        # Procesar resultados
        lista = []
        for fila in out_cur:
            jugador = {
                'id': fila[0],
                'rut': fila[1],
                'nombre': fila[2],
                'apellido': fila[3],
                'disciplina': fila[4],
                'sede': fila[5],
                'carrera': fila[6],
                'promedio_asistencia': fila[7]
            }
            lista.append(jugador)
        return lista
    except Exception as e:
        print(f"Error al obtener jugadores: {str(e)}")
        return []
    finally:
        if 'out_cur' in locals():
            out_cur.close()
        if 'django_cursor' in locals():
            django_cursor.close()


def registrar_asistencia(player_id, discipline_id, status, comments):
    try:
        with connection.cursor() as cursor:
            # Primero obtenemos el status_id
            cursor.execute(
                "SELECT status_id FROM attendance_status WHERE status_name = :1",
                [status]
            )
            status_row = cursor.fetchone()
            if not status_row:
                print(f"Estado no encontrado: {status}")
                return 0
                
            status_id = status_row[0]
            
            # Luego insertamos la asistencia
            cursor.execute("""
                INSERT INTO attendance (
                    player_id,
                    discipline_id,
                    status_id,
                    attendance_date,
                    attendance_comments
                ) VALUES (
                    :1,
                    :2,
                    :3,
                    SYSDATE,
                    :4
                )
            """, [player_id, discipline_id, status_id, comments])
            
            cursor.connection.commit()
            return 1
            
    except Exception as e:
        print(f"Error al registrar asistencia: {str(e)}")
        if 'cursor' in locals():
            cursor.connection.rollback()
        return -1


def verificar_asistencia_existente(discipline_id):
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) 
                FROM Attendance 
                WHERE discipline_id = :1 
                AND TRUNC(attendance_date) = TRUNC(SYSDATE)
            """, [discipline_id])
            
            count = cursor.fetchone()[0]
            return count > 0
    except Exception as e:
        print(f"Error al verificar asistencia: {str(e)}")
        return False

def listado_disciplinas_por_fechahoy_con_entrenador(id_entrenador):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_DISCIPLINE_DATE_FOR_COACH", [out_cur, id_entrenador])

    lista = []
    for fila in out_cur: 
        lista.append(fila)

    return lista