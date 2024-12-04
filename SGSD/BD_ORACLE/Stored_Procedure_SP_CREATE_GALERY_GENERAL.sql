create or replace PROCEDURE SP_CREATE_GALERY_GENERAL(
    p_galery_img BLOB,
    p_galery_tag VARCHAR2,
    
    p_salida OUT NUMBER
) AS
    v_galery_status NUMBER;
    v_galery_date DATE;

BEGIN

    v_galery_date:= SYSDATE;
    v_galery_status:= 1; -- 1 = ACTIVE

    INSERT INTO galery_general (
        galery_gen_img,
        galery_gen_tag,
        galery_gen_status,
        galery_gen_date
    ) VALUES (
        p_galery_img,
        p_galery_tag,
        v_galery_status,
        v_galery_date
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
