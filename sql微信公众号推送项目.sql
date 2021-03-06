#微信公众号推送效果评估案例#
--------------------
#表1：微信活动推送表push（推送日期、推送成本）#
#表2：微信推送明细表push detail（阅读日期）#
#表3：销售表sales（交易金额、交易时间）#
--------------------------------------
#业务问题：哪些微信推送活动有比较好的效果？#
#评价标准：ROI=收入/活动成本，找到ROI高的微信推送活动#
---------------------------------------
#其他细节#
#如何明确一笔交易是由哪个特定的推送活动产生的？#
#有3个关键时间点：微信活动推送的时间、用户阅读推送内容的时间、用户发生购买行为的时间#
#由此，可以定义判断一个交易是由微信推送活动所带来的2个条件：#
#对于每一条用户阅读时间是在推送时间的24小时以内#
#交易发生时间是在阅读时间的24小时以内#
----------------------------------------

#步骤一：从微信推送活动中，只保留阅读日期是在推送日期一天以内的记录#

CREATE TABLE push_reader AS
SELECT DISTINCT a.*,b.drop_dt
FROM push_detail a
INNER JOIN push b ON a.camp_id=b.camp_id
WHERE a.read_date>=b.drop_dt
AND a.read_date<=DATE(b.drop_dt)+1;

#步骤二：把满足条件的用户（在活动推送一天内阅读）和发生过购买行为的用户进行匹配链接#

CREATE TABLE push_sales AS
SELECT DISTINCT a.camp_id,
SUM(b.amount) AS total_amount
FROM push_reader a
INNER JOIN sales b 
ON a.member_id=b.member_id
WHERE b.transaction_date>=a.read_date
AND b.transaction_date<=DATE(a.read_date)+1
GROUP BY camp_id;

#步骤三：计算ROI，并找到ROI最高的推送活动#

SELECT a.camp_id, b.total_amount, a.cost, b.total_amount/a.cost AS ROI
FROM push a
INNER JOIN push_sales b 
ON a.camp_id=b.camp_id
ORDER BY ROI DESC;