@ClientHandling.type: #CLIENT_DEPENDENT
//@AbapCatalog.deliveryClass: #APPLICATION_DATA
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get BOM Components (Multi Level)'
define table function ZI_BOM_Components
  with parameters
    @Environment.systemField: #CLIENT
    p_clnt  : zd_mandt,
    p_matnr : abap.char( 40 ),
    p_werks : abap.char( 4 )
  //    p_status : zd_bomstatus1
  //    p_datum : datum
returns
{
  key Mandt                : abap.clnt;
  key Material             : matnr;
  key Plant                : werks_d;
      BOMStatus            : zd_bomstatus1;
      AlternativeBOM       : abap.char(2);
      MaterialDescription  : maktx;
      subBOM               : matnr;
      SubBOMDesc           : maktx;
      SUBAlternativeBOM    : abap.char(2);
      Quantity             : abap.quan(13,3);
      BaseUOM              : abap.unit( 3 );
      BOMComponent         : matnr;
      ComponentDescription : maktx;
      ComponentQty         : abap.quan(13,3);
      ComponentUOM         : abap.unit( 3 );
      ValidityStartDate    : datuv;
      ValidityEndDate      : datuv;
      BOMLevel             : abap.int4;
      creationon           : datum;

}
implemented by method
  zcl_pp_get_bom_components=>get_bom_component