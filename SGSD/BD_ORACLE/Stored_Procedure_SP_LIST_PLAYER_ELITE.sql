create or replace procedure sp_list_player_elite (list_player_elite out SYS_REFCURSOR) 
is

BEGIN
    open list_player_elite for SELECT *
    FROM player_elite;

end;