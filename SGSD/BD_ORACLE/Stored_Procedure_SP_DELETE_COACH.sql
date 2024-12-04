create or replace NONEDITIONABLE PROCEDURE sp_delete_coach(
    p_coach_id IN VARCHAR,
    salida OUT NUMBER
) AS

    v_main_user_id NUMBER;

    -- Cursor para usuarios
    CURSOR coach_discipline_cursor IS
        SELECT d.coach_id
        FROM COACH_DISCIPLINE d
        WHERE d.coach_id = p_coach_id;

BEGIN

    FOR cd_cursor IN coach_discipline_cursor LOOP
        DELETE FROM coach_discipline 
        WHERE coach_id = cd_cursor.coach_id;
    END LOOP;



    SELECT c.user_id
        INTO v_main_user_id
    FROM coach c
    WHERE c.coach_id = p_coach_id;

    DELETE FROM requests WHERE coach_id = p_coach_id;

    DELETE FROM coach WHERE coach_id = p_coach_id;

    DELETE FROM main_user WHERE user_id = v_main_user_id;


    salida := 1;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        salida := 0;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error al eliminar la disciplina: ' || SQLERRM);
END;