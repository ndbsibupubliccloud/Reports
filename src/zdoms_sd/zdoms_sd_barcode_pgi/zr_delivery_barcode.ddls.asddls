@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View For Delivery Details for Bar Code'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_Delivery_BARCODE
  as select from ZI_Delivery_Barcode
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
