create or replace procedure sp_list_discipline (list_discipline out SYS_REFCURSOR) is
BEGIN
    open list_discipline for SELECT * 
    from discipline
    where discipline_id != 13
    order by discipline_name;

end;