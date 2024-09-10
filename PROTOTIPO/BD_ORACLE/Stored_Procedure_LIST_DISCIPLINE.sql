create or replace procedure sp_list_discipline (list_discipline out SYS_REFCURSOR) is
BEGIN
    open list_discipline for SELECT * 
    from discipline;

end;