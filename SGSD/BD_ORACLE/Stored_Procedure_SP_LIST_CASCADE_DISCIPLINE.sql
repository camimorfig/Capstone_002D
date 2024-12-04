create or replace procedure sp_list_cascade_discipline (
    
    v_id_disciplina number,

    v_count_player out number,
    v_count_player_elite out number,
    v_count_galery_discipline out number,
    v_count_attendance out number,
    v_count_events out number,
    v_count_coach_discipline out number


) is
BEGIN

    --player
    SELECT count(p.player_id)
    into v_count_player
    from player p
    where p.discipline_id = v_id_disciplina;
    --player_elite
    SELECT count(pe.player_elite_id)
    into v_count_player_elite
    from player_elite pe
    where pe.discipline_id = v_id_disciplina;
    --galery_discipline
    SELECT count(gd.discipline_id)
    into v_count_galery_discipline
    from galery_discipline gd
    where gd.discipline_id= v_id_disciplina;
    --attendance
    SELECT count(a.attendance_id)
    into v_count_attendance
    from attendance a
    where a.discipline_id = v_id_disciplina; 
    --events
    SELECT count(e.events_id)
    into v_count_events
    from events e
    where e.discipline_id = v_id_disciplina; 
    --coach_discipline
    SELECT count(cd.discipline_id)
    into v_count_coach_discipline
    from coach_discipline cd
    where cd.discipline_id = v_id_disciplina; 


end;