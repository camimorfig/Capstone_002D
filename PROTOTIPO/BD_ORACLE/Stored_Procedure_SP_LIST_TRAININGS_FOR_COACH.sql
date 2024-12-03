CREATE OR REPLACE PROCEDURE "SP_LIST_TRAININGS_FOR_COACH" (
  list_trainings_coach OUT SYS_REFCURSOR,
  v_coach_id IN VARCHAR2
) IS
BEGIN
  OPEN list_trainings_coach FOR 
      SELECT 
          t.training_id,
          t.training_name,
          d.discipline_name,
          CASE TO_NUMBER(t.weekdays)
              WHEN 1 THEN 'Lunes'
              WHEN 2 THEN 'Martes'
              WHEN 3 THEN 'Miércoles'
              WHEN 4 THEN 'Jueves'
              WHEN 5 THEN 'Viernes'
              WHEN 6 THEN 'Sábado'
              WHEN 7 THEN 'Domingo'
              ELSE 'Desconocido'
          END as weekdays,
          TO_CHAR(t.start_time, 'HH24:MI') as start_time,
          TO_CHAR(t.end_time, 'HH24:MI') as end_time,
          d.discipline_id
      FROM training t
      JOIN discipline d ON (t.discipline_id = d.discipline_id)
      JOIN coach_discipline cd ON (d.discipline_id = cd.discipline_id)
      WHERE cd.coach_id = v_coach_id
      AND t.is_active = 1
      ORDER BY t.start_time;
END;