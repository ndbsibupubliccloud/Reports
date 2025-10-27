@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base View for GRIR Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_GRIR_REPORT
  as select from I_MaterialDocumentItem_2 as _item
  //    association[0..*] to i_supplier as _supplier on $projection.supplier = _supplier.Supplier

{
  key _item.MaterialDocument                                   as MigoMMNo,
  key _item.MaterialDocumentItem                               as matitem,
  key _item.MaterialDocumentYear                               as matyear,
      _item._MaterialDocumentHeader.PostingDate                as MigoDate,
      //      _head.PostingDate      as MigoDate,
      _item.Plant                                              as Plant,
      _item._MaterialDocumentHeader.MaterialDocumentHeaderText as GateInwardNo,
      //      _head.MaterialDocumentHeaderText as GateInwardNo,
      _item.Supplier                                           as Vendorcode,
      _item._Supplier.SupplierName                             as supplier,
      _item._Supplier.TaxNumber3                               as GSTIN,
      _item._MaterialDocumentHeader.ReferenceDocument          as InvNo,
      _item._MaterialDocumentHeader.DocumentDate               as Invdate

}
where
  GoodsMovementType = '101' //added on 1stAug 2025
