---- MAIN_USER ----
DROP TABLE Main_User CASCADE CONSTRAINTS;
DROP TABLE Coach CASCADE CONSTRAINTS;
DROP TABLE Admin CASCADE CONSTRAINTS;
--------------------

---- OTHER FUNCTIONS ----
DROP TABLE Contact CASCADE CONSTRAINTS;
DROP TABLE Galery CASCADE CONSTRAINTS;
DROP TABLE Events CASCADE CONSTRAINTS;
DROP TABLE News CASCADE CONSTRAINTS;
--------------------------

---- PLAYER DATA ----
DROP TABLE Discipline CASCADE CONSTRAINTS;
DROP TABLE Game_Position CASCADE CONSTRAINTS;
DROP TABLE Player CASCADE CONSTRAINTS;
DROP TABLE Attendance CASCADE CONSTRAINTS;
DROP TABLE Statistic CASCADE CONSTRAINTS;
DROP TABLE Team_Roster CASCADE CONSTRAINTS;
--------------------

---- ELITE THLETE DATA ----
DROP TABLE Elite_Athlete CASCADE CONSTRAINTS;
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
    
----------------------------------------------------------
--  DDL for COACH
----------------------------------------------------------   
CREATE TABLE Coach (
    coach_id VARCHAR(20) NOT NULL ,
    coach_name VARCHAR(50) NOT NULL,
    coach_img blob,
---- USER ID ----
    user_id INT NOT NULL,
----

   CONSTRAINT pk_Coach PRIMARY KEY (coach_id)
);

----------------------------------------------------------
--  DDL for ADMIN
----------------------------------------------------------   
CREATE TABLE Admin (
    admin_id VARCHAR(20) NOT NULL ,
    admin_name VARCHAR(50) NOT NULL,
    admin_img blob,
---- USER ID ----
    user_id INT NOT NULL,
----

   CONSTRAINT pk_Admin PRIMARY KEY (admin_id)
);

     ------------------------------
    --------- ALTER COACH ----------
     ------------------------------
     
ALTER TABLE Coach
	 ADD CONSTRAINT Coach_Main_User_fk FOREIGN KEY (user_id)
	  REFERENCES Main_User (user_id);

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
    ---- ADMIN ID ----
    admin_id VARCHAR(20) NOT NULL,
    ----

   CONSTRAINT pk_Contact PRIMARY KEY (contact_id)
);

----------------------------------------------------------
--  DDL for GALERY
----------------------------------------------------------   
CREATE TABLE Galery (
    galery_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    galery_img blob NOT NULL,
    galery_status VARCHAR(50) NOT NULL,
    galery_description VARCHAR(100),

   CONSTRAINT pk_Galery PRIMARY KEY (galery_id)
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
          ----------------------------- PLAYER DATA -----------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------
                
--------------------------------------------------------
--  DDL for DISCIPLINE
--------------------------------------------------------
CREATE  TABLE Discipline (
   discipline_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
   discipline_name VARCHAR(50) NOT NULL,
   discipline_description VARCHAR(500) NOT NULL,
---- COAHC DATA ----
    coach_id VARCHAR(20) NOT NULL,
----   
   
   CONSTRAINT pk_Discipline PRIMARY KEY (discipline_id)
);

--------------------------------------------------------
--  DDL for GAME_POSITION
--------------------------------------------------------
CREATE  TABLE Game_Position (
   game_position_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
   game_position_name VARCHAR(50) NOT NULL,

   CONSTRAINT pk_Game_Position PRIMARY KEY (game_position_id)
);

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
---- IDs ----
    discipline_id INT NOT NULL,
    game_position_id INT NOT NULL,    
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
CREATE  TABLE Team_Roster (
    team_roster_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    team_roster_date DATE NOT NULL,
---- player data ----
    player_id int NOT NULL,
--------------------

   CONSTRAINT pk_Team_Roster PRIMARY KEY (team_roster_id)
);

     ------------------------------
    ------ ALTER DISCIPLINE --------
     ------------------------------
     
ALTER TABLE Discipline
	 ADD CONSTRAINT Discipline_Coach_fk FOREIGN KEY (coach_id)
	  REFERENCES Coach (coach_id);

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

                -------------------------------------------------------------
            -------------------------------------------------------------------
          -------------------------- ELITE THLETE DATA --------------------------
            -------------------------------------------------------------------             
                -------------------------------------------------------------
                
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
    
                ----------------------------
             ------------------------------------
            --              INSERT              --     
             ------------------------------------
                ----------------------------    
                
    
-----------------------------------------------
----------------USER-----------------------
-----------------------------------------------      
INSERT INTO Main_User (email, password, user_type) VALUES ('gu.burgos@duocuc.cl','pbkdf2_sha256$870000$J0J33BXdyXe8pfXZDDAUpg$mymvPrQJReIL6DUdVju9RMKcPJAVzCkejK6dFbUO+bY=','admin01');
INSERT INTO Main_User (email, password, user_type) VALUES ('gustav@duocuc.cl','pbkdf2_sha256$870000$J0J33BXdyXe8pfXZDDAUpg$mymvPrQJReIL6DUdVju9RMKcPJAVzCkejK6dFbUO+bY=','coach01');
INSERT INTO Main_User (email, password, user_type) VALUES ('pati@duocuc.cl','pbkdf2_sha256$870000$fj1dS3moZBgOgOyLUWjbkr$GazdavvLLIQR9TjJWvXKDk01qX3msCpZUOSpRIw/kVQ=','coach01');
---------------------------------------

-----------------------------------------------
----------------ADMIN-----------------------
-----------------------------------------------      
INSERT INTO Admin (admin_id, admin_name, user_id) VALUES ('20824912-6','Gustavo Burgos Admin',1);
---------------------------------------

ALTER TABLE Main_User
ADD last_login TIMESTAMP;

ALTER TABLE Main_User
ADD date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP;


-----------------------------------------------
----------------COACH-----------------------
-----------------------------------------------  
--INSERT INTO Coach (coach_id, coach_name, user_id) VALUES ('12345678-9','Gustavo Burgos Entrenador',2);
---------------------------------------

-----------------------------------------------
----------------DISCIPLINE-----------------------
-----------------------------------------------  
--INSERT INTO Discipline (discipline_name, discipline_description, coach_id) VALUES ('Ajedrez','El ajedrez es un juego de tablero entre dos contrincantes en el que cada uno dispone al inicio de dieciséis piezas móviles, desiguales en importancia y valor, que se desplazan sobre un tablero capturando piezas del jugador contrario. El objetivo final del juego consiste en “derrocar al rey” del oponente.','12345678-9');
--
--INSERT INTO Discipline (discipline_name, discipline_description, coach_id) VALUES ('Tenis','El tenis es un deporte que se disputa entre dos jugadores (individuales) o entre dos parejas (dobles). El objetivo principal del juego es lanzar una pelota golpeándola con la raqueta de modo que rebote en el otro lado pasando la red dentro de los límites permitidos del campo del rival, procurando que este no pueda devolverla para conseguir un segundo rebote en el suelo y darle un punto','12345678-9');
---------------------------------------

     ------------------------------
    ---------- ALTER MAIN_USER ----------
     ------------------------------



commit;
      