select KARTYA_KARTYASZAM,
       KARTYA_FELVITELDDATUMA,
       KARTYA_NYITASDATUMA,
       KARTYA_LEJARAT,
       KARTYA_BANKSZAMLASZAM,
       KARTYA_PARTNER_ID
from IM_BI.dbo.KARTYA k
         left join IM_BI.dbo.UGYFET u
                   on k.KARTYA_PARTNER_ID = u.UGYFET_PARTNER_ID
where k.KARTYA_PARTNER_ID is not null
  and k.KARTYA_PARTNER_ID <> '0000000000'
  and u.UGYFET_PARTNER_ID is null

