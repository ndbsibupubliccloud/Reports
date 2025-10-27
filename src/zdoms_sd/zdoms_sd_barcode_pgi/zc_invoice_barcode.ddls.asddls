@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Invoice Details-Barcode Scanning for PGI'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_Invoice_Barcode
  provider contract transactional_query
  as projection on ZR_INVOICE_BARCODE
{
  key InvoiceNo,
  key BillingDocumentItem,
      BillingDocumentDate,
      Plant,
      NonSAPBarcode,
      Material,
      MatDescription,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      BillingQuantity,
      BillingQuantityUnit,
      TotalCarton,
      PartyName
}
