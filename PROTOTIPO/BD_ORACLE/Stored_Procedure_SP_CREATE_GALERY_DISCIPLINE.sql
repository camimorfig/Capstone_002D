create or replace  PROCEDURE SP_CREATE_GALERY_DISCIPLINE(
    p_galery_img BLOB,
    p_galery_tag VARCHAR2,
    p_galery_discipline_id NUMBER,
    
    p_salida OUT NUMBER
) AS
    v_galery_status NUMBER;
    v_galery_date DATE;

BEGIN

    v_galery_date:= SYSDATE;
    v_galery_status:= 1; -- 1 = ACTIVE

    INSERT INTO galery_discipline (
        galery_dis_img,
        galery_dis_status,        
        galery_dis_tag,
        galery_dis_date,
        discipline_id
    ) VALUES (
        p_galery_img,
        v_galery_status,        
        p_galery_tag,
        v_galery_date,
        p_galery_discipline_id
    );

    -- Si la inserción fue exitosa, se asigna 1 a la variable de salida
    p_salida := 1;
    commit;
EXCEPTION
    -- En caso de error, se asigna 0 a la variable de salida
    WHEN OTHERS THEN
        p_salida := 0;
        RAISE;
END;