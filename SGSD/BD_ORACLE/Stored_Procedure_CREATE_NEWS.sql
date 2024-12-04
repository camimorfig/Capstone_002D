create or replace PROCEDURE sp_create_news(
    
    p_news_name VARCHAR2,
    
    p_news_description VARCHAR2,
    p_news_img BLOB,
    p_news_tag VARCHAR2,
    p_salida OUT NUMBER
) AS
    v_news_date DATE;
    v_news_status NUMBER;

BEGIN

    v_news_date:= SYSDATE;
    v_news_status:= 1; --1 = ACTIVE
    
    INSERT INTO news (
        news_name,
        news_status,
        news_description,
        news_date,
        news_img,
        news_tag
    ) VALUES (
        p_news_name,
        v_news_status,
        p_news_description,       
        v_news_date,
        p_news_img,
        p_news_tag
    );

    p_salida := 1;
    commit;
EXCEPTION

    -- En caso de error, se asigna 0 a la variable de salida
    WHEN OTHERS THEN
        p_salida := 0;
        RAISE;
END;
