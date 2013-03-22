-- ex_securities

DROP TABLE IF EXISTS ex_securities;
CREATE TABLE ex_securities (

     cid VARCHAR(6) NOT NULL, -- company id
     sid VARCHAR(3) NOT NULL, -- security id
     
     cusip	varchar(9),
     dldtei	date,
     dlrsni	varchar(8),
     dsci	varchar(28),
     epf	varchar(1),
     exchg	smallint,
     excntry	varchar(3),
     ibtic	varchar(6),
     isin	varchar(12),
     secstat	varchar(1),
     sedol	varchar(7),
     tic	varchar(20),
     tpci	varchar(8),
     name	varchar(64),
     ticker	varchar(20), 

     INDEX ex_securities_ix01 (cid,sid),
     INDEX ex_securities_ix02 (ticker),
     INDEX ex_securities_ix03 (tic)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- This table holds price data
--

DROP TABLE IF EXISTS ex_prices;
CREATE TABLE ex_prices (

       cid VARCHAR(6) NOT NULL, -- company id
       sid VARCHAR(3) NOT NULL, -- security id
       
       datadate DATE NOT NULL, -- weekly or month, tbd

       csho   FLOAT, -- common shares outstanding
       ajex   FLOAT, -- adjustment factor
       price  FLOAT, -- closing price on datadate
       volume FLOAT, -- volume (not currently populated)
       pch1m  FLOAT, -- 1 month price change
       pch3m  FLOAT, -- 3 month price change
       pch6m  FLOAT, -- 6 month price change
       pch9m  FLOAT, -- 9 month price change
       pch12m FLOAT, -- 12 month price change

       INDEX ex_price_ix01 (cid,sid,datadate)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_factdata
--
-- This table holds the data used to calculate factors and
-- search for similar investments efficiently
--

DROP TABLE IF EXISTS ex_factdata;
CREATE TABLE ex_factdata (
       
       cid VARCHAR(6) NOT NULL, -- company id
       sid VARCHAR(3) NOT NULL, -- security id

       fromdate DATE NOT NULL, -- data available from this date
       thrudate DATE NOT NULL, -- new data available after this date
       datadate DATE NOT NULL, -- financial period end date
      
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
       dlcq_mrq	     FLOAT, -- Short-Term Debt
       dlttq_mrq     FLOAT, -- Long-Term Debt
       pstkq_mrq     FLOAT, -- Prefered Stock
       mibnq_mrq     FLOAT, -- Non-controlling interests non-redeamable - balance
       mibq_mrq	     FLOAT, -- Non-controlling interests redeamable - balance sheet
       fcfq_mrq	     FLOAT, -- Free Cash Flow TTM
       fcfq_4yISm    FLOAT, -- Free Cash Flow 4 year median
       
       INDEX ex_factdata_ix01 (cid,sid,fromdate,thrudate), -- point-in-time index
       INDEX ex_factdata_ix02 (idxsec,idxnew,idxcapl,idxcaph),
       INDEX ex_factdata_ix03 (idxgrp,idxnew,idxcapl,idxcaph),
       INDEX ex_factdata_ix04 (idxind,idxnew,idxcapl,idxcaph),
       INDEX ex_factdata_ix05 (idxsub,idxnew,idxcapl,idxcaph)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_funddata
--
-- This table holds point in time fundemental data for all companies
--

DROP TABLE IF EXISTS ex_fundmts;
CREATE TABLE ex_fundmts (

       cid VARCHAR(6) NOT NULL, -- company id (gvkey in compustat)
       sid VARCHAR(3) NOT NULL, -- security id

       fromdate DATE NOT NULL,
       thrudate DATE NOT NULL,
       datadate DATE NOT NULL,

       type CHAR(3) NOT NULL, -- 'ANN' or 'QTR'

       -- INCOME STATEMENT
       sale	 FLOAT, -- Revenue
       cogs	 FLOAT, -- Cost of Revenue
       gross	 FLOAT, -- Gross Profit = [sale - cogs]
       xsga	 FLOAT, -- Selling/General/Admin. Expenses
       xrd	 FLOAT, -- Research & Development
       dp	 FLOAT, -- Depreciation/Amortization
       xint	 FLOAT, -- Interest Expense
       xopit     FLOAT, -- Total Operating Expense (xsgna + xrd + dp + xint) 
       opi	 FLOAT, -- Operating Income (oiadp - xint)
       nooth	 FLOAT, -- Non-Operating Income (Expenses) (nopi + spi)
       pi	 FLOAT, -- Income Before Tax
       txt	 FLOAT, -- Income Taxes
       mii	 FLOAT, -- Minority Interest
       dvp	 FLOAT, -- Dividends Preferred
       xido	 FLOAT, -- Extraordinary Items & Discontinued Operations
       ni	 FLOAT, -- Net Income

       epspx     FLOAT, -- Earnings per Share -Basic Excluding Extraordinary Items
       epspi     FLOAT, -- Earnings per Share -Basic Including Extraordinary Items
       epsfx	 FLOAT, -- Earnings per Share -Diluted Excluding Extraordinary Items
       epsfi     FLOAT, -- Earnings per Share -Diluted Including Extraordinary Items

       cshpr     FLOAT, -- Common Shares Used to Calculate EPS Basic
       cshfd	 FLOAT, -- Common Shares Used to Calculate EPS Diluted

       -- BALANCE SHEET
       che	 FLOAT, -- Cash & Short Term Investments
       rect	 FLOAT, -- Accounts Receivables
       invt	 FLOAT, -- Total Inventory
       aco	 FLOAT, -- Other Current Assets, Total
       act	 FLOAT, -- Total Current Assets
       ppent	 FLOAT, -- Property/Plant/Equipment, Net
       gdwl	 FLOAT, -- Goodwill, Net
       intano	 FLOAT, -- Intangibles, Net
       ivlt	 FLOAT, -- Long Term Investments
       alto	 FLOAT, -- Other Long Term Assets, Total
       at	 FLOAT, -- Total Assets
       dlc	 FLOAT, -- Debt in Current Liabilities 
       ap	 FLOAT, -- Accounts Payable/Creditors - Trade
       txp	 FLOAT, -- Income Taxes Payable                      
       lco	 FLOAT, -- Current Liabilities - Other                    
       lct	 FLOAT, -- Current Liabilities - Total                
       dltt	 FLOAT, -- Long-Term Debt - Total
       txditc	 FLOAT, -- Deferred Taxes and Investment Tax Credit
       lo	 FLOAT, -- Liabilities - Other                            
       lt	 FLOAT, -- Liabilities - Total                      

       pstk	 FLOAT, -- Preferred/Preference Stock (Capital) - Total
       ceq	 FLOAT, -- Common/Ordinary Equity - Total
       cstk	 FLOAT, -- Common/Ordinary Stock (Capital)
       caps	 FLOAT, -- Capital Surplus/Share Premium Reserve
       re	 FLOAT, -- Retained Earnings
       tstk	 FLOAT, -- Treasury Stock - Total (All Capital)  
       seq	 FLOAT, -- Stockholders' Equity
       lse	 FLOAT, -- Liabilities and Stockholders Equity - Total  

       csho	 FLOAT, -- Common Shares Outstanding
       cshi	 FLOAT, -- Common Shares Issued			

       -- CASHFLOW
       oancf	 FLOAT, -- Operating Cash Flow
       capx	 FLOAT, -- Capital Expenditures
       dv	 FLOAT, -- Dividends
       fcf	 FLOAT, -- Free Cash Flow

       -- INDEXES
       INDEX ex_fundmts_01 (cid,sid,fromdate,thrudate,type)     

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS ex_centers;
CREATE TABLE ex_centers (

     ex_centers_id INT NOT NULL,

     cid        VARCHAR(6) NOT NULL, -- company id
     sid        VARCHAR(3) NOT NULL, -- security id
     pricedate  DATE       NOT NULL, -- pricing weekly

     INDEX ex_centers_ix01 (ex_centers_id), 
     INDEX ex_centers_ix02 (cid,sid,pricedate)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS ex_dists;
CREATE TABLE ex_dists (

     ex_centers_id INT NOT NULL,

     cid        VARCHAR(6) NOT NULL, -- company id
     sid        VARCHAR(3) NOT NULL, -- security id
     pricedate  DATE       NOT NULL, -- pricing date weekly
     dist       FLOAT,      

     INDEX ex_dist_ix01 (ex_centers_id), 
     INDEX ex_dist_ix02 (cid,sid,pricedate),
     INDEX ex_dist_ix03 (dist)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_econ
--
-- This table holds economic data
--

DROP TABLE IF EXISTS ex_econ;
CREATE TABLE ex_econ (

       datadate DATE NOT NULL, -- weekly or month, tbd

       cape      FLOAT,
       tbill1mo  FLOAT,
       tbill6mo  FLOAT,
       note10yr  FLOAT,

       INDEX ex_econ_ix01 (datadate)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;
