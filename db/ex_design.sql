-- ex_qtrfund

CREATE TABLE ex_qtrfund (

       ckey     VARCHAR2 NOT NULL PRIMARY KEY,
       datadate DATE,
       fromdate DATE,
       thrudate DATE,

       -- INCOME STATEMENT

       -- BALANCE SHEET

       -- CASHFLOW

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_annfund

CREATE TABLE ex_qtrfund (

       ckey     VARCHAR2 NOT NULL PRIMARY KEY,
       datadate DATE,
       fromdate DATE,
       thrudate DATE,

       -- INCOME STATEMENT

       -- BALANCE SHEET

       -- CASHFLOW

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_factors

CREATE TABLE ex_factors (

       ckey     VARCHAR2   NOT NULL PRIMARY KEY,
       sid      VARCHAR(3) NOT NULL,
       datadate DATE,
       
       -- search index data

       capidx   INT,
       validx   INT,
       indidx   INT,
       
       -- factors go here (eventually there will be many more)

       oiadpq_ttmDmrkcap_mrq DECIMAL(10,6), -- earnings yield
       oiadpq_ttmDseqq_mrq   DECIMAL(10,6), -- return on equity
       saleq_4yISgx          DECIMAL(10,6), -- sales growth 4 yrs
       epspiq_10yISr	     DECIMAL(10,6), -- consistency of eps growth
       seqq_ttmDatq_ttm	     DECIMAL(10,6)  -- equity / assets

) ENGINE=InnoDB DEFAULT CHARSET=latin1;
