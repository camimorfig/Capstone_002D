create or replace procedure sp_list_news_for_time (list_news out SYS_REFCURSOR) is
BEGIN
    open list_news for SELECT 
    news_id,
    news_name,
    news_status,
    news_description,
    news_date,
    news_img,
    news_tag
    
    
    from news
    where news_status = 1
    order by news_date desc;

end;