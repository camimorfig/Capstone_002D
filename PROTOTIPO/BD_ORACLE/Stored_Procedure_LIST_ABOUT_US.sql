create or replace procedure sp_list_coach(list_coach out SYS_REFCURSOR) is
BEGIN
    open list_coach for SELECT 
 
        (SELECT ci.coach_img 
         FROM Coach ci 
         WHERE ci.coach_id = c.coach_id) AS coach_img,
        c.coach_name,
        LISTAGG(d.discipline_name, ' y ') WITHIN GROUP (ORDER BY d.discipline_name) AS "LIST_OF_DISCIPLINE",
        u.user_email
    FROM 
        coach c 
    JOIN 
        discipline d ON c.coach_id = d.coach_id 
    JOIN 
        main_user u ON c.user_id = u.user_id
    GROUP BY 
        c.coach_name, u.user_email, c.coach_id;

end;
