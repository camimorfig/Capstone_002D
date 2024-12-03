create or replace procedure sp_list_coach(list_coach out SYS_REFCURSOR) is
BEGIN
    open list_coach for SELECT 
    (SELECT ci.coach_img 
     FROM Coach ci 
     WHERE ci.coach_id = c.coach_id) AS coach_img,
    c.coach_name,
    COALESCE(LISTAGG(d.discipline_name, ', ') WITHIN GROUP (ORDER BY d.discipline_name), 'Sin disciplina') AS discipline_list,
    u.email,
    c.coach_id,
    ct.coach_type_name
FROM 
    coach c
    JOIN main_user u ON c.user_id = u.user_id
    LEFT JOIN coach_discipline cd ON c.coach_id = cd.coach_id
    LEFT JOIN discipline d ON cd.discipline_id = d.discipline_id
    JOIN coach_type ct ON c.coach_type_id = ct.coach_type_id
GROUP BY 
    c.coach_name, u.email, c.coach_id, ct.coach_type_name;

end;

