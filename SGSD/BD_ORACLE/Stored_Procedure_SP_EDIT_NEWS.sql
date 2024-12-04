create or replace PROCEDURE sp_edit_news(
    
    p_news_id number,
    p_news_name VARCHAR,
    p_news_description VARCHAR,
    p_news_date_string VARCHAR,
    p_news_img blob,
    p_news_tag VARCHAR,
    
    salida out number
) AS

v_news_date TIMESTAMP;  
BEGIN
    v_news_date := to_timestamp(p_news_date_string, 'YYYY-MM-DD HH24:MI:SS');


    UPDATE news
    set news_name = p_news_name,
        news_description = p_news_description,
        news_date = v_news_date,
        news_img = p_news_img,
        news_tag = p_news_tag
    
    WHERE news_id = p_news_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;