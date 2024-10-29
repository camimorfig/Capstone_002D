create or replace NONEDITIONABLE PROCEDURE sp_acept_request(

    p_request_id NUMBER,
    
    salida out number
) AS

    v_player_rut varchar(12);

BEGIN


    SELECT player_rut 

    into v_player_rut
    FROM requests
    where request_id = p_request_id;

--  Actualizar Estado de Jugador
    UPDATE player
    SET player_status = 1 -- 1 = 'Activo'
    WHERE player_rut = v_player_rut;

--  Actualizar Estado de Solicitud
    UPDATE requests
    SET request_status = 0  -- 0 = 'Aceptada'
    WHERE request_id = p_request_id;
    
    salida := 1; 

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    
        salida := 0;
        ROLLBACK;
        RAISE;

END;