create or replace NONEDITIONABLE PROCEDURE sp_list_discipline_date_for_coach (
    list_discipline_coach OUT SYS_REFCURSOR,
    v_coach_id VARCHAR2
) IS
BEGIN
    OPEN list_discipline_coach FOR 
        SELECT 
            d.discipline_id,
            d.discipline_name,
            SYSDATE as current_date
        FROM discipline d 
        JOIN coach_discipline cd ON (d.discipline_id = cd.discipline_id)
        WHERE cd.coach_id = v_coach_id;
END;