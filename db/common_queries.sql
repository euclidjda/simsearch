
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
AND B.pricedate='2013-09-16') C
WHERE C.comps >= 20
ORDER BY C.pcnt DESC limit 50;

