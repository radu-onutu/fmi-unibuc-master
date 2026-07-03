 --LAB DW 8 - Functii pentru grupare si clasare
     
--1
/*
group by (categorie_1, oras)
union all
group by (categorie_1)
union all
()

group by (a,b)
group by (a)
group by ()
=> rollup (a,b)

group by (a,b,c)
group by (a,b)
group by (a)
group by ()
=> rollup (a,b,c)
*/

--a
-- cost=4462
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, produse_*** p, regiuni_*** r, 
       timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by rollup (p.categorie_1,r.oras);

--b
--cost = 25337
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, produse_*** p, regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by (p.categorie_1,r.oras)
union
select p.categorie_1 as raion,
       max(null),
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id = p.id_produs
and    v.timp_id = t.id_timp
and    t.an = 2007
group by (p.categorie_1)
union
select max(null) as raion,
       max(null) as oras,
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, timp_*** t
where  v.timp_id = t.id_timp
and    t.an = 2007;

--cost = 13131
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, produse_*** p, regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by (p.categorie_1,r.oras)
union all
select p.categorie_1 as raion,
       max(null),
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id = p.id_produs
and    v.timp_id = t.id_timp
and    t.an = 2007
group by (p.categorie_1)
union all
select max(null) as raion,
       max(null) as oras,
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, timp_*** t
where  v.timp_id = t.id_timp
and    t.an = 2007
order by 1,2
;

--c
-- cost = 4462
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari
from   vanzari_*** v, produse_*** p, regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by grouping sets ((p.categorie_1,r.oras),(p.categorie_1),());

--d
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari,
       grouping(p.categorie_1) as "GC",
       grouping(r.oras) as "GO"
from   vanzari_*** v, produse_*** p, 
       regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by rollup (p.categorie_1,r.oras);

--e
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari,
       grouping(p.categorie_1) as "GC",
       grouping(r.oras) as "GO",
       grouping_id(p.categorie_1,r.oras) as "G_ID"
from   vanzari_*** v, produse_*** p, regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by rollup (p.categorie_1,r.oras);

--f
-- cost = 4462
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari,
       grouping(p.categorie_1) as "GC",
       grouping(r.oras) as "GO"
from   vanzari_*** v, produse_*** p, regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by rollup (p.categorie_1,r.oras)
having grouping(p.categorie_1)=1 or grouping(r.oras)=1;

-- cost = 4462
select p.categorie_1 as raion,
       r.oras,
       sum(v.valoare) as total_vanzari,
       grouping_id(p.categorie_1,r.oras) as "G_ID"
from   vanzari_*** v, produse_*** p, regiuni_*** r, timp_*** t
where  v.produs_id = p.id_produs
and    v.regiune_id = r.id_regiune
and    v.timp_id = t.id_timp
and    t.an = 2007
group by rollup (p.categorie_1,r.oras)
having grouping_id(p.categorie_1,r.oras)<>0;

-- cost = 4447
select p.categorie_1 as raion,
       max(null) as oras,
       sum(v.valoare) as total_vanzari,
       grouping_id(p.categorie_1) as G_ID
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id = p.id_produs
and    v.timp_id = t.id_timp
and    t.an = 2007
group by rollup (p.categorie_1);

--g
select p.categorie_1 as raion,
       max(null) as oras,
       sum(v.valoare) as total_vanzari,
       grouping_id(p.categorie_1) as G_ID
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id = p.id_produs
and    v.timp_id = t.id_timp
and    t.an = 2007
group by grouping sets ((p.categorie_1),());

--2
/*
group by (client, grupa)
union all
group by (client)
union all
group by (grupa)
union all
()

group by (a,b)
group by (a)
group by (b)
() 
=> cube (a,b)

group by (a,b,c)
group by (a,b)
group by (a,c)
group by (b,c)
group by (a)
group by (b)
group by (c)
()
=> cube (a,b)

*/

--a
desc vanzari_***
desc produse_***
desc clienti_***
desc timp_***

-- cost = 4452
select c.nume, p.categorie_2 grupa, 
       sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,clienti_*** c, 
       timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2);

--b
--cost = 35557
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by (c.nume, p.categorie_2)
union
select c.nume, null, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by (c.nume)
union
select null, p.categorie_2 grupa, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    t.an=2007
and    p.categorie_1='IT'
group by (p.categorie_2)
union
select null, null, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    t.an=2007
and    p.categorie_1='IT'
;

-- cost = 17621
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by (c.nume, p.categorie_2)
union all
select c.nume, null, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by (c.nume)
union all
select null, p.categorie_2 grupa, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    t.an=2007
and    p.categorie_1='IT'
group by (p.categorie_2)
union all
select null, null, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    t.an=2007
and    p.categorie_1='IT'
;

--c
-- cost = 4505
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by grouping sets ((c.nume, p.categorie_2),
                         (c.nume),
                         (p.categorie_2),
                         ());

--d
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, 
       grouping(p.categorie_2) gg
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2);


--teste 1
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, 
       grouping(p.categorie_2) gg
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2)
having grouping(c.nume) = 0;

select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, 
       grouping(p.categorie_2) gg
from   vanzari_*** v, produse_*** p,
       clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by 
 grouping sets ((c.nume, p.categorie_2),(c.nume));

--teste 2
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, grouping(p.categorie_2) gg
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2)
having grouping(p.categorie_2) = 0;

select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, grouping(p.categorie_2) gg
from   vanzari_*** v, produse_*** p,clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by grouping sets 
       ((c.nume, p.categorie_2),(p.categorie_2));

--teste 3
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, grouping(p.categorie_2) gg
from   vanzari_*** v, produse_*** p,
       clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2)
having grouping(p.categorie_2) = 1 
       or grouping(c.nume)=1;

select c.nume, null, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,
       clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by (c.nume)
union all
select null, p.categorie_2, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    t.an=2007
and    p.categorie_1='IT'
group by (p.categorie_2)
union all
select null, null, sum(v.cantitate) cant_totala
from   vanzari_*** v, produse_*** p,timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    t.an=2007
and    p.categorie_1='IT';

--e
select c.nume, p.categorie_2 grupa, 
       sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, 
       grouping(p.categorie_2) gc,
       GROUPING_ID(c.nume,p.categorie_2) gr_id
from   vanzari_*** v, produse_*** p,
       clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2);

--teste 1
select c.nume, p.categorie_2 grupa, sum(v.cantitate) cant_totala,
       grouping(c.nume) gn, 
       grouping(p.categorie_2) gc,
       grouping_id(c.nume,p.categorie_2) gr_id
from   vanzari_*** v, produse_*** p,
       clienti_*** c, timp_*** t
where  v.produs_id=p.id_produs 
and    v.timp_id = t.id_timp
and    v.client_id = c.id_client
and    t.an=2007
and    p.categorie_1='IT'
group by cube (c.nume, p.categorie_2)
having grouping_id(c.nume,p.categorie_2) in (1,0);

--3
--a
desc vanzari_***
desc produse_***
desc timp_***
select * from timp_***;

select p.denumire, 
       round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by p.denumire
order by valoare_totala desc;

--b
--rownum
select rownum,p.denumire, 
       round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by rownum,p.denumire
order by valoare_totala desc;

-- cost=4343
select rownum, denumire, valoare_totala
from (select p.denumire, 
             round(sum(v.valoare),1) valoare_totala
        from   vanzari_*** v, produse_*** p, 
               timp_*** t
        where  v.produs_id=p.id_produs
        and    v.timp_id=t.id_timp
        and    t.trimestru=1
        and    t.an=2007
        group by p.denumire
        order by valoare_totala desc);

--row_number
-- cost=4372
select ROW_NUMBER() 
  OVER (ORDER BY ROUND(SUM(valoare),1) DESC) row_nr,
       p.denumire, round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by p.denumire;
--order by valoare_totala desc;

--c
select ROW_NUMBER() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) row_nr,
       DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank,  
       p.denumire, round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by p.denumire;

select *
from (select 
        ROW_NUMBER() 
         OVER (ORDER BY ROUND(SUM(valoare),1) DESC) row_nr,
        DENSE_RANK() 
         OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank,  
        p.denumire, round(sum(v.valoare),1) valoare_totala
        from   vanzari_*** v, produse_*** p, 
               timp_*** t
        where  v.produs_id=p.id_produs
        and    v.timp_id=t.id_timp
        and    t.trimestru=1
        and    t.an=2007
        group by p.denumire)
where row_nr<>d_rank;

--d
select ROW_NUMBER() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) row_nr,
       DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank, 
       RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) rank,           
       p.denumire, round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by p.denumire;

--teste 1
select DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc, 
       DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) ASC) d_rank_asc,           
       p.denumire, round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by p.denumire;

--teste 2
select DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc, 
       DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) ASC) d_rank_asc, 
       DENSE_RANK() 
        OVER (ORDER BY SUM(cantitate) DESC) d_rank_desc_cantitate,    
       p.denumire, round(sum(v.valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    t.trimestru=1
and    t.an=2007
group by p.denumire;

--4
select DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc, 
       categorie_2, ROUND(SUM(valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id=t.id_timp
and    p.categorie_1='IT'
and    t.an=2007
group by categorie_2;     
       
--5
--top orase
select DENSE_RANK() 
        OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc, 
       oras, ROUND(SUM(valoare),1) valoare_totala
from   vanzari_*** v, regiuni_*** p, timp_*** t
where  v.regiune_id=p.id_regiune
and    v.timp_id=t.id_timp
and    t.an=2007
group by oras;  

-- top 5 orase
select *
from
    (select DENSE_RANK() 
            OVER (ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc, 
           oras, ROUND(SUM(valoare),1) valoare_totala
    from   vanzari_*** v, regiuni_*** p, timp_*** t
    where  v.regiune_id=p.id_regiune
    and    v.timp_id=t.id_timp
    and    t.an=2007
    group by oras)
where d_rank_desc<=5;

--6
--top clienti pentru fiecare oras
select r.oras,c.nume,ROUND(SUM(valoare),1) valoare_totala,
       DENSE_RANK() OVER
        (PARTITION BY r.oras
         ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc
from   vanzari_*** v, regiuni_*** r, timp_*** t,
       clienti_*** c
where  v.regiune_id=r.id_regiune
and    v.timp_id=t.id_timp
and    v.client_id=c.id_client
and    t.an=2007
group by r.oras,c.nume;

--top 5 clienti pentru fiecare oras
select *
from 
    (select r.oras,c.nume,ROUND(SUM(valoare),1) valoare_totala,
           DENSE_RANK() OVER
            (PARTITION BY r.oras
             ORDER BY ROUND(SUM(valoare),1) DESC) d_rank_desc
    from   vanzari_*** v, regiuni_*** r, timp_*** t,
           clienti_*** c
    where  v.regiune_id=r.id_regiune
    and    v.timp_id=t.id_timp
    and    v.client_id=c.id_client
    and    t.an=2007
    group by r.oras,c.nume
    )
where d_rank_desc <=5;

--7
--fara clasament
select p.categorie_1 raion,t.luna,
       ROUND(SUM(valoare),1) valoare_totala
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id = t.id_timp
and    t.an=2007
group by cube(p.categorie_1,t.luna);

--cu clasament
select p.categorie_1 raion,t.luna,
       ROUND(SUM(valoare),1) valoare_totala,
       DENSE_RANK() OVER
        (PARTITION BY GROUPING_ID(categorie_1, luna)
         ORDER BY ROUND(SUM(valoare),1) DESC) d_rank
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id = t.id_timp
and    t.an=2007
group by cube(p.categorie_1,t.luna);

select p.categorie_1 raion,t.luna,
       ROUND(SUM(valoare),1) valoare_totala,
       GROUPING_ID(p.categorie_1, t.luna) gr_id,
       DENSE_RANK() OVER
        (PARTITION BY GROUPING_ID(p.categorie_1, t.luna)
         ORDER BY ROUND(SUM(valoare),1) DESC) d_rank
from   vanzari_*** v, produse_*** p, timp_*** t
where  v.produs_id=p.id_produs
and    v.timp_id = t.id_timp
and    t.an=2007
group by cube(p.categorie_1,t.luna);




