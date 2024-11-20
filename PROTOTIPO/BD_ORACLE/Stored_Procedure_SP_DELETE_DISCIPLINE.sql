CREATE OR REPLACE PROCEDURE sp_delete_discipline(
    p_discipline_id IN NUMBER,
    
    salida OUT NUMBER   
) AS
BEGIN
    -- Primero eliminamos los registros de las tablas hijo
    
    DELETE FROM COACH_DISCIPLINE 
    WHERE DISCIPLINE_ID = p_discipline_id;
    
    DELETE FROM PLAYER 
    WHERE DISCIPLINE_ID = p_discipline_id;
    
    DELETE FROM EVENTS 
    WHERE DISCIPLINE_ID = p_discipline_id;
      
    DELETE FROM ATTENDANCE 
    WHERE DISCIPLINE_ID = p_discipline_id;
    
    DELETE FROM GALERY_DISCIPLINE 
    WHERE DISCIPLINE_ID = p_discipline_id;
    
    DELETE FROM PLAYER_ELITE 
    WHERE PLAYER_ELITE_DISCIPLINE = p_discipline_id;
    
    
    -- Al final eliminamos los registros en la tabla madre
    DELETE FROM DISCIPLINE
    WHERE DISCIPLINE_ID = p_discipline_id;
    
    salida := 1;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        salida := 0;
        ROLLBACK;
        -- Levantamos el error para poder verlo
        RAISE_APPLICATION_ERROR(-20001, 'Error al eliminar la disciplina: ' || SQLERRM);
END;
/