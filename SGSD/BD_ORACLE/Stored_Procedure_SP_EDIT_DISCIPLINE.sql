create or replace PROCEDURE sp_edit_discipline(
    
    p_discipline_id number,
    p_discipline_img blob,
    p_discipline_name VARCHAR,
    p_discipline_descripcion VARCHAR,
    
    salida out number
) AS

BEGIN

    UPDATE discipline
    set 
        galery_img = p_discipline_img,
        discipline_name = p_discipline_name,
        discipline_description = p_discipline_descripcion

    WHERE discipline_id = p_discipline_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;