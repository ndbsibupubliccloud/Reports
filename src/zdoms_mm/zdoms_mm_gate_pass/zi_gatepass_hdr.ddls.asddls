@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header View for Gate Entry - RGP/NRGP'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_GATEPASS_HDR
  as select from zmm_gateentryhdr
  composition [0..*] of ZI_GATEPASS_ITEM as _item

{
  key gatepasstype       as Gatepasstype,
  key gatepassnumber     as Gatepassnumber,

      plant              as Plant,
      storagelocation    as Storagelocation,
      vendorcode         as Vendorcode,
      vendorname         as Vendorname,
      gstno              as Gstno,
      state              as State,
      pincode            as Pincode,
      address            as Address,
      vehicleno          as Vehicleno,
      departmentname     as Departmentname,
      requestername      as Requestername,
      transporterdetails as Transporterdetails,
      remarks            as Remarks,
      lorry_num          as Lorrynum,
      modeoftransport    as Modeoftransport,
      @Semantics.user.createdBy: true
      createdby          as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat          as Createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby      as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      as Lastchangedat,
      printform          as printform,

      /* associations */
      _item // Make association public
}
