@EndUserText.label: 'Custom Entity for Vendor Ledger Rep'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_VENDOR_LEDGER'
@UI: {
        headerInfo: {
            title: {
                type: #STANDARD
            },
            typeName: 'Vendor Ledger Report',
            typeNamePlural: 'Vendor Ledger Report'
        } }
define custom entity ZI_Vendor_Ledger_report
{
      @UI.facet                   : [
            {
                 id               : 'idVLReport',
                 purpose          : #STANDARD,
                 type             : #COLLECTION,
                 label            : 'Vendor Ledger Report',
                 position         : 10
             },
             {   id               : 'idDetails',
                 parentId         : 'idVLReport',
                 purpose          : #STANDARD,
                 type             : #FIELDGROUP_REFERENCE,
                 label            : 'Vendor Ledger Report',
                 position         : 20,
                 targetQualifier  : 'VLDetails'
             }]

      @UI                         : {
      lineItem                    : [ { position: 10 } ],
      fieldGroup                  : [ { position: 10, qualifier: 'VLDetails'}],
      selectionField              : [ { position: 10 } ] }
      @EndUserText.label          : 'Company Code'
      @Consumption.valueHelpDefinition: [
      { entity                    :  { name    :    'I_Companycode',
                                       element : 'CompanyCode' } } ]
  key CompanyCode                 : abap.char(4);

      @UI                         : {
       lineItem                   : [ { position: 50 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'} ] }
      @EndUserText.label          : 'Document Number'
       @Consumption.filter.hidden: true
  key AccountingDocument          : abap.char(10);

      @UI                         : {
       lineItem                   : [ { position: 10 } ],
       selectionField             : [ { position: 20 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}]}
      @EndUserText.label          : 'Vendor Code'
      @Consumption.valueHelpDefinition: [
       { entity                   :  { name:    'I_Supplier',
                    element       : 'Supplier' } } ]
      @Consumption.filter         : { multipleSelections: true     }
  key Supplier                    : lifnr;

//      @UI.hidden: true
 @UI                         : {
       lineItem                   : [ { position: 210 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}]}
      @Consumption.filter.hidden: true
      Accountingdocumentitem        : abap.numc(3);
      
      @UI                         : {
      lineItem                    : [ { position: 180 } ],
      fieldGroup                  : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'FinancialAccountType'
      @Consumption.filter.hidden: true
      FinancialAccountType        : abap.char(1);

      @UI                         : {
      lineItem                    : [ { position: 20 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'Vendor Name'
      @Consumption.filter.hidden: true
      Supplier_name               : abap.char(80);

      @UI                         : {
      lineItem                    : [ { position: 30 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'AccountingDocumentType'
      @Consumption.filter.hidden: true
      AccountingDocumentType      : abap.char(2);

      @UI                         : {
      lineItem                    : [ { position: 40 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'SpecialGLCode'
      @Consumption.filter.hidden: true
      SpecialGLCode               : abap.char(1);

      @UI                         : {
      lineItem                    : [ { position: 60 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'DocumentDate'
      @Consumption.filter.hidden: true
      DocumentDate                : abap.dats;

      @UI                         : {
       lineItem                   : [ { position: 70 } ],
       selectionField             : [ { position: 30 } ],
        fieldGroup                : [ { position: 10, qualifier: 'VLDetails'}] }
      @Consumption.filter         : {  mandatory: true}
      @EndUserText.label          : 'Posting Date'
      PostingDate                 : abap.dats;

      @UI                         : {
      lineItem                    : [ { position: 80 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'PO Document'
      @Consumption.filter.hidden: true
      PurchasingDocument          : abap.char(10);

      @UI                         : {
      lineItem                    : [ { position: 110 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'Narration'
      @Consumption.filter.hidden: true
      DocumentItemText            : abap.char(50);

      @UI                         : {
      lineItem                    : [ { position: 150 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'Assignment'
      @Consumption.filter.hidden: true
      AssignmentReference         : abap.char(18);

      @UI                         : {
      lineItem                    : [ { position: 170 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'ClearingDate'
      @Consumption.filter.hidden: true
      ClearingDate                : abap.dats;

      @UI                         : {
      lineItem                    : [ { position: 140 } ] }
      @EndUserText.label          : 'Clearing Document'
      @Consumption.filter.hidden: true
      ClearingJournalEntry        : abap.char(10);

      @UI                         : {
      lineItem                    : [ { position: 120 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'Amount'
      @Consumption.filter.hidden: true
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      AmountInCompanyCodeCurrency : abap.curr( 23,2 );

      @UI                         : {
      lineItem                    : [ { position: 160 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'CompanyCodeCurrency'
      @Consumption.filter.hidden: true
      CompanyCodeCurrency         : abap.cuky( 5 );

      @UI                         : {
      lineItem                    : [ { position: 130 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'Dr/Cr'
      @Consumption.filter.hidden: true
      DebitCreditCode             : abap.char(1);

      @UI                         : {
      lineItem                    : [ { position: 180 } ],
       fieldGroup                 : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'OpeningBalance'
      @Consumption.filter.hidden: true
      OpeningBalance              : abap.dec(23,2);

      @UI                         : {
        lineItem                  : [ { position: 110 } ],
         fieldGroup               : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'Balance'
      @Consumption.filter.hidden: true
      Amount                      : abap.dec(23,2);
      
      @UI                         : {
        lineItem                  : [ { position: 190 } ],
         fieldGroup               : [ { position: 10, qualifier: 'VLDetails'}] }
      @EndUserText.label          : 'TDS_Amount'
      @Consumption.filter.hidden: true
      TDS_Amount                      : abap.dec(23,2);
      
      

}
