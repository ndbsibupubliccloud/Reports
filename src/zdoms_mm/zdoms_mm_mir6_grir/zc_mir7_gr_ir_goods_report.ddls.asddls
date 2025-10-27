@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for GR IR Goods Report'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_MIR7_GR_IR_GOODS_REPORT 
provider contract transactional_query
as projection on ZR_MIR7_GR_IR_GOODS_REPORT


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

