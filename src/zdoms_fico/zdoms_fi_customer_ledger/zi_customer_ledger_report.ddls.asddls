@EndUserText.label: 'Custom Entity for Customer Ledger Report'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_CUSTOMER_LEDGER'
@UI: {
        headerInfo: {
            title: {
                type: #STANDARD
            },
            typeName: 'Customer Ledger Report',
            typeNamePlural: 'Customer Ledger Report'
        } }
define custom entity ZI_Customer_Ledger_Report
{
      @UI.facet                   : [
             {
                  id              : 'idCLReport',
                  purpose         : #STANDARD,
                  type            : #COLLECTION,
                  label           : 'Customer Ledger Report',
                  position        : 10
              },
              {   id              : 'idDetails',
                  parentId        : 'idCLReport',
                  purpose         : #STANDARD,
                  type            : #FIELDGROUP_REFERENCE,
                  label           : 'Customer Ledger Report',
                  position        : 20,
                  targetQualifier : 'CLDetails'
              }]

      @UI                         : {
      lineItem                    : [ { position: 5 } ],
      fieldGroup                  : [ { position: 10, qualifier: 'CLDetails'}],
      selectionField              : [ { position: 10 } ] }
      @EndUserText.label          : 'Company Code'
      @Consumption.valueHelpDefinition: [
      { entity                    :  { name    :    'I_Companycode',
                                       element : 'CompanyCode' } } ]
  key CompanyCode                 : abap.char(4);

      @UI                         : {
       lineItem                   : [ { position: 60 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'} ] }
      @EndUserText.label          : 'Doc No'
      @Consumption.filter.hidden  : true
  key AccountingDocument          : abap.char(10);

      @UI                         : {
       lineItem                   : [ { position: 10 } ],
       selectionField             : [ { position: 20 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}]}
      @EndUserText.label          : 'Customer Code'
      @Consumption.valueHelpDefinition: [
       { entity                   :  { name    :    'I_Customer',
                                       element : 'Customer' } } ]
      @Consumption.filter         : { multipleSelections: true     }
  key Customer                    : kunnr;

      @UI                         : {
      lineItem                    : [ { position: 40 } ],
      fieldGroup                  : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'FinancialAccountType'
      @Consumption.filter.hidden  : true
      FinancialAccountType        : abap.char(1);

      @UI                         : {
      lineItem                    : [ { position: 20 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Customer name'
      @Consumption.filter.hidden  : true
      Customer_name               : abap.char(80);

      @UI                         : {
      lineItem                    : [ { position: 45 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Doc Type'
      @Consumption.filter.hidden  : true
      AccountingDocumentType      : abap.char(2);

      @UI                         : {
      lineItem                    : [ { position: 50 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'SpecialGLCode'
      @Consumption.filter.hidden  : true
      SpecialGLCode               : abap.char(1);

      @UI                         : {
      lineItem                    : [ { position: 70 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Document Date'
      @Consumption.filter.hidden  : true
      DocumentDate                : abap.dats;

      @UI                         : {
       lineItem                   : [ { position: 80 } ],
       selectionField             : [ { position: 30 } ],
        fieldGroup                : [ { position: 10, qualifier: 'CLDetails'}] }
      @Consumption.filter         : {  mandatory: true}
      @EndUserText.label          : 'Posting Date'
      PostingDate                 : abap.dats;

      @UI                         : {
      lineItem                    : [ { position: 200 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'DocumentItemText'
      @Consumption.filter.hidden  : true
      DocumentItemText            : abap.char(50);

      @UI                         : {
      lineItem                    : [ { position: 30 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Assignment'
      @Consumption.filter.hidden  : true
      AssignmentReference         : abap.char(18);

      @UI                         : {
      lineItem                    : [ { position: 140 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'ClearingDocDate'
      @Consumption.filter.hidden  : true
      ClearingDate                : abap.dats;

      @UI                         : {
      lineItem                    : [ { position: 130 } ] }
      @EndUserText.label          : 'ClearingDoc'
      @Consumption.filter.hidden  : true
      ClearingJournalEntry        : abap.char(10);

      @UI                         : {
      lineItem                    : [ { position: 110 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Amount'
      @Consumption.filter.hidden  : true
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency : abap.curr( 23,2 );

      @UI                         : {
      lineItem                    : [ { position: 160 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'CompanyCodeCurrency'
      @Consumption.filter.hidden  : true
      CompanyCodeCurrency         : abap.cuky( 5 );

      @UI                         : {
      lineItem                    : [ { position: 115 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Dr/Cr'
      @Consumption.filter.hidden  : true
      DebitCreditCode             : abap.char(1);

      @UI                         : {
      lineItem                    : [ { position: 100 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'OpeningBalance'
      @Consumption.filter.hidden  : true
      OpeningBalance              : abap.dec(23,2);

      @UI                         : {
        lineItem                  : [ { position: 120 } ],
         fieldGroup               : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Bal Amount'
      @Consumption.filter.hidden  : true
      Amount                      : abap.dec(23,2);

      @UI                         : {
        lineItem                  : [ { position: 90 } ],
         fieldGroup               : [ { position: 10, qualifier: 'CLDetails'}] }
      @EndUserText.label          : 'Reference Document'
      @Consumption.filter.hidden  : true
      ReferenceDoc                : abap.char(16);

}
