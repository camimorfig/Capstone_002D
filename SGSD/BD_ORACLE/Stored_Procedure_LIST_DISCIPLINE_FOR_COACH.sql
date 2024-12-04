create or replace procedure sp_list_discipline_for_coach (list_discipline_coach out SYS_REFCURSOR, 
v_coach_id VARCHAR2) 
is

BEGIN
    open list_discipline_coach for SELECT d.discipline_id,
    d.discipline_name

from discipline d join coach_discipline cd on (d.discipline_id = cd.discipline_id )

where cd.coach_id = v_coach_id;

end;