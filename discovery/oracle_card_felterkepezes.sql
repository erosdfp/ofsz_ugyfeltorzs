-- 1. Simple completeness check - which card numbers are only present in one db.
-- 0 rows, Kartya can only be a subset of CARDINFO
select count(*)
from IM_BI.dbo.KARTYA
where KARTYA_KARTYASZAM not in (select distinct CardNo
                                from ORACLE_BI.dbo.CARDINFO);

-- 91.705 rows. Cardinfo is a proper superset of Kartya
select top 100 *
from ORACLE_BI.dbo.CARDINFO
where CARDINFO.CARDNO not in (select distinct KARTYA_KARTYASZAM
                              from IM_BI.dbo.KARTYA);

-- 2. Relationship check - partner ids and account ids
-- Partner ids are not present in Oracle, we can only get this data from IM

-- We have a full match on non-empty bank accounts, and have around 30k card-account relations
select CARDSTATUS, count(*)
from ORACLE_BI.dbo.CARDINFO
         inner join IM_BI.dbo.KARTYA
                    on CARDNO = KARTYA_KARTYASZAM
                        and ACCNO <> concat('2222', KARTYA_BANKSZAMLASZAM)
                        and CARDSTATUS <> 'AVAILABLE'
group by CARDSTATUS
with rollup

select count(*)
from ORACLE_BI.dbo.CARDINFO
         inner join IM_BI.dbo.KARTYA
                    on CARDNO = KARTYA_KARTYASZAM
                        and ACCNO <> concat('2222', KARTYA_BANKSZAMLASZAM)

-- 3. Currently active check - how many active cards we have
select count(*)
from ORACLE_BI.dbo.CARDINFO
where CARDINFO.CARDSTATUS = 'ACTIVE'

