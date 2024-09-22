CREATE OR REPLACE PROCEDURE sp_create_coach_user(
    -- coach data --
    p_rut VARCHAR2,
    p_name VARCHAR2,
    p_lastname VARCHAR2,
    p_image BLOB,
    coach_type NUMBER,
    -- user data --
    p_email VARCHAR2,
    p_password VARCHAR2,
    v_salida OUT NUMBER
) IS
    v_coach_id VARCHAR2(200);
    v_user_id NUMBER;
    v_name_complete VARCHAR2(2000);
    v_user_type VARCHAR2(500);
    v_active NUMBER;
    v_staff NUMBER;
    v_superuser NUMBER;
    v_count_rut NUMBER;
    v_count_email NUMBER;

BEGIN
    -- Verificar RUT 
    SELECT COUNT(*)
    INTO v_count_rut
    FROM coach
    WHERE coach_id = p_rut;

    -- Verificar email
    SELECT COUNT(*)
    INTO v_count_email
    FROM main_user
    WHERE email = p_email;

    -- Validar
    IF v_count_rut > 0 THEN
        v_salida := -1; -- RUT ya existe
        RETURN;
    ELSIF v_count_email > 0 THEN
        v_salida := -2; -- Email ya existe
        RETURN;
    ELSE

        v_active := 1;    -- 1 = sí
        v_staff := 0;     -- 0 = no
        v_superuser := 0; -- 0 = no
        v_user_type := 'coach01';

        -- Crear usuario
        INSERT INTO main_user (email, password, user_type, is_active, is_staff, is_superuser)
        VALUES (p_email, p_password, v_user_type, v_active, v_staff, v_superuser)
        RETURNING user_id INTO v_user_id;

        -- Concatenar nombre completo
        v_name_complete := p_name || ' ' || p_lastname;

        -- Crear entrenador
        INSERT INTO coach (coach_id, coach_name, coach_img, user_id, coach_type_id)
        VALUES (p_rut, v_name_complete, p_image, v_user_id, coach_type)
        RETURNING coach_id INTO v_coach_id;

        v_salida := 1; -- Operación exitosa
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_salida := 0; -- Error
        ROLLBACK;
END;