@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Final Base View for std vs act report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_STD_ACT_FINAL
  as select from ZI_STD_ACT
{

  key      productionorder,
  key      materialcode,
  key      plant,
  key      AlternativeBOM,
  key      BillOfMaterialVariantUsage,
  key      Reservation,
  key      BillOfMaterialItemNodeNumber,
           MfgOrderConfirmation,
           MfgOrderConfirmationGroup,
           materialdescription,
           @Semantics.quantity.unitOfMeasure: 'BOMBaseUom'
           bombaseqty,
           bombaseuom,
           max(_ordconf.PostingDate)                              as postingdate,
           @Semantics.quantity.unitOfMeasure: 'STD_UOM'
           std_planqty,
           std_uom,
           alternativebommat,
           _ordcomp.Material                                      as std_componentcode,
           componentdescription,
           @Semantics.quantity.unitOfMeasure: 'std_unit'
           _ordcomp.RequiredQuantity                              as std_qty,
           _ordcomp.BaseUnit                                      as std_unit,
           @Semantics.quantity.unitOfMeasure: 'bombaseuom'
           ACT_PRD_QTY,
           act_uom,
           _ordcomp.Material                                      as ACTcode,

           ACTdescription,
           @Semantics.quantity.unitOfMeasure: 'act_unit'
           _ordcomp.WithdrawnQuantity                             as Actqty,
           _ordcomp.EntryUnit                                     as act_unit,
           @Semantics.quantity.unitOfMeasure: 'act_unit'
           _ordcomp.RequiredQuantity - _ordcomp.WithdrawnQuantity as StdVsActVariance,
           //           @Semantics.quantity.unitOfMeasure: 'STD_UOM'
           cast(ActualDeliveredQuantity as abap.dec( 12, 3 ))     as ActualDeliveredQuantity,
           ProductionUnit,
           BillOfMaterial,
           compmat,


           _ordconf,
           _billofmat,
           _ordcomp
}
group by
  productionorder,
  materialcode,
  plant,
  AlternativeBOM,
  BillOfMaterialVariantUsage,
  MfgOrderConfirmationGroup,
  MfgOrderConfirmation,
  materialdescription,
  bombaseqty,
  bombaseuom,
  std_planqty,
  std_uom,
  alternativebommat,
  ACTdescription,
  ACT_PRD_QTY,
  act_uom,
  Reservation,
  ActualDeliveredQuantity,
  BillOfMaterial,
  BillOfMaterialItemNodeNumber,
  _ordcomp.Material,
  componentdescription,
  _ordcomp.RequiredQuantity,
  _ordcomp.BaseUnit,
  ProductionUnit,
  _ordcomp.WithdrawnQuantity,
  _ordcomp.EntryUnit,
  compmat
