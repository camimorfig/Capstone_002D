CREATE OR REPLACE PROCEDURE SP_REGISTRAR_ASISTENCIA(
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
BEGIN
    -- Verificar si ya existe asistencia para hoy
    SELECT COUNT(*) 
    INTO v_count
    FROM Attendance 
    WHERE player_id = p_player_id 
    AND training_id = p_training_id 
    AND TRUNC(attendance_date) = TRUNC(SYSDATE);
    
    IF v_count > 0 THEN
        v_success := 0;
    ELSE
        -- Obtener status_id
        SELECT status_id 
        INTO v_status_id
        FROM attendance_status 
        WHERE status_name = p_status_name;
        
        -- Insertar asistencia
        INSERT INTO attendance (
            player_id,
            training_id,
            discipline_id,
            status_id,
            attendance_date,
            attendance_comments,
            creation_timestamp
        ) VALUES (
            p_player_id,
            p_training_id,
            p_discipline_id,
            v_status_id,
            TRUNC(SYSDATE),
            p_comments,
            SYSDATE
        );
        
        v_success := 1;
    END IF;
    
    -- Abrir el cursor con el resultado
    OPEN p_result FOR 
    SELECT v_success FROM DUAL;
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        OPEN p_result FOR 
        SELECT 0 FROM DUAL;
    WHEN OTHERS THEN
        ROLLBACK;
        OPEN p_result FOR 
        SELECT 0 FROM DUAL;
END;
/