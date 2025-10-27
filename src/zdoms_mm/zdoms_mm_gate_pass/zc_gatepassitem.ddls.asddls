@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Gate Entry Item - RGP/NRGP'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_GatePassITEM
  as projection on ZI_GATEPASS_ITEM
{
  key Gatepasstype,
  key Gatepassnumber,
  key Slno,
      Materialnumber,
      Materialdescription,
      @Semantics.quantity.unitOfMeasure : 'uom'
      Quantity,
      Uom,
      @Semantics.amount.currencyCode : 'currency'
      Value,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      Currency,
      Batchno,
      Expectedreturndate,
      Returndate,
      @Semantics.quantity.unitOfMeasure : 'uom'
      Totalreceivedqty,
      @Semantics.quantity.unitOfMeasure : 'uom'
      Receivedqty,
      ItemRemarks,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,

      /* Associations */
      _hdr : redirected to parent ZC_GatePassHDR
}
