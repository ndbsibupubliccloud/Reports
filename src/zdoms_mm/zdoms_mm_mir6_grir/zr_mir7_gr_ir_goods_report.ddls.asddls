@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for GR IR Goods Report'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_MIR7_GR_IR_GOODS_REPORT as select from ZI_MIR7_GR_IR_GOODS_REPORT

{
    key SupplierInvoice,
    key FiscalYear,
    PostingDate,
    SupplierInvoiceStatus,
    SupplierInvoiceIDByInvcgParty,
    AccountingDocument,
    MaterialDocument,
    Supplier,
    AccountingDocCreatedByUser,
    SupplierName
}


