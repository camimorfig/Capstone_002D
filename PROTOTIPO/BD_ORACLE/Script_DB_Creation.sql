---- MAIN_USER ----
DROP TABLE Main_User CASCADE CONSTRAINTS;
--------------------

---- ADMIN ----
DROP TABLE Admin CASCADE CONSTRAINTS;
--------------------------

---- COACH ----
DROP TABLE Discipline CASCADE CONSTRAINTS;
DROP TABLE Coach_Type CASCADE CONSTRAINTS;
DROP TABLE Coach CASCADE CONSTRAINTS;
DROP TABLE Coach_Discipline CASCADE CONSTRAINTS;
--------------------------

---- OTHER FUNCTIONS ----
DROP TABLE Contact CASCADE CONSTRAINTS;
DROP TABLE Events CASCADE CONSTRAINTS;
DROP TABLE News CASCADE CONSTRAINTS;
--------------------------

---- GALERYS ----
DROP TABLE Galery_General CASCADE CONSTRAINTS;
DROP TABLE Galery_Discipline CASCADE CONSTRAINTS;
DROP TABLE Galery_Front CASCADE CONSTRAINTS;

--------------------------

---- PLAYER DATA ----
DROP TABLE Player CASCADE CONSTRAINTS;
DROP TABLE Attendance_Status CASCADE CONSTRAINTS;
DROP TABLE Attendance CASCADE CONSTRAINTS;
DROP TABLE Statistic CASCADE CONSTRAINTS;
DROP TABLE Team_Roster CASCADE CONSTRAINTS;
--------------------

---- OTHER DATA ----
DROP TABLE Status_Type CASCADE CONSTRAINTS;
DROP TABLE Requests CASCADE CONSTRAINTS;
--------------------

                -------------------------------------------------------------
            -------------------------------------------------------------------
          ------------------------------ USER DATA ------------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------

--------------------------------------------------------
--  DDL for MAIN_USER
--------------------------------------------------------
CREATE TABLE Main_User (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    user_type VARCHAR(50) NOT NULL,

    -- Campos booleanos simulados
    -- 1 = True, 0 = False
    is_active NUMBER(1) DEFAULT 1 NOT NULL,  
    is_staff NUMBER(1) DEFAULT 0 NOT NULL,   
    is_superuser NUMBER(1) DEFAULT 0 NOT NULL, 
    CONSTRAINT pk_User PRIMARY KEY (user_id)
);


                -------------------------------------------------------------
            -------------------------------------------------------------------
          ------------------------------ COACH DATA ------------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------

--------------------------------------------------------
--  DDL for DISCIPLINE
--------------------------------------------------------
CREATE  TABLE Discipline (
   discipline_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
   discipline_name VARCHAR(50) NOT NULL,
   discipline_description VARCHAR(500) NOT NULL,
   galery_img blob,

 
   
   CONSTRAINT pk_Discipline PRIMARY KEY (discipline_id)
);

--------------------------------------------------------
--  DDL for COACH_TYPE
--------------------------------------------------------
CREATE  TABLE Coach_Type (
   coach_type_id INT NOT NULL,
   coach_type_name VARCHAR(100) NOT NULL,
   coach_type_description VARCHAR(2000),
 
   
   CONSTRAINT pk_Coach_Type PRIMARY KEY (coach_type_id)
);
 
----------------------------------------------------------
--  DDL for COACH
----------------------------------------------------------   
CREATE TABLE Coach (
    coach_id VARCHAR(20) NOT NULL ,
    coach_name VARCHAR(100) NOT NULL,
    coach_img blob,
---- USER AND DISCIPLINE FOREAN KEY----
    user_id INT NOT NULL,
    coach_type_id INT NOT NULL,
----

   CONSTRAINT pk_Coach PRIMARY KEY (coach_id)

);

--------------------------------------------------------
--  DDL for DISCIPLINE_LIST
--------------------------------------------------------
CREATE  TABLE Coach_Discipline (   
   coach_id VARCHAR(20) NOT NULL REFERENCES Coach(coach_id),
   discipline_id INTEGER NOT NULL REFERENCES Discipline(discipline_id),

   CONSTRAINT pk_Coach_Discipline PRIMARY KEY (coach_id, discipline_id)
);
     ------------------------------
    --------- ALTER COACH ----------
     ------------------------------
     
ALTER TABLE Coach
	 ADD CONSTRAINT Coach_Main_User_fk FOREIGN KEY (user_id)
	  REFERENCES Main_User (user_id);
      
ALTER TABLE Coach
	 ADD CONSTRAINT Coach_Coach_Type_fk FOREIGN KEY (coach_type_id)
	  REFERENCES Coach_Type (coach_type_id);      
   
                -------------------------------------------------------------
            -------------------------------------------------------------------
          ------------------------------ ADMIN DATA ------------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------
                
----------------------------------------------------------
--  DDL for ADMIN
----------------------------------------------------------   
CREATE TABLE Admin (
    admin_id VARCHAR(20) NOT NULL ,
    admin_name VARCHAR(50) NOT NULL,
    admin_img blob,
---- USER FOREAN KEY ----
    user_id INT NOT NULL,
----

   CONSTRAINT pk_Admin PRIMARY KEY (admin_id)
);


     ------------------------------
    --------- ALTER ADMIN ----------
     ------------------------------
     
ALTER TABLE Admin
	 ADD CONSTRAINT Admin_Main_User_fk FOREIGN KEY (user_id)
	  REFERENCES Main_User (user_id);    

                -------------------------------------------------------------
            -------------------------------------------------------------------
          ------------------------------ OTHER FUNCTIONS ------------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------


----------------------------------------------------------
--  DDL for CONTACT
----------------------------------------------------------   
CREATE TABLE Contact (
    contact_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    contact_name VARCHAR(50) NOT NULL,
    contact_email VARCHAR(50) NOT NULL,
    contact_description VARCHAR(2000) NOT NULL,
    ---- ADMIN FOREAN KEY ----
    admin_id VARCHAR(20) NOT NULL,
    ----

   CONSTRAINT pk_Contact PRIMARY KEY (contact_id)
);

----------------------------------------------------------
--  DDL for EVENTS
----------------------------------------------------------   
CREATE TABLE Events (
    events_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    events_name VARCHAR(50) NOT NULL,
    events_status VARCHAR(50) NOT NULL,
    events_start DATE NOT NULL,
    events_end DATE NOT NULL,
    events_description VARCHAR(100),

   CONSTRAINT pk_Events PRIMARY KEY (events_id)
);

----------------------------------------------------------
--  DDL for NEWS
----------------------------------------------------------   
CREATE TABLE News (
    news_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    news_name VARCHAR(50) NOT NULL,
    news_status VARCHAR(50) NOT NULL,
    news_description VARCHAR(500),    
    news_date DATE NOT NULL,
    news_img blob,
    news_tag VARCHAR(50) NOT NULL,

   CONSTRAINT pk_News PRIMARY KEY (news_id)
);

     ------------------------------
    --------- ALTER CONTACT ----------
     ------------------------------
     
ALTER TABLE Contact
	 ADD CONSTRAINT Contact_Admin_fk FOREIGN KEY (admin_id)
	  REFERENCES Admin (admin_id); 
      
   
   
      
                -------------------------------------------------------------
            -------------------------------------------------------------------
          ----------------------------- GALERYS -----------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------      
     
  
   
      
----------------------------------------------------------
--  DDL for GALERY_GENERAL
----------------------------------------------------------   
CREATE TABLE Galery_General(
    galery_gen_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    galery_gen_img blob NOT NULL,
    galery_gen_tag VARCHAR(50),
    galery_gen_status NUMBER NOT NULL,
    galery_gen_date DATE,
    
   CONSTRAINT pk_Galery_General PRIMARY KEY (galery_gen_id)
);
      
      
----------------------------------------------------------
--  DDL for GALERY_DISCIPLINE
----------------------------------------------------------   
CREATE TABLE Galery_Discipline (
    galery_dis_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    galery_dis_img blob NOT NULL,
    galery_dis_status NUMBER NOT NULL,
    galery_dis_tag VARCHAR(50),
    galery_dis_date DATE,
    ---- ADMIN FOREAN KEY ----
    discipline_id INT,
    ----
   CONSTRAINT pk_Galery_Discipline PRIMARY KEY (galery_dis_id)
);      
      
     ------------------------------
    --------- ALTER GALERY_DISCIPLINE ----------
     ------------------------------
     
ALTER TABLE Galery_Discipline
	 ADD CONSTRAINT Galery_Discipline_Discipline_fk FOREIGN KEY (discipline_id)
	  REFERENCES Discipline (discipline_id);         
 
      
----------------------------------------------------------
--  DDL for GALERY_FRONT
----------------------------------------------------------   
CREATE TABLE Galery_Front (
    galery_front_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    galery_front_img blob NOT NULL,
    galery_front_status NUMBER NOT NULL,
    galery_front_title VARCHAR(100),
    galery_front_description VARCHAR(200),
    galery_front_place VARCHAR(200),
    galery_front_date DATE,

   CONSTRAINT pk_Galery_Front PRIMARY KEY (galery_front_id)
);      
      
      
                -------------------------------------------------------------
            -------------------------------------------------------------------
          ----------------------------- PLAYER DATA -----------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------

--------------------------------------------------------
--  DDL for PLAYER
--------------------------------------------------------
CREATE TABLE Player (
    player_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    player_rut VARCHAR(13)NOT NULL,
    player_name VARCHAR(50) NOT NULL,
    player_last_name VARCHAR(50) NOT NULL,
    player_headquarters VARCHAR(50),
    player_career VARCHAR(30) NOT NULL,
    player_img blob,
    player_status VARCHAR(30) NOT NULL,
    player_horary VARCHAR(30) NOT NULL,
    player_birthday DATE NOT NULL,
---- IDs ----
    discipline_id INT NOT NULL,
----         
    
    CONSTRAINT pk_Player PRIMARY KEY (player_id)
);

--------------------------------------------------------
--  DDL for ATTENDANCE
--------------------------------------------------------

CREATE TABLE Attendance_Status (
    status_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    status_name VARCHAR(20) NOT NULL,  -- 'present', 'absent', 'justified'
    status_description VARCHAR(100),
    CONSTRAINT pk_Attendance_Status PRIMARY KEY (status_id)
);

--------------------------------------------------------
--  DDL for ATTENDANCE
--------------------------------------------------------
CREATE TABLE Attendance (
    attendance_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    attendance_date DATE NOT NULL,
    attendance_comments VARCHAR(200),
    creation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Llaves foráneas
    player_id INT NOT NULL,
    discipline_id INT NOT NULL,
    status_id INT NOT NULL,
    
    CONSTRAINT pk_Attendance PRIMARY KEY (attendance_id)
);


--------------------------------------------------------
--  DDL for STATISTIC   
--------------------------------------------------------
CREATE  TABLE Statistic (
   statistic_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
---- player data ----
    player_id int NOT NULL,
--------------------

   CONSTRAINT pk_Statistic PRIMARY KEY (statistic_id)
);

--------------------------------------------------------
--  DDL for TEAM_ROSTER   
--------------------------------------------------------
-- nomina de equipo
CREATE  TABLE Team_Roster (
    team_roster_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    team_roster_date DATE NOT NULL,
---- player data ----
    player_id int NOT NULL,
--------------------

   CONSTRAINT pk_Team_Roster PRIMARY KEY (team_roster_id)
);

     ------------------------------
    ------ ALTER PLAYER --------
     ------------------------------
     
ALTER TABLE Player
	 ADD CONSTRAINT Player_Discipline_fk FOREIGN KEY (discipline_id)
	  REFERENCES Discipline (discipline_id);

     ------------------------------
    ------ ALTER ATTENDANCE --------
     ------------------------------
     
ALTER TABLE Attendance
	 ADD CONSTRAINT Attendance_Player_fk FOREIGN KEY (player_id)
	  REFERENCES Player (player_id);

     ------------------------------
    ------ ALTER STATISTIC --------
     ------------------------------
     
ALTER TABLE Statistic
	 ADD CONSTRAINT Statistic_Player_fk FOREIGN KEY (player_id)
	  REFERENCES Player (player_id);

     ------------------------------
    ------ ALTER TEAM_ROSTER --------
     ------------------------------
     
ALTER TABLE Team_Roster
	 ADD CONSTRAINT Team_Roster_Player_fk FOREIGN KEY (player_id)
	  REFERENCES Player (player_id);

--------------------------------------------------------
--  DDL for PLAYER
--------------------------------------------------------

                -------------------------------------------------------------
            -------------------------------------------------------------------
          -------------------------- OTHER DATA --------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------


--------------------------------------------------------
--  DDL for REQUESTS
--------------------------------------------------------               

CREATE TABLE Requests (
    request_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    coach_name VARCHAR(100) NOT NULL,
    player_rut VARCHAR(13)NOT NULL,
    player_name VARCHAR(50) NOT NULL,
    player_last_name VARCHAR(50) NOT NULL,
    discipline_name VARCHAR(50) NOT NULL,
    player_headquarters VARCHAR(50),
    player_career VARCHAR(30) NOT NULL,
    request_status VARCHAR(30) NOT NULL,
    request_date DATE NOT NULL,
    
---- USER AND DISCIPLINE FOREAN KEY----
    coach_id VARCHAR(20) NOT NULL,
----
 
   CONSTRAINT pk_Requests PRIMARY KEY (request_id)
);

    ALTER TABLE Requests
    ADD CONSTRAINT Requests_Coach_fk FOREIGN KEY (coach_id)
    REFERENCES Coach (coach_id);      

--------------------------------------------------------
--  DDL for STATUS_TYPE
--------------------------------------------------------
CREATE  TABLE Status_Type (
   status_id INT NOT NULL,
   status_type_name VARCHAR(100) NOT NULL,
    
   CONSTRAINT pk_status_type PRIMARY KEY (status_id)
);
 



                ----------------------------
             ------------------------------------
            --              INSERT              --     
             ------------------------------------
                ----------------------------    
                
    
-----------------------------------------------
----------------USER-----------------------
-----------------------------------------------      
    INSERT INTO Main_User (email, password, user_type) VALUES ('gu.burgos@duocuc.cl','pbkdf2_sha256$870000$J0J33BXdyXe8pfXZDDAUpg$mymvPrQJReIL6DUdVju9RMKcPJAVzCkejK6dFbUO+bY=','admin01');
---------------------------------------

-----------------------------------------------
----------------ADMIN-----------------------
-----------------------------------------------      
    INSERT INTO Admin (admin_id, admin_name, user_id) VALUES ('20824912-6','Gustavo Burgos Admin',1);
---------------------------------------

-----------------------------------------------
----------------ALTER ADMIN-----------------------
-----------------------------------------------   
    ALTER TABLE Main_User
    ADD last_login TIMESTAMP;

    ALTER TABLE Main_User
    ADD date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
---------------------------------------


-----------------------------------------------
----------------COACH_TYPE-----------------------
----------------------------------------------- 

    INSERT INTO Coach_Type (coach_type_id,coach_type_name)
    VALUES (1,'Entrenador');

    INSERT INTO Coach_Type (coach_type_id,coach_type_name)
    VALUES (2,'Preparador Físico');
    
---------------------------------------

-----------------------------------------------
----------------DISCIPLINE-----------------------
-----------------------------------------------  
    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Básquetbol Varones','El básquetbol es uno de los deportes más populares del mundo y uno de los más vistos. Es un deporte de equipo en el que dos equipos de cinco jugadores activos cada uno intentan anotar puntos entre sí lanzando una pelota a través de un aro de 300 cm de altura (la "canasta") bajo reglas establecidas.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Básquetbol Damas','El básquetbol es uno de los deportes más populares del mundo y uno de los más vistos. Es un deporte de equipo en el que dos equipos de cinco jugadores activos cada uno intentan anotar puntos entre sí lanzando una pelota a través de un aro de 300 cm de altura (la "canasta") bajo reglas establecidas.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Ajedrez','El ajedrez es un juego de tablero entre dos contrincantes en el que cada uno dispone al inicio de dieciséis piezas móviles, desiguales en importancia y valor, que se desplazan sobre un tablero capturando piezas del jugador contrario. El objetivo final del juego consiste en "derrocar al rey" del oponente.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Tenis de Mesa Varones','Consiste en un deporte de oposición, que se realiza en una mesa de juego, separando los dos campos por una red, con dos jugadores/as con sus raquetas respectivas y una bola que hay que pasar al campo contrario después de golpear la mesa. Se pierde el tanto cuando no se pasa la bola al campo contrario.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Tenis de Mesa Damas','Consiste en un deporte de oposición, que se realiza en una mesa de juego, separando los dos campos por una red, con dos jugadores/as con sus raquetas respectivas y una bola que hay que pasar al campo contrario después de golpear la mesa. Se pierde el tanto cuando no se pasa la bola al campo contrario.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Fútbol Varones','Se juega mediante una pelota que se debe desplazar a través del campo con cualquier parte del cuerpo que no sean los brazos o las manos, y mayoritariamente con los pies (de ahí su nombre). El objetivo es introducirla dentro de la portería o arco contrario, acción que se denomina marcar un gol', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Futbolito Damas','El Futbolito es un deporte colectivo muy parecido al fútbol, presentando diferencias con respecto al terreno de juego, medidas de la cancha, medidas de la portería, peso y tamaño del balón y algunas reglas de juego. El Futbolito se juega entre dos equipos de 7 jugadores cada uno.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Futsal Varones','El Futsal es un deporte colectivo muy parecido al fútbol, presentando diferencias con respecto al terreno de juego, medidas de la cancha, medidas de la portería, peso y tamaño del balón y algunas reglas de juego. El Futbolito se juega entre dos equipos de 7 jugadores cada uno.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Futsal Damas','El Futsal es un deporte colectivo muy parecido al fútbol, presentando diferencias con respecto al terreno de juego, medidas de la cancha, medidas de la portería, peso y tamaño del balón y algunas reglas de juego. El Futbolito se juega entre dos equipos de 7 jugadores cada uno.', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Vóleibol Varones','El voleibol, simplemente voley, es un deporte donde dos equipos se enfrentan sobre un terreno de juego liso separados por una red central, tratando de pasar el balón por encima de la red hacia el suelo del campo contrario', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Vóleibol Damas','El voleibol, simplemente voley, es un deporte donde dos equipos se enfrentan sobre un terreno de juego liso separados por una red central, tratando de pasar el balón por encima de la red hacia el suelo del campo contrario', empty_blob());

    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Rugby Varones','Es un deporte de equipo en el que cada jugador puede darlo todo. El rugby es un deporte de equipo en el que se juegan quince jugadores por equipo. El objetivo del juego es apoyar la pelota detrás de la línea de try del oponente, en lo que se denomina el área de in-goal. El rugby se juega tanto con la pelota en la mano como con patadas .', empty_blob());
 
    INSERT INTO Discipline (discipline_name, discipline_description, galery_img)
    VALUES ('Deportista De Elite','Nuestros deportistas destacados que representan Duoc.', empty_blob());


---------------------------------------

-----------------------------------------------
----------------PLAYER-----------------------
-----------------------------------------------


    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (1, 'RICARDO IGNACIO', 'LEAL SALAS', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('24-10-1999', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (2, 'PABLO ANDRES', 'SAAVEDRA ALVAREZ', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('26-12-2002', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (3, 'LUIS', 'SILVA PEÑAILILLO', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('12-01-2002', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (4, 'JHETRO ALONSO', 'ESPINOZA MARIANI', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('25-08-1999', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (5, 'FREDDY GABRIEL', 'GALARZA RIOS', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('21-10-1998', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (6, 'ALAIN ANTOINE', 'SOUR TRASLAVIÑA', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('09-07-1995', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (7, 'TOMAS EDUARDO', 'SAAVEDRA MARTINEZ', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-05-2000', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (8, 'ALEJANDRO BENJAMIN', 'ORDENES VALENZUELA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('15-05-2000', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (9, 'SAMUEL ALEXIS', 'VALENZUELA MORENO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('15-02-2004', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (10, 'CESAR ANTONIO', 'JIMENEZ LERMANDA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('06-12-1998', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (11, 'CAMILO NICOLAS ARIEL', 'CHAPARRO RAMIREZ', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('15-01-1990', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (12, 'SEBASTIAN IGNACIO', 'JARA MALDONADO', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-11-2001', 'DD-MM-YYYY'), 3);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (13, 'MONSERRAT', 'AREVALO SILVA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('04-05-2000', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (14, 'GEORGETE ALEXANDRA', 'ARIAS ARIAS', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('12-06-1996', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (15, 'GRACE VALENTINA', 'ESPINA MARTINEZ', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-03-2003', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (16, 'PAZ ALEJANDRA', 'CARTES ALARCON', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('25-07-2002', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (17, 'AILINE MARCELA', 'GONZALEZ MELGAREJO', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('24-04-1998', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (18, 'ADRIANA BELEN', 'RIOS TORRES', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('27-08-2001', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (19, 'MACARENA NATHALY', 'CABRERA PENAILILLO', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('27-08-1990', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (20, 'VALENTINA', 'RIOS VALENZUELA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-11-2000', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (21, 'DANITZA BELEN', 'OLAVE OSORIO', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('05-12-1997', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (22, 'SABINA AMANDA', 'ZUÑIGA DIAZ', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('01-10-2002', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (23, 'ANA CONSUELO', 'VALENZUELA ARAYA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-09-2002', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (24, 'TAMARA', 'ELVEA CARRASCO', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('24-03-1997', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (25, 'ALONDRA DEL CARMEN', 'MARABOLI GONZALEZ', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-12-2000', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (26, 'VALENTINA ANTONIA', 'DE LA FUENTE ESPINOZA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-06-2004', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (27, 'ELIZABETH GABRIELA', 'ORELLANA ITURRIETA', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-05-2006', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (28, 'DANIELA VALENTINA', 'ROMAN FERNANDEZ', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-10-2002', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (29, 'STEFFI DEL ROSARIO', 'RETAMAL CANESSA', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-08-2000', 'DD-MM-YYYY'), 2);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (30, 'JAVIER ESTEBAN', 'BECERRA CONTRERAS', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-11-1995', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (31, 'CARLOS', 'DOMINGUEZ HERRERA', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('07-11-2003', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (32, 'BRYAN ALEXIS', 'MORALES OLEA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-03-2002', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (33, 'BRANCO JESUS', 'HUICHALAO DELGADO', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('07-07-2000', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (34, 'SERGIO ESTEBAN', 'PEREZ RIOS', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('19-08-2003', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (35, 'EDISSON ALEXSANDER', 'JOFRE VALENZUELA', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-05-2001', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (36, 'LUCAS ALONSO', 'FERNANDEZ ACEVEDO', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-07-2002', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (37, 'CESAR', 'VILLANUEVA RIOS', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('22-11-1998', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (38, 'GABRIEL JOSE', 'GONZALEZ LOPEZ', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('31-08-2001', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (39, 'SEBASTIAN', 'GONZALEZ PEÑA', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-04-2003', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (40, 'JOSE GERMAN', 'MARTINEZ RETAMAL', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('16-06-2004', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (41, 'MATIAS ERNESTO', 'REYES MARINI', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('06-02-2006', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (42, 'CRISTIAN ALEJANDRO', 'ROJAS SUAREZ', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-09-2004', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (43, 'MARIO ERNESTO', 'CUBILLOS CABRERA', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-05-2004', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (44, 'IGNACIO ALEJANDRO', 'MORALES BRAMBILLA', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-12-2001', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (45, 'BENJAMIN', 'SOTO CAREAGA', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('22-03-2004', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (46, 'ARIEL ISAIAS', 'VALVERDE PAINE', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('05-04-2005', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (47, 'JOHAN ALBERTO', 'GALLARDO JERVIS', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('05-12-1998', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (48, 'DIEGO', 'PLAZA GONZALEZ', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-03-2003', 'DD-MM-YYYY'), 1);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (49, 'JULIAN ALONSO', 'BERNAL ARAUJO', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-02-2000', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (50, 'DENILSON REINALDO', 'CORTEZ CHAIMA', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('09-02-2002', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (51, 'MATIAS MAXIMILIANO', 'OSORIO SALAZAR', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('01-07-2003', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (52, 'NELSON IGNACIO', 'VENEGAS SANCHEZ', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('08-10-2004', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (53, 'NILAN LUKAS', 'TORREALBA JARA', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('19-07-2002', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (54, 'MATIAS NICOLAS', 'BAHAMONDEZ ROCO', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('02-05-2001', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (55, 'MATIAS IGNACIO', 'MALDONADO ACEVEDO', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-01-2002', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (56, 'FRANCO ALEJANDRO', 'ALVAREZ MUNOZ', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-10-2001', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (57, 'LUKAS HECTOR', 'SANCHEZ ACUÑA', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('11-01-1999', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (58, 'IVAN ARIEL', 'BARRERA PEREZ', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('02-04-1996', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (59, 'JUAN LUIS', 'CUEVAS QUERALTO', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('22-03-2002', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (60, 'JOAQUIN', 'JARA MARIN', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('08-06-2003', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (61, 'MATIAS JESUS', 'AGUILAR ASTUDILLO', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-10-2005', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (62, 'MARTIN ESTEBAN', 'OSSES LOMBARDI', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('18-01-2003', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (63, 'GUILLERMO', 'MALUENDA TORRES', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('06-03-2002', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (64, 'ROCKO ANTONIO', 'FUENTES REYES', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('14-12-2001', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (65, 'TOMAS IGNACIO', 'MUNOZ FAUNDEZ', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-12-2001', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (66, 'JOSE IGNACIO', 'FUENTES THOMAS', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('15-01-2001', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (67, 'CRISTHIAN ISAIAS', 'SELMAN OSORIO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('01-03-2003', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (68, 'JAVIER ALFREDO', 'ARAVENA AVILES', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('13-03-2006', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (69, 'JORGE ALEX JULIO', 'AHUMADA GONZALES', 'PLAZA OESTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('26-11-2005', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (70, 'VICENTE GABRIEL', 'CABRERA TORRES', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('15-03-1999', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (71, 'THOMAS', 'ZANARTU ALZERRECA', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('26-12-2000', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (72, 'JAIRO EMMANUEL', 'ESPINOZA TORRES', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('26-01-2005', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (73, 'VICENTE', 'RIOS RAMIREZ', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('30-09-2004', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (74, 'CHRISTIAN FERNANDO', 'BURGOS VASQUEZ', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-06-1999', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (75, 'LUCIANO BENJAMIN', 'CARCAMO GALLEGOS', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('09-06-2004', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (76, 'NICOLAS RODRIGO', 'JIMENEZ SAN MARTIN', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('22-09-1999', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (77, 'MARCOS FRANCISCO', 'SAN MARTIN LAGOS', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('08-04-2004', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (78, 'LUIS IGNACIO', 'VARGAS VARGAS', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('16-09-2003', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (79, 'LUCAS MATIAS', 'ULLOA GAETE', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-04-1999', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (80, 'CRISTOBAL IGNACIO', 'OLIVARES SOTO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('25-09-2001', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (81, 'LUCAS IVAN', 'VALDES JIMENEZ', 'MELIPILLA', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('23-10-2004', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (82, 'MATIAS JAVIER', 'RODRIGUEZ VILLANUEVA', 'MELIPILLA', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('17-01-2005', 'DD-MM-YYYY'), 6);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (83, 'PATRICIA ISIDORA MANE', 'GODOY MALDONADO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-07-2000', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (84, 'VALERIA RAYEN', 'MANRIQUEZ BRAVO', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-09-2000', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (85, 'CATALINA ANDREA', 'CASTILLO MULLER', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('05-09-2005', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (86, 'PAULINA', 'CARDENAS RETAMAL', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('02-12-2003', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (87, 'NISSI ESTEFANIA', 'VENEGAS DOMINGUEZ', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-07-1991', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (88, 'MILLARAY NALLELY', 'RAMIREZ SAAVEDRA', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('22-04-2002', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (89, 'ALMENDRA PAZ', 'ROMERO BASCUR', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('01-12-2004', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (90, 'ANTONIA BELEN', 'QUINTANILLA REYES', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-03-2002', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (91, 'PIA', 'FLORES GONZALEZ', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('30-10-2000', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (92, 'DANIELA DAYANA', 'RODRIGUEZ RODRIGUEZ', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('22-06-2004', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (93, 'FRANCESCA', 'GODOY BASTIAS', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-07-1992', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (94, 'PRYSCILA ALEJANDRA', 'ARANIBAR JIMENEZ', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('18-10-2003', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (95, 'MARIA JOSE', 'URRUTIA SANCHEZ', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('17-12-1993', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (96, 'CLAUDIA GABRIELA', 'HERRERA MUNOZ', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('24-06-1997', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (97, 'FERNANDA AILEN', 'JARAMILLO PARRA', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-05-2004', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (98, 'ROMINA TAMARA', 'ROBLES SANDOVAL', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-05-1996', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (99, 'TAMARA CATALINA', 'LILLO ZUÑIGA', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('22-02-2001', 'DD-MM-YYYY'), 7);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (100, 'ANTONIA BELEN', 'QUINTANILLA REYES', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-03-2002', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (101, 'JOSEFA VALERIA', 'GRANDON BARRERA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('27-08-2001', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (102, 'THIARE ANNAIS', 'VOURIO VALENZUELA', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('18-06-2001', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (103, 'PATRICIA ISIDORA MANE', 'GODOY MALDONADO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-07-2000', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (104, 'FERNANDA', 'RIVERA PARRA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('03-12-2001', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (105, 'MILLARAY', 'SALAMANCA ESPINOSA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-02-2002', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (106, 'ESKARLET ANGELICA', 'BONTA REYES', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('21-02-2004', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (107, 'SOFIA', 'SAEZ URRA', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-11-2001', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (108, 'DAMARI BELEN', 'VASQUEZ MELLA', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-09-2005', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (109, 'AYLINE IOMARA', 'BARRENECHEA AMPUERO', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('12-08-2001', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (110, 'CLAUDIA GABRIELA', 'HERRERA MUNOZ', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('24-06-1997', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (111, 'JASMINE CAMILA', 'URREA RIVERA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-07-1998', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (112, 'NATASHA ANDREA', 'OLMOS LARRE', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('15-05-2004', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (113, 'GABRIELA CECILIA', 'PEÑA LARA', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('05-01-1989', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (114, 'VALERIA RAYEN', 'MANRIQUEZ BRAVO', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-09-2000', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (115, 'MARIA JOSE', 'URRUTIA SANCHEZ', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('17-12-1993', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (116, 'ROMINA TAMARA', 'ROBLES SANDOVAL', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-05-1996', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (117, 'CAROLINA CECILIA', 'PLAZA GONZALEZ', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('19-01-2004', 'DD-MM-YYYY'), 9);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (118, 'EITHAN BENJAMIN', 'AVENDAÑO DIAZ', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('26-12-2002', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (119, 'FELIPE MATIAS', 'DIAZ GODOY', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-01-1999', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (120, 'FELIPE ALFONSO', 'RODRIGUEZ RODRIGUEZ', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('26-09-2000', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (121, 'CARLOS BASTIAN', 'TRONCOSO TAPIA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('31-03-2004', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (122, 'NICOLAS WLADIMIR', 'HENRIQUEZ  GOMEZ', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-11-2002', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (123, 'CRISTOFER DIEGO', 'REYES ESCOBAR', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('28-01-1992', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (124, 'CARLOS EDUARDO', 'ARAYA MORAGA', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('10-12-1991', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (125, 'FELIPE ANTONIO', 'VILLALOBOS VILLALOBOS', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('15-04-1996', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (126, 'DIEGO LUCIANO', 'POBLETE GODOY', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('08-07-2001', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (127, 'RODRIGO ALONSO', 'GUZMAN AHUMADA', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('02-08-2000', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (128, 'KEVIN ARIEL', 'MARTI TAPIA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('31-03-1998', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (129, 'MARCELO ANDRES', 'GUERRERO LEYTON', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('07-08-1998', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (130, 'CRISTIAN IGNACIO', 'TRONCOSO SANCHEZ', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('22-02-2005', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (131, 'YERKO', 'GARCIA MUÑOZ', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('24-09-1993', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (132, 'MARTIN GUSTAVO', 'MUNOZ VINALS', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-10-2003', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (133, 'IVAN', 'AGUAYO VARGAS', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-12-2004', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (134, 'NICOLAS ALEJANDO', 'CHACON CALFULAF', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('04-03-1999', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (135, 'BAYRON SEBASTIAN', 'SILVA OLIVARES', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('22-01-1997', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (136, 'BENJAMIN IGNACIO', 'CATALDO ARQUERO', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('01-06-2005', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (137, 'GEORGY FABIAN', 'FARIAS TUDELA', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('24-08-2001', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (138, 'DAVID EDUARDO', 'MOLINA OSORIO', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('16-12-2002', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (139, 'RAFAEL ANDRES', 'RIQUELME CABELLO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('01-06-2000', 'DD-MM-YYYY'), 8);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (140, 'SAMANTHA ROMINA', 'HERNANDEZ PINTO', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('16-03-2005', 'DD-MM-YYYY'), 5);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (141, 'CATALINA ALEJANDRA', 'BELLO GOMEZ', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('01-11-2001', 'DD-MM-YYYY'), 5);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (142, 'JAVIERA DENISSE', 'ORELLANA MUÑOZ', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('12-02-2001', 'DD-MM-YYYY'), 5);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (143, 'CONSUELO ANDREA', 'MEZA AYALA', 'MELIPILLA', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('03-06-2004', 'DD-MM-YYYY'), 5);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (144, 'VALENTINA ALEJANDRA', 'RIOS SALAZAR', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('15-04-2002', 'DD-MM-YYYY'), 5);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (145, 'ANDRES', 'MARTINEZ ARRIAGADA', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('18-09-2001', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (146, 'SEBASTIAN JESUS', 'CAROCA FELIU', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('25-11-1992', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (147, 'CLAUDIO ANTONIO', 'PALACIOS RUIZ', 'ALAMEDA', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('13-01-1992', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (148, 'TOMAS LEANDRO', 'CORNEJO HERNANDEZ', 'PLAZA OESTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('03-04-1998', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (149, 'MAURICIO ANTONIO', 'REVILLAR QUINTANA', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-07-2002', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (150, 'BAYRON JACOB', 'HURTADO LOBOS', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('18-01-1999', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (151, 'GONZALO IGNACIO', 'ROBLES SALITT', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-05-2000', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (152, 'LUIS ALEJANDRO', 'MARCANO CHACIN', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('19-09-2005', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (153, 'FELIPE MATIAS', 'ANTILLANCA QUINTRIQUEO', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-10-2002', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (154, 'JOAQUIN ALONSO', 'ORELLANA ASSIS', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-06-2003', 'DD-MM-YYYY'), 4);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (155, 'JAVIERA', 'FLORES COURT', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-09-2001', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (156, 'CONSTANZA BELEN', 'CORDOVA AILLAPAN', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('24-11-1998', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (157, 'BARBARA', 'DUQUE ORTEGA', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-12-2000', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (158, 'ROMINA BELEN', 'LAZO AGUERO', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('26-12-2000', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (159, 'ROMINA ALEJANDRA', 'LLANQUIN ARCOS', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('03-02-2003', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (160, 'TAMARA DEL CARMEN', 'MALDONADO SAAVEDRA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('05-01-1997', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (161, 'ANTONELLA PAZ', 'MORI MORENO', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('11-11-2001', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (162, 'RENATA BELEN', 'ORTEGA BECERRA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('05-05-2003', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (163, 'CAMILA', 'PEÑA CUADRA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('15-06-1998', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (164, 'ROMINA POULETTE', 'RIVAS MONTES', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('05-12-2000', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (165, 'ALEJANDRA ANDREA', 'SANDOVAL LAGOS', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-08-2001', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (166, 'VANNESA CATALINA', 'SILVA QUILALEO', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-08-2001', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (167, 'FERNANDA JESUS', 'SOTO VILLEGAS', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-01-2003', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (168, 'CATALINA ANTONIA', 'TOBAR QUIROZ', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('19-01-2001', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (169, 'GERALDYNNE SARAY', 'CASTILLO RODRIGUEZ', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('21-06-2004', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (170, 'JAVIERA IGNACIA', 'BARROS CERDA', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('17-08-2005', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (171, 'ROMINA BELEN', 'CRETTON RAMIREZ', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('30-09-2002', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (172, 'VALENTINA IGNACIA', 'GARRIDO ALBURQUENQUE', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('09-03-2003', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (173, 'ALEXANDRA ABRIL', 'VELIZ MENDOZA', 'PLAZA NORTE', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('18-04-2005', 'DD-MM-YYYY'), 11);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (174, 'ENRIQUE IGNACIO', 'ARANEDA MARIN', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-09-2001', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (175, 'ANGELO ZACARIAS', 'TAPIA PINA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-11-2002', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (176, 'IVAN', 'HUENTEMILLA MORENO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-12-1999', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (177, 'JOHAN ALEXANDER', 'PINO FIGUEROA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-07-2002', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (178, 'SEBASTIAN ISAIAS', 'AUAD MERCADO', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-05-2001', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (179, 'CRISTOBAL ANDRES', 'GODOY CABALLERO', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('04-07-2001', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (180, 'AARON ALBERTO', 'RIVEROS MORALES', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('25-03-2001', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (181, 'BRAYAN', 'DELGADO VERDUGO', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-08-2001', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (182, 'WILLIAMS', 'MARTINEZ NANCO', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('24-04-2002', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (183, 'BENJAMIN ALONSO', 'ALVAREZ JELDES', 'PLAZA VESPUCIO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('09-09-1998', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (184, 'HECTOR', 'MARTINEZ CARRASCO', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('09-10-1997', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (185, 'MANUEL', 'MADRID BAHAMONDES', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('12-12-1991', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (186, 'MAURICIO SEBASTIAN', 'QUINTANILLA CALFUMAN', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('28-07-2003', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (187, 'PABLO JAVIER', 'GODOY BARKER', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('08-11-1998', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (188, 'RENATO', 'ULLOA DIAZ', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('21-04-2003', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (189, 'NICKO MATEO', 'CORTES GONZALEZ', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-04-2001', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (190, 'GUSTAVO', 'SOTO CARDENAS', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('25-08-1994', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (191, 'IGNACIO ANDRES', 'SOTO ACEITUNO', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-07-2004', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (192, 'THOMAS', 'ACEVEDO QUEZADA', 'CAMPUS VIRTUAL', 
    'NO_REGISTRADO', empty_blob(), 1, 'O', 
    TO_DATE('29-12-2003', 'DD-MM-YYYY'), 10);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (193, 'TOMAS', 'BRICENO MATTHIES', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('24-11-1999', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (194, 'KIARA BELEN', 'HENRIQUEZ REYES', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-04-2000', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (195, 'JOSE JAVIER', 'MERA RODRIGUEZ', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('17-04-2003', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (196, 'PATRICK MAURICIO', 'SOTO VARELA', 'VIÑA DEL MAR', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('25-09-1999', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (197, 'FERNANDO DANIEL', 'SAAVEDRA SILVA', 'VIÑA DEL MAR', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('20-06-1997', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (198, 'FELIPE ANTONIO', 'ARAYA ROZAS', 'VIÑA DEL MAR', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-03-2002', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (199, 'BASTIAN EDGARD', 'IRRIBARRA POLLONI', 'VIÑA DEL MAR', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('14-01-1999', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (200, 'SEBASTIAN', 'VARGAS AGUILERA', 'VIÑA DEL MAR', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('13-11-2002', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (201, 'SEBASTIAN', 'GOMEZ ALVARADO', 'PUERTO MONTT', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('07-03-2000', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (202, 'ARACELY ANTONIA', 'QUIROZ PIZARRO', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('30-09-2004', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (203, 'LUCAS GUATAVO', 'PAVEZ GONZALEZ', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-03-2000', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (204, 'MARTIN', 'PINTO PARDO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('27-12-2000', 'DD-MM-YYYY'), 13);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (205, 'MARTIN ARIEL', 'ARAVENA HERNANDEZ', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('08-11-2003', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (206, 'IGNACIO ALEJANDRO', 'GONZALEZ NORAMBUENA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('20-04-2000', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (207, 'BALTAZAR EDUARDO', 'GARATE PARDO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('16-03-2005', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (208, 'MAURICIO JAVIER', 'CORTES CONEJEROS', 'PUENTE ALTO', 
    'NO_REGISTRADO', empty_blob(), 1, 'V', 
    TO_DATE('30-04-2001', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (209, 'MATIAS JAVIER', 'MONTENEGRO GONZALEZ', 'SAN CARLOS DE APOQUINDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('23-10-2002', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (210, 'RENATO', 'TANK DIAZ', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('02-01-2003', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (211, 'JAVIER IGNACIO', 'FLIES TRONCOSO', 'ANTONIO VARAS', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('16-10-2003', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (212, 'FERNANDO', 'VILLALOBOS BENAVIDES', 'SAN BERNARDO', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('10-11-2004', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (213, 'NESTOR NICOLAS', 'ALMAZABAL MORA', 'MAIPU', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('25-11-1998', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (214, 'JOSE SEBASTIAN', 'VASQUEZ ALFARO', 'SAN JOAQUIN', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('30-03-2001', 'DD-MM-YYYY'), 12);
    

    INSERT INTO PLAYER (PLAYER_RUT, PLAYER_NAME, PLAYER_LAST_NAME, PLAYER_HEADQUARTERS, 
    PLAYER_CAREER, PLAYER_IMG, PLAYER_STATUS, PLAYER_HORARY, PLAYER_BIRTHDAY, DISCIPLINE_ID)
    VALUES (215, 'BARBARA', 'SALINAS EGAÑA', 'PADRE ALONSO DE OVALLE', 
    'NO_REGISTRADO', empty_blob(), 1, 'D', 
    TO_DATE('29-11-2001', 'DD-MM-YYYY'), 7);
    

-----------------------------------------------
----------------Status_type-----------------------
-----------------------------------------------
    INSERT INTO Status_Type (status_id, Status_Type_name)
    VALUES (0,'Inactivo');

    INSERT INTO Status_Type (status_id, Status_Type_name)
    VALUES (1,'Activo');

-----------------------------------------------
----------------Attendance_Status-----------------------
-----------------------------------------------

INSERT INTO Attendance_Status (status_name, status_description) VALUES
    ('present', 'El jugador asistió a la actividad');
INSERT INTO Attendance_Status (status_name, status_description) VALUES 
    ('absent', 'El jugador no asistió a la actividad');
INSERT INTO Attendance_Status (status_name, status_description) VALUES
    ('justified', 'El jugador no asistió pero presentó justificación');
    
 
ALTER TABLE attendance     
    ADD CONSTRAINT fk_Attendance_Player FOREIGN KEY (player_id) 
        REFERENCES Player(player_id);

ALTER TABLE attendance     
    ADD CONSTRAINT fk_Attendance_Discipline FOREIGN KEY (discipline_id) 
        REFERENCES Discipline(discipline_id);
        
ALTER TABLE attendance     
    ADD CONSTRAINT fk_Attendance_Status FOREIGN KEY (status_id) 
        REFERENCES Attendance_Status(status_id);
    
commit;
      