CREATE OR REPLACE PROCEDURE sp_insert_training(
    p_training_name IN VARCHAR2,
    p_discipline_id IN NUMBER,
    p_period_id IN NUMBER,
    p_weekdays IN VARCHAR2,
    p_start_time IN TIMESTAMP,
    p_end_time IN TIMESTAMP,
    p_is_active IN NUMBER,
    p_result OUT NUMBER
)
AS
    v_discipline_count NUMBER;
    v_period_count NUMBER;
BEGIN
    -- Inicializar resultado
    p_result := 0;
    
    -- Validaciones básicas
    IF p_start_time >= p_end_time THEN
        p_result := -1; -- Error: hora de inicio debe ser anterior a hora de fin
        RETURN;
    END IF;
    
    -- Validar que la disciplina existe
    SELECT COUNT(*)
    INTO v_discipline_count
    FROM Discipline
    WHERE discipline_id = p_discipline_id;
    
    IF v_discipline_count = 0 THEN
        p_result := -2; -- Error: disciplina no existe
        RETURN;
    END IF;
    
    -- Validar que el período existe
    SELECT COUNT(*)
    INTO v_period_count
    FROM Academic_Period
    WHERE period_id = p_period_id;
    
    IF v_period_count = 0 THEN
        p_result := -3; -- Error: período no existe
        RETURN;
    END IF;
    
    -- Insertar el entrenamiento
    INSERT INTO Training (
        training_name,
        discipline_id,
        period_id,
        weekdays,
        start_time,
        end_time,
        is_active
    ) VALUES (
        p_training_name,
        p_discipline_id,
        p_period_id,
        p_weekdays,
        p_start_time,
        p_end_time,
        p_is_active
    );
    
    -- Si llegamos aquí, la inserción fue exitosa
    p_result := 1;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_result := -99; -- Error general
        ROLLBACK;
END;
/