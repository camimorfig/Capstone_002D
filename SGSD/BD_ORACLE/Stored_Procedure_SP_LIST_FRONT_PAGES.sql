create or replace procedure sp_list_front_pages (list_front_pages out SYS_REFCURSOR) is
BEGIN
    open list_front_pages for SELECT * 
    from galery_front
    where galery_front_status = 1;

end;