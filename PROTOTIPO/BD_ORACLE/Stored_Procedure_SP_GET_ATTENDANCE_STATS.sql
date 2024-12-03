CREATE OR REPLACE PROCEDURE sp_get_attendance_stats(
    p_discipline_id IN NUMBER DEFAULT NULL,
    p_training_id IN NUMBER DEFAULT NULL,
    p_period_id IN NUMBER DEFAULT NULL,
    p_result OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN p_result FOR
    WITH asistencia_diaria AS (
        SELECT 
            a.attendance_date,
            COUNT(*) as total_asistentes,
            SUM(CASE WHEN ast.status_name = 'present' THEN 1 ELSE 0 END) as presentes,
            SUM(CASE WHEN ast.status_name = 'absent' THEN 1 ELSE 0 END) as ausentes,
            SUM(CASE WHEN ast.status_name = 'justified' THEN 1 ELSE 0 END) as justificados,
            COUNT(DISTINCT a.player_id) as total_jugadores
        FROM attendance a
        JOIN attendance_status ast ON a.status_id = ast.status_id
        JOIN training t ON a.training_id = t.training_id
        WHERE 1=1
        AND (p_discipline_id IS NULL OR a.discipline_id = p_discipline_id)
        AND (p_training_id IS NULL OR a.training_id = p_training_id)
        AND (p_period_id IS NULL OR t.period_id = p_period_id)
        GROUP BY a.attendance_date
    )
    SELECT
        COUNT(DISTINCT attendance_date) as total_entrenamientos,
        ROUND(AVG(CAST(presentes AS FLOAT) / NULLIF(total_asistentes, 0) * 100), 2) as promedio_asistencia,
        MAX(CAST(presentes AS FLOAT) / NULLIF(total_asistentes, 0) * 100) as mejor_asistencia,
        MIN(CAST(presentes AS FLOAT) / NULLIF(total_asistentes, 0) * 100) as peor_asistencia,
        SUM(presentes) as total_presentes,
        SUM(ausentes) as total_ausentes,
        SUM(justificados) as total_justificados,
        COUNT(CASE WHEN CAST(presentes AS FLOAT) / NULLIF(total_asistentes, 0) = 1 THEN 1 END) as dias_100_asistencia,
        COUNT(CASE WHEN CAST(presentes AS FLOAT) / NULLIF(total_asistentes, 0) = 
            (SELECT MIN(CAST(presentes AS FLOAT) / NULLIF(total_asistentes, 0)) FROM asistencia_diaria)
        THEN 1 END) as dias_peor_asistencia
    FROM asistencia_diaria;
END;
/