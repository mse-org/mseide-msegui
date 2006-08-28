SET CLIENT_ENCODING TO 'UTF8';
SET DATESTYLE TO 'German';

---------------------------------------------------------
create sequence feature_id_seq;
create table features (
  id integer default nextval('feature_id_seq'),
  descr text not null
);

insert into features (descr) values ('nasty');
insert into features (descr) values ('ill');
insert into features (descr) values ('tender');

insert into features (descr) values ('bizzare');
insert into features (descr) values ('atrocious');
insert into features (descr) values ('cunny');

insert into features (descr) values ('reliable');
insert into features (descr) values ('hard-working');
insert into features (descr) values ('lazy');

insert into features (descr) values ('nice');
insert into features (descr) values ('sexy');
insert into features (descr) values ('disgusting');

insert into features (descr) values ('traitrous');
insert into features (descr) values ('smart');
insert into features (descr) values ('dumb');

insert into features (descr) values ('mad');
insert into features (descr) values ('volatile');
insert into features (descr) values ('right');
---------------------------------------------------------
create sequence occupation_id_seq;
create table occupations (
  id integer default nextval('occupation_id_seq'),
  descr text not null
);

insert into occupations (descr) values ('precident');
insert into occupations (descr) values ('pirate');
insert into occupations (descr) values ('just good guy');

insert into occupations (descr) values ('a bad guy');
insert into occupations (descr) values ('actress/actor');
insert into occupations (descr) values ('producer');

insert into occupations (descr) values ('singer');
insert into occupations (descr) values ('mus.band');
insert into occupations (descr) values ('vampire');

insert into occupations (descr) values ('sportsman');
---------------------------------------------------------
create sequence planet_id_seq;
create table planets (
  id integer default nextval('planet_id_seq'),
  descr text not null
);
insert into planets (descr) values ('Earth');
insert into planets (descr) values ('Mars');
insert into planets (descr) values ('Merqury');
insert into planets (descr) values ('Pluton');
insert into planets (descr) values ('Jupiter');
insert into planets (descr) values ('Faeton');
---------------------------------------------------------
create sequence continent_id_seq;
create table continents (
  id integer default nextval('continent_id_seq'),
  planet_id integer,
  descr text not null
);

insert into continents (planet_id,descr) values (1,'Africa');
insert into continents (planet_id,descr) values (1,'Gondvana');
insert into continents (planet_id,descr) values (1,'Antartica');
insert into continents (planet_id,descr) values (1,'N.America');
insert into continents (planet_id,descr) values (1,'Asia');
insert into continents (planet_id,descr) values (1,'Europe');
---------------------------------------------------------
create sequence country_id_seq;
create table countries (
  id integer default nextval('country_id_seq'),
  continent_id integer,
  descr text not null
);

insert into countries (continent_id, descr) values (4,'USA');
insert into countries (continent_id, descr) values (5,'Iraqe');
insert into countries (continent_id, descr) values (6,'Finland');
insert into countries (continent_id, descr) values (6,'Sweeden');
insert into countries (continent_id, descr) values (6,'Germany');
insert into countries (continent_id, descr) values (5,'Uzbekistan');
---------------------------------------------------------
create sequence person_id_seq;
create table persons (
  id integer default nextval('person_id_seq'),
  feature_id integer,
  occupation_id integer,
  country_id integer,
  descr text not null,  
  sexual_potention float,
  photo bytea,
  if_happy boolean,
  dateofbirth date
 );
  

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (5,2,NULL,'F.Dreik',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention,dateofbirth) values (5,2,NULL,'c.Morgan',100.0,'29.12.1800');
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (18,2,NULL,'J.Blud', 0.0);

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'R.Reighan',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'J.Bush',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'S.Hussein',NULL);

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'I.Ghandy',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'J.Lopes',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention,if_happy,dateofbirth) values (10,5,2,'Sh.Fenn', 99.2,'t','01.03.1960');

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'H.Berry',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention,if_happy) values (NULL,NULL,NULL,'H.Ford',NULL,'f');
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'B.Willis',99.6);

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'Ch.Theron',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'J.Kameron',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'ABBA',NULL);

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'The Rasmus',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'Halloween',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'WhiteSnake',NULL);

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (3,9,NULL,'g.Drakula',100.0);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'W.Hewston',NULL);
insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'M.Schumaher',NULL);

insert into persons (feature_id, occupation_id,country_id,descr,sexual_potention) values (NULL,NULL,NULL,'I.Karimov',NULL);
---------------------------------------------------------
DROP USER worldadmin;
CREATE USER worldadmin WITH ENCRYPTED PASSWORD 'all';
GRANT ALL PRIVILEGES ON 
  persons,person_id_seq,
  features,feature_id_seq,
  occupations,occupation_id_seq,
  planets,planet_id_seq,
  continents,continent_id_seq,
  countries,country_id_seq
TO worldadmin;
