@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for STD vs Act Report'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_STD_ACT
  provider contract transactional_query
  as projection on ZR_STD_ACT
{
  key   productionorder,
  key   materialcode,
  key   plant,
  key   AlternativeBOM,
  key   BillOfMaterialVariantUsage,
  key   Reservation,
  key   BillOfMaterialItemNodeNumber,
        MfgOrderConfirmation,
        MfgOrderConfirmationGroup,

        materialdescription,
        //        @Semantics.quantity.unitOfMeasure: 'bombaseuom'
        bombaseqty,
        bombaseuom,
        //      AlternativeBOM,
        postingdate,
        //        @Semantics.quantity.unitOfMeasure: 'std_uom'
        std_planqty,
        std_uom,
        alternativebommat,
        std_componentcode,
        componentdescription,
        //        @Semantics.quantity.unitOfMeasure: 'std_unit'
        std_qty,
        std_unit,
        //        @Semantics.quantity.unitOfMeasure: 'act_unit'
        ACT_PRD_QTY,
        act_uom,
        ACTcode,
        ACTdescription,
        //        @Semantics.quantity.unitOfMeasure: 'act_unit'
        Actqty,
        act_unit,
        //        @Semantics.quantity.unitOfMeasure: 'act_unit'
        StdVsActVariance,
        //        @Semantics.quantity.unitOfMeasure: 'bombaseuom'
        ActualDeliveredQuantity,
        ProductionUnit,
        BillOfMaterial,
        compmat,
        //        BillOfMaterialItemNodeNumber,
        //      BillOfMaterialVariantUsage,
        /* Associations */
        _billofmat,
        _ordcomp,
        _ordconf
}
