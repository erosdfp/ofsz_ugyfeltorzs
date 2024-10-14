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
                              from IM_BI.dbo.KARTYA)
and CARDSTATUS = 'ACTIVE';

-- 2. Relationship check - partner ids and account ids
-- Partner ids are not present in Oracle, we can only get this data from IM

-- We have a full match on non-empty bank accounts, and have around 30k card-account relations
select count(*)
from ORACLE_BI.dbo.CARDINFO
         inner join IM_BI.dbo.KARTYA
                    on CARDNO = KARTYA_KARTYASZAM
                        and ACCNO <> concat('2222', KARTYA_BANKSZAMLASZAM)
select count(*)
from ORACLE_BI.dbo.CARDINFO
         inner join IM_BI.dbo.KARTYA
                    on CARDNO = KARTYA_KARTYASZAM
                        and right(ACCNO, 12) <> KARTYA_BANKSZAMLASZAM

-- 3. Currently active check - how many active cards we have
select count(*)
from ORACLE_BI.dbo.CARDINFO
where CARDINFO.CARDSTATUS = 'ACTIVE'

-- 4. Expiration date check - how many rows have differing expiration dates
/* We have differing dates in our source systems, but we can correct with some heuristics
    1. We take the smallest expiration date of the 2
    2. If we have a card which is active, but it's past the expiration date, we set the status to EXPIRED
    3. If we have a card which is expired, but the expiration is not actually due, we set the status to ACTIVE
    4. We don't change anything else.
 */
select top 100 EXPIREDATE
             , KARTYA_LEJARAT
             , IIF(cast(EXPIREDATE as date) < KARTYA_LEJARAT, cast(EXPIREDATE as date), KARTYA_LEJARAT) as valos_lejarati_datum
             , CARDSTATUS
from ORACLE_BI.dbo.CARDINFO
         inner join IM_BI.dbo.KARTYA
                    on CARDNO = KARTYA_KARTYASZAM
where cast(EXPIREDATE as date) <> KARTYA_LEJARAT

-- 5. Card history check - we have 2 rows without a corresponding row in the card table. These are archaic rows, we don't care about them.
select top 100 *
from ORACLE_BI.dbo.CARD_HISTORY
where OPCODE in ('CHANGECARD', 'ACTIVATECARD')
and CARDNO not in (select distinct CARDNO from ORACLE_BI.dbo.CARDINFO)