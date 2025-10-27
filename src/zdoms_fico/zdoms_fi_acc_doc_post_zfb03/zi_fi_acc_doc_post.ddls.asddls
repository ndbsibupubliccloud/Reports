@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI GL Account Document Post Line Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_FI_ACC_DOC_POST
  as select from I_GLAccountLineItemRawData as _glaccountitem
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
      //_glaccountitem._ClearingJournalEntry.AccountingDocumentHeaderText,
      //_glaccountitem._GLAccountInChartOfAccounts._Text[Language = $session.system_language ].GLAccountName,
      
      
      case
      when _glaccountitem.Customer is not initial
        then _glaccountitem._Customer.CustomerName
      when (_glaccountitem.Customer is initial
       and _glaccountitem.Supplier is not initial)
        then _glaccountitem._Supplier.SupplierName
      else _glaccountitem._GLAccountInChartOfAccounts._Text[Language = $session.system_language ].GLAccountName
      end as AccountingDocumentHeaderText,
      
      _glaccountitem.DocumentItemText,
      _glaccountitem.TaxCode,
      _glaccountitem._CostCenter._Text[Language = $session.system_language ].CostCenterDescription,
      _glaccountitem.ProfitCenter,
      _glaccountitem.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast(
         case
             when _glaccountitem.DebitCreditCode = 'S'
             then cast(_glaccountitem.AmountInCompanyCodeCurrency as abap.dec(13,2))
             else cast( 0 as abap.dec(13,2))
         end
         as abap.curr(13,2)
      )   as DebitAmount,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast(
          case
              when _glaccountitem.DebitCreditCode = 'H'
              then cast(_glaccountitem.AmountInCompanyCodeCurrency as abap.dec(13, 2))
              else cast( 0 as abap.dec(13,2))
          end
          as abap.curr(13,2)
      )   as CreditAmount,

      case
      when _glaccountitem.Customer is not initial
        then _glaccountitem.Customer
      when (_glaccountitem.Customer is initial
       and _glaccountitem.Supplier is not initial)
        then _glaccountitem.Supplier
      else _glaccountitem.GLAccount
      end as GL/Vender/CustCode

}
where
       _glaccountitem.SourceLedger           = '0L'
  and(
       _glaccountitem.AccountingDocumentType = 'KR'
    or _glaccountitem.AccountingDocumentType = 'KZ'
    or _glaccountitem.AccountingDocumentType = 'SA'
    or _glaccountitem.AccountingDocumentType = 'DG'
    or _glaccountitem.AccountingDocumentType = 'DZ'
    or _glaccountitem.AccountingDocumentType = 'DR'
    or _glaccountitem.AccountingDocumentType = 'ZP'
  )
