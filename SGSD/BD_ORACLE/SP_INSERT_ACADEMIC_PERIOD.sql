create or replace PROCEDURE sp_insert_academic_period(
    p_period_name IN VARCHAR2,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_semester IN NUMBER,
    p_is_active IN NUMBER,
    p_result OUT NUMBER
) AS 
BEGIN
    -- Validar que la fecha de inicio sea menor que la fecha de fin
    IF p_start_date >= p_end_date THEN
        p_result := 0;  -- Error en fechas
        RETURN;
    END IF;

    -- Insertar el nuevo periodo
    INSERT INTO Academic_Period (
        period_name,
        start_date,
        end_date,
        semester,
        is_active
    ) VALUES (
        p_period_name,
        p_start_date,
        p_end_date,
        p_semester,
        p_is_active
    );

    COMMIT;
    p_result := 1;  -- Éxito

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := -1;  -- Error general
END;