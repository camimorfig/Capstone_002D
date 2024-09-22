SET SERVEROUTPUT ON;

DECLARE
    l_bfile BFILE;
    l_bfilep BFILE;

    l_blob BLOB;
    l_blobp BLOB;    

    l_dest_offset INTEGER := 1;
    l_src_offset INTEGER := 1;

    l_dest_offsetp INTEGER := 1;
    l_src_offsetp INTEGER := 1;

    l_lobmaxsize CONSTANT INTEGER := DBMS_LOB.LOBMAXSIZE;

    l_lobmaxsizep CONSTANT INTEGER := DBMS_LOB.LOBMAXSIZE;
BEGIN
    INSERT INTO Coach (coach_id, coach_name, coach_img, user_id, discipline_id, coach_type_id) 
    VALUES ('12345678-9', 'Gustavo Burgos', empty_blob(), 2, 3, 1)
    RETURN Coach_img INTO l_blob;
    
    l_bfile := BFILENAME('IMG_OF_COACHS','GUSTAV.JPG');
    DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.loadblobfromfile (l_blob, l_bfile, l_lobmaxsize, l_dest_offset, l_src_offset);
    DBMS_LOB.fileclose(l_bfile);

    INSERT INTO Coach (coach_id, coach_name, coach_img, user_id, discipline_id, coach_type_id) 
    VALUES ('98765432-1','Patricia Gonzalez', empty_blob() ,3)
    RETURN Coach_img INTO l_blobp;
    
    l_bfilep := BFILENAME('IMG_OF_COACHS','PATRICIA_G.JPG');
    DBMS_LOB.fileopen(l_bfilep, DBMS_LOB.file_readonly);
    DBMS_LOB.loadblobfromfile (l_blobp, l_bfilep, l_lobmaxsizep, l_dest_offsetp, l_src_offsetp);
    DBMS_LOB.fileclose(l_bfilep);


    
    COMMIT; 
END;