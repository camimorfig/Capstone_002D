create or replace procedure sp_list_news_index (list_news out SYS_REFCURSOR) is
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
    order by news_id desc
    FETCH FIRST 2 ROWS ONLY;

end;