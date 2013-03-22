SELECT A.name,A.ticker,B.cid,B.sid,B.count,B.wins,B.mean,B.min,B.max 
FROM ex_securities A, searches B 
WHERE A.cid=B.cid AND A.sid=B.sid
ORDER BY B.wins DESC
LIMIT 10;