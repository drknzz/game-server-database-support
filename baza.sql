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
drop table rozgrywki cascade constraints;

create table typy(
    typ varchar2(20) primary key
);

create table gry(
    nazwa varchar2(20) primary key,
    min_graczy number(2) not null,
    max_graczy number(2) not null
);

create table gracze(
    nick varchar2(20) primary key,
    haslo varchar2(20) not null,
    typ_gracza varchar2(20) not null references typy
);

create table rozgrywki(
    id number(6) primary key,
    nazwa varchar2(20) not null references gry
);

create table hSzachy(
    id number(6) not null references rozgrywki,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    zwyciezca varchar2(20) references gracze
);

create table hWarcaby(
    id number(6) not null references rozgrywki,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    zwyciezca varchar2(20) references gracze
);

create table hBierki(
    id number(6) not null references rozgrywki,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    gracz_3 varchar2(20) references gracze,
    gracz_4 varchar2(20) references gracze,
    zwyciezca varchar2(20) not null references gracze
);

create table hPilka(
    id number(6) not null references rozgrywki,
    gracz_1 varchar2(20) not null references gracze,
    gracz_2 varchar2(20) not null references gracze,
    zwyciezca varchar2(20) not null references gracze
);

create table hChinczyk(
    id number(6) not null references rozgrywki,
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
    id number(3) primary key,
    gra varchar2(20) not null references gry,
    formula varchar2(100) not null,
    wartosc_domyslna number(5) not null
);

create table rankingAdvanced(
    nick_gracza varchar2(20) not null references gracze,
    pkt_rankingowe varchar2(20) not null,
    id_formuly number(2) not null references formuly
);

-----------------------TRIGGERY---------------------------

create or replace procedure dodaj_rankingi(nick varchar2) is
    cursor formulyCur is (select wartosc_domyslna, id from formuly);
    cursor graCur is (select nazwa from gry);
begin
    for gra in graCur
    loop
    insert into rankingBasic values (nick, 0, 0, 0, gra.nazwa);
    end loop;

    for formula in formulyCur
    loop
        insert into rankingAdvanced values (nick, formula.wartosc_domyslna, formula.id);
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


insert into typy values('uzytkownik');
insert into typy values('admin');
insert into typy values('bot');

insert into gry values('szachy', 2, 2);
insert into gry values('bierki', 2, 4);
insert into gry values('chinczyk', 2, 4);
insert into gry values('pilka', 2, 2);
insert into gry values('warcaby', 2, 2);

insert into formuly (select nvl(max(id), 0) + 1, 'szachy', 'R 32 S 10 R 400 / ^ 10 R 400 / ^ 10 E 400 / ^ + / - * +', 1000 from formuly);
insert into formuly (select nvl(max(id), 0) + 1 , 'warcaby', 'R 64 S 10 R 400 / ^ 10 R 400 / ^ 10 E 400 / ^ + / - * +', 1000 from formuly);
insert into formuly (select nvl(max(id), 0) + 1 , 'pilka', 'R 32 S 10 R 400 / ^ 10 R 400 / ^ 10 E 400 / ^ + / - * +', 200 from formuly);
insert into formuly (select nvl(max(id), 0) + 1 , 'chinczyk', 'Placeholder', 500 from formuly);
insert into formuly (select nvl(max(id), 0) + 1 , 'bierki', 'Placeholder', 200 from formuly);

insert into gracze values('alphazero', 'oro', 'bot');
insert into gracze values('admin', '123', 'admin');
insert into gracze values('bob', 'oro', 'admin');
insert into gracze values('abc', 'abc', 'uzytkownik');
insert into gracze values('marek', 'maro', 'uzytkownik');
insert into gracze values('scube420', '6969', 'uzytkownik');
insert into gracze values('darek68', 'hehe', 'uzytkownik');
insert into gracze values('kk418331', '$H00michek$', 'admin');



select * from gry;
select * from gracze;
