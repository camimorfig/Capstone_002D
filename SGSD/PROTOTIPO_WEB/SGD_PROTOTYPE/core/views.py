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
from itertools import cycle



def validar_rut(rut):
    rut = rut.upper().replace("-", "").replace(".", "")
    rut_aux = rut[:-1]
    dv = rut[-1:]

    if not rut_aux.isdigit() or not (1_000_000 <= int(rut_aux) <= 25_000_000):
        print('no es rut')
        return False

    revertido = map(int, reversed(rut_aux))
    factors = cycle(range(2, 8))
    suma = sum(d * f for d, f in zip(revertido, factors))
    residuo = suma % 11

    if dv == 'K':
        return residuo == 1
        print(residuo)

    if dv == '0':
        return residuo == 11
        print(residuo)
    print(residuo)
    return residuo == 11 - int(dv)


###########  views de Templates  ###########
def index(request):
    

    data = {
        
        'noticias_index': listado_noticias_index(), 
        'galeria_index':listado_galeria_portada(),
        'portada':listado_portadas()
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
    'paginator': paginator,
    'portada':listado_portadas()

    }   


    return render (request, 'core/galeria.html', data)


def nosotros(request):
    data = {
        'entrenadores':listado_entrenadores(),
        'portada':listado_portadas()
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
        'paginator': paginator,
        'portada':listado_portadas()

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
        'disciplinas':listado_disciplinas(),
        'portada':listado_portadas()
        }  

    return render (request, 'core/selecciones.html', data)


def talento(request):
    
    data = {
        'jugador_elite' : listado_jugar_elite(),
        'portada':listado_portadas()
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

    if request.method == 'POST':

        if 'form_eliminar' in request.POST:
            id_jugador = request.POST.get('id')
            salida = eliminar_jugador(id_jugador)
            if salida == 1:
                messages.success(request, "Jugador eliminado correctamente.")
            else:
                messages.error(request, "No se ha podido eliminar al Jugador. ERROR.")
            return redirect('perfil_jugadores')


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
            messages.error(request, "Debes subir una imagen para registrar un jugador.")
            return redirect('crear_perfil_Jugador')

        rut = request.POST.get('rut')
        if not rut:
            messages.error(request, "Debes ingresar un Rut para registrar un jugadorentrenador.")
            return redirect('crear_perfil_Jugador')
        elif not validar_rut(rut):
            messages.error(request, "Debes ingresar un Rut valido para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
        else:
            rut = rut.replace(".", "")
        nombre = request.POST.get('nombre')
        if not nombre:
            messages.error(request, "Debes ingresar un Nombre para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
        else:
            nombre = nombre.upper()

        apellido = request.POST.get('apellido')
        if not apellido:
            messages.error(request, "Debes ingresar un Apellido para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
        else:
            apellido = apellido.upper()


        headquarters = request.POST.get('headquarters')
        if not headquarters:
            messages.error(request, "Debes ingresar una Sede para registrar un jugador.")
            return redirect('crear_perfil_Jugador')

        career = request.POST.get('career')
        if not career:
            messages.error(request, "Debes ingresar una Carrera para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
            

        horario = request.POST.get('horario')
        if not horario:
            messages.error(request, "Debes Seleccionar un horario para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
            
        fecha_nacimiento = request.POST.get('fecha_nacimiento')
        if not fecha_nacimiento:
            messages.error(request, "Debes ingresar una fecha de nacimiento para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
            

        discipline_id = request.POST.get('disciplina')
        if not discipline_id:
            messages.error(request, "Debes ingresar una Disciplina para registrar un jugador.")
            return redirect('crear_perfil_Jugador')
            

        # Guardar el jugador en la base de datos
        salida = guardar_jugador(rut, nombre, apellido, headquarters, career, horario, fecha_nacimiento, imagen, discipline_id, entrenador_id)

        if salida == 1:
            messages.success(request, "Solicitud de Creación de Jugador enviada correctamente.")
            return redirect('crear_perfil_Jugador')
        elif salida == -1:
            messages.error(request, "Rut ya registrado. Cambie el rut o contacto con el administrador.")
            return redirect('crear_perfil_Jugador')
        else:
            messages.error(request, "No se ha podido registrar. ERROR.")
            return redirect('crear_perfil_Jugador')

    return render (request, 'intranet/entrenador/crear_perfil_Jugador.html', data)

@login_required
def asistencia_entrenador(request):
    if not hasattr(request.user, 'coach'):
        return HttpResponseForbidden("El usuario no está asociado a ningún entrenador.")

    entrenador = request.user.coach.first()  

    if not entrenador:
        return HttpResponseForbidden("No hay entrenadores asociados a este usuario.")

    entrenador_id = entrenador.coach_id
    entrenamientos = listado_entrenamientos_por_entrenador(entrenador_id)
    
    data = {
        'entrenamientos': entrenamientos,
        'nombre_entrenador': entrenador.name if hasattr(entrenador, 'name') else 'Entrenador'
    }
    return render(request, 'intranet/entrenador/asistencia_entrenador.html', data)

@login_required
def jugadores_por_disciplina(request):
    
    disciplina = request.GET.get('disciplina') 
    data = { 
        'jugadores':listado_jugador_por_disciplinas(disciplina),


    }

    return render (request, 'intranet/entrenador/obtener_datos_entrenador.html', data)


from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from django.db.models import Count, Avg, Q, Case, When, FloatField

from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from django.db.models import Count, Avg, Q, Case, When, FloatField
from .models import Attendance, AttendanceStatus, Discipline
from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from django.http import HttpResponse

from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from django.db.models import Count, Avg, Q, Case, When, FloatField
from django.utils import timezone
from datetime import datetime
from .models import Attendance, AttendanceStatus, Discipline, Coach, CoachDiscipline


@login_required
def grafico(request):
    try:
        # Obtener el coach asociado al usuario actual
        coach = Coach.objects.get(user=request.user)
        
        # Obtener las disciplinas asociadas al coach
        disciplinas_entrenador = Discipline.objects.filter(
            discipline_id__in=CoachDiscipline.objects.filter(coach_id=coach.coach_id).values_list('discipline_id', flat=True)
        )

    except Coach.DoesNotExist:
        disciplinas_entrenador = Discipline.objects.none()

    # Obtener parámetros de filtro
    discipline_id = request.GET.get('discipline_id')
    date_from = request.GET.get('date_from')
    date_to = request.GET.get('date_to')

    # Aplicar filtros a las consultas
    asistencias = Attendance.objects.filter(discipline__in=disciplinas_entrenador)
    if discipline_id:
        asistencias = asistencias.filter(discipline_id=discipline_id)
    if date_from:
        asistencias = asistencias.filter(attendance_date__gte=date_from)
    if date_to:
        asistencias = asistencias.filter(attendance_date__lte=date_to)
    # Obtener los estados de asistencia
    status_present = AttendanceStatus.objects.filter(status_name__icontains='present').first()
    status_absent = AttendanceStatus.objects.filter(status_name__icontains='absent').first()
    status_justified = AttendanceStatus.objects.filter(status_name__icontains='justified').first()

    # Estadísticas generales por disciplina
    estadisticas_disciplina = []
    for disciplina in disciplinas_entrenador:
        asistencias_disc = asistencias.filter(discipline=disciplina)
        total_disc = asistencias_disc.count()
        if total_disc > 0:
            presentes_disc = asistencias_disc.filter(status=status_present).count()
            ausentes_disc = asistencias_disc.filter(status=status_absent).count()
            justificados_disc = asistencias_disc.filter(status=status_justified).count()
            
            # Calcular regularidad de asistencia por estudiante
            estudiantes_stats = asistencias_disc.values('player').annotate(
                total_clases=Count('attendance_id'),
                asistencias=Count('attendance_id', filter=Q(status=status_present))
            )
            
            # Calcular promedios
            promedio_asistencia = round(presentes_disc / total_disc * 100, 2)
            
            estadisticas_disciplina.append({
                'nombre': disciplina.discipline_name,
                'total_estudiantes': asistencias_disc.values('player').distinct().count(),
                'promedio_asistencia': promedio_asistencia,
                'presentes': presentes_disc,
                'ausentes': ausentes_disc,
                'justificados': justificados_disc,
                'total_entrenamientos': asistencias_disc.values('attendance_date').distinct().count(),
                'mejor_asistencia': round(max((stat['asistencias'] / stat['total_clases'] * 100) 
                                        for stat in estudiantes_stats) if estudiantes_stats else 0, 2),
                'peor_asistencia': round(min((stat['asistencias'] / stat['total_clases'] * 100) 
                                        for stat in estudiantes_stats) if estudiantes_stats else 0, 2)
            })

    # Datos para el gráfico de tendencia mensual
    tendencia_data = asistencias.values('attendance_date').annotate(
        porcentaje=Avg(Case(
            When(status=status_present, then=100),
            When(status=status_justified, then=50),
            default=0,
            output_field=FloatField(),
        ))
    ).order_by('attendance_date')

    labels = [d['attendance_date'].strftime('%b %Y') for d in tendencia_data]
    datos = [round(d['porcentaje'], 2) for d in tendencia_data]

    context = {
        'nombre_entrenador': coach.coach_name,
        'disciplines': disciplinas_entrenador,
        'estadisticas_disciplina': estadisticas_disciplina,
        'estadisticas_tendencia': {
            'labels': labels,
            'datos': datos
        }
    }
    
    return render(request, 'intranet/entrenador/grafico.html', context)


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
            successful_registrations = 0
            failed_registrations = 0
            
            for jugador in jugadores:
                player_id = jugador['id']
                estado = request.POST.get(f'estado_{player_id}')
                
                if not estado:
                    print(f"No se encontró estado para jugador {player_id}")
                    continue
                    
                comentario = request.POST.get(f'comentario_{player_id}', '').strip() or None
                
                print(f"Procesando asistencia:")
                print(f"- Jugador ID: {player_id}")
                print(f"- Estado: {estado}")
                print(f"- Comentario: {comentario}")
                
                try:
                    with connection.cursor() as cursor:
                        # Verificar si ya existe asistencia
                        cursor.execute("""
                            SELECT COUNT(*)
                            FROM attendance
                            WHERE player_id = :player_id
                            AND training_id = :training_id
                            AND TRUNC(attendance_date) = TRUNC(SYSDATE)
                        """, {
                            'player_id': player_id,
                            'training_id': training_id
                        })
                        
                        if cursor.fetchone()[0] > 0:
                            print(f"Ya existe asistencia para jugador {player_id}")
                            continue

                        # Obtener status_id
                        cursor.execute("""
                            SELECT status_id
                            FROM attendance_status
                            WHERE status_name = :status
                        """, {'status': estado})
                        
                        status_row = cursor.fetchone()
                        if not status_row:
                            print(f"Estado no válido: {estado}")
                            continue
                        
                        status_id = status_row[0]

                        # Insertar asistencia
                        cursor.execute("""
                            INSERT INTO attendance (
                                player_id,
                                training_id,
                                discipline_id,
                                status_id,
                                attendance_date,
                                attendance_comments,
                                creation_timestamp
                            ) VALUES (
                                :player_id,
                                :training_id,
                                :discipline_id,
                                :status_id,
                                TRUNC(SYSDATE),
                                :comments,
                                SYSTIMESTAMP
                            )
                        """, {
                            'player_id': player_id,
                            'training_id': training_id,
                            'discipline_id': discipline_id,
                            'status_id': status_id,
                            'comments': comentario
                        })
                        
                        successful_registrations += 1
                        print(f"Asistencia registrada exitosamente para jugador {player_id}")
                        
                except Exception as e:
                    print(f"Error al registrar asistencia para jugador {player_id}: {str(e)}")
                    failed_registrations += 1

            if successful_registrations > 0:
                messages.success(request, f'Se registró la asistencia de {successful_registrations} jugador(es)')
            if failed_registrations > 0:
                messages.warning(request, f'No se pudo registrar la asistencia de {failed_registrations} jugador(es)')
            
            connection.commit()  # Asegurar que los cambios se guarden
            return redirect('asistencia_entrenador')
        
        context = {
            'jugadores': jugadores,
            'disciplina_id': discipline_id,
            'training_id': training_id,
            'fecha_actual': datetime.now().strftime('%Y-%m-%d')
        }
        
        return render(request, 'intranet/entrenador/tomar_asistencia.html', context)
                
    except Exception as e:
        print(f"Error en tomar_asistencia: {str(e)}")
        print(f"Tipo de error: {type(e)}")
        import traceback
        traceback.print_exc()
        messages.error(request, f'Error al procesar la asistencia: {str(e)}')
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

from django.views.generic import TemplateView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.shortcuts import redirect
from django.http import HttpResponseForbidden, HttpResponse
from django.db.models import Count, Avg, Max, Min, Case, When, FloatField, F, Q
import pandas as pd
from datetime import datetime
from django.contrib import messages
from .models import Attendance, Discipline, Player, AttendanceStatus

class AdminDashboardView(LoginRequiredMixin, TemplateView):
    template_name = 'intranet/administrador/administrador.html'

    def dispatch(self, request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('login')  

        if not hasattr(request.user, 'user_type') or request.user.user_type != 'admin01':
            return HttpResponseForbidden("No tienes permiso para acceder a esta página.")

        return super().dispatch(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # Obtener parámetros de filtro
        discipline_id = self.request.GET.get('discipline_id')
        date_from = self.request.GET.get('date_from')
        date_to = self.request.GET.get('date_to')

        # Aplicar filtros a las consultas
        asistencias = Attendance.objects.all()
        if discipline_id:
            asistencias = asistencias.filter(discipline_id=discipline_id)
        if date_from:
            asistencias = asistencias.filter(attendance_date__gte=date_from)
        if date_to:
            asistencias = asistencias.filter(attendance_date__lte=date_to)

        # Obtener los estados de asistencia
        status_present = AttendanceStatus.objects.filter(status_name__icontains='present').first()
        status_absent = AttendanceStatus.objects.filter(status_name__icontains='absent').first()
        status_justified = AttendanceStatus.objects.filter(status_name__icontains='justified').first()

        # Calcular estadísticas generales
        total_estudiantes = asistencias.values('player').distinct().count()
        total_presentes = asistencias.filter(status=status_present).count()
        total_ausentes = asistencias.filter(status=status_absent).count()
        total_justificados = asistencias.filter(status=status_justified).count()
        total_registros = asistencias.count()

        # Calcular porcentajes
        porcentaje_presentes = (total_presentes / total_registros * 100) if total_registros > 0 else 0
        porcentaje_ausentes = (total_ausentes / total_registros * 100) if total_registros > 0 else 0
        porcentaje_justificados = (total_justificados / total_registros * 100) if total_registros > 0 else 0

        # Calcular regularidad por estudiante
        estudiantes_stats = asistencias.values('player').annotate(
            total_clases=Count('attendance_id'),
            asistencias=Count('attendance_id', 
                            filter=Q(status=status_present))
        )

        asistencia_alta = sum(1 for stat in estudiantes_stats if (stat['asistencias'] / stat['total_clases'] * 100) > 75)
        asistencia_media = sum(1 for stat in estudiantes_stats if 50 <= (stat['asistencias'] / stat['total_clases'] * 100) <= 75)
        asistencia_baja = sum(1 for stat in estudiantes_stats if (stat['asistencias'] / stat['total_clases'] * 100) < 50)

        # Estadísticas por disciplina
        estadisticas_disciplina = []
        for disciplina in Discipline.objects.all():
            asistencias_disciplina = asistencias.filter(discipline=disciplina)
            total_disc = asistencias_disciplina.count()
            if total_disc > 0:
                presentes_disc = asistencias_disciplina.filter(status=status_present).count()
                estadisticas_disciplina.append({
                    'nombre': disciplina.discipline_name,
                    'total_estudiantes': asistencias_disciplina.values('player').distinct().count(),
                    'promedio_asistencia': round(presentes_disc / total_disc * 100, 2),
                    'presentes': presentes_disc,
                    'ausentes': asistencias_disciplina.filter(status=status_absent).count(),
                    'justificados': asistencias_disciplina.filter(status=status_justified).count(),
                    'regularidad': round(presentes_disc / total_disc * 100, 2)
                })

        # Datos para el gráfico de tendencia
        tendencia_data = asistencias.values('attendance_date') \
            .annotate(porcentaje=Avg(Case(
                When(status=status_present, then=100),
                When(status=status_justified, then=50),
                default=0,
                output_field=FloatField(),
            ))).order_by('attendance_date')

        labels = [d['attendance_date'].strftime('%b %Y') for d in tendencia_data]
        datos = [round(d['porcentaje'], 2) for d in tendencia_data]

        context.update({
            'disciplines': Discipline.objects.all(),
            'estadisticas': {
                'total_estudiantes': total_estudiantes,
                'total_presentes': total_presentes,
                'total_ausentes': total_ausentes,
                'total_justificados': total_justificados,
                'porcentaje_presentes': round(porcentaje_presentes, 2),
                'porcentaje_ausentes': round(porcentaje_ausentes, 2),
                'porcentaje_justificados': round(porcentaje_justificados, 2),
                'asistencia_alta': asistencia_alta,
                'asistencia_media': asistencia_media,
                'asistencia_baja': asistencia_baja,
                'total_entrenamientos': asistencias.values('attendance_date').distinct().count(),
                'promedio_asistencia': round(porcentaje_presentes, 2),
                'mejor_asistencia': round(max((stat['asistencias'] / stat['total_clases'] * 100) for stat in estudiantes_stats) if estudiantes_stats else 0, 2),
                'peor_asistencia': round(min((stat['asistencias'] / stat['total_clases'] * 100) for stat in estudiantes_stats) if estudiantes_stats else 0, 2)
            },
            'estadisticas_disciplina': estadisticas_disciplina,
            'estadisticas_tendencia': {
                'labels': labels,
                'datos': datos
            }
        })

        return context

    def get(self, request, *args, **kwargs):
        if request.GET.get('descargar'):
            return self.exportar_excel(request)
        return super().get(request, *args, **kwargs)

    def exportar_excel(self, request):
        try:
            # Obtener parámetros de filtro
            discipline_id = request.GET.get('discipline_id')
            date_from = request.GET.get('date_from')
            date_to = request.GET.get('date_to')

            # Aplicar filtros
            asistencias = Attendance.objects.all()
            if discipline_id:
                asistencias = asistencias.filter(discipline_id=discipline_id)
            if date_from:
                asistencias = asistencias.filter(attendance_date__gte=date_from)
            if date_to:
                asistencias = asistencias.filter(attendance_date__lte=date_to)

            # Crear DataFrame
            data = []
            for asistencia in asistencias:
                data.append({
                    'Fecha': asistencia.attendance_date,
                    'RUT': asistencia.player.player_rut,
                    'Estudiante': f"{asistencia.player.player_name} {asistencia.player.player_last_name}",
                    'Disciplina': asistencia.discipline.discipline_name,
                    'Estado': asistencia.status.status_name,
                    'Comentarios': asistencia.attendance_comments or ''
                })

            df = pd.DataFrame(data)

            # Crear respuesta Excel
            response = HttpResponse(content_type='application/vnd.ms-excel')
            response['Content-Disposition'] = f'attachment; filename=asistencias_{datetime.now().strftime("%Y%m%d")}.xlsx'
            
            df.to_excel(response, index=False, engine='openpyxl')
            
            messages.success(request, 'Excel exportado exitosamente')
            return response

        except Exception as e:
            messages.error(request, f'Error al exportar Excel: {str(e)}')
            return redirect('asistencia_admin')

@login_required
def crear_perfil_entrenador(request):

    entrenadores = listado_entrenadores()
    page = request.GET.get('page',1)

    try:
        paginator = Paginator(entrenadores, 9)
        entrenadores = paginator.page(page)
    except:
        raise Http404            


    data = {
    'entity':entrenadores,
    'paginator': paginator,
    'disciplinas': listado_disciplinas(),
    'tipo_entrenador': listado_tipo_entrenador(),

    } 


    if request.method == 'POST':
        if 'form_crear' in request.POST:

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
                messages.error(request, "Debes ingresar imagen para crear un entrenador.")
                return redirect('crear_perfil_entrenador')

            disciplinas_seleccionadas = request.POST.getlist('lista_de_disciplina')

            # Validaciones
            if not rut:
                messages.error(request, "Debes ingresar rut para crear un entrenador.")
                return redirect('crear_perfil_entrenador')
            elif not validar_rut(rut):
                messages.error(request, "Debes ingresar un Rut valido para registrar un entrenador.")
                return redirect('crear_perfil_entrenador')
            else:
                rut = rut.replace(".", "")
            
            if not nombre:
                messages.error(request, "Debes ingresar nombre para crear un entrenador.")
                return redirect('crear_perfil_entrenador')
            if not apellido:
                messages.error(request, "Debes ingresar apellido para crear un entrenador.")
                return redirect('crear_perfil_entrenador')
            if not tipo_entrenador:
                messages.error(request, "Debes seleccionar un tipo de entrenador para crear un entrenador.")
                return redirect('crear_perfil_entrenador')
            if not email:
                messages.error(request, "Debes ingresar email para crear un entrenador.")
                return redirect('crear_perfil_entrenador')
            if not disciplinas_seleccionadas:
                messages.error(request, "Debes ingresar una disciplina para crear un entrenador.")
                return redirect('crear_perfil_entrenador')

            disciplinas_seleccionadas = [int(disciplina) for disciplina in disciplinas_seleccionadas]
            

            # Generar contraseña
            nombre_concatenado = apellido[:1]
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
                messages.success(request, "Entrenador registrado correctamente.")
                return redirect('crear_perfil_entrenador')

            elif salida == -1:
                messages.error(request, "Rut ya registrado en otro entrenador.")
                return redirect('crear_perfil_entrenador')
            elif salida == -2:
                messages.error(request, "Email ya registrado en otro entrenador.")
                return redirect('crear_perfil_entrenador')
            else:
                messages.error(request, "No se ha podido registrar el entrenador. ERROR.")
                return redirect('crear_perfil_entrenador')


        elif 'form_editar' in request.POST:
            id_entrenador = request.POST.get('id')
            if id_entrenador:
                entrenador = get_object_or_404(Coach, coach_id=id_entrenador)
                
                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    img_entrenador = imagen_file.read()
                else:
                    img_entrenador = entrenador.coach_img

                nombre_entrendaor = request.POST.get('nombre')

                if 'lista_de_disciplina' in request.POST:
                    # El usuario envió disciplinas nuevas
                    disciplinas_seleccionadas = request.POST.getlist('lista_de_disciplina')
                    disciplinas_seleccionadas = [int(disciplina) for disciplina in disciplinas_seleccionadas]
                    disciplinas_json = json.dumps(disciplinas_seleccionadas)
                
                else:
                    disciplinas_json = None

                if 'tipo_entrenador' in request.POST:
                    tipo_entrenador = int(request.POST.get('tipo_entrenador')) 
                    print(tipo_entrenador)               
                else:
                    tipo_entrenador = None   


                print(tipo_entrenador)
                salida = editar_entrenador(id_entrenador, img_entrenador, nombre_entrendaor, disciplinas_json, tipo_entrenador)

                if salida == 1:
                    messages.success(request, "Entrenador actualizado correctamente.")
                else:
                    messages.error(request, "No se ha podido actualizar al entrenador. ERROR.")
                return redirect('crear_perfil_entrenador')
    
            else:
                messages.error(request, "No se ha proporcionado un ID para el entrenador a editar.")
            return redirect('crear_perfil_entrenador')

        elif 'form_eliminar' in request.POST:
            id_entrenador = request.POST.get('id')
            salida = eliminar_entrenador(id_entrenador)
            if salida == 1:
                messages.success(request, "Entrenador eliminado correctamente.")
            else:
                messages.error(request, "Debes ingresar imagen para crear un entrenador.")
            return redirect('crear_perfil_entrenador')


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
                messages.success(request, "Noticia registrada correctamente.")
            else:
                messages.error(request, "No se ha podido registrar la Noticia. ERROR.")
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
                return redirect('gestion_noticias')
            else:
                messages.error(request, "No se ha podido eliminar la noticia. ERROR.")
            return redirect('gestion_noticias')

    return render(request, 'intranet/administrador/gestion_noticias.html', data)


from django.http import HttpResponse
import pandas as pd
from datetime import datetime
from django.db.models import F
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, HttpResponseForbidden
from django.contrib import messages
from django.db import connection
import pandas as pd
from datetime import datetime

@login_required
def asistencia_admin(request):
    if request.user.user_type != 'admin01':
        return HttpResponseForbidden("Acceso denegado. Se requieren permisos de administrador.")

    try:
        # Obtener disciplinas para el filtro
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT discipline_id, discipline_name 
                FROM discipline 
                ORDER BY discipline_name
            """)
            disciplines = [
                {'discipline_id': row[0], 'discipline_name': row[1]} 
                for row in cursor.fetchall()
            ]

            # Obtener entrenamientos
            cursor.execute("""
                SELECT t.training_id, 
                        t.training_name || ' (' || d.discipline_name || ')' as display_name,
                        t.discipline_id
                FROM training t
                JOIN discipline d ON t.discipline_id = d.discipline_id
                ORDER BY d.discipline_name, t.training_name
            """)
            trainings = [
                {'training_id': row[0], 'training_name': row[1], 'discipline_id': row[2]} 
                for row in cursor.fetchall()
            ]

            # Obtener períodos académicos
            cursor.execute("""
                SELECT period_id, period_name 
                FROM academic_period
                WHERE is_active = 1
                ORDER BY period_name
            """)
            periods = [
                {'period_id': row[0], 'period_name': row[1]} 
                for row in cursor.fetchall()
            ]

        if request.GET.get('descargar') == '1':
            return descargar_asistencia(request)

        context = {
            'disciplines': disciplines,
            'trainings': trainings,
            'periods': periods,
        }

        return render(request, 'intranet/administrador/asistencia_admin.html', context)

    except Exception as e:
        print(f"Error en asistencia_admin: {str(e)}")
        messages.error(request, f'Error al cargar los datos: {str(e)}')
        return render(request, 'intranet/administrador/asistencia_admin.html', {})

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
def gestion_portada(request):
    
    data = {
        'portada':listado_portadas()

    }   


    if request.method == 'POST':

        if 'form_editar' in request.POST:
            id_portada = request.POST.get('id')
            
            if id_portada:
                portada = get_object_or_404(GaleryFront, galery_front_id=id_portada)
                if 'imagen' in request.FILES:
                    imagen_file = request.FILES['imagen']
                    img_portada = imagen_file.read()
                else:
                    img_portada = portada.galery_front_img
                
                titulo_portada = request.POST.get('titulo')
                descripcion_portada = request.POST.get('descripcion')
                        
                salida = editar_portadas(id_portada, img_portada ,titulo_portada, descripcion_portada)

                if salida == 1:
                    messages.success(request, "Portada actualizada correctamente.")
                    return redirect('gestion_portada')
                else:
                    messages.error(request, "No se ha podido actualizar la portada. ERROR.")
                    return redirect('gestion_portada')

    return render (request, 'intranet/administrador/gestion_portada.html', data)

@login_required
def solicitud_jugador(request):

    data = {
        'solicitud': listado_solicitud(),
        'contacto': listado_contacto()
    }



    return render (request, 'intranet/administrador/solicitud_jugador.html', data)

from django.shortcuts import redirect
from django.http import HttpResponse
from django.contrib.auth.decorators import login_required

@login_required
def aceptar_solicitud(request, id):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()
    salida = cursor.var(oracledb.NUMBER)

    # Llamar al procedimiento almacenado
    cursor.callproc('sp_acept_request', [id, salida])

    # Obtén el resultado del procedimiento almacenado
    resultado = salida.getvalue()

    # Redirige a una página o retorna un mensaje
    if resultado == 1:
        # Si la operación fue exitosa, redirige o muestra un mensaje
        return redirect('solicitud_jugador')  # Cambia por tu vista de redirección
    else:
        # Si ocurrió un error, retorna un mensaje adecuado
        return HttpResponse(f"Error al aceptar la solicitud. Código de error: {resultado}")


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

        if 'form_crear' in request.POST:

            if 'imagen' in request.FILES:
                imagen_file = request.FILES['imagen']
                imagen = imagen_file.read()
            else:
                messages.error(request, "Debes subir una imagen para crear la disciplina.")
                return redirect('gestion_disciplina')
            
            nombre = request.POST.get('nombre')
            if not nombre:
                messages.error(request, "Debes ingresar un nombre para crear una disciplina.")
                return redirect('gestion_disciplina')
            
            descripcion = request.POST.get('descripcion')
            if not descripcion:
                messages.error(request, "Debes ingresar una descripcion para crear una disciplina.")
                return redirect('gestion_disciplina')
            # Guardar la imagen en la galeria general de la base de datos
            salida = crear_disciplina(nombre, descripcion, imagen)

            if salida == 1:
                messages.success(request, "Disciplina creada correctamente.")            
            else:
                messages.error(request, "No se ha podido crear la disciplina. ERROR.")            
            return redirect('gestion_disciplina')


        elif 'form_editar' in request.POST:
        
            discipline_id = request.POST.get('id')
            if discipline_id:

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

        elif 'form_eliminar' in request.POST:
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
                messages.error(request, "Debes subir una imagen para registrar un jugador.")
                return redirect('gestion_Jugador_elite')

            rut = request.POST.get('rut')
            if not rut:
                messages.error(request, "Debes ingresar un Rut para registrar un jugador.")
                return redirect('gestion_Jugador_elite')
            elif not validar_rut(rut):
                messages.error(request, "Debes ingresar un Rut valido para registrar un jugador.")
                return redirect('gestion_Jugador_elite')
            else:
                rut = rut.replace(".", "")
                
            nombre = request.POST.get('nombre')
            if not nombre:
                messages.error(request, "Debes ingresar un Nombre para registrar un jugador.")
                return redirect('gestion_Jugador_elite')

            apellido = request.POST.get('apellido')
            if not apellido:
                messages.error(request, "Debes ingresar un Apellido para registrar un jugador.")
                return redirect('gestion_Jugador_elite')

            disciplina = request.POST.get('disciplina')
            if not disciplina:
                messages.error(request, "Debes ingresar una disciplina para registrar un jugador.")
                return redirect('gestion_Jugador_elite')

            fecha_nacimiento = request.POST.get('fecha_nacimiento')
            if not fecha_nacimiento:
                messages.error(request, "Debes ingresar una fwcha de nacimiento para registrar un jugador.")
                return redirect('gestion_Jugador_elite')

            discipline_id = request.POST.get('disciplina_id')
            if not discipline_id:
                messages.error(request, "Debes ingresar una Disciplina para registrar un jugador.")
                return redirect('gestion_Jugador_elite')

            # Guardar el jugador en la base de datos
            salida = guardar_jugador_elite(rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id)

            if salida == 1:
                messages.success(request, "Creación de Jugador enviada correctamente.")
                jugador_elite = listado_jugar_elite()

                data = {
                'entity':jugador_elite,
                'paginator': paginator
                }  
                return redirect('gestion_Jugador_elite')

            elif salida == -1:
                messages.error(request, "Rut ya registrado. Cambie el rut o contacto con el administrador.")
                return redirect('gestion_Jugador_elite')

            else:
                messages.error(request, "No se ha podido registrar. ERROR.")
                return redirect('gestion_Jugador_elite')
            
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
                if not validar_rut(rut):
                    messages.error(request, "Debes ingresar un Rut valido para editar un jugador.")
                    return redirect('gestion_Jugador_elite')
                else:
                    rut = rut.replace(".", "")


                nombre = request.POST.get('nombre')
                apellido = request.POST.get('apellido')
                disciplina = request.POST.get('disciplina')
                fecha_nacimiento = request.POST.get('fecha')
                discipline_id = request.POST.get('id_disciplina')
                
        
                salida = editar_jugador_elite(id_jugador_elite, rut, nombre, apellido, disciplina, fecha_nacimiento, imagen, discipline_id)

                if salida == 1:
                    messages.success(request, "Jugador actualizado correctamente.")
                else:
                    messages.error(request, "No se ha podido actualizar al jugador. ERROR.")

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


def eliminar_entrenador(id_entrenador):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_DELETE_COACH', [
        id_entrenador,
        salida
    ])

    return salida.getvalue()


def editar_entrenador(id_entrenador, img_entrenador, nombre_entrendaor, disciplinas_json, tipo_entrenador):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    
    try:
        cursor.callproc('SP_EDIT_COACH', [
            id_entrenador, 
            img_entrenador, 
            nombre_entrendaor, 
            disciplinas_json, 
            tipo_entrenador,

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


##############  PORTADAS ##############
def listado_portadas():
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    out_cur = django_cursor.connection.cursor()

    cursor.callproc("SP_LIST_FRONT_PAGES", [out_cur])

    lista = []
    for fila in out_cur:
        data={
            'data':fila,
            'imagen':str(base64.b64encode(fila[1].read()), 'utf-8'),    
            
        }

        lista.append(data)

    return lista


def editar_portadas(id_portada, img_portada, titulo_portada, descripcion_portada):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()
    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_EDIT_FRONT_PAGES', [
        id_portada,
        img_portada,
        titulo_portada, 
        descripcion_portada,

        salida
    ])

    return salida.getvalue()

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
    """
    Obtiene la lista de jugadores usando el procedimiento almacenado original
    """
    try:
        django_cursor = connection.cursor()
        out_cur = django_cursor.connection.cursor()
        
        # Ejecutar el procedimiento almacenado original
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
                'carrera': fila[6]
            }
            lista.append(jugador)
            
        print(f"Jugadores encontrados: {lista}")  # Debug
        return lista
        
    except Exception as e:
        print(f"Error al obtener jugadores: {str(e)}")
        print(f"Tipo de error: {type(e)}")
        import traceback
        traceback.print_exc()
        return []
        
    finally:
        if 'out_cur' in locals():
            try:
                out_cur.close()
            except:
                pass
        if 'django_cursor' in locals():
            try:
                django_cursor.close()
            except:
                pass


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

def eliminar_jugador(id_jugador):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_DELETE_PLAYER', [
        id_jugador,
        salida
    ])

    return salida.getvalue()


def crear_disciplina( nombre, descripcion, imagen):
    django_cursor = connection.cursor()
    cursor = django_cursor.connection.cursor()

    salida = cursor.var(oracledb.NUMBER)

    cursor.callproc('SP_CREATE_DISCIPLINA', [ nombre, descripcion, imagen, salida])

    return salida.getvalue()




###### CONTRASEÑA ENTRENADOR #######


from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.shortcuts import render, redirect
from django.contrib.auth.hashers import check_password
from django.contrib.auth import update_session_auth_hash

@login_required
def contrasena_entrenador(request):
    if request.method == 'POST':
        current_password = request.POST.get('current_password')
        new_password = request.POST.get('new_password')
        confirm_password = request.POST.get('confirm_password')
        
        # Verificar si la contraseña actual es correcta
        if not check_password(current_password, request.user.password):
            messages.error(request, 'La contraseña actual no es correcta')
            return redirect('contrasena_entrenador')
        
        # Verificar si las nuevas contraseñas coinciden
        if new_password != confirm_password:
            messages.error(request, 'Las nuevas contraseñas no coinciden')
            return redirect('contrasena_entrenador')
        
        # Cambiar la contraseña
        try:
            request.user.set_password(new_password)
            request.user.save()
            update_session_auth_hash(request, request.user)  # Mantener la sesión activa
            messages.success(request, 'Contraseña cambiada exitosamente')
            return redirect('contrasena_entrenador')
        except Exception as e:
            messages.error(request, 'Ocurrió un error al cambiar la contraseña')
            return redirect('contrasena_entrenador')
    
    return render(request, 'intranet/entrenador/contrasena_entrenador.html')
###################################################################################################



def calcular_estadisticas_asistencia(request):
    try:
        discipline_id = request.GET.get('discipline_id')
        training_id = request.GET.get('training_id')
        period_id = request.GET.get('period_id')

        with connection.cursor() as cursor:
            query = """
                WITH asistencia_diaria AS (
                    SELECT 
                        a.attendance_date,
                        COUNT(*) as total_asistentes,
                        SUM(CASE WHEN ast.status_name = 'present' THEN 1 ELSE 0 END) as presentes,
                        SUM(CASE WHEN ast.status_name = 'absent' THEN 1 ELSE 0 END) as ausentes,
                        SUM(CASE WHEN ast.status_name = 'justified' THEN 1 ELSE 0 END) as justificados,
                        COUNT(DISTINCT a.player_id) as total_jugadores
                    FROM attendance a
                    JOIN attendance_status ast ON a.status_id = ast.status_id
                    WHERE 1=1
                    {% if discipline_id %}AND a.discipline_id = :discipline_id{% endif %}
                    {% if training_id %}AND a.training_id = :training_id{% endif %}
                    {% if period_id %}AND t.period_id = :period_id{% endif %}
                    GROUP BY a.attendance_date
                )
                SELECT
                    COUNT(DISTINCT attendance_date) as total_entrenamientos,
                    ROUND(AVG(CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0) * 100), 2) as promedio_asistencia,
                    MAX(CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0) * 100) as mejor_asistencia,
                    MIN(CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0) * 100) as peor_asistencia,
                    SUM(presentes) as total_presentes,
                    SUM(ausentes) as total_ausentes,
                    SUM(justificados) as total_justificados,
                    MAX(CASE 
                        WHEN CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0) = 
                            (SELECT MAX(CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0))
                            FROM asistencia_diaria)
                        THEN (SELECT COUNT(*) 
                            FROM asistencia_diaria ad2 
                            WHERE CAST(ad2.presentes AS FLOAT) / NULLIF(ad2.total_jugadores, 0) = 
                                    CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0))
                    END) as dias_mejor_asistencia,
                    MAX(CASE 
                        WHEN CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0) = 
                            (SELECT MIN(CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0))
                            FROM asistencia_diaria)
                        THEN (SELECT COUNT(*) 
                            FROM asistencia_diaria ad2 
                            WHERE CAST(ad2.presentes AS FLOAT) / NULLIF(ad2.total_jugadores, 0) = 
                                    CAST(presentes AS FLOAT) / NULLIF(total_jugadores, 0))
                    END) as dias_peor_asistencia
                FROM asistencia_diaria
            """

            param_dict = {}
            if discipline_id:
                param_dict['discipline_id'] = discipline_id
            if training_id:
                param_dict['training_id'] = training_id
            if period_id:
                param_dict['period_id'] = period_id

            cursor.execute(query, param_dict)
            result = cursor.fetchone()

            if result:
                estadisticas = {
                    'total_entrenamientos': result[0],
                    'promedio_asistencia': f"{result[1]}%",
                    'mejor_asistencia': f"{int(result[2])}% ({result[7]} días)",
                    'peor_asistencia': f"{int(result[3])}% ({result[8]} días)",
                    'total_presentes': result[4],
                    'total_ausentes': result[5],
                    'total_justificados': result[6]
                }
                return estadisticas
            else:
                return None

    except Exception as e:
        print(f"Error calculando estadísticas: {str(e)}")
        return None
###################################################################################################





from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseForbidden
from django.contrib import messages
from django.db import connection
import pandas as pd
from datetime import datetime
import traceback
import numpy as np

@login_required
def descargar_asistencia(request):
    try:
        discipline_id = request.GET.get('discipline_id')
        training_id = request.GET.get('training_id')
        period_id = request.GET.get('period_id')

        print(f"Filtros recibidos: discipline_id={discipline_id}, training_id={training_id}, period_id={period_id}")

        with connection.cursor() as cursor:
            query_params = []
            where_clauses = []

            base_query = """
                SELECT 
                    TO_CHAR(a.attendance_date, 'DD/MM/YYYY') as fecha,
                    NVL(p.player_name, '') as nombre,
                    NVL(p.player_last_name, '') as apellido,
                    NVL(d.discipline_name, '') as disciplina,
                    NVL(t.training_name, '') as entrenamiento,
                    CASE 
                        WHEN ast.status_name = 'present' THEN 'Presente'
                        WHEN ast.status_name = 'absent' THEN 'Ausente'
                        WHEN ast.status_name = 'justified' THEN 'Justificado'
                        ELSE ast.status_name
                    END as estado,
                    NVL(a.attendance_comments, '') as comentarios,
                    NVL(p.player_career, '') as carrera,
                    NVL(p.player_headquarters, '') as sede
                FROM attendance a
                JOIN player p ON a.player_id = p.player_id
                JOIN discipline d ON a.discipline_id = d.discipline_id
                JOIN training t ON a.training_id = t.training_id
                JOIN attendance_status ast ON a.status_id = ast.status_id
                WHERE 1=1
            """

            if discipline_id:
                where_clauses.append("a.discipline_id = :discipline_id")
                query_params.append(discipline_id)
            if training_id:
                where_clauses.append("a.training_id = :training_id")
                query_params.append(training_id)
            if period_id:
                where_clauses.append("t.period_id = :period_id")
                query_params.append(period_id)

            if where_clauses:
                base_query += " AND " + " AND ".join(where_clauses)

            # Consulta final con totales por jugador y disciplina
            final_query = f"""
                WITH base_data AS ({base_query})
                SELECT 
                    fecha,
                    nombre,
                    apellido,
                    disciplina,
                    entrenamiento,
                    estado,
                    comentarios,
                    carrera,
                    sede,
                    COUNT(*) OVER (PARTITION BY disciplina) as total_asistencias,
                    COUNT(*) OVER () as total_general,
                    SUM(CASE WHEN estado = 'Presente' THEN 1 ELSE 0 END) OVER (PARTITION BY disciplina) as presentes_disciplina,
                    SUM(CASE WHEN estado = 'Ausente' THEN 1 ELSE 0 END) OVER (PARTITION BY disciplina) as ausentes_disciplina,
                    SUM(CASE WHEN estado = 'Justificado' THEN 1 ELSE 0 END) OVER (PARTITION BY disciplina) as justificados_disciplina,
                    SUM(CASE WHEN estado = 'Presente' THEN 1 ELSE 0 END) OVER (PARTITION BY disciplina, nombre, apellido) as presentes_jugador,
                    SUM(CASE WHEN estado = 'Ausente' THEN 1 ELSE 0 END) OVER (PARTITION BY disciplina, nombre, apellido) as ausentes_jugador,
                    SUM(CASE WHEN estado = 'Justificado' THEN 1 ELSE 0 END) OVER (PARTITION BY disciplina, nombre, apellido) as justificados_jugador
                FROM base_data
                ORDER BY disciplina, nombre, apellido
            """

            print("Ejecutando consulta...")

            param_dict = {}
            if discipline_id:
                param_dict['discipline_id'] = discipline_id
            if training_id:
                param_dict['training_id'] = training_id
            if period_id:
                param_dict['period_id'] = period_id

            cursor.execute(final_query, param_dict)
            results = cursor.fetchall()

            if not results:
                print("No se encontraron resultados")
                messages.warning(request, 'No se encontraron registros de asistencia para los filtros seleccionados')
                return redirect('asistencia_admin')

            columns = [
                'Fecha',
                'Nombre',
                'Apellido',
                'Disciplina',
                'Entrenamiento',
                'Estado de Asistencia',
                'Comentarios',
                'Carrera',
                'Sede',
                'Total Asistencias',
                'Total General',
                'Presentes Disciplina',
                'Ausentes Disciplina',
                'Justificados Disciplina',
                'Presentes Jugador',
                'Ausentes Jugador',
                'Justificados Jugador'
            ]

            # Crear DataFrame principal
            df = pd.DataFrame(results, columns=columns)

            # Crear resumen por jugador
            resumen_jugador = df.groupby(['Disciplina', 'Nombre', 'Apellido']).agg({
                'Presentes Jugador': 'first',
                'Ausentes Jugador': 'first',
                'Justificados Jugador': 'first'
            }).reset_index()

            # Renombrar columnas del resumen por jugador
            resumen_jugador.columns = [
                'Disciplina', 'Nombre', 'Apellido',
                'Presentes', 'Ausentes', 'Justificados'
            ]

            # Crear resumen general por disciplina
            resumen_general = pd.DataFrame({
                'Disciplina': df['Disciplina'].unique(),
                'Presentes': [df[df['Disciplina'] == d]['Presentes Disciplina'].iloc[0] 
                        for d in df['Disciplina'].unique()],
                'Ausentes': [df[df['Disciplina'] == d]['Ausentes Disciplina'].iloc[0] 
                        for d in df['Disciplina'].unique()],
                'Justificados': [df[df['Disciplina'] == d]['Justificados Disciplina'].iloc[0] 
                            for d in df['Disciplina'].unique()],
                'Total Asistencias': [df[df['Disciplina'] == d]['Total Asistencias'].iloc[0] 
                                    for d in df['Disciplina'].unique()]
            })

            # Agregar fila de totales al resumen general
            resumen_general.loc['Total'] = [
                'Total General',
                resumen_general['Presentes'].sum(),
                resumen_general['Ausentes'].sum(),
                resumen_general['Justificados'].sum(),
                resumen_general['Total Asistencias'].sum()
            ]

            # Crear Excel
            response = HttpResponse(
                content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            )
            filename = f'asistencia_{datetime.now().strftime("%Y%m%d_%H%M%S")}.xlsx'
            response['Content-Disposition'] = f'attachment; filename="{filename}"'

            print("Generando archivo Excel...")
            with pd.ExcelWriter(response, engine='openpyxl') as writer:
                resumen_jugador.to_excel(writer, sheet_name='Resumen por Jugador', index=False)
                resumen_general.to_excel(writer, sheet_name='Resumen General', index=False)
                df.to_excel(writer, sheet_name='Detalle Completo', index=False)

            print("Archivo Excel generado con éxito")
            return response

    except Exception as e:
        print(f"Error en descargar_asistencia: {str(e)}")
        print(f"Tipo de error: {type(e)}")
        import traceback
        print(f"Traceback completo: {traceback.format_exc()}")
        messages.error(request, 'Error al generar el archivo de asistencia')
        return redirect('asistencia_admin')
###################################################################################################






from datetime import datetime
from django.shortcuts import render, redirect
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.db import connection
from django.http import HttpResponseForbidden

def obtener_entrenamientos_activos(coach_id):
    """
    Obtiene los entrenamientos activos del entrenador
    """
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                t.training_id,
                t.training_name,
                d.discipline_id,
                d.discipline_name,
                t.start_time,
                t.end_time,
                ap.period_id,
                ap.period_name,
                ap.is_active
            FROM training t
            JOIN discipline d ON t.discipline_id = d.discipline_id
            JOIN academic_period ap ON t.period_id = ap.period_id
            WHERE t.coach_id = :1
            AND ap.is_active = 1
            ORDER BY t.training_name
        """, [coach_id])
        
        columns = [
            'training_id',
            'training_name',
            'discipline_id',
            'discipline_name',
            'start_time',
            'end_time',
            'period_id',
            'period_name',
            'is_active'
        ]
        
        return [dict(zip(columns, row)) for row in cursor.fetchall()]



