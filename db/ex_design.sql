
-- ex_factdata
--
-- This table holds the data used to calculate factors and
-- search for similar investments efficiently
--

CREATE TABLE ex_factdata (
       
       cid VARCHAR(6) NOT NULL PRIMARY KEY,   -- company id
       sid VARCHAR(3) NOT NULL,	              -- security id

       datadate DATE, -- financial period end date
       fromdate DATE, -- data available from this date
       thrudate DATE, -- new data available after this date
      
       --
       -- search index data
       --
       indidx   INT NOT NULL,  -- industry indexing
       lcapidx  INT NOT NULL,  -- lo market cap (size) indexing
       hcapidx  INT NOT NULL,  -- hi market cap (size) indexing
       lvalidx  INT NOT NULL,  -- ho value (e.g., P/E) indexing
       hvalidx  INT NOT NULL,  -- hi value (e.g., P/E) indexing
       ldividx  INT NOT NULL,  -- lo div yield indexing
       hdividx  INT NOT NULL,  -- hi div yield indexing
       
       --
       -- the fields below are used to calculate factor "on the fly"
       -- see example queries at end of this file
       --
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

-- ex_funddata
--
-- This table holds point in time fundemental data for all companies
--

CREATE TABLE ex_funddata (

       cid VARCHAR(6) NOT NULL PRIMARY KEY,

       type CHAR(3) NOT NULL, -- 'QTR' or 'ANN'

       datadate DATE NOT NULL,
       fromdate DATE NOT NULL,
       thrudate DATE,

       -- INCOME STATEMENT
       saleq	 FLOAT, -- Revenue
       cogsq	 FLOAT, -- Cost of Revenue
       grossq	 FLOAT, -- Gross Profit = [saleq - cogsq]
       xsgnaq	 FLOAT, -- Selling/General/Admin. Expenses
       xrdq	 FLOAT, -- Research & Development
       dpq	 FLOAT, -- Depreciation/Amortization
       xintq	 FLOAT, -- Interest Expense
       xopitq    FLOAT, -- Total Operating Expense (xsgnq + xrdq + dpq + xintx) 
       opiq	 FLOAT, -- Operating Income (oiadpq - xintq)
       noothq	 FLOAT, -- Non-Operating Income (Expenses) (nopiq+spiq)
       piq	 FLOAT, -- Income Before Tax
       txtq	 FLOAT, -- Income Taxes
       miiq	 FLOAT, -- Minority Interest
       dvpq	 FLOAT, -- Dividends Preferred
       xidoq	 FLOAT, -- Extraordinary Items & Discontinued Operations
       niq	 FLOAT, -- Net Inocme

       epspxq    FLOAT, -- Earnings per Share - Basic  Excluding Extraordinary Items
       epspiq    FLOAT, -- Earnings per Share - Basic  Including Extraordinary Items
       epsfxq	 FLOAT, -- Earnings per Share - Diluted  Excluding Extraordinary Items
       epsfiq    FLOAT, -- Earnings per Share - Diluted  Including Extraordinary Items

       cshprq    FLOAT, -- Common Shares Used to Calculate EPS Basic
       cshfdq	 FLOAT, -- Common Shares Used to Calculate EPS Diluted

       -- BALANCE SHEET

       cheq	 FLOAT, -- Cash & Short Term Investments
       rectq	 FLOAT, -- Accounts Receivables
       invtq	 FLOAT, -- Total Inventory
       acoq	 FLOAT, --Other Current Assets, Total
       actq	 FLOAT, -- Total Current Assets
       ppentq	 FLOAT, -- Property/Plant/Equipment, Net
       gdwlq	 FLOAT, -- Goodwill, Net
       intanoq	 FLOAT, -- Intangibles, Net
       ivltq	 FLOAT, -- Long Term Investments
       altoq	 FLOAT, -- Other Long Term Assets, Total
       atq	 FLOAT, -- Total Assets
       dlcq	 FLOAT, -- Debt in Current Liabilities 
       apq	 FLOAT, -- Accounts Payable/Creditors - Trade
       txpq	 FLOAT, -- Income Taxes Payable                      
       lcoq	 FLOAT, -- Current Liabilities - Other                    
       lctq	 FLOAT, -- Current Liabilities - Total                
       dlttq	 FLOAT, -- Long-Term Debt - Total
       txditcq	 FLOAT, -- Deferred Taxes and Investment Tax Credit
       loq	 FLOAT, -- Liabilities - Other                            
       ltq	 FLOAT, -- Liabilities - Total                      

       pstkq	 FLOAT, -- Preferred/Preference Stock (Capital) - Total
       ceqq	 FLOAT, -- Common/Ordinary Equity - Total
       cstkq	 FLOAT, -- Common/Ordinary Stock (Capital)
       capsq	 FLOAT, -- Capital Surplus/Share Premium Reserve
       req	 FLOAT, -- Retained Earnings
       tstkq	 FLOAT, -- Treasury Stock - Total (All Capital)  
       seqq	 FLOAT, -- Stockholders' Equity
       lseq	 FLOAT, -- Liabilities and Stockholders Equity - Total  

       cshoq	 FLOAT, -- Common Shares Outstanding
       cshiq	 FLOAT, -- Common Shares Issued			

       -- CASHFLOW

       oancfq	 FLOAT, -- Operating Cash Flow
       capxq	 FLOAT, -- Capital Expenditures
       dvq	 FLOAT, -- Dividends
       fcflq	 FLOAT, -- Free Cash Flow
   
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- HERE IS AN EXAMPLE OF HOW THE ABOVE SCHEMA CAN BE QUERIED EFFICIENTLY
--
-- var target_ind = get_target_ind();
-- var target_div = get_target_div();
-- var target_cap = get_target_cap();
-- var target_val = get_target_val();
-- 
-- SELECT A.datadate DT,
--       B.oiadpq_ttm/(A.price*A.csho + B.dlttq_mrq - B.cheq_mrq) FACTOR1,
--       ... FACTOR2,
--	 ... FACTOR3,
--	 ...
--	 ... FACTORN
-- FROM prices A,
--    (SELECT cid,fromdate,thrudate,oiadpq,dlttq,cheq 
--     FROM ex_factdata
--     WHERE indidx = target_ind
--     AND ldividx <= target_div
--     AND hdividx >= target_div
--     AND lcapidx <= target_cap
--     AND hcapidx >= target_cap
--     AND lvalidx <= target_val
--     AND hvalidx >= target_val) B
-- WHERE A.cid = B.cid
-- AND A.datadate >= B.fromdate
-- AND A.datadate <= B.thrudate
--