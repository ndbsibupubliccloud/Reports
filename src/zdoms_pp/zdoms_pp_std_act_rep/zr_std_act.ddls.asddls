@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View For STD vs Act report'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_STD_ACT
  as select from ZI_STD_ACT_FINAL
  //composition of target_data_source_name as _association_name
{
  key     productionorder,
  key     materialcode,
  key     plant,
  key     AlternativeBOM,
  key     BillOfMaterialVariantUsage,
  key     Reservation,
  key     BillOfMaterialItemNodeNumber,
          MfgOrderConfirmation,
          MfgOrderConfirmationGroup,

          materialdescription,
          //          @Semantics.quantity.unitOfMeasure: 'bombaseuom'
          cast(bombaseqty as abap.dec( 12, 3 ) )               as bombaseqty,
          bombaseuom,

          postingdate,
          //          @Semantics.quantity.unitOfMeasure: 'std_uom'
          cast(std_planqty as abap.dec( 12, 3 ))               as std_planqty,
          std_uom,
          alternativebommat,
          std_componentcode,
          componentdescription,
          //          @Semantics.quantity.unitOfMeasure: 'std_unit'
          cast(std_qty as abap.dec( 12, 3 ) )                  as std_qty,
          std_unit,
          //          @Semantics.quantity.unitOfMeasure: 'act_unit'
          cast(ACT_PRD_QTY as abap.dec( 12, 3 ) )              as ACT_PRD_QTY,
          act_uom,
          ACTcode,
          ACTdescription,
          //          @Semantics.quantity.unitOfMeasure: 'bombaseuom'
          cast(Actqty as abap.dec( 12, 3 ) )                   as Actqty,
          act_unit,
          //          @Semantics.quantity.unitOfMeasure: 'bombaseuom'
          cast(StdVsActVariance as abap.dec( 12, 3 ) )         as StdVsActVariance,
          //          @Semantics.quantity.unitOfMeasure: 'bombaseuom'
          cast( ActualDeliveredQuantity as abap.dec( 12, 3 ) ) as ActualDeliveredQuantity,
          ProductionUnit,
          BillOfMaterial,
          compmat,
          //       BillOfMaterialItemNodeNumber,
          /* Associations */
          _billofmat,
          _ordcomp,
          _ordconf
          //    _association_name // Make association public
}
