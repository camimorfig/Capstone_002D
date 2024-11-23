create or replace procedure sp_create_disciplina(
    
    v_nombre      VARCHAR2,
    v_descripcion VARCHAR2,
    v_img         BLOB,
    
    v_salida out number
)
is

BEGIN

    INSERT into discipline(discipline_name, discipline_description, galery_img)
    VALUES(v_nombre,v_descripcion,v_img);
    commit;

    v_salida:=1;

    EXCEPTION

    when others then
        v_salida:=0;

end;