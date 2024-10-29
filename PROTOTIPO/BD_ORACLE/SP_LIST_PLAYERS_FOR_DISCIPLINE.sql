create or replace procedure sp_list_players_for_discipline (list_players_discipline out SYS_REFCURSOR, 
v_discipline_id VARCHAR2) 
is

BEGIN
    open list_players_discipline for SELECT 
    p.player_id, 
    p.player_rut,
    p.player_name,
    p.player_last_name,
    d.discipline_name,
    p.player_headquarters,
    p.player_career,
    concat(COALESCE(AVG(CASE WHEN a.attendance_status = 'present' THEN 1 ELSE 0 END), 0),'%') AS attendance_avg,
    REPLACE((REPLACE(p.player_status, 0, 'En espera')), 1, 'Activo') as "PLAYER_STATUS"

FROM 
    player p 
JOIN 
    discipline d ON p.discipline_id = d.discipline_id
LEFT JOIN 
    attendance a ON p.player_id = a.player_id

WHERE d.discipline_id = v_discipline_id 
GROUP BY 
    p.player_id, 
    p.player_rut,
    p.player_name,
    p.player_last_name,
    d.discipline_name,
    p.player_headquarters,
    p.player_career,
    player_status;

end;