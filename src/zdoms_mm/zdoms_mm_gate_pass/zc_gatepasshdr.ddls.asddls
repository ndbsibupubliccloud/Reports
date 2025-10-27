@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Gate Entry HDR - RGP/NRGP'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_GatePassHDR
  provider contract transactional_query
  as projection on ZI_GATEPASS_HDR
{
  key Gatepasstype,
  key Gatepassnumber,
      Plant,
      Storagelocation,
      Vendorcode,
      Vendorname,
      Gstno,
      State,
      Pincode,
      Address,
      Vehicleno,
      Departmentname,
      Requestername,
      Transporterdetails,
      Remarks,
      Lorrynum,
      Modeoftransport,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      printform,

      /* Associations */
      _item : redirected to composition child ZC_GatePassITEM

}
