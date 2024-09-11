CREATE OR REPLACE PROCEDURE sp_create_coach_user(
-- coach data --
    p_rut VARCHAR2,
    p_name VARCHAR2,
    p_lastname VARCHAR2,
    p_image blob,
    coah_type NUMBER,
    
    p_discipline IN T_sports,
-- user data --
    p_email VARCHAR2,
    p_password VARCHAR2,

    
    v_salida OUT NUMBER
) is
    v_coach_id NUMBER;
    v_user_id NUMBER;


    v_name_complete VARCHAR2(200);

    v_user_type VARCHAR2(50);
    v_active NUMBER;
    v_staff NUMBER;
    v_superuser NUMBER;

BEGIN
    
    --CREATE USER--

    v_active:=1;    -- 1 = yes 
    v_staff:=0;     -- 0 = no
    v_superuser:=0; -- 0 = no
    v_user_type:= 'coach01';

    INSERT INTO main_user (email, password ,user_type ,is_active ,is_staff ,is_superuser)
    VALUES (p_email, p_password, v_user_type, v_active, v_staff, v_superuser)
    RETURNING user_id INTO v_user_id;


    --CREATE COACH --

    v_name_complete := p_name || ' ' || p_lastname;

    INSERT INTO coach (coach_id, coach_name, coach_img, user_id, coach_type_id)
    VALUES (p_rut, v_name_complete, p_image, v_user_id, coah_type)
    RETURNING coach_id INTO v_coach_id;

    FOR i IN 1..p_discipline.COUNT LOOP
        INSERT INTO coach_discipline (coach_id, discipline_id)
        VALUES (v_coach_id, p_discipline(i));
    END LOOP;
    v_salida:= 1;
    COMMIT;
    
    v_salida:=0;
END;
