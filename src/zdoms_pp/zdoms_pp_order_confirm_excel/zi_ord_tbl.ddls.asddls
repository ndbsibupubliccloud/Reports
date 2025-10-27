@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base view for ord table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ORD_TBL
  as select from zexcel_ord_tbl
  association to parent ZIR_ORD_att as _excel on $projection.FileId = _excel.FileId
{
  key file_id        as FileId,
  key mfgorder       as Mfgorder,
      order_id       as OrderId,
      partial_cnf    as PartialCnf,
      final_cnf      as FinalCnf,
      auto_cnf       as AutoCnf,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      yield_cnf      as YieldCnf,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      cnf_scrap      as CnfScrap,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      rework         as Rework,
      unit           as Unit,
      execution_date as ExecutionDate,
      finish_date    as FinishDate,
      posting_dt     as PostingDt,
      status         as status,

      _excel

}
