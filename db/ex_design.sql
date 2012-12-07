-- ex_prices

CREATE TABLE securities (

     cid VARCHAR(6) NOT NULL, -- company id
     sid VARCHAR(3) NOT NULL, -- security id
     
     cusip varchar(9),
     dldtei date,
     dlrsni varchar(8),
     dsci varchar(28),
     epf varchar(1),
     exchg smallint,
     excntry varchar(3),
     ibtic varchar(6),
     isin varchar(12),
     secstat varchar(1),
     sedol varchar(7),
     tic varchar(20),
     tpci varchar(8),
     name varchar(64),
     ticker varchar(20), 

     INDEX securities_ix01 (cid,sid),
     INDEX securities_ix02 (ticker),
     INDEX securities_ix03 (tic)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- This table holds price data
--

CREATE TABLE ex_prices (

       cid VARCHAR(6) NOT NULL, -- company id
       sid VARCHAR(3) NOT NULL, -- security id
       
       datadate DATE NOT NULL, -- weekly or month, tbd

       csho   FLOAT, -- common shares outstanding
       ajex   FLOAT, -- adjustment factor
       price  FLOAT, -- closing price on datadate
       pch1m  FLOAT, -- 1 month price change
       pch3m  FLOAT, -- 3 month price change
       pch6m  FLOAT, -- 6 month price change
       pch9m  FLOAT, -- 9 month price change
       pch12m FLOAT, -- 12 month price change

       INDEX ex_price_ix01 (cid,sid,datadate)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_econ
--
-- This table holds economic data
--

CREATE TABLE ex_econ (

       datadate DATE NOT NULL, -- weekly or month, tbd

       cape      FLOAT,
       tbill1mo  FLOAT,
       tbill6mo  FLOAT,
       note10yr  FLOAT,

       INDEX ex_econ_ix01 (datadate)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_factdata
--
-- This table holds the data used to calculate factors and
-- search for similar investments efficiently
--

CREATE TABLE ex_factdata (
       
       cid VARCHAR(6) NOT NULL, -- company id
       sid VARCHAR(3) NOT NULL, -- security id

       fromdate DATE NOT NULL, -- data available from this date
       thrudate DATE NOT NULL, -- new data available after this date
       datadate DATE NOT NULL, -- financial period end date
      
       --
       -- search index data
       --
       idxind  INT NOT NULL,  -- industry indexing
       idxdiv  INT NOT NULL,  -- pays dividend as of datadate
       idxnew  INT NOT NULL,  -- is new issue? (within 9 mo of IPO)
       idxcapl INT NOT NULL,  -- lo market cap (size) in range fromdate -> thrudate
       idxcaph INT NOT NULL,  -- hi market cap (size) in range fromdate -> thrudate
       idxvall INT NOT NULL,  -- ho value (e.g., P/E) in range fromdate -> thrudate
       idxvalh INT NOT NULL,  -- hi value (e.g., P/E) in range fromdate -> thrudate
       
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
 
       INDEX ex_factdata_ix01 (cid,sid,fromdate,thrudate), -- point-in-time index
       INDEX ex_factdata_ix02 (idxind,idxdiv,idxnew,idxcapl,idxcaph,idxvall,idxvalh)

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ex_funddata
--
-- This table holds point in time fundemental data for all companies
--

CREATE TABLE ex_fundmts (

       cid VARCHAR(6) NOT NULL, -- company id (gvkey in compustat)

       fromdate DATE NOT NULL,
       thrudate DATE NOT NULL,
       datadate DATE NOT NULL,

       type CHAR(3) NOT NULL, -- 'ANN' or 'QTR'

       -- INCOME STATEMENT
       sale	 FLOAT, -- Revenue
       cogs	 FLOAT, -- Cost of Revenue
       gross	 FLOAT, -- Gross Profit = [sale - cogs]
       xsgna	 FLOAT, -- Selling/General/Admin. Expenses
       xrd	 FLOAT, -- Research & Development
       dp	 FLOAT, -- Depreciation/Amortization
       xint	 FLOAT, -- Interest Expense
       xopit     FLOAT, -- Total Operating Expense (xsgnq + xrdq + dpq + xintx) 
       opi	 FLOAT, -- Operating Income (oiadpq - xintq)
       nooth	 FLOAT, -- Non-Operating Income (Expenses) (nopiq+spiq)
       pi	 FLOAT, -- Income Before Tax
       txt	 FLOAT, -- Income Taxes
       mii	 FLOAT, -- Minority Interest
       dvp	 FLOAT, -- Dividends Preferred
       xido	 FLOAT, -- Extraordinary Items & Discontinued Operations
       ni	 FLOAT, -- Net Inocme

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
       fcfl	 FLOAT, -- Free Cash Flow

       -- INDEXES
       INDEX ex_fundmts_01 (cid,fromdate,thrudate,type)     

) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- HERE IS AN EXAMPLE OF HOW THE ABOVE SCHEMA CAN BE QUERIED EFFICIENTLY

SET @target_ind = '4520'; 
SET @target_div = 0;
SET @target_new = 0;
SET @target_cap = 1000;
SET @target_val = 14;

SELECT A.datadate DT,B.idxind,B.idxdiv,B.idxcapl,B.idxvall,
      A.price,A.csho,B.oiadpq_ttm,B.dlttq_mrq,B.dlcq_mrq,
      B.cheq_mrq,B.pstkq_mrq,B.mibq_mrq,B.mibnq_mrq
FROM ex_prices A,
   (SELECT *
    FROM ex_factdata
    WHERE idxind = @target_ind
    AND idxdiv   = @target_div
    AND idxnew   = @target_new
    AND idxcapl >= 0.5*@target_cap
    AND idxcaph <= 5*@target_cap
    AND idxvall <= @target_val
    AND idxvalh >= @target_val) B
WHERE A.cid = B.cid
AND A.sid = B.sid
AND A.datadate BETWEEN B.fromdate AND B.thrudate
