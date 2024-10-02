CREATE OR REPLACE PROCEDURE SP_CREATE_GALERY(
    p_galery_img BLOB,
    
    p_galery_front_page NUMBER,
    p_galery_description VARCHAR2,
    p_discipline_id NUMBER,
    
    
    p_salida OUT NUMBER
) AS
    v_galery_status NUMBER;


BEGIN
    v_galery_status:= 1; -- 1 = ACTIVE
    
    INSERT INTO GALERY (
        galery_img,
        galery_status,
        galery_front_page,
        galery_description,
        discipline_id
    ) VALUES (
        p_galery_img,
        v_galery_status,
        p_galery_front_page,       
        p_galery_description,
        p_discipline_id
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


