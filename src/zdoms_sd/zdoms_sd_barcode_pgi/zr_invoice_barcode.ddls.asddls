@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for Invoice Details-Barcode Scanning for PGI'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_INVOICE_BARCODE
  as select from ZI_Invoice_Barcode

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
