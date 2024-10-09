create or replace procedure sp_list_news (list_news out SYS_REFCURSOR) is
BEGIN
    open list_news for SELECT * 
    from news
    where news_status = 0;

end;