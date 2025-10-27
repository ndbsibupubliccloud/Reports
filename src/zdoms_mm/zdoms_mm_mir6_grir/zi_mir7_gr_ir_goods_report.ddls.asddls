@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for GR IR Goods Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MIR7_GR_IR_GOODS_REPORT
  as select from I_SupplierInvoiceAPI01        as Header
    inner join   I_SuplrInvcItemPurOrdRefAPI01 as Item         on  Header.SupplierInvoice = Item.SupplierInvoice
                                                               and Header.FiscalYear      = Item.FiscalYear
    inner join   I_JournalEntry                as Accounting   on  Item.FiscalYear                      = Accounting.FiscalYear
                                                               and Accounting.OriginalReferenceDocument = concat(
      Item.ReferenceDocument, Item.FiscalYear
    )
    inner join   I_MaterialDocumentHeader_2    as MatdocHeader on  Item.ReferenceDocument = MatdocHeader.MaterialDocument
                                                               and Header.FiscalYear      = MatdocHeader.MaterialDocumentYear
    inner join   I_MaterialDocumentItem_2      as MatdocItem   on  MatdocHeader.MaterialDocument     = MatdocItem.MaterialDocument
                                                               and MatdocHeader.MaterialDocumentYear = MatdocItem.MaterialDocumentYear
    inner join   I_Supplier                    as Supplier     on MatdocItem.Supplier = Supplier.Supplier
{

  key Header.SupplierInvoice,
  key Header.FiscalYear,
      Header.PostingDate,
      case Header.SupplierInvoiceStatus
      when 'A' then 'Parked'
      when 'B' then 'Parked and completed'
      when 'C' then 'Parked and held'
      when 'D' then 'Entered and held'
      when 'E' then 'Parked and Released'
      else Header.SupplierInvoiceStatus end as SupplierInvoiceStatus,
      Header.SupplierInvoiceIDByInvcgParty,
      Accounting.AccountingDocument,
      MatdocHeader.MaterialDocument,
      MatdocItem.Supplier,
      Accounting.AccountingDocCreatedByUser,
      Supplier.SupplierName
}
where
  (
       Header.SupplierInvoiceStatus = 'A'
    or Header.SupplierInvoiceStatus = 'B'
    or Header.SupplierInvoiceStatus = 'C'
    or Header.SupplierInvoiceStatus = 'D'
    or Header.SupplierInvoiceStatus = 'E'
  )
group by
  Header.SupplierInvoice,
  Header.FiscalYear,
  Header.PostingDate,
  Header.SupplierInvoiceStatus,
  Header.SupplierInvoiceIDByInvcgParty,
  Accounting.AccountingDocument,
  MatdocHeader.MaterialDocument,
  MatdocItem.Supplier,
  Accounting.AccountingDocCreatedByUser,
  Supplier.SupplierName
