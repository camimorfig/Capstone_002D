create or replace PROCEDURE sp_delete_news(
    
    p_news_id number,
    
    salida out number   
) AS

BEGIN


    DELETE FROM news
    WHERE news_id = p_news_id;

    salida := 1; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN

        salida := 0;
        ROLLBACK;
        RAISE;

END;