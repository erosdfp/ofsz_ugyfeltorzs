select BANKSZ_BANKSZAMLA,
       BANKSZ_UGYFEL_ID,
       BANKSZ_BANKSZ_FELVITEL_DATUMA,
       BANKSZ_BANKSZ_MEGSZUNES_DATUMA,
       BANKSZ_TIPUS,
       BANKSZ_KONDICIOSOSZTALY,
       [BANKSZ_SZAMLAALAPOT]
from IM_BI.dbo.BANKSZAMLA szamla
         left join IM_BI.dbo.UGYFEL ugyfel
                   on szamla.BANKSZ_UGYFEL_ID = ugyfel.UGYFEL_CLIENTID
where szamla.BANKSZ_UGYFEL_ID is not null and ugyfel.UGYFEL_CLIENTID is null