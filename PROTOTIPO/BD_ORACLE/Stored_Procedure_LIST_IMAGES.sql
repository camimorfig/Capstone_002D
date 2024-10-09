create or replace procedure sp_list_images (list_images out SYS_REFCURSOR) is
BEGIN
    open list_images for SELECT * 
    from galery
    where galery_front_page = 0;

end;