drop table typy cascade constraints;
drop table rankingAdvanced cascade constraints;
drop table rankingBasic cascade constraints;
drop table formuly cascade constraints;
drop table hSzachy cascade constraints;
drop table hBierki cascade constraints;
drop table hWarcaby cascade constraints;
drop table hChinczyk cascade constraints;
drop table hPilka cascade constraints;
drop table gracze cascade constraints;
drop table gry cascade constraints;
drop table sposobyObliczania cascade constraints;

create table typy(
    typ varchar2(20) primary key
);

create table gry(
    nazwa varchar2(20) primary key,
    opis varchar2(200),
    min_graczy number(2) not null,
    max_graczy number(2) not null
);

create table gracze(
    nick varchar2(20) primary key,
    haslo varchar2(20) not null,
    typ_gracza varchar2(20) not null references typy
);

create table hSzachy(
    id number(6) primary key,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    zwyciezca varchar2(20) references gracze
);

create table hWarcaby(
    id number(6) primary key,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    zwyciezca varchar2(20) references gracze
);

create table hBierki(
    id number(6) primary key,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    gracz_3 varchar2(20) references gracze,
    gracz_4 varchar2(20) references gracze,
    zwyciezca varchar2(20) not null references gracze
);

create table hPilka(
    id number(6) primary key,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    zwyciezca varchar2(20) not null references gracze
);

create table hChinczyk(
    id number(6) primary key,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    gracz_3 varchar2(20) references gracze,
    gracz_4 varchar2(20) references gracze,
    miejsce_1 varchar2(20) not null references gracze,
    miejsce_2 varchar2(20) not null references gracze,
    miejsce_3 varchar2(20) references gracze,
    miejsce_4 varchar2(20) references gracze
);

create table rankingBasic(
    nick_gracza varchar2(20) not null references gracze,
    ilosc_zagranych number(5) not null,
    ilosc_wygranych number(5) not null,
    ilosc_remisow number(5) not null,
    gra varchar2(20) not null references gry
);

create table formuly(
    id number(2) primary key,
    nazwa varchar2(20) not null,
    formula varchar2(100) not null
);

create table sposobyObliczania(
    id number(3) primary key,
    id_formuly number(2) not null references formuly,
    gra varchar2(20) not null references gry,
    wartosc_domyslna number(5) not null
);

create table rankingAdvanced(
    nick_gracza varchar2(20) not null references gracze,
    pkt_rankingowe number(10) not null,
    id_sposobu number(2) not null references sposobyObliczania
);

-----------------------TRIGGERY---------------------------

create or replace procedure dodaj_rankingi(nick varchar2) is
    cursor sposobyCur is (select wartosc_domyslna, id from sposobyObliczania);
    cursor graCur is (select nazwa from gry);
begin
    for gra in graCur
    loop
    insert into rankingBasic values (nick, 0, 0, 0, gra.nazwa);
    end loop;

    for sposob in sposobyCur
    loop
        insert into rankingAdvanced values (nick, sposob.wartosc_domyslna, sposob.id);
    end loop;
end;
/

create or replace trigger dodaj_rank
after insert on gracze
for each row
begin
   dodaj_rankingi(:new.nick);
end;
/

create or replace trigger usun_gracza
before delete on gracze
for each row
begin
   delete from rankingAdvanced where nick_gracza=:old.nick;
   delete from rankingBasic where nick_gracza=:old.nick;
end;
/

create or replace procedure dodanie_gry(nazwa varchar2) is
    cursor graczeCur is (select nick from gracze);
begin
    insert into sposobyObliczania (select nvl(max(id), 0) + 1, 0, nazwa, 1000);
    for gracz in graczeCur
    loop
        insert into rankingBasic(gracz, 0, 0, 0, nazwa);
    end loop;
end;
/

create or replace trigger dodaj_gre
after insert on gry
for each row
begin
    dodanie_gry(:new.nazwa);
end;
/

create or replace procedure dodanie_sposobu(id number, wrt number) is
    cursor graczeCur is (select nick from gracze);
begin
   for gracz in graczeCur
   loop
        insert into rankingAdvanced(gracz, wrt, id);
   end loop;
end;
/

create or replace trigger dodaj_sposob
after insert on sposobyObliczania
for each row
begin
   dodanie_sposobu(:new.id, :new.wartosc_domyslna);
end;
/

--formula podstawowa ma id=0
insert into formuly values (0, 'elo', 'R 32 S 10 R 400 / ^ 10 R 400 / ^ 10 E 400 / ^ + / - * +');

insert into typy values('uzytkownik');
insert into typy values('admin');
insert into typy values('bot');

insert into gry values('szachy', 'Grasz pionkami. I wgl fajnie sie gra w szachy zagraj se w szachy', 2, 2);
insert into gry values('warcaby', 'Grasz pionkami, ale nie takimi fajnymi jak w szachach. I wgl srednio sie gra w warcaby zagraj se w warcaby', 2, 2);
insert into gry values('chinczyk', 'Znowu grasz pionkami co jest kruczi', 2, 4);
insert into gry values('pilka', 'Gralo sie w gimnazjum oj gralo', 2, 2);
insert into gry values('bierki', 'Patyki jakies ciongasz', 2, 4);

insert into gracze values('alphazero', 'oro', 'bot');
insert into gracze values('admin', '123', 'admin');
insert into gracze values('bob', 'oro', 'admin');
insert into gracze values('abc', 'abc', 'uzytkownik');
insert into gracze values('marek', 'maro', 'uzytkownik');
insert into gracze values('scube420', '6969', 'uzytkownik');
insert into gracze values('darek68', 'hehe', 'uzytkownik');
insert into gracze values('kk418331', '$H00michek$', 'admin');

insert into gracze values('siusiak', 'oro', 'bot');
delete from gracze where nick='siusiak';


select * from gry;
select * from gracze;
