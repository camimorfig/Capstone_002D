CREATE OR REPLACE PROCEDURE sp_edit_coach(
    v_id_entrenador     VARCHAR2,
    v_img_entrenador    BLOB,
    v_nombre_entrenador VARCHAR2,
    p_discipline_json   CLOB, 
    v_id_tipo_entrenador NUMBER,

    v_salida            OUT NUMBER
) IS
    v_discipline_id NUMBER;
    v_json_list JSON_ARRAY_T;
BEGIN
    IF v_id_tipo_entrenador IS NOT NULL THEN

    -- Actualizar datos básicos del entrenador
    UPDATE coach 
    SET coach_name = v_nombre_entrenador,
        coach_img = v_img_entrenador,
        coach_type_id = v_id_tipo_entrenador
    WHERE coach_id = v_id_entrenador;
    
    else
    UPDATE coach 
    SET coach_name = v_nombre_entrenador,
        coach_img = v_img_entrenador
    WHERE coach_id = v_id_entrenador;
    END IF;

    -- Verificar si se envió una lista de disciplinas
    IF p_discipline_json IS NOT NULL AND JSON_ARRAY_T(p_discipline_json).get_size() > 0 THEN
        -- Eliminar disciplinas anteriores
        DELETE FROM coach_discipline WHERE coach_id = v_id_entrenador;

        -- Insertar nuevas disciplinas
        v_json_list := JSON_ARRAY_T(p_discipline_json);
        FOR i IN 0 .. v_json_list.get_size() - 1 LOOP
            v_discipline_id := v_json_list.get_number(i);
            INSERT INTO coach_discipline (coach_id, discipline_id)
            VALUES (v_id_entrenador, v_discipline_id);
        END LOOP;
    END IF;

    v_salida := 1;  -- Éxito
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        v_salida := 0;  -- Error
        ROLLBACK;
END;
