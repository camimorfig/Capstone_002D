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
    user_email VARCHAR(100) NOT NULL,
    user_pass VARCHAR(100) NOT NULL,
    user_type VARCHAR(50) NOT NULL,            
---- ID OF TYPES OF USERS ----    
    coach_id INT,
    admin_id INT,
----

    CONSTRAINT pk_User PRIMARY KEY (user_id)
);
    
----------------------------------------------------------
--  DDL for COACH
----------------------------------------------------------   
CREATE TABLE Coach (
    coach_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    coach_rut VARCHAR(20) NOT NULL,
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
    admin_id INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL ,
    admin_rut VARCHAR(20) NOT NULL,
    admin_name VARCHAR(50) NOT NULL,
    admin_img blob,
---- USER ID ----
    user_id INT NOT NULL,
----

   CONSTRAINT pk_Admin PRIMARY KEY (admin_id)
);

     ------------------------------
    ---------- ALTER MAIN_USER ----------
     ------------------------------


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
    contact_description VARCHAR(100) NOT NULL,
    ---- ADMIN ID ----
    admin_id INT NOT NULL,
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
    news_description VARCHAR(100),    
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
   discipline_description VARCHAR(200) NOT NULL,
---- COAHC DATA ----
    coach_id INT NOT NULL,
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
INSERT INTO Main_User (user_email, user_pass, user_type,admin_id) VALUES ('gu.burgos@duocuc.cl','124','admin01',1);
---------------------------------------
-----------------------------------------------

----------------ADMIN-----------------------
-----------------------------------------------      
INSERT INTO Admin (admin_rut, admin_name, user_id) VALUES ('20824912-6','Gustavo Burgos',1);
---------------------------------------
ALTER TABLE Main_User
	 ADD CONSTRAINT Main_User_Coach_fk FOREIGN KEY (coach_id)
	  REFERENCES Coach (coach_id);

ALTER TABLE Main_User
	 ADD CONSTRAINT Main_User_Admin_fk FOREIGN KEY (admin_id)
	  REFERENCES Admin (admin_id);


commit;
      