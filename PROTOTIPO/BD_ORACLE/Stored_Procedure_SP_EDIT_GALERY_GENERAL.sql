create or replace PROCEDURE sp_edit_galery_general(
    
    p_galery_id number,
    p_galery_img blob,
    p_galery_name VARCHAR,
    p_galery_date_string VARCHAR,
    
    salida out number
) AS

v_galery_date TIMESTAMP;  
BEGIN
    v_galery_date := to_timestamp(p_galery_date_string, 'YYYY-MM-DD HH24:MI:SS');


    UPDATE galery_general
    set 
        galery_gen_img = p_galery_img,
        galery_gen_tag = p_galery_name,
        galery_gen_date = v_galery_date
    
    WHERE galery_gen_id = p_galery_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;