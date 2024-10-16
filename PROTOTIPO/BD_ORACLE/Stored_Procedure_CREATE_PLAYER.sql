create or replace PROCEDURE sp_create_player(
    p_rut VARCHAR2,
    p_name VARCHAR2,
    p_last_name VARCHAR2,
    p_headquarters VARCHAR2,
    p_career VARCHAR2,
    p_img BLOB,
    p_discipline_id NUMBER,
    p_coach_id VARCHAR2,
    
    v_salida OUT NUMBER
) IS

    v_status_player VARCHAR2(30);
    v_status_request VARCHAR2(30);
    
    v_request_date DATE;
    
    v_coach_name VARCHAR2(100);
    v_discipline_name VARCHAR2(100);

BEGIN
    v_status_player:= 0; -- 1 = Active 0 = Inactive
    v_status_request:= 1; -- 1 = Unread 0 = Acepted -1 = rejected

    v_request_date:= SYSDATE;

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
        v_status_player,
        p_discipline_id
    );
    
    SELECT discipline_name
    INTO v_discipline_name
    FROM discipline
    where discipline_id = p_discipline_id;
    
    SELECT coach_name
    INTO v_coach_name
    FROM coach
    where coach_id = p_coach_id;
    
    
    INSERT INTO requests (
        coach_name,
        player_rut,
        player_name,
        player_last_name,
        discipline_name,
        player_headquarters,
        player_career,
        request_status,
        request_date,
        coach_id    
    ) VALUES (
        v_coach_name,
        p_rut,
        p_name,
        p_last_name,
        v_discipline_name,
        p_headquarters,
        p_career,
        v_status_request,
        v_request_date,
        p_coach_id);
    
    

    v_salida := 1;  -- Indica éxito
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        v_salida := 0;  -- Indica error
        ROLLBACK;
END;