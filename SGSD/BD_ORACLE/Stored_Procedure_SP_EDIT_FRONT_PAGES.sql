create or replace PROCEDURE sp_edit_front_pages(
    
    p_galery_front_id number,
    p_galery_front_img blob,
    p_galery_front_title VARCHAR,
    p_galery_front_description VARCHAR,
    
    salida out number
) AS

v_galery_date date;  
BEGIN
    v_galery_date := sysdate;


    UPDATE galery_front
    set 
        galery_front_img = p_galery_front_img,
        galery_front_title = p_galery_front_title,
        galery_front_description = p_galery_front_description,
        galery_front_date = v_galery_date

    WHERE galery_front_id = p_galery_front_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;