-- ex_factdata

CREATE TABLE ex_factdata (

       cid VARCHAR(6) NOT NULL PRIMARY KEY,   -- company id
       sid VARCHAR(3) NOT NULL,	              -- security id

       datadate DATE, -- financial period end date
       fromdate DATE, -- data available from this date
       thrudate DATE, -- new data available after this date
      
       -- search index data
       indidx   INT,  -- industry indexing
       lcapidx  INT,  -- lo market cap (size) indexing
       hcapidx  INT,  -- hi market cap (size) indexing
       lvalidx  INT,  -- ho value (e.g., P/E) indexing
       hvalidx  INT,  -- hi value (e.g., P/E) indexing
       ldividx  INT,  -- lo div yield indexing
       hdividx  INT,  -- hi div yield indexing
       
       -- factors input data goes here
       -- below is the data we need to be able to calc

       dvpsxm_ttm    FLOAT, -- Dividends/Share TTM
       epspiq_ttm    FLOAT, -- EPS TTM
       epspiq_10yISr FLOAT, -- EPS 10 Year Growth Consistency
       niq_ttm       FLOAT, -- Net Income TTM
       oiadpq_ttm    FLOAT, -- EBIT TTM
       saleq_ttm     FLOAT, -- Revenue TTM
       saleq_4yISgx  FLOAT, -- Revenue Growth 4 Years
       seqq_mrq      FLOAT, -- Shareholders' Equity
       atq_mrq       FLOAT, -- Total Assets
       dlttq_mrq     FLOAT, -- Long-Term Debt
       dlcq_mrq	     FLOAT, -- Short-Term Debt
       pstkq_mrq     FLOAT  -- Prefered
       
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_qtrfund

CREATE TABLE ex_qtrfund (

       cid VARCHAR(6) NOT NULL PRIMARY KEY,

       datadate DATE,
       fromdate DATE,
       thrudate DATE,

       -- INCOME STATEMENT


       -- BALANCE SHEET


       -- CASHFLOW

       oancfy
       capxy
       dvy
       fcfly
   
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_annfund

CREATE TABLE ex_annfund (

       cid VARCHAR(6) NOT NULL PRIMARY KEY,

       datadate DATE,
       fromdate DATE,
       thrudate DATE,

       -- INCOME STATEMENT

       -- BALANCE SHEET

       -- CASHFLOW

) ENGINE=InnoDB DEFAULT CHARSET=latin1;


target_ind
target_div
target_cap
target_val

SELECT A.datadate DT,
       B.oiadpq/(A.price*A.csho + B.dlttq - B.cheq) FACTOR1,
       ... FACTOR2,

FROM prices A,
    (SELECT cid,fromdate,thrudate,oiadpq,dlttq,cheq 
     FROM ex_factdata
     WHERE indidx = target_ind
     AND lodividx <= target_div
     AND hidividx >= target_div
     AND locapidx <= target_cap
     AND hicapidx >= target_cap
     AND lovalidx <= target_val
     AND hivalidx >= target_val) B
WHERE A.cid = B.cid
AND A.datadate >= B.fromdate
AND A.datadate <= B.thrudate
...