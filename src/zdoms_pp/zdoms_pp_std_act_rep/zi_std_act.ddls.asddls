@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base View for standard vs actual report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_STD_ACT
  as select from I_MfgOrderForExtraction as _ordext
  association [0..*] to I_MfgOrderConfirmation       as _ordconf   on  $projection.productionorder = _ordconf.ManufacturingOrder
                                                                   and $projection.plant           = _ordconf.Plant

  association [0..*] to ZI_MULTILLEVEL_BOM           as _billofmat on  $projection.materialcode               = _billofmat.Material
                                                                   and $projection.plant                      = _billofmat.Plant
                                                                   and $projection.BillOfMaterialVariantUsage = _billofmat.BOMUsage
                                                                   and $projection.AlternativeBOM             = _billofmat.AlternativeBOM
                                                                   and $projection.BillOfMaterial             = _billofmat.BillOfMaterial

  association [0..*] to I_MfgOrderOperationComponent as _ordcomp   on  $projection.Reservation     = _ordcomp.Reservation
                                                                   and $projection.compmat         = _ordcomp.Material
                                                                   and $projection.productionorder = _ordcomp.ManufacturingOrder
                                                                   and _ordcomp.GoodsMovementType  = '261'

{

  key      _ordext.ManufacturingOrder      as productionorder,
  key      _ordext.Material                as materialcode,
  key      _ordext.ProductionPlant         as plant,
  key      _ordext.BillOfMaterialVariant   as AlternativeBOM,
  key      _ordext.BillOfMaterialVariantUsage,
  key      _ordext.Reservation,
  key      _billofmat.BillOfMaterialItemNodeNumber,
           _ordext.MfgOrderConfirmation,
           _ordconf.MfgOrderConfirmationGroup,
           _billofmat.MaterialDescription  as materialdescription,
           @Semantics.quantity.unitOfMeasure: 'BOMBaseUom'
           _billofmat.Quantity             as bombaseqty,
           _billofmat.BaseUOM              as bombaseuom,


           _ordconf.PostingDate            as postingdate,
           @Semantics.quantity.unitOfMeasure: 'STD_UOM'
           _ordext.MfgOrderPlannedTotalQty as std_planqty,
           _ordext.ProductionUnit          as std_uom,
           _ordext.BillOfMaterialVariant   as alternativebommat,
           _billofmat.ComponentDescription as componentdescription,
           @Semantics.quantity.unitOfMeasure: 'act_uom'
           _ordext.ActualDeliveredQuantity as ACT_PRD_QTY,
           _ordext.ProductionUnit          as act_uom,
           _billofmat.ComponentDescription as ACTdescription,
           @Semantics.quantity.unitOfMeasure: 'STD_UOM'
           _ordext.ActualDeliveredQuantity,
           _ordext.ProductionUnit,
           _ordext.BillOfMaterial,
           _billofmat.BOMComponent         as compmat,

           _ordconf,
           _billofmat,
           _ordcomp


}

where
  MfgOrderItemActualDeliveryDate is not initial;
