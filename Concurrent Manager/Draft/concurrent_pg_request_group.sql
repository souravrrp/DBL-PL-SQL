select FCPV.USER_CONCURRENT_PROGRAM_NAME,
       FCPV.APPLICATION_ID,FCPV.CONCURRENT_PROGRAM_ID,
       FCPV.CONCURRENT_PROGRAM_NAME
    from
    apps.FND_REQUEST_GROUP_UNITS FRGU,        
    apps.fnd_application FA,
    apps.FND_CONCURRENT_PROGRAMS_VL FCPV
        where
            frgu.application_id=fa.application_id
            --and fa.product_code='CE'
            AND FRGU.REQUEST_UNIT_ID=FCPV.CONCURRENT_PROGRAM_ID
            --AND FCPV.USER_CONCURRENT_PROGRAM_NAME LIKE 'AKG%Bank%'
            and fcpv.CONCURRENT_PROGRAM_ID=224431 
            
select
    USER_CONCURRENT_PROGRAM_NAME,APPLICATION_ID,CONCURRENT_PROGRAM_ID,CONCURRENT_PROGRAM_NAME
    from
        apps.FND_CONCURRENT_PROGRAMS_VL        
        where 
            CONCURRENT_PROGRAM_ID=224431
            

SELECT 
    *
        FROM
            apps.fnd_application FA            