CREATE OR REPLACE PROCEDURE SP_LIST_PLAYERS_FOR_DISCIPLINE (
    list_players_discipline OUT SYS_REFCURSOR, 
    v_discipline_id VARCHAR2
) IS
BEGIN
    OPEN list_players_discipline FOR 
    SELECT 
        p.player_id, 
        p.player_rut,
        p.player_name,
        p.player_last_name,
        d.discipline_name,
        p.player_headquarters,
        p.player_career,
        COALESCE(AVG(CASE WHEN ast.status_name = 'present' THEN 1 ELSE 0 END), 0) AS attendance_avg,
        REPLACE(REPLACE(p.player_status, 0, 'En espera'), 1, 'Activo') as "PLAYER_STATUS"
    FROM 
        player p 
    JOIN 
        discipline d ON p.discipline_id = d.discipline_id
    LEFT JOIN 
        attendance a ON p.player_id = a.player_id
    LEFT JOIN 
        attendance_status ast ON a.status_id = ast.status_id
    WHERE 
        d.discipline_id = v_discipline_id
    GROUP BY 
        p.player_id, 
        p.player_rut,
        p.player_name,
        p.player_last_name,
        d.discipline_name,
        p.player_headquarters,
        p.player_career,
        player_status;
END;