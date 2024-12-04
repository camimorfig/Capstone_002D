create or replace procedure sp_list_images_general (list_images_general out SYS_REFCURSOR) is
BEGIN
    open list_images_general for SELECT * 
    from galery_general
    where galery_gen_status = 1;

end;