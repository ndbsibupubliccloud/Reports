@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Root View For GRIR Report'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_GRIR_REPORT
  as select from ZI_GRIR_REPORT
  //composition of target_data_source_name as _association_name
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
      //    _association_name // Make association public
}
