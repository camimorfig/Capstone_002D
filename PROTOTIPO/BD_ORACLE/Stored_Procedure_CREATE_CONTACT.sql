create or replace procedure sp_create_contact(
    v_nombre      VARCHAR2,
    v_email       VARCHAR2,
    v_descripcion VARCHAR2,

    v_salida out number
)
is
    v_id_admin   VARCHAR2(50);
    
BEGIN

    select admin_id 
    
    INTO v_id_admin  
    
    from admin;
    
    
    INSERT into contact(contact_name, contact_email, contact_description, admin_id)
    VALUES(v_nombre,v_email,v_descripcion,v_id_admin);
    commit;
    
    v_salida:=1;

    EXCEPTION

    when others then
        v_salida:=0;

end;