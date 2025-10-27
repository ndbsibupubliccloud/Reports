@EndUserText.label: 'Stock Report Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MM_STOCK_REPORT'
@UI: {
        headerInfo: {
            title: {
                value: 'Material',
                type: #STANDARD
            },
            typeName: 'Stock Report',
            typeNamePlural: 'Stock Report Details'
        } }
define custom entity ZI_STOCK_Custom
  // with parameters parameter_name : parameter_type
{
      @UI.facet            : [{
           id              : 'Material',
           position        :10 ,
           label           : 'Stock Report',
           type            : #IDENTIFICATION_REFERENCE

          }]

      @UI.selectionField   : [{position: 10 }]
      @UI                  : { lineItem: [{ position: 10 }],identification: [{ position: 10 }] }
      @EndUserText.label   : 'Material Code'
      @Consumption         : { valueHelpDefinition: [{ entity : { name: 'ZI_MATERIALDES_F4',
                                                                      element: 'Product'  } } ] }

  key Material             : matnr;
      @UI.selectionField   : [{position: 20 }]
      @UI                  : { lineItem: [{ position: 30 }],identification: [{ position: 30 }] }
      @EndUserText.label   : 'Plant'
      @Consumption         : { valueHelpDefinition: [{ entity : { name: 'I_Plant',
                                                                      element: 'Plant'  } } ] }
  key plant                : werks_d;
      @UI                  : { lineItem: [{ position: 20 }],identification: [{ position: 20 }] }
      @EndUserText.label   : 'Material Description'
      material_description : maktx;
      @UI                  : { lineItem: [{ position: 40 }],identification: [{ position: 40 }] }
      @EndUserText.label   : 'Stock'
      //      @Semantics.quantity.unitOfMeasure: 'pouom'
      stock                : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 50 }],identification: [{ position: 50 }] }
      @EndUserText.label   : 'Buffer Stock'
      //      @Semantics.quantity.unitOfMeasure: 'pouom'
      bufferstock          : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 60 }],identification: [{ position: 60 }] }
      @EndUserText.label   : 'Buffer Days'
      bufferdays           : abap.numc( 2 );
      @UI                  : { lineItem: [{ position: 70 }],identification: [{ position: 70 }] }
      @EndUserText.label   : 'Pending PO'
      //      @Semantics.quantity.unitOfMeasure: 'pouom'
      pendingpo            : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 80 }],identification: [{ position: 80 }] }
      @EndUserText.label   : 'PO Uom'
      pouom                : meins;
      @UI                  : { lineItem: [{ position: 90 }],identification: [{ position: 90 }] }
      @EndUserText.label   : 'Previous3'
      previous3            : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 100 }],identification: [{ position: 100 }] }
      @EndUserText.label   : 'Previous2'
      previous2            : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 110 }],identification: [{ position: 110 }] }
      @EndUserText.label   : 'Previous1'
      previous1            : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 120 }],identification: [{ position: 120 }] }
      @EndUserText.label   : 'Current Qty'
      Currentqty           : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 130 }],identification: [{ position: 130 }] }
      @EndUserText.label   : 'Avg Consumption'
      avgconsumption       : abap.dec( 13, 3 );
      @UI                  : { lineItem: [{ position: 140 }],identification: [{ position: 140 }] }
      @EndUserText.label   : 'Stock Days'
      stockdays            : abap.dec( 13, 2 );
      @UI                  : { lineItem: [{ position: 150 }],identification: [{ position: 150 }] }
      @EndUserText.label   : 'Last PO Rate'
      @Semantics.amount.currencyCode: 'cuky'
      lastporate           : abap.curr( 15, 2 );
      @UI                  : { lineItem: [{ position: 160 }],identification: [{ position: 160 }] }
      @EndUserText.label   : 'Price Unit'
      @Semantics.amount.currencyCode: 'cuky'
      priceunit            : abap.curr( 11, 2 );
      @UI                  : { lineItem: [{ position: 170 }],identification: [{ position: 170 }] }
      @EndUserText.label   : 'Safety Stock'
      safety_stock         : abap.dec( 11, 3 );
      cuky                 : abap.cuky( 5 );
      @UI                  : { lineItem: [{ position: 180 }],identification: [{ position: 180 }] }
      @EndUserText.label   : 'Nil Stock & Cons'
      nilstock             : abap.char( 3 );
      @UI                  : { lineItem: [{ position: 190 }],identification: [{ position: 190 }] }
      @EndUserText.label   : 'Remarks'
      Remarks              : abap.char( 128 );
      @UI.selectionField   : [{position: 30 }]
      //      @UI                  : { lineItem: [{ position: 30 }],identification: [{ position: 30 }] }
      //      @EndUserText.label   : 'Plant'
      @Consumption         : { valueHelpDefinition: [{ entity : { name: 'I_MaterialDocumentItem_2',
                                                                      element: 'PostingDate'  } } ],
                                filter:{ selectionType:#SINGLE,mandatory: true }}
      //                                      defaultValue: 'SY-DATUM' }
      //      @Consumption.defaultValue: 'SY-DATUM'
      pdate                : budat;


}
