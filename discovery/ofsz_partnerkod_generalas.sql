with ecrm_partners as (SELECT RIGHT(LEFT(REPLACE(REPLACE([BankACNumber], '-', ''), ' ', ''), 16), 12) AS account
                            , ut.[PartnerKod]                                                         as partnerkod
                            , ROW_NUMBER() OVER (PARTITION BY RIGHT(
            LEFT(REPLACE(REPLACE([BankACNumber], '-', ''), ' ', ''), 16),
            12) ORDER BY [LastModifiedDate] DESC)                                                     AS rn
                       FROM [ECRM_BI].[dbo].[Invoice] iv
                                inner join [WORK].[dbo].[DQ_UGYFELTORZS_PARTNERAZON] ut
                                           ON iv.[Company_Id] = ut.[ECRM.Company.ID] AND ut.[ECRM.Company.ID] <> '-1'

                       WHERE [IsDeleted] = 0
                         AND [BankACNumber] <> ''
                         and [bankacnumber] is not null
                         AND ut.[ECRM.Company.ID] <> '-1')
   , otmr_partners as (SELECT RIGHT([Account], 12)                                        AS account
                            , [CorporationID]
                            , ROW_NUMBER() OVER (PARTITION BY account ORDER BY [Id] DESC) AS rn
                            , ut.PARTNERKOD                                               as partnerkod
                       FROM [OTMR_BI].[dbo].[T_Partner] pa
                                INNER JOIN [WORK].[dbo].[DQ_UGYFELTORZS_PARTNERAZON] ut
                                           ON pa.[CorporationID] = ut.[OTMR.T_Corporation.ID]
                       where ut.[OTMR.T_Corporation.ID] <> '-1')
   , im_partners as (select [BANKSZ_BANKSZAMLA]
                          , [BANKSZ_UGYFEL_ID]
                          , [BANKSZ_BANKSZ_FELVITEL_DATUMA]
                          , [BANKSZ_BANKSZ_MEGSZUNES_DATUMA]
                          , [BANKSZ_TIPUS]
                          , [BANKSZ_KONDICIOSOSZTALY]
                          , ut.PARTNERKOD as partnerkod
                     from IM_BI.dbo.BANKSZAMLA
                              LEFT JOIN [WORK].[dbo].[DQ_UGYFELTORZS_PARTNERAZON] ut
                                        ON [BANKSZ_UGYFEL_ID] = ut.[IM.UGYFET.UGYFET_PARTNER_ID]
                     where ut.[IM.UGYFET.UGYFET_PARTNER_ID] <> '-1')
SELECT [BANKSZ_BANKSZAMLA]
     , [BANKSZ_UGYFEL_ID]
     , [BANKSZ_BANKSZ_FELVITEL_DATUMA]
     , [BANKSZ_BANKSZ_MEGSZUNES_DATUMA]
     , iif([BANKSZ_BANKSZ_MEGSZUNES_DATUMA] = '9999-12-31', 'ÉLŐ', 'MEGSZŰNT')                       számla_státusza
     , [BANKSZ_TIPUS]
     , CASE
           WHEN [BANKSZ_TIPUS] like '1%' THEN 'Lakossági'
           WHEN [BANKSZ_TIPUS] like '2%' THEN 'EV'
           WHEN [BANKSZ_TIPUS] = '311' THEN 'FP Saját'
           WHEN [BANKSZ_TIPUS] like '32%' THEN 'FP Saját'
           WHEN [BANKSZ_TIPUS] like '35%' THEN 'Társasági'
           WHEN [BANKSZ_TIPUS] like '37%' THEN 'Egyesületi'
           WHEN [BANKSZ_TIPUS] like '4%' THEN 'Önkormányzati'
           WHEN [BANKSZ_TIPUS] = '904' THEN 'OFSZ Saját'
           WHEN [BANKSZ_TIPUS] = '907' THEN 'Társasági Technikai'
           WHEN [BANKSZ_TIPUS] like '9%' THEN 'Technikai'
           ELSE
               '?'
    END                                                                                              számla_kategória
     , [BANKSZ_KONDICIOSOSZTALY]
     , CASE
           WHEN [BANKSZ_TIPUS] LIKE '9%' THEN COALESCE(ecrm.[PARTNERKOD], otmr.[PARTNERKOD], im.[PARTNERKOD])
           WHEN COALESCE(im.[PARTNERKOD], ecrm.[PARTNERKOD], otmr.[PARTNERKOD]) IS NOT NULL
               THEN COALESCE(im.[PARTNERKOD], ecrm.[PARTNERKOD], otmr.[PARTNERKOD])
           ELSE NULLIF(CONCAT('P', COALESCE(ugyt.[UGYFET_ADOSZAM], ugyl.[UGYFEL_TXNB])), 'P') END AS partnerkod
from im_partners as im
-- Invoice tábla kötése
         LEFT JOIN ecrm_partners as ecrm
                   on im.BANKSZ_BANKSZAMLA = ecrm.account
         left join otmr_partners as otmr
                   on im.BANKSZ_BANKSZAMLA = otmr.account
         LEFT JOIN [IM_BI].[dbo].[UGYFEL] ugyl
                   ON ugyl.[UGYFEL_CLIENTID] = im.[BANKSZ_UGYFEL_ID] AND ugyl.[UGYFEL_CLIENTID] <> ''
-- UGYFET
         LEFT JOIN [IM_BI].[dbo].[UGYFET] ugyt
                   ON ugyt.[UGYFET_PARTNER_ID] = im.[BANKSZ_UGYFEL_ID] AND ugyt.[UGYFET_PARTNER_ID] <> ''