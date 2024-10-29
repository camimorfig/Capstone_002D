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
DROP TABLE Attendance CASCADE CONSTRAINTS;
DROP TABLE Statistic CASCADE CONSTRAINTS;
DROP TABLE Team_Roster CASCADE CONSTRAINTS;
DROP TABLE Elite_Athlete CASCADE CONSTRAINTS;
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
--    player_birthday DATE NOT NULL,
--    player_horary VARCHAR(30) NOT NULL,
---- IDs ----
    discipline_id INT NOT NULL,
    game_position_id INT,    
----         
    
    CONSTRAINT pk_Player PRIMARY KEY (player_id)
);

--------------------------------------------------------
--  DDL for ATTENDANCE
--------------------------------------------------------
CREATE  TABLE Attendance (
   attendance_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
   attendance_status VARCHAR(20) NOT NULL,
   attendance_date DATE NOT NULL,
   attendace_comments VARCHAR(200),
--- player data ----
    player_id int NOT NULL,
--------------------

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

ALTER TABLE Player
	 ADD CONSTRAINT Player_Game_Position_fk FOREIGN KEY (game_position_id)
	  REFERENCES Game_Position (game_position_id);

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
CREATE TABLE Elite_Athlete (
    elite_athlete_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    elite_athlete_name VARCHAR(100) NOT NULL,
    elite_athlete_headquarters VARCHAR(50),
    elite_athlete_descipline VARCHAR(30) NOT NULL,
    elite_athlete_description VARCHAR(100) NOT NULL, 
    elite_athlete_img blob,
    elite_athlete_career VARCHAR(30) NOT NULL,
    player_status VARCHAR(30) NOT NULL,         
    
    CONSTRAINT pk_Elite_Athlete PRIMARY KEY (elite_athlete_id)
);            

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
---------------------------------------

-----------------------------------------------
----------------DISCIPLINE-----------------------
-----------------------------------------------
    INSERT INTO Status_Type (status_id, Status_Type_name)
    VALUES (0,'Inactivo');

    INSERT INTO Status_Type (status_id, Status_Type_name)
    VALUES (1,'Activo');
    
commit;
      