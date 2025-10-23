@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Delivery Details'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_DELIVER_Barcode
  provider contract transactional_query
  as projection on ZR_Delivery_BARCODE
{
  key DeliveryDocument,
  key DeliveryDocumentItem,
      DeliveryDate,
      Plant,
      Nonsapbarcode,
      Material,
      MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      DeliveryQuantity,
      Unit,
      numerator,
      name
}
