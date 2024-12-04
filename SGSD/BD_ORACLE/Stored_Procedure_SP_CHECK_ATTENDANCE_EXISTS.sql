create or replace PROCEDURE sp_check_attendance_exists (
    p_discipline_id IN NUMBER,
    p_attendance_date IN DATE,
    p_exists OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM Attendance
    WHERE discipline_id = p_discipline_id
    AND TRUNC(attendance_date) = TRUNC(p_attendance_date);
EXCEPTION
    WHEN OTHERS THEN
        p_exists := 0;
END;