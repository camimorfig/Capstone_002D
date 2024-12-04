from .models import Admin, Coach, Discipline


def coach_name_processor(request):
    if request.user.is_authenticated and request.user.user_type == 'coach01':
        try:
            coach = Coach.objects.get(user=request.user)
            return {'nombre_entrenador': coach.coach_name}
        except Coach.DoesNotExist:
            return {'nombre_entrenador': "Entrenador desconocido"}
    return {}
    
def admin_name_processor(request):
    if request.user.is_authenticated and request.user.user_type == 'admin01':
        try:
            admin = Admin.objects.get(user=request.user)
            return {'nombre_admin': admin.admin_name}
        except Admin.DoesNotExist:
            return {'nombre_admin': "Admin desconocido"}
    return {}




def disciplinas_navbar(request):
    disciplinas = Discipline.objects.all()  

    return {'disciplinas_navbar': disciplinas}