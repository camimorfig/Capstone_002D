create or replace procedure sp_list_coach_type (list_coach_type out SYS_REFCURSOR) is
BEGIN
    open list_coach_type for SELECT * 
    from coach_type;

end;