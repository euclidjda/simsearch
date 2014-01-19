--
-- DELETES ALL NON-REFERENCED SEARCHES THAT ARE OLDER THAN A DAY
--
DELETE FROM searches WHERE pricedate < DATE_SUB( CURDATE(), INTERVAL 1 DAY )
AND id NOT IN 
(SELECT distinct search_id FROM search_actions WHERE action_id > 1 AND search_id IS NOT NULL);
