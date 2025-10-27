@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Details-Barcode Scanning for PGI'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_Invoice_Barcode
  as select from I_BillingDocumentItemBasic as Item
  association [0..1] to I_ProductUnitsOfMeasure as _uom on  $projection.Material = _uom.Product
                                                        and _uom.AlternativeUnit = 'KAR'
{
  key  Item.BillingDocument               as InvoiceNo,
  key  Item.BillingDocumentItem,
       Item._BillingDocumentBasic.BillingDocumentDate,
       Item.Plant,
       Item._Product.IndustryStandardName as NonSAPBarcode,
       Item.Material,
       Item.BillingDocumentItemText       as MatDescription,
       @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
       Item.BillingQuantity,
       Item.BillingQuantityUnit,
       case when _uom.AlternativeUnit = 'KAR'
            then  cast( Item.BillingQuantity as abap.dec(13,3)) / cast(_uom.QuantityNumerator as abap.dec(5))
       //    then del.OriginalDeliveryQuantity / _uom.QuantityNumerator
            else 0  end                   as TotalCarton,

       //  Item._SoldToParty.CustomerFullName as PartyName
       Item._SoldToParty.CustomerName     as PartyName

}
