@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Sales Register Report'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SALES_DATA_REPORT
  as select from    I_BillingDocumentBasic         as billingheader

    inner join      I_BillingDocumentItemBasic     as billingitem         on billingitem.BillingDocument = billingheader.BillingDocument

    left outer join I_Customer                     as customer            on customer.Customer = billingheader.SoldToParty

    left outer join I_SalesDocumentItem            as salesdocumentitem   on  salesdocumentitem.SalesDocument         = billingitem.ReferenceSDDocument
                                                                          and salesdocumentitem.SalesDocumentItem     = billingitem.ReferenceSDDocumentItem
                                                                          and billingitem.ReferenceSDDocumentCategory = 'C'

    left outer join I_SalesDocumentItem            as salesitem           on  salesitem.SalesDocument                 = billingitem.SalesDocument
                                                                          and salesitem.SalesDocumentItem             = billingitem.SalesDocumentItem
                                                                          and billingitem.ReferenceSDDocumentCategory = 'J' //aubel

    left outer join I_SalesDocumentItem            as salesdocitem        on  salesdocitem.SalesDocument              = billingitem.SalesDocument
                                                                          and salesdocitem.SalesDocumentItem          = billingitem.SalesDocumentItem
                                                                          and billingitem.ReferenceSDDocumentCategory = 'T' //change on 24/05/2025

    left outer join ZI_SALES_REGISTER              as Amount              on  Amount.billingdocument     = billingitem.BillingDocument
                                                                          and Amount.billingdocumentitem = billingitem.BillingDocumentItem


    left outer join I_ProductPlantIntlTrd          as ProductPlantIntlTrd on  ProductPlantIntlTrd.Product = billingitem.Product
                                                                          and ProductPlantIntlTrd.Plant   = billingitem.Plant


    left outer join I_ProductUnitsOfMeasure        as productuom          on  productuom.Product         = salesitem.Product
                                                                          and productuom.BaseUnit        = salesitem.OrderQuantityUnit 
                                                                          and productuom.AlternativeUnit = 'KAR'

    left outer join I_Region                       as region              on  region.Region  = customer.Region
                                                                          and region.Country = customer.Country
    left outer join I_CustomerSalesArea            as _salesarea          on  _salesarea.SalesOrganization   = billingheader.SalesOrganization
                                                                          and _salesarea.Customer            = billingheader.SoldToParty
                                                                          and _salesarea.Division            = billingheader.Division
                                                                          and _salesarea.DistributionChannel = billingheader.DistributionChannel
    left outer join I_AdditionalCustomerGroup1Text as _custgroup          on _custgroup.AdditionalCustomerGroup1 = _salesarea.AdditionalCustomerGroup1


{
  key billingitem.BillingDocument,
  key billingitem.BillingDocumentItem,
      billingitem._SalesDocument.SalesDocumentDate                                                            as document_date,
      billingitem._BillingDocumentBasic.BillingDocumentType,
      billingitem.ReferenceSDDocumentCategory                                                                 as ReferenceSDDocumentCategory,
      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then billingitem.ReferenceSDDocument
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then billingitem.SalesDocument
           when billingitem.ReferenceSDDocumentCategory = 'T'   
           then billingitem.SalesDocument                       
       else ''
      end                                                                                                     as documentnumber,
      billingheader.SoldToParty                                                                               as custid,
      billingheader._SoldToParty.CustomerName                                                                 as customername,
      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then salesdocumentitem.ShipToParty
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then salesitem.ShipToParty
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then salesdocitem.ShipToParty                       
       else ''
      end                                                                                                     as shiptopartycode,
      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then salesdocumentitem._ShipToParty.CustomerName
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then salesitem._ShipToParty.CustomerName
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then salesdocitem._ShipToParty.CustomerName              
       else ''
      end                                                                                                     as shiptopartyname,
      billingitem.ProductGroup                                                                                as materialgroup,
      billingitem._ProductGroup._ProductGroupText[ Language = $session.system_language ].ProductGroupName     as materialgroupdesc, 
      billingitem.Product                                                                                     as material,
      billingitem.BillingDocumentItemText                                                                     as materialname,
      @Semantics.quantity.unitOfMeasure: 'orderquantityunit'
      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then salesdocumentitem.OrderQuantity
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then salesitem.OrderQuantity
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then salesdocitem.OrderQuantity                  
           else null end                                                                                      as orderquanity,
      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then salesdocumentitem.OrderQuantityUnit
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then salesitem.OrderQuantityUnit
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then salesdocitem.OrderQuantityUnit          

       else null
      end                                                                                                     as orderquantityunit, 

      case when productuom.AlternativeUnit = 'KAR'
           then ( cast(salesitem.OrderQuantity as abap.dec(15,3)) / cast ( productuom.QuantityNumerator as abap.dec(5) )  )
        else null
      end                                                                                                     as order_qty_in_cb,

      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then coalesce(cast( salesdocumentitem.NetAmount as abap.dec(15,2) ),0 ) + coalesce(cast( salesdocumentitem.TaxAmount as abap.dec(15,2) ),0 )
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then coalesce(cast( salesitem.NetAmount as abap.dec(15,2) ),0 ) + coalesce(cast( salesitem.TaxAmount as abap.dec(15,2) ),0 )
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then coalesce(cast( salesdocitem.NetAmount as abap.dec(15,2) ),0 ) + coalesce(cast( salesdocitem.TaxAmount as abap.dec(15,2) ),0 )
      else null
      end                                                                                                     as ordervalue,
      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then salesdocumentitem._SalesDocument.PurchaseOrderByCustomer
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then salesitem._SalesDocument.PurchaseOrderByCustomer
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then salesdocitem._SalesDocument.PurchaseOrderByCustomer
             else null end                                                                                    as custpono,

      case when billingitem.ReferenceSDDocumentCategory = 'C'
           then salesdocumentitem._SalesDocument.CustomerPurchaseOrderDate
           when billingitem.ReferenceSDDocumentCategory = 'J'
           then salesitem._SalesDocument.CustomerPurchaseOrderDate
           when billingitem.ReferenceSDDocumentCategory = 'T'
           then salesdocitem._SalesDocument.CustomerPurchaseOrderDate
           else null end                                                                                      as cutpodat,
      ''                                                                                                      as cust_po_expirydate,
      productuom.QuantityNumerator                                                                            as cbsize,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      case when billingitem.BillingDocumentType = 'S1'
             or billingitem.BillingDocumentType = 'CBRE'
             or  billingitem.BillingDocumentType = 'G2'
            then ( - billingitem.BillingQuantity )
       else billingitem.BillingQuantity
      end                                                                                                     as billingquantity, // change on 12/05/2025

      billingitem.BillingQuantityUnit,
      productuom.AlternativeUnit                                                                              as alternate_qty,
      case when productuom.AlternativeUnit = 'KAR'
           then ( cast(billingitem.BillingQuantity as abap.dec(13,3)) / cast ( productuom.QuantityNumerator as abap.dec(5) )  )
        else null
      end                                                                                                     as no_of_cb,
      billingitem.BaseUnit                                                                                    as uom,
      @Semantics.amount.currencyCode: 'Transactioncur'
      Amount.mrp_value                                                                                        as mrp_value,
      Amount.unit_price                                                                                       as unit_price,
      cast( billingitem.NetAmount as abap.dec(15,2) )                                                         as inv_basic_value,
      billingitem.TransactionCurrency                                                                         as item_transactioncurrency,
      Amount.igst,
      Amount.cgst,
      Amount.sgst,
      Amount.igstvalue,
      Amount.cgstvalue,
      Amount.sgstvalue,
      Amount.transactioncurrency,
      Amount.transaction_currency,
      Amount.trans_currency,
      @Semantics.amount.currencyCode: 'trans_currency'
      Amount.roundup,
      @Semantics.amount.currencyCode: 'Transactioncur'
      Amount.discount_amount,
      Amount.Transactioncur                                                                                   as Transactioncur,
      cast( billingitem.NetAmount + billingitem.TaxAmount as abap.dec(15,2) )                                 as finalvalue,
      billingitem.Plant                                                                                       as plant,
      billingitem._SalesDocument.SalesDocumentType                                                            as ordertype,
      billingheader._DistributionChannel._Text[ Language = $session.system_language ].DistributionChannelName as billtypedesc, // 08042025
      billingheader.DocumentReferenceID                                                                       as invoiceno,
      billingheader.CreationDate,
      case substring( cast( billingheader.CreationDate as abap.char(8) ), 5, 2 )
       when '01' then 'Jan'
       when '02' then 'Feb'
       when '03' then 'Mar'
       when '04' then 'Apr'
       when '05' then 'May'
       when '06' then 'Jun'
       when '07' then 'Jul'
       when '08' then 'Aug'
       when '09' then 'Sep'
       when '10' then 'Oct'
       when '11' then 'Nov'
       when '12' then 'Dec'
      else ' '
      end                                                                                                     as invmonth,
      region._RegionText[ Language = $session.system_language ].RegionName                                    as customerstate, 
      ''                                                                                                      as zones,
      ''                                                                                                      as zonedescription,
      ''                                                                                                      as sales_district_description,
      billingheader._CustomerGroup._Text[ Language = $session.system_language ].CustomerGroupName             as customergroup1, 
      _custgroup.AdditionalCustomerGroup1Name                                                                 as customergroup2, 
      customer.TaxNumber3                                                                                     as custgstno, 
      ProductPlantIntlTrd.ConsumptionTaxCtrlCode                                                              as HSNcode, 
      Amount.cashdiscount                                                                                     as cashdiscount,
      billingheader.AccountingTransferStatus                                                                  as postingstatus, 
      ''                                                                                                      as headertext,
      billingheader.TransactionCurrency                                                                       as currency,
      ''                                                                                                      as producthierarchy,
      ''                                                                                                      as pendingqty,
      ''                                                                                                      as pendingqtyincb,
      ''                                                                                                      as pending_order_basicvalue,
      ''                                                                                                      as pending_isgst_value,
      ''                                                                                                      as pending_sgst_value,
      ''                                                                                                      as pending_cgst_value,
      ''                                                                                                      as round_up,
      ''                                                                                                      as final_value,
      ''                                                                                                      as reason_of_rejection,
      productuom.QuantityNumerator                                                                            as cb_size,
      ''                                                                                                      as exc_inv_no,
      ''                                                                                                      as exc_inv_dt,
      ''                                                                                                      as excise,
      ''                                                                                                      as vat,
      ''                                                                                                      as cst,
      ''                                                                                                      as add_others,
      ''                                                                                                      as discount_promotion,
      ''                                                                                                      as additional_vat,
      ''                                                                                                      as add_in_freight,
      ''                                                                                                      as add_in_insurance,
      ''                                                                                                      as tcs,
      billingheader.DistributionChannel
}
where
  billingheader.BillingDocumentType <> 'JSN' 
