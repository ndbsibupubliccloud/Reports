@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for order data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@UI.createHidden: #(Hide_create) 
define view entity ZC_ORD_TBL
  //  provider contract transactional_query
  as projection on ZI_ORD_TBL
{
  key FileId,
  key Mfgorder,
      OrderId,
      PartialCnf,
      FinalCnf,
      AutoCnf,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      YieldCnf,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      CnfScrap,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Rework,
      Unit,
      ExecutionDate,
      FinishDate,
      PostingDt,
      status,
      /* Associations */
      _excel : redirected to parent ZC_ORD_ATT
}
