@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item View for Gate Entry - RGP/NRGP'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_GATEPASS_ITEM
  as select from zmm_gatepassitem
  association to parent ZI_GATEPASS_HDR as _hdr on  $projection.Gatepasstype   = _hdr.Gatepasstype
                                                and $projection.Gatepassnumber = _hdr.Gatepassnumber

{

  key gatepasstype        as Gatepasstype,
  key gatepassnumber      as Gatepassnumber,
  key slno                as Slno,

      materialnumber      as Materialnumber,
      materialdescription as Materialdescription,
      @Semantics.quantity.unitOfMeasure : 'uom'
      quantity            as Quantity,
      uom                 as Uom,
      @Semantics.amount.currencyCode : 'currency'
      value               as Value,
      currency            as Currency,
      batchno             as Batchno,
      expectedreturndate  as Expectedreturndate,
      returndate          as Returndate,
      @Semantics.quantity.unitOfMeasure : 'uom'
      totalreceivedqty    as Totalreceivedqty,
      @Semantics.quantity.unitOfMeasure : 'uom'
      receivedqty         as Receivedqty,
      remarks             as ItemRemarks,
      @Semantics.user.createdBy: true
      createdby           as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat           as Createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby       as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat       as Lastchangedat,

      /* associations */
      _hdr

}
