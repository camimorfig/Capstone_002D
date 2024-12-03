create or replace PROCEDURE sp_delete_discipline(
    p_discipline_id IN NUMBER,
    salida OUT NUMBER
) AS

    v_coach_id VARCHAR2(15);
    v_main_user_id NUMBER;

    -- Cursor para jugadores
    CURSOR player_cursor IS
        SELECT p.player_id
        FROM player p
        WHERE p.discipline_id = p_discipline_id;

    CURSOR coach_discipline_cursor IS
        SELECT d.coach_id
        FROM COACH_DISCIPLINE d
        WHERE d.discipline_id = p_discipline_id;



BEGIN
    -- Eliminar asistencia
    DELETE FROM ATTENDANCE 
    WHERE DISCIPLINE_ID = p_discipline_id;

    -- Eliminar registros de jugadores relacionados
    FOR player_rec IN player_cursor LOOP
        DELETE FROM team_roster 
        WHERE player_id = player_rec.player_id;

        DELETE FROM statistic 
        WHERE player_id = player_rec.player_id;
    END LOOP;



    -- Eliminar jugadores
    DELETE FROM PLAYER 
    WHERE DISCIPLINE_ID = p_discipline_id;


    FOR cd_cursor IN coach_discipline_cursor LOOP
        DELETE FROM coach_discipline 
        WHERE coach_id = cd_cursor.coach_id;

        DELETE FROM requests WHERE coach_id = v_coach_id;

    END LOOP;

    -- Eliminar otras tablas relacionadas con la disciplina
    DELETE FROM PLAYER_ELITE WHERE discipline_id = p_discipline_id;
    DELETE FROM training WHERE discipline_id = p_discipline_id;
    DELETE FROM EVENTS WHERE discipline_id = p_discipline_id;
    DELETE FROM GALERY_DISCIPLINE WHERE discipline_id = p_discipline_id;

    -- Eliminar la disciplina principal
    DELETE FROM DISCIPLINE
    WHERE DISCIPLINE_ID = p_discipline_id;

    salida := 1;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        salida := 0;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error al eliminar la disciplina: ' || SQLERRM);
END;