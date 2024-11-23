
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
from datetime import date, datetime, timedelta




###########  views de Templates  ###########
def index(request):
    

    data = {
        
        'noticias_index': listado_noticias_index(), 
        'galeria_index':listado_galeria_portada()
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
    noticia = listado_noticias_por_tiempo()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(noticia, 5)
        noticia = paginator.page(page)
    except:
        raise Http404            

    
    data = {
        'entity': noticia,
        'paginator': paginator

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

        # Recuperar jugadores relacionados con esta disciplina
        jugadores = Player.objects.filter(discipline=disciplina_obj, player_status = 1)
        
        # Lista para almacenar jugadores con sus imágenes en base64
        jugadores_listo = []
        for jugador in jugadores:
            if jugador.player_img:  # Verifica que haya una imagen
                # Codifica la imagen en base64 sin usar .read()
                imagen_base64 = base64.b64encode(jugador.player_img).decode('utf-8')
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

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        try:
            # Obtener el entrenador y su ID
            entrenador = self.request.user.coach.first()
            entrenador_id = entrenador.coach_id
            
            # Obtener las disciplinas del entrenador
            disciplinas = listado_disciplinas_por_entrenador(entrenador_id)
            # print(f"Disciplinas del entrenador: {disciplinas}")  # Para depuración
            
            # Obtener eventos para el entrenador
            eventos = listado_eventos_entrenador(entrenador_id)
            context['eventos'] = eventos
            context['disciplinas'] = disciplinas
            
            # print(f"Eventos obtenidos: {eventos}")  # Para depuración
            
        except Exception as e:
            print(f"Error al obtener datos: {str(e)}")
            context['eventos'] = []
            context['disciplinas'] = []
            messages.error(self.request, "Error al cargar los datos")
        return context

    def dispatch(self, request, *args, **kwargs):
        if request.user.is_anonymous:
            return HttpResponseForbidden("Debes tener una sesion iniciada para poder entrar.")
        elif request.user.user_type != 'coach01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")
            
        if not hasattr(request.user, 'coach'):
            return HttpResponseForbidden("El usuario no está asociado a ningún entrenador.")

        entrenador = request.user.coach.first()
        if not entrenador:
            return HttpResponseForbidden("No hay entrenadores asociados a este usuario.")

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

        horario = request.POST.get('horario')
        if not horario:
            data['mensaje_error'] = ["Debes Seleccionar un horario para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

        fecha_nacimiento = request.POST.get('fecha_nacimiento')
        if not fecha_nacimiento:
            data['mensaje_error'] = ["Debes ingresar una fwcha de nacimiento para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)


        discipline_id = request.POST.get('disciplina')
        if not discipline_id:
            data['mensaje_error'] = ["Debes ingresar una Disciplina para registrar un jugador."]
            return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)


        # Guardar el jugador en la base de datos
        salida = guardar_jugador(rut, nombre, apellido, headquarters, career, horario, fecha_nacimiento, imagen, discipline_id, entrenador_id)

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
    # Llamar al procedimiento almacenado para listar los entrenamientos del entrenador
    entrenamientos = listado_entrenamientos_por_entrenador(entrenador_id)
    print(entrenamientos)
    data = {
        'entrenamientos': entrenamientos
    }
    return render(request, 'intranet/entrenador/asistencia_entrenador.html', data)

@login_required
def tomar_asistencia(request):
    try:
        discipline_id = int(request.GET.get('disciplina_id', 0))
        training_id = int(request.GET.get('training_id', 0))
        
        if not discipline_id or not training_id:
            messages.error(request, 'Disciplina o entrenamiento no especificado')
            return redirect('asistencia_entrenador')
        
        # Obtener jugadores
        jugadores = listado_jugadores_por_disciplina(discipline_id)
        if not jugadores:
            messages.warning(request, 'No hay jugadores registrados en esta disciplina')
            return redirect('asistencia_entrenador')

        if request.method == 'POST':
            for jugador in jugadores:
                player_id = jugador['id']
                estado = request.POST.get(f'estado_{player_id}')
                comentario = request.POST.get(f'comentario_{player_id}', '')
                
                if estado:
                    print(f"Registrando asistencia para jugador {player_id}")
                    result = registrar_asistencia(
                        player_id=int(player_id),
                        discipline_id=discipline_id,
                        training_id=training_id,
                        status=estado,
                        comments=comentario
                    )
                    
                    if result:
                        print(f"Asistencia registrada exitosamente para jugador {player_id}")
                    else:
                        print(f"Error al registrar asistencia para jugador {player_id}")
                        messages.warning(
                            request, 
                            f'No se pudo registrar la asistencia para el jugador {jugador.get("nombre", player_id)}'
                        )
        context = {
            'jugadores': jugadores,
            'disciplina_id': discipline_id,
            'training_id': training_id,
            'fecha_asistencia': datetime.now().strftime('%Y-%m-%d')
        }
        
        return render(request, 'intranet/entrenador/tomar_asistencia.html', context)
                
    except Exception as e:
        print(f"Error en tomar_asistencia: {str(e)}")
        print(player_id)
        print(training_id)
        print(discipline_id)
        print(estado)
        print(comentario)
        messages.error(request, f'Error: {str(e)}')
        return redirect('asistencia_entrenador')

@login_required
def registrar_asistencia(player_id, discipline_id, training_id, status, comments=''):
    try:
        django_cursor = connection.cursor()
        cursor = django_cursor.connection.cursor()
        out_cur = django_cursor.connection.cursor()

        # Llamar al procedimiento
        cursor.callproc("SP_REGISTRAR_ASISTENCIA", [
            player_id,
            training_id,
            discipline_id,
            status,
            comments if comments else '',
            out_cur
        ])

        # Obtener resultado
        result = 0
        for fila in out_cur:
            result = fila[0]
            break

        return result == 1

    except Exception as e:
        print(f"Error al llamar SP_REGISTRAR_ASISTENCIA: {str(e)}")

        print(f"Parámetros: player_id={player_id}, training_id={training_id}, discipline_id={discipline_id}, status={status}, comments={comments}")
        return False

@login_required
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



###################### ADMIN ######################
class AdminDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/administrador/administrador.html'

    def dispatch(self, request, *args, **kwargs):

        if not request.user.is_authenticated:
            return redirect('login')  

        if not hasattr(request.user, 'user_type') or request.user.user_type != 'admin01':
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
def gestion_noticias(request):
    noticia = listado_noticias()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(noticia, 9)
        noticia = paginator.page(page)
    except:
        raise Http404            

    
    data = {
        'entity': noticia,
        'paginator': paginator

    }

    if request.method == 'POST':
        if 'form_crear' in request.POST:
            if 'img' in request.FILES:
                imagen_file = request.FILES['img']
                img_noticia = imagen_file.read()
            else:
                messages.error(request, "Debes subir una imagen para la noticia.")
                return redirect('gestion_noticias')

            nombre_noticia = request.POST.get('nombre')
            if not nombre_noticia:
                messages.error(request, "Debes ingresar un nombre para la noticia.")
                return redirect('gestion_noticias')

            descripcion_noticia = request.POST.get('descripcion')
            if not descripcion_noticia:
                messages.error(request, "Debes ingresar una descripción para la noticia.")
                return redirect('gestion_noticias')

            etiqueta = request.POST.get('etiqueta')
            if not etiqueta:
                messages.error(request, "Debes ingresar una etiqueta para la noticia.")
                return redirect('gestion_noticias')

            # Guardar la galería en la base de datos
            salida = guardar_noticias(nombre_noticia, descripcion_noticia, img_noticia, etiqueta)

            if salida == 1:
                messages.success(request, "Imagen registrada correctamente.")
            else:
                messages.error(request, "No se ha podido registrar la galería. ERROR.")
            return redirect('gestion_noticias')

        elif 'form_editar' in request.POST:
            id_noticias = request.POST.get('id')
            if id_noticias:
                noticia = get_object_or_404(News, news_id=id_noticias)
                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    img_noticia = imagen_file.read()
                else:
                    img_noticia = noticia.news_img

                nombre_noticia = request.POST.get('titulo')
                etiqueta = request.POST.get('etiqueta')
                descripcion_noticia = request.POST.get('descripcion')
                fecha_noticia = request.POST.get('fecha')

                fecha_noticia = datetime.strptime(fecha_noticia, '%Y-%m-%dT%H:%M').strftime('%Y-%m-%d %H:%M:%S')

                salida = editar_noticias(id_noticias, nombre_noticia, descripcion_noticia, fecha_noticia, img_noticia, etiqueta)

                if salida == 1:
                    messages.success(request, "Noticia actualizada correctamente.")
                else:
                    messages.error(request, "No se ha podido actualizar la noticia. ERROR.")
                return redirect('gestion_noticias')
    
            else:
                messages.error(request, "No se ha proporcionado un ID para la noticia a editar.")
            return redirect('gestion_noticias')

        elif 'form_eliminar' in request.POST:
            id_noticias = request.POST.get('id')
            salida = eliminar_noticias(id_noticias)
            if salida == 1:
                messages.success(request, "Noticia eliminada correctamente.")
            else:
                messages.error(request, "No se ha podido eliminar la noticia. ERROR.")
            return redirect('gestion_noticias')

    return render(request, 'intranet/administrador/gestion_noticias.html', data)

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

    galerias = listado_galeria_general()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(galerias, 9)
        galerias = paginator.page(page)
    except:
        raise Http404            


    data = {
    'entity':galerias,
    'paginator': paginator
    }   


    if request.method == 'POST':
        if 'form_crear' in request.POST:

            if 'imagen' in request.FILES:
                imagen_file = request.FILES['imagen']
                imagen = imagen_file.read()
            else:
                messages.error(request, "Debes subir una imagen para publicar en la galería general.")
                return redirect('gestion_galeria')
            

            etiqueta = request.POST.get('etiqueta')
            if not etiqueta:
                messages.error(request, "Debes ingresar una etiqueta para publicar en la galería general.")
                return redirect('gestion_galeria')

            # Guardar la imagen en la galeria general de la base de datos
            salida = guardar_galeria_general(imagen, etiqueta)

            if salida == 1:
                messages.success(request, "Imagen registrada correctamente en galeria general.")            
            else:
                messages.error(request, "No se ha podido registrar la imagen. ERROR.")            
            return redirect('gestion_galeria')

        elif 'form_editar' in request.POST:
            id_galeria = request.POST.get('id')
            if id_galeria:
                galeria = get_object_or_404(GaleryGeneral, galery_gen_id=id_galeria)
                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    img_galeria = imagen_file.read()
                else:
                    img_galeria = galeria.galery_gen_img
                
                nombre_galeria = request.POST.get('titulo')
                fecha_galeria = request.POST.get('fecha')
                
                fecha_galeria = datetime.strptime(fecha_galeria, '%Y-%m-%dT%H:%M').strftime('%Y-%m-%d %H:%M:%S')
        
                salida = editar_galeria_general(id_galeria, img_galeria ,nombre_galeria, fecha_galeria)

                if salida == 1:
                    messages.success(request, "Imagen actualizada correctamente.")
                    return redirect('gestion_galeria')
                else:
                    messages.error(request, "No se ha podido actualizar la imagen. ERROR.")
                    return redirect('gestion_galeria')

        elif 'form_eliminar' in request.POST:
            id_galeria = request.POST.get('id')
            salida = eliminar_galeria_general(id_galeria)

            if salida == 1:
                messages.success(request, "La imagen fue eliminada correctamente.")
                return redirect('gestion_galeria')
            else:
                messages.error(request, "No se ha podido eliminar la Imagen. ERROR.")
                return redirect('gestion_galeria')        


    return render (request, 'intranet/administrador/gestion_galeria.html', data)

@login_required
def solicitud_jugador(request):

    data = {
        'solicitud': listado_solicitud(),
        'contacto': listado_contacto()

    }
    return render (request, 'intranet/administrador/solicitud_jugador.html', data)

@login_required
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

### Disciplina ###

@login_required
def gestion_disciplina(request):
    disciplinas = listado_disciplinas()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(disciplinas, 9)
        disciplinas = paginator.page(page)
    except:
        raise Http404            


    data = {
    'entity':disciplinas,
    'paginator': paginator
    }  

    if request.method == 'POST':
    
        if 'form_editar' in request.POST:
        
            discipline_id = request.POST.get('id')
            print(discipline_id)
            if discipline_id:
                print("aaaa")

                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    img_disciplina = imagen_file.read()
                else:
                    disciplina = get_object_or_404(Discipline, discipline_id=discipline_id)
                    img_disciplina = disciplina.galery_img
                
                nombre_disciplina = request.POST.get('nombre')
                descripcion_disciplina = request.POST.get('descripcion')  

                salida = editar_disciplinas(discipline_id, img_disciplina ,nombre_disciplina, descripcion_disciplina)
                
                if salida == 1:
                    messages.success(request, "Disciplina actualizada correctamente.")
                    return redirect('gestion_disciplina')
                else:
                    messages.error(request, "No se ha podido actualizar la disciplina. ERROR.")
                    return redirect('gestion_disciplina')

        elif 'form_confirmacion' in request.POST:
            

            confirmacion_disciplina(discipline_id)
            
            
            
            
            if 'form_eliminar' in request.POST:
                discipline_id = request.POST.get('id')
                salida = eliminar_disciplina(discipline_id)

                if salida == 1:
                    messages.success(request, "La disciplina fue eliminada correctamente.")
                    return redirect('gestion_disciplina')
                else:
                    messages.error(request, "No se ha podido eliminar la Disciplina. ERROR.")
                    return redirect('gestion_disciplina')        

    return render(request, 'intranet/administrador/gestion_disciplina.html', data)

@login_required
def gestion_portada_disciplina(request):

    data = {
    }

    if request.method == 'POST':


        if 'imagen' in request.FILES:
            imagen_file = request.FILES['imagen']
            imagen = imagen_file.read()
        else:
            messages.error(request, "Debes subir una imagen para publicar en la galería general.")
            return redirect('portada_disciplina')
        

        etiqueta = request.POST.get('etiqueta')
        if not etiqueta:
            messages.error(request, "Debes ingresar una etiqueta para publicar en la galería general.")
            return redirect('portada_disciplina')

        # Guardar la imagen en la galeria general de la base de datos
        salida = guardar_galeria_general(imagen, etiqueta)

        if salida == 1:
            messages.success(request, "Imagen registrada correctamente en galeria general.")            
        else:
            messages.error(request, "No se ha podido registrar la imagen. ERROR.")            
        return redirect('portada_disciplina')




    return render(request, 'intranet/administrador/gestion_portada_disciplina.html', data)

###################

@login_required
def gestion_eventos(request):
    if request.method == 'POST':
        try:
            # Obtener y loggear todos los datos del POST
            print("POST data:", request.POST)
            
            event_scope = request.POST.get('eventScope')
            events_type = request.POST.get('events_type')
            events_name = request.POST.get('events_name')
            events_description = request.POST.get('events_description')
            events_recurring = request.POST.get('events_recurring')
            
            # Manejar discipline_id
            discipline_id = None
            if event_scope == 'especifica':
                discipline_id = request.POST.get('discipline_id')
                print(f"Disciplina seleccionada: {discipline_id}")
                if discipline_id:
                    try:
                        discipline_id = int(discipline_id)
                    except ValueError:
                        raise ValueError("ID de disciplina inválido")
                else:
                    raise ValueError("Se requiere seleccionar una disciplina")
            # Procesar fechas
            if events_recurring == '0':  # Si es evento único
                events_start = request.POST.get('events_start')
                events_end = request.POST.get('events_end')
                start_date = datetime.strptime(events_start, '%Y-%m-%dT%H:%M')
                end_date = datetime.strptime(events_end, '%Y-%m-%dT%H:%M')
            else:
                start_date = datetime.now()
                end_date = datetime.now()

            print("Valores a enviar al SP:", {
                "events_name": events_name,
                "events_type": events_type,
                "events_status": 'activo',
                "start_date": start_date,
                "end_date": end_date,
                "events_description": events_description,
                "events_recurring": events_recurring,
                "discipline_id": discipline_id
            })

            # Llamada al procedimiento almacenado
            with connection.cursor() as cursor:
                cursor.callproc("SP_INSERT_EVENT", [
                    events_name,
                    events_type,
                    'activo',
                    start_date,
                    end_date,
                    events_description,
                    int(events_recurring),
                    discipline_id  # Asegurarse que sea None o un entero válido
                ])
            
            messages.success(request, 'Evento creado exitosamente')
            
        except ValueError as ve:
            messages.error(request, f'Error de validación: {str(ve)}')
            print(f"Error de validación: {str(ve)}")
        except Exception as e:
            messages.error(request, f'Error al crear el evento: {str(e)}')
            print(f"Error general: {str(e)}")
    
    # Preparar datos para el template
    try:
        data = {
            'disciplinas': listado_disciplinas(),
            'eventos': listado_eventos()
        }
    except Exception as e:
        print(f"Error al preparar datos: {str(e)}")
        data = {
            'disciplinas': [],
            'eventos': []
        }
        messages.error(request, 'Error al cargar los datos')

    return render(request, 'intranet/administrador/gestion_eventos.html', data)

@login_required
def gestion_Jugador_elite(request):

    jugador_elite = listado_jugar_elite()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(jugador_elite, 9)
        jugador_elite = paginator.page(page)
    except:
        raise Http404            


    data = {
    'entity':jugador_elite,
    'paginator': paginator
    }   

    if request.method == 'POST':
        # Obtener los datos del formulario
        if 'crear_jugador_elite' in request.POST:

            imagen = request.FILES.get('imagen').read()
            if not imagen:
                data['mensaje_error'] = ["Debes subir una imagen para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            rut = request.POST.get('rut')
            if not rut:
                data['mensaje_error'] = ["Debes ingresar un Rut para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            nombre = request.POST.get('nombre')
            if not nombre:
                data['mensaje_error'] = ["Debes ingresar un Nombre para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            apellido = request.POST.get('apellido')
            if not apellido:
                data['mensaje_error'] = ["Debes ingresar un Apellido para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            disciplina = request.POST.get('disciplina')
            if not disciplina:
                data['mensaje_error'] = ["Debes ingresar una disciplina para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            fecha_nacimiento = request.POST.get('fecha_nacimiento')
            if not fecha_nacimiento:
                data['mensaje_error'] = ["Debes ingresar una fwcha de nacimiento para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            discipline_id = request.POST.get('disciplina_id')
            if not discipline_id:
                data['mensaje_error'] = ["Debes ingresar una Disciplina para registrar un jugador."]
                return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)

            # Guardar el jugador en la base de datos
            salida = guardar_jugador_elite(rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id)

            if salida == 1:
                data['mensaje_exito'] = ["Creación de Jugador enviada correctamente."]
                jugador_elite = listado_jugar_elite()

                data = {
                'entity':jugador_elite,
                'paginator': paginator
                }  
            elif salida == -1:
                data['mensaje_error'] = ["Rut ya registrado. Cambie el rut o contacto con el administrador."] 
                print("Rut ya registrado. Cambie el rut o contacto con el administrador.")            
            else:
                data['mensaje_error'] = ["No se ha podido registrar. ERROR."]
                print("No se ha podido registrar. ERROR.")
        
        
        elif 'form_editar' in request.POST:
            id_jugador_elite = request.POST.get('id')
            if id_jugador_elite:
                jugador_elite = get_object_or_404(PlayerElite, player_elite_id = id_jugador_elite)
                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    imagen = imagen_file.read()
                else:
                    imagen = jugador_elite.player_img

                rut = request.POST.get('rut')
                nombre = request.POST.get('nombre')
                apellido = request.POST.get('apellido')
                disciplina = request.POST.get('disciplina')
                fecha_nacimiento = request.POST.get('fecha')
                discipline_id = request.POST.get('id_disciplina')
                
                print(f"id_jugador_elite: {id_jugador_elite} \n  rut: {rut} \n nombre: {nombre} \n apellido: {apellido} \n disciplina: {disciplina} \n fecha_nacimiento: {fecha_nacimiento} \n discipline_id: {discipline_id} \n ")
                print(id_jugador_elite)

                print(discipline_id)
                # fecha_galeria = datetime.strptime(fecha_galeria, '%Y-%m-%dT%H:%M').strftime('%Y-%m-%d %H:%M:%S')
        
                salida = editar_jugador_elite(id_jugador_elite, rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id)

                if salida == 1:
                    messages.success(request, "Imagen actualizada correctamente.")
                    print("Imagen actualizada correctamente.")
                else:
                    messages.error(request, "No se ha podido actualizar la imagen. ERROR.")
                    print("Imagen actualizada correctamente.")

                return redirect('gestion_Jugador_elite')


        elif 'form_eliminar' in request.POST:
            id_jugador_elite = request.POST.get('id')
            salida = eliminar_jugador_elite(id_jugador_elite)

            if salida == 1:
                messages.success(request, "El jugador de elite fue eliminado correctamente.")
            else:
                messages.error(request, "No se ha podido eliminar al jugador. ERROR.")
            return redirect('gestion_Jugador_elite')  
        


    return render (request, 'intranet/administrador/gestion_Jugador_elite.html', data)


def listado_eventos_entrenador(coach_id):
    try:
        django_cursor = connection.cursor()
        cursor = django_cursor.connection.cursor()
        out_cur = django_cursor.connection.cursor()

        # Convertimos el coach_id a string si es necesario
        coach_id_str = str(coach_id)
        
        cursor.callproc("SP_LIST_EVENTS_FOR_COACH", [out_cur, coach_id_str])

        lista = []
        for fila in out_cur:
            data = {
                'events_id': fila[0],
                'events_name': fila[1],
                'events_type': fila[2],
                'events_description': fila[3],
                'events_start': fila[4],
                'events_end': fila[5],
                'discipline_id': fila[6],
                'discipline_name': fila[7] if fila[7] else 'Todas las disciplinas'
            }
            lista.append(data)

        return lista
    except Exception as e:
        print(f"Error en listado_eventos_entrenador: {str(e)}")
        return []
    finally:
        if 'out_cur' in locals():
            out_cur.close()
        if 'cursor' in locals():
            cursor.close()
        if 'django_cursor' in locals():
            django_cursor.close()


def listado_entrenamientos_por_entrenador(id_entrenador):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_TRAININGS_FOR_COACH", [out_cur, id_entrenador])
    
    lista = []
    for fila in out_cur:
        lista.append(fila)
    return lista


def gestionar_periodos(request):
    disciplinas = listado_disciplinas()
    
    if request.method == 'POST':
        if 'form-period' in request.POST:
            try:
                
                # Obtener los datos del formulario
                period_name = request.POST.get('period_name')
                start_date = request.POST.get('start_date')
                end_date = request.POST.get('end_date')
                semester = request.POST.get('semester')
                is_active = 1 if request.POST.get('is_active') == 'on' else 0

                # Validar que los campos requeridos no estén vacíos
                if not all([period_name, start_date, end_date, semester]):
                    messages.error(request, 'Por favor complete todos los campos requeridos.')
                    return redirect('gestionar_periodos')

                # Convertir las fechas a objetos datetime
                try:
                    start_date_obj = datetime.strptime(start_date, '%Y-%m-%d')
                    end_date_obj = datetime.strptime(end_date, '%Y-%m-%d')
                except ValueError:
                    messages.error(request, 'Formato de fecha inválido')
                    return redirect('gestionar_periodos')

                # Ejecutar el procedimiento almacenado
                with connection.cursor() as cursor:
                    # Crear variable de salida para el resultado
                    output_value = cursor.var(oracledb.NUMBER)
                    
                    # Ejecutar el procedimiento almacenado
                    cursor.execute("""
                        BEGIN
                            sp_insert_academic_period(
                                :period_name, 
                                :start_date,
                                :end_date,
                                :semester,
                                :is_active,
                                :result
                            );
                        END;
                    """, {
                        'period_name': period_name,
                        'start_date': start_date_obj,
                        'end_date': end_date_obj,
                        'semester': int(semester),
                        'is_active': is_active,
                        'result': output_value
                    })

                    # Obtener el resultado
                    result = output_value.getvalue()

                    if result == 1:
                        messages.success(request, 'Periodo académico creado exitosamente.')
                    elif result == 0:
                        messages.error(request, 'Error: La fecha de inicio debe ser anterior a la fecha de fin.')
                    else:
                        messages.error(request, 'Error al crear el periodo académico.')

            except oracledb.Error as e:
                error, = e.args
                messages.error(request, f'Error de Oracle: {str(error)}')
            except Exception as e:
                messages.error(request, f'Error al crear el periodo: {str(e)}')
            if result == 1:
                    messages.success(request, "Periodo creado correctamente.")
            else:
                    messages.error(request, "No se ha podido crear la Periodo. ERROR.")
            return redirect('gestionar_periodos')


        elif 'form-training' in request.POST:
            try:
                # Obtener los datos del formulario
                training_name = request.POST.get('training_name')
                discipline_id = request.POST.get('discipline_id')
                period_id = request.POST.get('period_id')
                weekdays = ','.join(request.POST.getlist('weekdays'))  # Convierte la lista de días en string
                
                # Convertir las horas a timestamp
                start_time = request.POST.get('start_time')
                end_time = request.POST.get('end_time')
                
                # Convertir a datetime
                start_timestamp = datetime.strptime(start_time, '%H:%M')
                end_timestamp = datetime.strptime(end_time, '%H:%M')
                
                is_active = request.POST.get('is_active')

                # Validar que los campos requeridos no estén vacíos
                if not all([training_name, discipline_id, period_id, weekdays, start_time, end_time]):
                    messages.error(request, 'Por favor complete todos los campos requeridos.')
                    return redirect('submit_training')

                with connection.cursor() as cursor:
                    # Variable de salida para el resultado
                    output_value = cursor.var(oracledb.NUMBER)
                    
                    # Ejecutar el procedimiento almacenado
                    cursor.execute("""
                        BEGIN
                            sp_insert_training(
                                :training_name,
                                :discipline_id,
                                :period_id,
                                :weekdays,
                                :start_time,
                                :end_time,
                                :is_active,
                                :result
                            );
                        END;
                    """, {
                        'training_name': training_name,
                        'discipline_id': int(discipline_id),
                        'period_id': int(period_id),
                        'weekdays': weekdays,
                        'start_time': start_timestamp,
                        'end_time': end_timestamp,
                        'is_active': int(is_active),
                        'result': output_value
                    })

                    # Obtener el resultado
                    result = output_value.getvalue()
                    
                    if result == 1:
                        messages.success(request, 'Entrenamiento creado exitosamente.')
                    elif result == -1:
                        messages.error(request, 'La hora de inicio debe ser anterior a la hora de fin.')
                    elif result == -2:
                        messages.error(request, 'La disciplina seleccionada no existe.')
                    elif result == -3:
                        messages.error(request, 'El período seleccionado no existe.')
                    else:
                        messages.error(request, 'Error al crear el entrenamiento.')

            except oracledb.Error as e:
                error, = e.args
                messages.error(request, f'Error de Oracle: {str(error)}')
            except Exception as e:
                messages.error(request, f'Error al crear el entrenamiento: {str(e)}')
        if result == 1:
                    messages.success(request, "Entrenamiento actualizado correctamente.")
        else:
            messages.error(request, "No se ha podido actualizar el entrenamiento. ERROR.")
        return redirect('gestionar_periodos')

    # Para mostrar los periodos existentes
    periodos = []
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT period_id, period_name, 
                TO_CHAR(start_date, 'YYYY-MM-DD') as start_date, 
                TO_CHAR(end_date, 'YYYY-MM-DD') as end_date, 
                semester, is_active, 
                TO_CHAR(creation_timestamp, 'YYYY-MM-DD HH24:MI:SS') as creation_timestamp
                FROM Academic_Period
                ORDER BY creation_timestamp DESC
            """)
            columns = [col[0] for col in cursor.description]
            periodos = [dict(zip(columns, row)) for row in cursor.fetchall()]
    
            
    except Exception as e:
        messages.error(request, f'Error al obtener los periodos: {str(e)}')
    # Para mostrar los entrenamientos existentes
    # Para mostrar los entrenamientos existentes
    entrenamientos = []
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT t.training_name,
                    CASE 
                        WHEN t.weekdays LIKE '%1%' THEN 'Lunes '
                        ELSE ''
                    END ||
                    CASE 
                        WHEN t.weekdays LIKE '%2%' THEN 'Martes '
                        ELSE ''
                    END ||
                    CASE 
                        WHEN t.weekdays LIKE '%3%' THEN 'Miércoles '
                        ELSE ''
                    END ||
                    CASE 
                        WHEN t.weekdays LIKE '%4%' THEN 'Jueves '
                        ELSE ''
                    END ||
                    CASE 
                        WHEN t.weekdays LIKE '%5%' THEN 'Viernes '
                        ELSE ''
                    END ||
                    CASE 
                        WHEN t.weekdays LIKE '%6%' THEN 'Sábado '
                        ELSE ''
                    END ||
                    CASE 
                        WHEN t.weekdays LIKE '%7%' THEN 'Domingo'
                        ELSE ''
                    END as dias,
                    TO_CHAR(t.start_time, 'HH24:MI') as start_time,
                    TO_CHAR(t.end_time, 'HH24:MI') as end_time,
                    d.discipline_name,
                    p.period_name,
                    t.is_active
                FROM Training t
                JOIN Discipline d ON t.discipline_id = d.discipline_id
                JOIN Academic_Period p ON t.period_id = p.period_id
                ORDER BY t.creation_timestamp DESC
            """)
            columns = [col[0] for col in cursor.description]
            entrenamientos = [dict(zip(columns, row)) for row in cursor.fetchall()]
            
            
    except Exception as e:
        messages.error(request, f'Error al obtener los entrenamientos: {str(e)}')

    data = {
            'disciplinas': disciplinas,
            'periodos': periodos,
            'entrenamientos': entrenamientos
        }
    return render(request, 'intranet/administrador/gestionar_periodos.html', data)


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


def editar_disciplinas(discipline_id, img_disciplina ,nombre_disciplina, descripcion_disciplina):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_EDIT_DISCIPLINE', [
        
        discipline_id, 
        img_disciplina,
        nombre_disciplina, 
        descripcion_disciplina,
        
        salida
    ])

    return salida.getvalue()


def confirmacion_disciplina(id_disciplina):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    v_count_player = cursor.var(oracledb.NUMBER)
    v_count_player_elite = cursor.var(oracledb.NUMBER)
    v_count_galery_discipline = cursor.var(oracledb.NUMBER)
    v_count_attendance = cursor.var(oracledb.NUMBER)
    v_count_events = cursor.var(oracledb.NUMBER)
    v_count_coach_discipline = cursor.var(oracledb.NUMBER)


    cursor.callproc('SP_LIST_CASCADE_DISCIPLINE', [
        id_disciplina,

        v_count_player,
        v_count_player_elite,
        v_count_galery_discipline,
        v_count_attendance,
        v_count_events,
        v_count_coach_discipline
    ])

    lista= []
    lista.append(v_count_player.getvalue(),
    v_count_player_elite.getvalue(),
    v_count_galery_discipline.getvalue(),
    v_count_attendance.getvalue(),
    v_count_events.getvalue(),
    v_count_coach_discipline.getvalue()
    ) 

    return lista


def eliminar_disciplina(id_disciplina):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_DELETE_DISCIPLINE', [
        id_disciplina,
        salida
    ])

    return salida.getvalue()


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


def guardar_jugador(rut, nombre, apellido, headquarters, career, horario, fecha_nacimiento, imagen, discipline_id, entrenador_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_PLAYER', [   rut, nombre, apellido, headquarters, career, horario, fecha_nacimiento, imagen, discipline_id, entrenador_id, salida])

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

    cursor.callproc("SP_LIST_IMAGES_GENERAL_INDEX", [out_cur])

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

##############  NOTICIAS ##############

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


def listado_noticias_por_tiempo():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_NEWS_FOR_TIME", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[5].read()), 'utf-8'),        
        }

        lista.append(data)

    return lista


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


def listado_noticias_index():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_NEWS_INDEX", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[5].read()), 'utf-8'),        
        }

        lista.append(data)
    return lista


##############################################


##############  GALERIA_GENERAL ##############
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


def editar_galeria_general(id_galeria, img_galeria ,nombre_galeria, fecha_galeria):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_EDIT_GALERY_GENERAL', [
        id_galeria, 
        img_galeria, 
        nombre_galeria,
        fecha_galeria,

        salida
    ])

    return salida.getvalue()


def eliminar_galeria_general(id_galeria_general):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_DELETE_GALERY_GENERAL', [
        id_galeria_general,
        salida
    ])

    return salida.getvalue()


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
#############################################

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


def listado_eventos():
    try:
        django_cursor = connection.cursor()
        cursor = django_cursor.connection.cursor()
        out_cur = django_cursor.connection.cursor()

        cursor.callproc("SP_LIST_EVENTS", [out_cur])

        lista = []
        for fila in out_cur:
            # Convertir los valores de recurring a string para comparación
            recurring = str(fila[7]) if fila[7] is not None else '0'
            
            data = {
                'events_id': fila[0],
                'events_name': fila[1],
                'events_type': fila[2],
                'events_status': fila[3],
                'events_start': fila[4],
                'events_end': fila[5],
                'events_description': fila[6],
                'events_recurring': recurring,  # Aseguramos que sea string
                'discipline_name': fila[8] if fila[8] is not None else 'Todas las disciplinas'
            }
            lista.append(data)
    
        return lista
    except Exception as e:
        print(f"Error en listado_eventos: {str(e)}")
        return []
    finally:
        if 'out_cur' in locals():
            out_cur.close()
        if 'cursor' in locals():
            cursor.close()
        if 'django_cursor' in locals():
            django_cursor.close()

##############  JUGADOR_ELITE ##############

def guardar_jugador_elite(rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_ELITE_PLAYER', [ rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id, salida])

    return salida.getvalue()


def listado_jugar_elite():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_PLAYER_ELITE", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[5].read()), 'utf-8'),    
            
        }

        lista.append(data)

    return lista


def eliminar_jugador_elite(id_jugador_elite):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_DELETE_PLAYER_ELITE', [
        id_jugador_elite,
        salida
    ])

    return salida.getvalue()


def editar_jugador_elite(id_jugador_elite, rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_EDIT_ELITE_PLAYER', [ id_jugador_elite, rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id, salida ])

    return salida.getvalue()
#############################################


