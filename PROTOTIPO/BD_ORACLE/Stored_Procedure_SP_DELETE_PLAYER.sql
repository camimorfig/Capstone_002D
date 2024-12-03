create or replace PROCEDURE sp_delete_player(
    
    p_player_id number,
    
    salida out number
) AS

BEGIN

    DELETE FROM player
    WHERE discipline_id = p_player_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;