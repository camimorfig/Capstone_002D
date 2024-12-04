create or replace PROCEDURE sp_delete_galery_general(
    
    p_galery_id number,
    
    salida out number   
) AS

BEGIN


    DELETE FROM galery_general
    WHERE galery_gen_id = p_galery_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;