@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Acc Doc Post Line Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_FI_ACC_DOC_POST
  provider contract transactional_query
  as projection on ZIR_FI_ACC_DOC_POST
{

      @Search.defaultSearchElement: true
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_GLAccountLineItemRawData', element: 'SourceLedger'} }]
      @ObjectModel.text.element: ['CompanyCode']
  key SourceLedger,
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_GLAccountLineItemRawData', element: 'LedgerLineItem'} }]
      @Search.defaultSearchElement: true
  key LedgerGLLineItem,
      @Search.defaultSearchElement: true
  key CompanyCode,
      @Search.defaultSearchElement: true
  key FiscalYear,
      @Search.defaultSearchElement: true
  key AccountingDocument,
      @Search.defaultSearchElement: true
      @Consumption.filter: {  mandatory: true}
      PostingDate,
      @Search.defaultSearchElement: true
      DocumentDate,
      ReferenceDocument,
      SettlementReferenceDate,
      AccountingDocumentType,
      GLAccount,
      Supplier,
      Customer,
      CostCenter,
      AccountingDocumentHeaderText,
      DocumentItemText,
      TaxCode,
      CostCenterDescription,
      ProfitCenter,
      CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      DebitAmount,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      CreditAmount,
      GL/Vender/CustCode as GL_Vender_CustCode,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalDebitAmount,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalCreditAmount
}
