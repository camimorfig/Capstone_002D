create or replace procedure sp_list_images_discipline (list_images_dis out SYS_REFCURSOR, v_discipline_id VARCHAR2) is
BEGIN
    open list_images_dis for SELECT * 
    from galery_discipline
    where galery_dis_status = 1 and discipline_id = v_discipline_id ;

end;