create or replace procedure sp_list_contact (list_contact out SYS_REFCURSOR) is
BEGIN
    open list_contact for SELECT * 
    from contact;
end;