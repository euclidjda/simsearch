
SELECT company_name,ticker,comps,pcnt,mean_rtn,min_rtn,max_rtn
FROM 
(SELECT 
A.name company_name,
A.ticker ticker,
B.count comps,
B.wins/B.count pcnt,
B.mean mean_rtn,
B.min min_rtn,
B.max max_rtn
FROM ex_securities A, searches B 
WHERE A.cid=B.cid AND A.sid=B.sid
AND B.pricedate='2013-05-31') C
WHERE C.comps >= 20
ORDER BY C.pcnt DESC limit 50;



SELECT idxsub,COUNT(*) FROM (

       SELECT idxsub,cid,sid,MAX(idxcaph) maxcap,MAX(datadate) maxdate
       FROM ex_factdata 
       GROUP BY idxsub,cid,sid

) A 
WHERE maxcap >= 1000
AND maxdate BETWEEN '2000-01-01' AND '2020-12-31'
GROUP BY idxsub;

SELECT idxind,COUNT(*) FROM (

       SELECT idxind,cid,sid,MAX(idxcaph) maxcap,MAX(datadate) maxdate
       FROM ex_factdata 
       GROUP BY idxind,cid,sid

) A 
WHERE maxcap >= 1000
AND maxdate BETWEEN '2000-01-01' AND '2020-12-31'
GROUP BY idxind;

SELECT idxgrp,COUNT(*) FROM (

       SELECT idxgrp,cid,sid,MAX(idxcaph) maxcap,MAX(datadate) maxdate
       FROM ex_factdata 
       GROUP BY idxgrp,cid,sid

) A 
WHERE maxcap >= 1000
AND maxdate BETWEEN '2000-01-01' AND '2020-12-31'
GROUP BY idxgrp;

