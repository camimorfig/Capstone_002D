create or replace procedure sp_list_images_front (list_images_f out SYS_REFCURSOR) is
BEGIN
    open list_images_f for SELECT * 
    from galery_front
    where galery_front_status = 1;

end;