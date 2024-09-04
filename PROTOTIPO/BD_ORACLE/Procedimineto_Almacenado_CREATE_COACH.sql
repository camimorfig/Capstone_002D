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
    INSERT INTO Coach (coach_id, coach_name, coach_img, user_id) 
    VALUES ('12345678-9','Gustavo Burgos Entrenador', empty_blob() ,2)
    RETURN Coach_img INTO l_blob;
    
    l_bfile := BFILENAME('IMG_OF_COACHS','GUSTAV.JPG');
    DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
    DBMS_LOB.loadblobfromfile (l_blob, l_bfile, l_lobmaxsize, l_dest_offset, l_src_offset);
    DBMS_LOB.fileclose(l_bfile);

    INSERT INTO Coach (coach_id, coach_name, coach_img, user_id) 
    VALUES ('98765432-1','Patricia Gonzalez', empty_blob() ,3)
    RETURN Coach_img INTO l_blobp;
    
    l_bfilep := BFILENAME('IMG_OF_COACHS','PATRICIA_G.JPG');
    DBMS_LOB.fileopen(l_bfilep, DBMS_LOB.file_readonly);
    DBMS_LOB.loadblobfromfile (l_blobp, l_bfilep, l_lobmaxsizep, l_dest_offsetp, l_src_offsetp);
    DBMS_LOB.fileclose(l_bfilep);


    INSERT INTO Discipline (discipline_name, discipline_description, coach_id)
    VALUES ('Ajedrez','El ajedrez es un juego de tablero entre dos contrincantes en el que cada uno dispone al inicio de dieciséis piezas móviles, desiguales en importancia y valor, que se desplazan sobre un tablero capturando piezas del jugador contrario. El objetivo final del juego consiste en “derrocar al rey” del oponente.','12345678-9');
    
    INSERT INTO Discipline (discipline_name, discipline_description, coach_id) 
    VALUES ('Tenis','El tenis es un deporte que se disputa entre dos jugadores (individuales) o entre dos parejas (dobles). El objetivo principal del juego es lanzar una pelota golpeándola con la raqueta de modo que rebote en el otro lado pasando la red dentro de los límites permitidos del campo del rival, procurando que este no pueda devolverla para conseguir un segundo rebote en el suelo y darle un punto','12345678-9');

    INSERT INTO Discipline (discipline_name, discipline_description, coach_id) 
    VALUES ('Natación','La natación es el arte de sostenerse y avanzar, usando los brazos y las piernas, sobre o bajo el agua.','98765432-1');

    
    COMMIT; 
END;