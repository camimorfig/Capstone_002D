CREATE OR REPLACE PROCEDURE SP_LIST_EVENTS (
    p_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            e.events_id,
            e.events_name,
            e.events_type,
            e.events_status,
            e.events_start,
            e.events_end,
            e.events_description,
            e.events_recurring,
            d.discipline_name
        FROM 
            events e
            LEFT JOIN discipline d ON e.discipline_id = d.discipline_id
        ORDER BY 
            e.events_start DESC;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error al listar eventos: ' || SQLERRM);
END SP_LIST_EVENTS;
/
