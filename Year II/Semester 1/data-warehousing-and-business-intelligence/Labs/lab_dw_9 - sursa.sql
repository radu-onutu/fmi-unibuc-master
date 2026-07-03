---------------------------------------------------------------------------
--Lab 9 DW - FUNCTII SQL PENTRU RAPORTARE   
---------------------------------------------------------------------------
     
--1
desc vanzari_***

SELECT factura, produs_id, 
       pret_unitar_vanzare*cantitate AS valoare,
       SUM(pret_unitar_vanzare*cantitate) 
          OVER  (PARTITION BY factura
                 ORDER BY     produs_id  
                 ROWS UNBOUNDED PRECEDING)
          AS Valoare_Cumulata
FROM  vanzari_***
where client_id = 146;

--2
SELECT produs_id, data, valoare
FROM  (SELECT v.produs_id, timp_id data, 
              SUM(pret_unitar_vanzare*cantitate) 
                  AS valoare,
              MAX(SUM(pret_unitar_vanzare*cantitate)) 
                  OVER (PARTITION BY v.produs_id) 
                  AS vanz_max
       FROM   vanzari v, timp t, produse p
       WHERE  v.timp_id = t.id_timp
       AND    v.produs_id = p.id_produs
       AND    categorie_5 = 'Markere permanente'
       AND    an = 2007
       GROUP BY v.produs_id,timp_id)
WHERE  valoare=vanz_max;

--folosim coloana calculata valoare
SELECT produs_id, data, valoare
FROM  (SELECT v.produs_id, timp_id data, 
              SUM(valoare) 
                  AS valoare,
              MAX(SUM(valoare)) 
                  OVER (PARTITION BY v.produs_id) 
                  AS vanz_max
       FROM   vanzari_*** v, timp t, produse p
       WHERE  v.timp_id = t.id_timp
       AND    v.produs_id = p.id_produs
       AND    categorie_5 = 'Markere permanente'
       AND    an = 2007
       GROUP BY v.produs_id,timp_id)
WHERE  valoare=vanz_max;




--3
desc timp

SELECT timp_id, 
       valoare,
       SUM(valoare) OVER  
          (ORDER BY timp_id 
          ROWS UNBOUNDED PRECEDING) 
          AS valoare_cumulata,
       SUM(valoare) OVER 
         (ORDER BY timp_id 
          RANGE INTERVAL '1' DAY PRECEDING) 
          AS azi_si_ieri
FROM  (SELECT timp_id, 
              SUM(pret_unitar_vanzare*cantitate) valoare
       FROM   vanzari v, timp t
       WHERE  v.timp_id=t.id_timp
       AND    luna = 3
       AND    an = 2007
       GROUP BY timp_id);

--4
SELECT client_id, trimestru, 
       SUM(pret_unitar_vanzare*cantitate) valoare,
       SUM(SUM(pret_unitar_vanzare*cantitate)) 
           OVER (PARTITION BY client_id 
                 ORDER BY     client_id, trimestru
                 ROWS UNBOUNDED PRECEDING) CLIENT_VANZARI
FROM   vanzari v, timp t
WHERE  v.timp_id=t.id_timp 
AND    client_id IN (44,82,84,146)
AND    an=2007
GROUP BY client_id, trimestru;


--5
SELECT  client_id,luna, 
        SUM(pret_unitar_vanzare*cantitate) valoare,
        AVG(SUM(pret_unitar_vanzare*cantitate)) 
            OVER (ORDER BY client_id,luna 
            ROWS 2 PRECEDING) AS MEDIA_3_LUNI
FROM   vanzari v, timp t
WHERE  v.timp_id=t.id_timp 
AND    client_id =146
AND    an=2007
GROUP BY client_id, luna;

desc timp

--ordare dupa to_number(luna)
SELECT  client_id,to_number(luna), 
        SUM(pret_unitar_vanzare*cantitate) valoare,
        AVG(SUM(pret_unitar_vanzare*cantitate)) 
            OVER (ORDER BY client_id,to_number(luna) 
            ROWS 2 PRECEDING) AS MEDIA_3_LUNI
FROM   vanzari v, timp t
WHERE  v.timp_id=t.id_timp 
AND    client_id =146
AND    an=2007
GROUP BY client_id, to_number(luna);

--folosesc tabela timp_*** in care adaug o coloana nous luna_nr
alter table timp_***
add (luna_nr number(2));

update timp_***
set luna_nr = to_number(luna);
commit;

--verific planul de executie pentru luna ca number
SELECT  client_id,luna_nr, 
        SUM(pret_unitar_vanzare*cantitate) valoare,
        AVG(SUM(pret_unitar_vanzare*cantitate)) 
            OVER (ORDER BY client_id,luna_nr 
            ROWS 2 PRECEDING) AS MEDIA_3_LUNI
FROM   vanzari v, timp_*** t
WHERE  v.timp_id=t.id_timp 
AND    client_id =146
AND    an=2007
GROUP BY client_id, luna_nr;

SELECT  client_id,luna_nr, 
        SUM(valoare) valoare,
        AVG(SUM(valoare)) 
            OVER (ORDER BY client_id,luna_nr 
            ROWS 2 PRECEDING) AS MEDIA_3_LUNI
FROM   vanzari_*** v, timp_*** t
WHERE  v.timp_id=t.id_timp 
AND    client_id =146
AND    an=2007
GROUP BY client_id, luna_nr;

--6
SELECT client_id,timp_id, 
       SUM(pret_unitar_vanzare*cantitate) valoare,
       AVG(SUM(pret_unitar_vanzare*cantitate))
           OVER (PARTITION BY client_id ORDER BY timp_id
           RANGE BETWEEN INTERVAL '1' DAY PRECEDING
                 AND INTERVAL '1' DAY FOLLOWING) 
           AS MEDIE_CENTRATA_3_ZILE
FROM   vanzari v, timp t
WHERE  v.timp_id=t.id_timp
AND    client_id =233
AND    an=2007
GROUP BY client_id, timp_id;

--7
SELECT categorie_5 AS categorie, denumire,
       pret_unitar_curent,
       FIRST_VALUE(denumire)
          OVER (ORDER BY pret_unitar_curent DESC 
                ROWS BETWEEN UNBOUNDED PRECEDING 
                AND UNBOUNDED FOLLOWING) 
          AS den_prod_cu_pret_maxim
FROM  (SELECT * 
       FROM   produse 
       WHERE  categorie_5 = 'Plicuri securizate'
       ORDER BY id_produs);

--8
SELECT produs_id, timp_id, valoare,
       FIRST_VALUE(valoare) 
          OVER (PARTITION BY produs_id ORDER BY timp_id) 
          AS valoare_zi1, 
       ROUND(valoare/FIRST_VALUE(valoare) 
                     OVER (PARTITION BY produs_id 
                     ORDER BY timp_id)
             * 100,2)  AS procent_din_zi1 
FROM  (SELECT v.produs_id, timp_id,
             SUM(pret_unitar_vanzare*cantitate) valoare
      FROM   vanzari v, timp t, produse p
      WHERE  v.timp_id=t.id_timp
      AND    v.produs_id=p.id_produs
      AND    v.produs_id IN (899, 1377, 1378, 1482, 2334 )
      AND    an = 2007
      GROUP BY produs_id,timp_id);

--9
SELECT categorie_3 AS subgrupa, oras, valoare
FROM(SELECT categorie_3, oras,
            SUM(pret_unitar_vanzare*cantitate) AS valoare,
            MAX(SUM(pret_unitar_vanzare*cantitate ))
              OVER (PARTITION BY categorie_3) AS max_val
     FROM   vanzari v, regiuni r, 
            produse p, timp t
     WHERE  v.regiune_id=r.id_regiune
     AND    v.produs_id=p.id_produs
     AND    v.timp_id=t.id_timp
     AND    categorie_1 = 'IT'
     GROUP BY categorie_3, oras)
WHERE valoare= max_val;

--10
SELECT categorie_1 AS raion, 
       categorie_2 AS grupa, 
       produs, rang , vanzari    
FROM (SELECT categorie_1, categorie_2, 
            v.produs_id produs, denumire, 
            SUM(pret_unitar_vanzare*cantitate ) VANZARI,
            SUM(SUM(pret_unitar_vanzare*cantitate )) 
              OVER (PARTITION BY categorie_1) AS raion,
            SUM(SUM(pret_unitar_vanzare*cantitate)) 
              OVER (PARTITION BY categorie_2) AS grupa,
            DENSE_RANK() 
              OVER  (PARTITION BY categorie_2  
              ORDER BY SUM(pret_unitar_vanzare*cantitate)) 
              AS rang
      FROM  vanzari v, regiuni r, 
            produse p, timp t
      WHERE v.regiune_id=r.id_regiune
      AND   v.produs_id=p.id_produs
      AND   v.timp_id=t.id_timp
      GROUP BY categorie_1, categorie_2, 
               v.produs_id, denumire) 
WHERE grupa>0.2*raion AND rang<=5;

--11
SELECT cod,
      SUM(pret_unitar_vanzare*cantitate)
          VANZARI,
      SUM(SUM(pret_unitar_vanzare*cantitate)) 
          OVER () 
          AS TOTAL_VANZ,
      round(RATIO_TO_REPORT(
          SUM(pret_unitar_vanzare*cantitate)) 
          OVER (), 6)
           AS RATIO_REP
FROM   vanzari v, plati p
WHERE  v.plata_id=p.id_plata
GROUP BY cod;

--12
SELECT timp_id, 
       SUM(pret_unitar_vanzare*cantitate) AS VANZARI,
       LAG(SUM(pret_unitar_vanzare*cantitate),1)  OVER (ORDER BY timp_id) AS LAG1,
       LEAD(SUM(pret_unitar_vanzare*cantitate),1) OVER (ORDER BY timp_id) AS LEAD1
FROM   vanzari v, timp t
WHERE  v.timp_id=t.id_timp
AND    luna= 7
and    an = 2007
GROUP BY timp_id;

--13
SELECT produs_id, timp_id, valoare_vanzari, 
       valoare_vanzari-LAG (valoare_vanzari, 1) 
            OVER (PARTITION BY produs_id ORDER BY timp_id) 
         AS Diferenta
FROM (SELECT produs_id, timp_id,
             SUM(pret_unitar_vanzare*cantitate) AS valoare_vanzari
      FROM   vanzari v, timp t
      WHERE  v.timp_id=t.id_timp
      AND    produs_id IN (899, 1377, 1378, 1482, 2334 )
      AND    luna= 3
      AND    an = 2007
      GROUP BY produs_id, timp_id);

--14
SELECT timp_id, vanzari,
       vanzari-LAG(vanzari, 1) OVER ( ORDER BY timp_id) 
         AS Diferenta
FROM (SELECT timp_id, 
             SUM(pret_unitar_vanzare*cantitate) AS vanzari
      FROM   vanzari v, timp t
      WHERE  v.timp_id=t.id_timp
      AND    luna= 3
      AND    an = 2007
      GROUP BY timp_id);



