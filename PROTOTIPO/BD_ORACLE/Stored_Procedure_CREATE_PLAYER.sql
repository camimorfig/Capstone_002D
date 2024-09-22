    CREATE OR REPLACE PROCEDURE sp_create_player(
    p_rut VARCHAR2,
    p_name VARCHAR2,
    p_last_name VARCHAR2,
    p_headquarters VARCHAR2,
    p_career VARCHAR2,
    p_img BLOB,
    p_discipline_id NUMBER,
--    p_game_position_id NUMBER,
    v_salida OUT NUMBER
) IS

    p_status VARCHAR2(30);

BEGIN
    p_status:= 1; -- Active

    INSERT INTO player (
        player_rut,
        player_name,
        player_last_name,
        player_headquarters,
        player_career,
        player_img,
        player_status,
        discipline_id
    ) VALUES (
        p_rut,
        p_name,
        p_last_name,
        p_headquarters,
        p_career,
        p_img,
        p_status,
        p_discipline_id
    );

    v_salida := 1;  -- Indica éxito
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        v_salida := 0;  -- Indica error
        ROLLBACK;
END;
