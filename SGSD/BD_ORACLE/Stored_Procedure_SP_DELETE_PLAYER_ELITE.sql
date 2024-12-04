create or replace PROCEDURE sp_delete_player_elite(
    
    p_player_elite_id number,
    
    salida out number
) AS

BEGIN


    DELETE FROM player_elite
    WHERE player_elite_id = p_player_elite_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;