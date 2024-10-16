CREATE OR REPLACE PROCEDURE sp_aceptar_solicitud(

    p_request_id IN NUMBER
) AS

BEGIN
    UPDATE requests
    SET request_status = 0  -- 0 = 'Aceptada'
    WHERE request_id = p_request_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;