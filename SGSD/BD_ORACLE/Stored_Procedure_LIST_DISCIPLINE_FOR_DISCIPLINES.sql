create or replace procedure sp_list_discipline_for_disciplines (list_discipline_for_disciplines out SYS_REFCURSOR, 
v_discipline_id VARCHAR2 ) is
BEGIN
    open list_discipline_for_disciplines for SELECT * 
    from discipline
    WHERE discipline_id = v_discipline_id;
end;