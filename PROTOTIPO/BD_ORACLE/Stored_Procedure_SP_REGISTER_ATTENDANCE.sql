create or replace PROCEDURE sp_register_attendance(
    p_player_id IN NUMBER,
    p_discipline_id IN NUMBER,
    p_status_name IN VARCHAR2,
    p_comments IN VARCHAR2,
    p_result OUT NUMBER
) IS
    v_status_id NUMBER;
BEGIN
    -- Obtener el ID del estado
    SELECT status_id INTO v_status_id 
    FROM attendance_status 
    WHERE status_name = p_status_name;

    -- Insertar la asistencia
    INSERT INTO attendance (
        player_id,
        discipline_id,
        status_id,
        attendance_date,
        attendance_comments
    ) VALUES (
        p_player_id,
        p_discipline_id,
        v_status_id,
        SYSDATE,
        p_comments
    );

    p_result := 1; -- Éxito
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 0; -- Estado de asistencia no encontrado
        ROLLBACK;
    WHEN OTHERS THEN
        p_result := -1; -- Error general
        ROLLBACK;
END;