DROP TABLE IF EXISTS ex_combined;

CREATE TABLE ex_combined (
       
       cid VARCHAR(6) NOT NULL, -- company id
       sid VARCHAR(3) NOT NULL, -- security id
       
       --
       -- search index data
       --
       idxsec  CHAR(2) NOT NULL,  -- industry indexing
       idxgrp  CHAR(4) NOT NULL,  -- industry indexing
       idxind  CHAR(6) NOT NULL,  -- industry indexing
       idxsub  CHAR(8) NOT NULL,  -- industry indexing

       idxnew  INT NOT NULL,  -- is new issue? (within 9 mo of IPO)
       idxcapl INT NOT NULL,  -- lo market cap (size) in range fromdate -> thrudate
       idxcaph INT NOT NULL,  -- hi market cap (size) in range fromdate -> thrudate

       --
       -- dates
       --
       pricedate DATE NOT NULL, 
       fpedate   DATE NOT NULL,
       fromdate  DATE NOT NULL, -- data available from this date
       thrudate  DATE NOT NULL, -- new data available after this date
      
       csho   FLOAT, -- common shares outstanding
       ajex   FLOAT, -- adjustment factor
       price  FLOAT, -- closing price on datadate
       volume FLOAT, -- volume (not currently populated)
       pch1m  FLOAT, -- 1 month price change
       pch3m  FLOAT, -- 3 month price change
       pch6m  FLOAT, -- 6 month price change
       pch9m  FLOAT, -- 9 month price change
       pch12m FLOAT, -- 12 month price change

       --
       -- the fields below are used to calculate factors "on the fly"
       -- see example queries at end of this file
       --
       dvpsxm_ttm    FLOAT, -- Dividends/Share TTM
       epspiq_ttm    FLOAT, -- EPS TTM
       epspxq_ttm    FLOAT, -- EPS TTM (excluding extra-ordinary items)
       epspiq_10yISr FLOAT, -- EPS 10 Year Growth Consistency
       niq_ttm       FLOAT, -- Net Income TTM
       oiadpq_ttm    FLOAT, -- EBIT TTM
       cogsq_ttm     FLOAT, -- Cost of Goods Sold TTM
       saleq_ttm     FLOAT, -- Revenue TTM
       saleq_4yISgx  FLOAT, -- Revenue Growth 4 Years
       seqq_mrq      FLOAT, -- Shareholders' Equity
       cheq_mrq	     FLOAT, -- Cash & Cash Equiv
       atq_mrq       FLOAT, -- Total Assets
       dlttq_mrq     FLOAT, -- Long-Term Debt
       dlcq_mrq	     FLOAT, -- Short-Term Debt
       pstkq_mrq     FLOAT, -- Prefered Stock
       mibnq_mrq     FLOAT, -- Non-controlling interests non-redeamable - balance
       mibq_mrq	     FLOAT, -- Non-controlling interests redeamable - balance sheet
       fcfq_mrq	     FLOAT, -- Free Cash Flow TTM
       fcfq_4yISm    FLOAT, -- Free Cash Flow 4 year median
 
       INDEX ex_combined_ix01 (cid,sid,fromdate,thrudate), -- point-in-time index
       INDEX ex_combined_ix02 (idxsec,idxnew,pricedate,idxcapl,idxcaph),
       INDEX ex_combined_ix03 (idxgrp,idxnew,pricedate,idxcapl,idxcaph),
       INDEX ex_combined_ix04 (idxind,idxnew,pricedate,idxcapl,idxcaph),
       INDEX ex_combined_ix05 (idxsub,idxnew,pricedate,idxcapl,idxcaph)


) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO ex_combined
    SELECT
    A.cid,A.sid,
    B.idxsec,B.idxgrp,B.idxind,B.idxsub,
    B.idxnew,
    B.idxcapl,B.idxcaph,
    A.datadate,B.datadate,B.fromdate,B.thrudate,
    A.csho,A.ajex,A.price,A.volume,
    A.pch1m,A.pch3m,A.pch6m,A.pch9m,A.pch12m,
       B.dvpsxm_ttm    , -- Dividends/Share TTM
       B.epspiq_ttm    , -- EPS TTM
       B.epspxq_ttm    , -- EPS TTM (excluding extra-ordinary items)
       B.epspiq_10yISr , -- EPS 10 Year Growth Consistency
       B.niq_ttm       , -- Net Income TTM
       B.oiadpq_ttm    , -- EBIT TTM
       B.cogsq_ttm     , -- Cost of Goods Sold TTM
       B.saleq_ttm     , -- Revenue TTM
       B.saleq_4yISgx  , -- Revenue Growth 4 Years
       B.seqq_mrq      , -- Shareholders' Equity
       B.cheq_mrq      , -- Cash & Cash Equiv
       B.atq_mrq       , -- Total Assets
       B.dlttq_mrq     , -- Long-Term Debt
       B.dlcq_mrq      , -- Short-Term Debt
       B.pstkq_mrq     , -- Prefered Stock
       B.mibnq_mrq     , -- Non-controlling interests non-redeamable - balance
       B.mibq_mrq      , -- Non-controlling interests redeamable - balance sheet
       B.fcfq_mrq      , -- Free Cash Flow TTM
       B.fcfq_4yISm      -- Free Cash Flow 4 year median
    FROM ex_prices A,  ex_factdata B
    WHERE A.cid = B.cid AND
    A.sid = B.sid AND	
    A.price  IS NOT NULL AND
    A.csho   IS NOT NULL AND
    A.ajex   IS NOT NULL AND
    A.pch1m  IS NOT NULL AND
    A.pch3m  IS NOT NULL AND
    A.pch6m  IS NOT NULL AND
    A.pch9m  IS NOT NULL AND
    A.pch12m IS NOT NULL AND
    B.dvpsxm_ttm    IS NOT NULL AND
    B.epspiq_ttm    IS NOT NULL AND
    B.epspxq_ttm    IS NOT NULL AND
    B.epspiq_10yISr IS NOT NULL AND
    B.niq_ttm       IS NOT NULL AND
    B.oiadpq_ttm    IS NOT NULL AND
    B.cogsq_ttm     IS NOT NULL AND
    B.saleq_ttm     IS NOT NULL AND
    B.saleq_4yISgx  IS NOT NULL AND
    B.seqq_mrq      IS NOT NULL AND
    B.cheq_mrq      IS NOT NULL AND
    B.atq_mrq       IS NOT NULL AND
    B.dlttq_mrq     IS NOT NULL AND
    B.dlcq_mrq      IS NOT NULL AND
    B.pstkq_mrq     IS NOT NULL AND
    A.datadate BETWEEN B.fromdate AND B.thrudate;
