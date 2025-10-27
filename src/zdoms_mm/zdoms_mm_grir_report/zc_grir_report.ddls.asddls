@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View for GRIR Report'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_GRIR_REPORT
  provider contract transactional_query
  as projection on ZR_GRIR_REPORT
{
  key MigoMMNo,
  key matitem,
  key matyear,
      MigoDate,
      Plant,
      GateInwardNo,
      Vendorcode,
      supplier,
      GSTIN,
      InvNo,
      Invdate
}
