-- Lab 2 DW&BI
select * from tab;

--1
--2
desc vanzari

--3
desc promo
desc timp
desc produse
desc regiuni

--5
select count(*) from vanzari_***;
select * from vanzari_***;

--7
desc oferte_***
desc promo_***
desc produse_***
desc clienti_***

--10
alter table vanzari_***
add valoare number default 0 not null;

select id, produs_id, cantitate, 
       pret_unitar_vanzare, valoare
from vanzari_***;

update vanzari_***
set valoare = pret_unitar_vanzare*cantitate;
commit;

--11
select * from timp_***;
select min(id_timp), max(id_timp) from timp_***;

--a
create table timp_extins_***
as select * from timp;

--b
select to_char(sysdate+rownum-1,'dd.mm.yyyy hh24:mi:ss')
from   dual
connect by sysdate+rownum-1 <= sysdate+9;

select to_char(trunc(sysdate+rownum-1),'dd.mm.yyyy hh24:mi:ss')
from   dual
connect by sysdate+rownum-1 <= sysdate+9;

select trunc(sysdate+rownum-1)
from   dual
connect by sysdate+rownum-1 <= sysdate+9;

desc timp

select 
data id_timp,
extract(year from data) an,
case when extract(month from data)<7 
     then 1
     else 2
     end AS semestru,
to_char(data,'q') trimestru,
to_char(data,'mm') luna,
to_char(data,'ww') saptamana_an,
to_char(data,'w') saptamana_luna,
to_char(data,'ddd') zi_an,
to_char(data,'dd') zi_luna,
to_char(data,'d') zi_saptamana,
to_char(data,'Day') zi_nume,
to_char(data,'Month') luna_nume,
case 
   when to_char(data,'d')  not in (7,1)
   then 0
   else 1
   end AS weekend,
case 
 when mod(extract(year from data),4) = 0
 and mod(extract(year from data),4) <>100
 then 1
 else 0
 end AS an_bisect,
to_number(to_char(data,'iw')) saptamana_calendar,
case 
when to_number(to_char(data,'D')) <> 1 
then to_number(to_char(data,'IW')) - 1 
else to_number(to_char(data,'IW')) 
end AS SAPTAMANA_AN_BUSINESS,
data
from 
( select trunc(sysdate+rownum-1) data    
  from   dual
  connect by sysdate+rownum-1 <= sysdate+9);

create or replace procedure 
  extinde_timp_***(start_date date, end_date date)
AS
begin
  insert into timp_extins_***
      select 
    data id_timp,
    extract(year from data) an,
    case when extract(month from data)<7 
         then 1
         else 2
         end AS semestru,
    to_char(data,'q') trimestru,
    to_char(data,'mm') luna,
    to_char(data,'ww') saptamana_an,
    to_char(data,'w') saptamana_luna,
    to_char(data,'ddd') zi_an,
    to_char(data,'dd') zi_luna,
    to_char(data,'d') zi_saptamana,
    to_char(data,'Day') zi_nume,
    to_char(data,'Month') luna_nume,
    case 
       when to_char(data,'d')  not in (7,1)
       then 0
       else 1
       end AS weekend,
    case 
     when mod(extract(year from data),4) = 0
     and mod(extract(year from data),4) <>100
     then 1
     else 0
     end AS an_bisect,
    to_number(to_char(data,'iw')) saptamana_calendar,
    case 
    when to_number(to_char(data,'D')) <> 1 
    then to_number(to_char(data,'IW')) - 1 
    else to_number(to_char(data,'IW')) 
    end AS SAPTAMANA_AN_BUSINESS,
    data
    from 
    ( select trunc(start_date+rownum-1) data    
      from   dual
      connect by start_date+rownum-1 <= end_date);
end;
/

exec extinde_timp_***(to_date('01.01.2008','dd.mm.yyyy'),to_date('31.12.2008','dd.mm.yyyy'))
select min(id_timp),max(id_timp) from timp_extins_***;

commit;

--12
--a
select * from clienti_***
where id_client=94;

--b
select sum(valoare) suma
from   vanzari_***
where  client_id = 94;

select c.nume, t.an, t.semestru, p.denumire,
       r.oras, sum(v.valoare) suma
from   vanzari_*** v, clienti_*** c,
       timp_*** t, produse_*** p,
       regiuni_*** r
where v.client_id =  c.id_client
and   v.timp_id = t.id_timp
and   v.regiune_id = r.id_regiune
and   v.produs_id = p.id_produs
and c.id_client = 94
group by c.nume, t.an, t.semestru, p.denumire,
       r.oras;

select c.nume, t.an, t.semestru, p.denumire,
       r.oras, sum(v.cantitate*v.pret_unitar_vanzare) suma
from   vanzari_*** v, clienti_*** c,
       timp_*** t, produse_*** p,
       regiuni_*** r
where v.client_id =  c.id_client
and   v.timp_id = t.id_timp
and   v.regiune_id = r.id_regiune
and   v.produs_id = p.id_produs
and c.id_client = 94
group by c.nume, t.an, t.semestru, p.denumire,
       r.oras;

update clienti_***
set nume = 'xyz'
where id_client = 94;

select sum(valoare) suma
from   vanzari_***
where  client_id = 94;

select c.nume, t.an, t.semestru, p.denumire,
       r.oras, sum(v.valoare) suma
from   vanzari_*** v, clienti_*** c,
       timp_*** t, produse_*** p,
       regiuni_*** r
where v.client_id =  c.id_client
and   v.timp_id = t.id_timp
and   v.regiune_id = r.id_regiune
and   v.produs_id = p.id_produs
and c.id_client = 94
group by c.nume, t.an, t.semestru, p.denumire,
       r.oras;

-- insert tema
ROLLBACK;

--d
--d1
create table clienti_d1_***
as select * from clienti_***;

select * from clienti_d1_***
where id_client =94;

alter table clienti_d1_***
add (activ number(1) default 1 not null);

select id_client, nume, activ
from   clienti_d1_***
where  id_client = 94;

update clienti_d1_***
set activ = 0
where id_client = 94;
commit;

desc clienti_d1_***

insert into clienti_d1_***
select 1000,'xyz', telefon, email, tip, oras,
       data_crearii, sysdate, 1
from clienti_d1_***
where id_client=94;

select id_client, nume, activ
from   clienti_d1_***
where  id_client in (94,1000);
commit;

select id_client, nume, activ, telefon, email
from   clienti_d1_***
where  id_client in (94,1000);

/*
nu am nevoie de unicitate pe email / telefon
in raport pot folosi 
   grouping sets ((c.email,c.nume),
                   (c.email))
*/