create or replace procedure sp_list_coach(list_coach out SYS_REFCURSOR) is
BEGIN
    open list_coach for SELECT 
        (SELECT ci.coach_img 
         FROM Coach ci 
         WHERE ci.coach_id = c.coach_id) AS coach_img,
        c.coach_name,
        u.email
    FROM 
        coach c    JOIN 
        main_user u ON c.user_id = u.user_id
    GROUP BY 
        c.coach_name, u.email, c.coach_id;

end;