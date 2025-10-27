@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'RootView for FI GL AccDoc Post LineItems'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define root view entity ZIR_FI_ACC_DOC_POST
  as select from ZI_FI_ACC_DOC_POST     as _glaccountitem
    inner join   ZI_FI_ACC_DOC_POST_SUM as _sumaccdoc on _sumaccdoc.AccountingDocument = _glaccountitem.AccountingDocument
{
  key _glaccountitem.SourceLedger,
  key _glaccountitem.LedgerGLLineItem,
  key _glaccountitem.CompanyCode,
  key _glaccountitem.FiscalYear,
  key _glaccountitem.AccountingDocument,
      _glaccountitem.PostingDate,
      _glaccountitem.DocumentDate,
      _glaccountitem.ReferenceDocument,
      _glaccountitem.SettlementReferenceDate,
      _glaccountitem.AccountingDocumentType,
      _glaccountitem.GLAccount,
      _glaccountitem.Supplier,
      _glaccountitem.Customer,
      _glaccountitem.CostCenter,
      _glaccountitem.AccountingDocumentHeaderText,
      _glaccountitem.DocumentItemText,
      _glaccountitem.TaxCode,
      _glaccountitem.CostCenterDescription,
      _glaccountitem.ProfitCenter,
      _glaccountitem.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _glaccountitem.DebitAmount,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      abs(_glaccountitem.CreditAmount)  as CreditAmount,
      _glaccountitem.GL/Vender/CustCode,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _sumaccdoc.TotalDebitAmount,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      abs(_sumaccdoc.TotalCreditAmount) as TotalCreditAmount
}
