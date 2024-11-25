create or replace PROCEDURE sp_create_elite_player(
    p_rut VARCHAR2,
    p_name VARCHAR2,
    p_last_name VARCHAR2,
    p_discipline VARCHAR2,
    p_birthday DATE,
    p_img BLOB,
    p_discipline_id NUMBER,
    
    v_salida OUT NUMBER
) IS

    v_status_player VARCHAR2(30);
    v_count_rut NUMBER;


BEGIN
    v_status_player:= 1; -- 1 = Active 0 = Inactive


    -- Verificar rut
    SELECT COUNT(*)
    INTO v_count_rut
    FROM player
    WHERE player_rut = p_rut;  

    -- Validar
    IF v_count_rut > 0 THEN
        v_salida := -1; -- RUT ya existe
        RETURN;

    ELSE

        INSERT INTO Player_Elite (
            Player_Elite_rut,
            Player_Elite_name,
            Player_Elite_last_name,
            Player_Elite_discipline,
            player_img,
            player_status,
            player_birthday,
            discipline_id
        ) VALUES (
            p_rut,
            p_name,
            p_last_name,
            p_discipline,
            p_img,
            v_status_player,
            p_birthday,
            p_discipline_id
        );


        v_salida := 1;  -- Indica éxito
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_salida := 0;  -- Indica error
        ROLLBACK;
END;