-- Procedimiento para insertar eventos
CREATE OR REPLACE PROCEDURE SP_INSERT_EVENT (
    p_events_name IN VARCHAR2,
    p_events_type IN VARCHAR2,
    p_events_status IN VARCHAR2,
    p_events_start IN DATE,
    p_events_end IN DATE,
    p_events_description IN VARCHAR2,
    p_events_recurring IN NUMBER,
    p_discipline_id IN NUMBER
)
IS
BEGIN
    INSERT INTO events (
        events_name,
        events_type,
        events_status,
        events_start,
        events_end,
        events_description,
        events_recurring,
        discipline_id
    ) VALUES (
        p_events_name,
        p_events_type,
        p_events_status,
        p_events_start,
        p_events_end,
        p_events_description,
        p_events_recurring,
        p_discipline_id
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Error al insertar evento: ' || SQLERRM);
END SP_INSERT_EVENT;
/