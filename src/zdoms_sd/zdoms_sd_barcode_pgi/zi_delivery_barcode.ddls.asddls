@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Details For Barcode Scanning For PGI'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_Delivery_Barcode
  as select from I_DeliveryDocumentItem as del
  association [0..1] to I_ProductUnitsOfMeasure as _uom on  $projection.Material = _uom.Product
                                                        and _uom.AlternativeUnit = 'KAR'

{
  key  del.DeliveryDocument,
  key  del.DeliveryDocumentItem,
       del._DeliveryDocument.DeliveryDate              as DeliveryDate,
       del.Plant,
       del._Product.IndustryStandardName               as Nonsapbarcode,
       del.Material,
       del.DeliveryDocumentItemText                    as MaterialDescription,
       @Semantics.quantity.unitOfMeasure: 'Unit'
       del.OriginalDeliveryQuantity                    as DeliveryQuantity,
       del.BaseUnit                                    as Unit,
       //  del._Product._ProductMeasurementUnit.SIUnitCnvrsnRateNumerator as numerator,
       //  @Semantics.quantity.unitOfMeasure: 'Unit'
       case when _uom.AlternativeUnit = 'KAR'
       then  cast( del.OriginalDeliveryQuantity as abap.dec(13,3)) / cast(_uom.QuantityNumerator as abap.dec(5))
       //    then del.OriginalDeliveryQuantity / _uom.QuantityNumerator
       else 0  end                                     as numerator,
       //  _uom.QuantityNumerator                              as numerator,
       //  del._DeliveryDocument._SoldToParty.CustomerFullName as name,
       del._DeliveryDocument._SoldToParty.CustomerName as name


}
