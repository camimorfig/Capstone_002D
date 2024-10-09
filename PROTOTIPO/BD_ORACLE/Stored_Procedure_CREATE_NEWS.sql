create or replace PROCEDURE sp_create_news(
    
    p_news_name VARCHAR2,
    
    p_news_description VARCHAR2,
    p_news_img BLOB,
    v_news_status NUMBER,

    p_salida OUT NUMBER
) AS
    p_news_date DATE;

BEGIN

    p_news_date:= SYSDATE;

    INSERT INTO news (
        news_name,
        news_status,
        news_description,
        news_date,
        news_img
    ) VALUES (
        p_news_name,
        v_news_status,
        p_news_description,       
        p_news_date,
        p_news_img
    );

    -- Si la inserción fue exitosa, se asigna 1 a la variable de salida
    p_salida := 1;
    commit;
EXCEPTION
    -- En caso de error, se asigna 0 a la variable de salida
    WHEN OTHERS THEN
        p_salida := 0;
        RAISE;
END;

