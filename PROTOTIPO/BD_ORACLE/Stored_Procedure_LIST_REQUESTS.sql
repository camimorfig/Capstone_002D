create or replace NONEDITIONABLE procedure sp_list_request (list_request  out SYS_REFCURSOR) is
BEGIN
    open list_request  for select  
        request_id,
        coach_name,
        player_rut,
        player_name,
        player_last_name,
        discipline_name,
        player_headquarters,
        player_career,
        REPLACE(request_status, 1, 'En espera')AS "REQUEST_STATUS" ,
        request_date,
        coach_id    
    FROM requests
    where request_status = 1;

end;


