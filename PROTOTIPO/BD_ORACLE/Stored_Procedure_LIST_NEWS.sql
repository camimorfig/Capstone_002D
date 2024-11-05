create or replace procedure sp_list_news (list_news out SYS_REFCURSOR) is
BEGIN
    open list_news for SELECT 
    news_id,
    news_name,
    news_status,
    news_description,
    to_char(news_date,'dd/mm/yyyy'),
    news_img,
    news_tag
    
    
    from news
    where news_status = 1;

end;