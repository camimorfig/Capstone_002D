CREATE OR REPLACE PROCEDURE SP_LIST_EVENTS_FOR_COACH (
    p_cursor OUT SYS_REFCURSOR,
    p_coach_id IN VARCHAR2
)
IS
BEGIN
    OPEN p_cursor FOR
        SELECT
            e.events_id,
            e.events_name,
            e.events_type,
            e.events_description,
            TO_CHAR(e.events_start, 'DD/MM/YYYY HH24:MI:SS') as events_start,
            TO_CHAR(e.events_end, 'DD/MM/YYYY HH24:MI:SS') as events_end,
            e.discipline_id,  -- Agregamos discipline_id
            d.discipline_name  -- Agregamos discipline_name
        FROM 
            events e
            LEFT JOIN discipline d ON e.discipline_id = d.discipline_id
        WHERE 
            e.discipline_id IS NULL  -- Eventos para todas las disciplinas
            OR e.discipline_id IN (
                SELECT cd.discipline_id 
                FROM coach_discipline cd 
                WHERE cd.coach_id = p_coach_id
            )
        ORDER BY 
            e.events_start DESC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error al listar eventos para entrenador: ' || SQLERRM);
END SP_LIST_EVENTS_FOR_COACH;
/
