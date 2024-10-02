    create or replace  procedure sp_list_images_front_page (list_images_fp out SYS_REFCURSOR) is
BEGIN
    open list_images_fp for SELECT * 
    from galery
    where galery_front_page = 1;

end;