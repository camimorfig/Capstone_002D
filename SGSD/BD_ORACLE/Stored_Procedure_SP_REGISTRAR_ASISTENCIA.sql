create or replace PROCEDURE SP_REGISTRAR_ASISTENCIA(
    p_player_id IN NUMBER,
    p_training_id IN NUMBER,
    p_discipline_id IN NUMBER,
    p_status_name IN VARCHAR2,
    p_comments IN VARCHAR2,
    p_result OUT SYS_REFCURSOR
) AS
    v_status_id NUMBER;
    v_count NUMBER;
    v_success NUMBER := 0;
    v_period_id NUMBER;
    v_training_period_id NUMBER;
    v_debug VARCHAR2(1000);
BEGIN
    v_debug := 'Iniciando registro de asistencia';

    -- Primero obtener el periodo del entrenamiento
    BEGIN
        SELECT period_id 
        INTO v_training_period_id
        FROM training 
        WHERE training_id = p_training_id;

        v_debug := v_debug || ' | Periodo del entrenamiento: ' || v_training_period_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_debug := v_debug || ' | Error: Entrenamiento no encontrado';
            RAISE;
    END;

    -- Verificar que el periodo del entrenamiento esté activo
    BEGIN
        SELECT period_id 
        INTO v_period_id
        FROM academic_period 
        WHERE period_id = v_training_period_id
        AND is_active = 1;

        v_debug := v_debug || ' | Periodo activo confirmado: ' || v_period_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_debug := v_debug || ' | Error: El periodo del entrenamiento no está activo';
            RAISE;
    END;

    -- Obtener status_id
    BEGIN
        SELECT status_id 
        INTO v_status_id
        FROM attendance_status 
        WHERE status_name = p_status_name;

        v_debug := v_debug || ' | Status ID: ' || v_status_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_debug := v_debug || ' | Error: Status no encontrado';
            RAISE;
    END;

    -- Verificar asistencia existente
    SELECT COUNT(*) 
    INTO v_count
    FROM Attendance 
    WHERE player_id = p_player_id 
    AND training_id = p_training_id 
    AND TRUNC(attendance_date) = TRUNC(SYSDATE);

    IF v_count = 0 THEN
        -- Insertar asistencia con el periodo del entrenamiento
        INSERT INTO attendance (
            player_id, 
            training_id, 
            discipline_id, 
            period_id,
            status_id, 
            attendance_date, 
            attendance_comments, 
            creation_timestamp
        ) VALUES (
            p_player_id, 
            p_training_id, 
            p_discipline_id, 
            v_training_period_id,  -- Usamos el periodo del entrenamiento
            v_status_id, 
            TRUNC(SYSDATE), 
            p_comments, 
            SYSTIMESTAMP
        );

        v_success := 1;
        v_debug := v_debug || ' | Inserción exitosa';
        COMMIT;
    ELSE
        v_debug := v_debug || ' | Ya existe asistencia para hoy';
    END IF;

    OPEN p_result FOR 
        SELECT v_success AS result, v_debug AS debug_message 
        FROM DUAL;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        OPEN p_result FOR 
            SELECT 0 AS result, 
                   v_debug || ' | Error: Datos requeridos no encontrados' 
            AS debug_message 
            FROM DUAL;
    WHEN OTHERS THEN
        v_debug := v_debug || ' | Error: ' || SQLERRM;
        ROLLBACK;
        OPEN p_result FOR 
            SELECT 0 AS result, v_debug AS debug_message 
            FROM DUAL;
END;