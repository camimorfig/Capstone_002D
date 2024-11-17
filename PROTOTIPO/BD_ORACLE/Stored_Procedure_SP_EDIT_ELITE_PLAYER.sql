create or replace PROCEDURE sp_edit_elite_player(
    
    p_id number,
    p_rut VARCHAR2,
    p_name VARCHAR2,
    p_last_name VARCHAR2,
    p_discipline VARCHAR2,
    p_birthday DATE,
    p_img BLOB,
    p_discipline_id NUMBER,
    
    v_salida OUT NUMBER
) IS


BEGIN

    
    UPDATE Player_Elite 
    set Player_Elite_rut = p_rut,
        Player_Elite_name = p_name,
        Player_Elite_last_name = p_last_name,
        Player_Elite_discipline = p_discipline,
        player_img = p_img,
        player_birthday = p_birthday,
        discipline_id = p_discipline_id

    WHERE player_elite_id = p_id;
         
    v_salida := 1;  -- Indica éxito
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        v_salida := 0;  -- Indica error
        ROLLBACK;
END;