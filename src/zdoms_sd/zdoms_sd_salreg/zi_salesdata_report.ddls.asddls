@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Sales data Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_SALESDATA_REPORT
  as select from ZI_SALES_DATA_REPORT
{
  key BillingDocument,
  key BillingDocumentItem,
      document_date,
      BillingDocumentType,
      ReferenceSDDocumentCategory,
      documentnumber,
      custid,
      customername,
      shiptopartycode,
      shiptopartyname,
      materialgroup,
      materialgroupdesc,
      material,
      materialname,
      @Semantics.quantity.unitOfMeasure: 'orderquantityunit'
      orderquanity,
      orderquantityunit,
      order_qty_in_cb,
      ordervalue,
      custpono,
      cutpodat,
      cust_po_expirydate,
      cbsize,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      billingquantity,
      BillingQuantityUnit,
      alternate_qty,
      case
      when ZI_SALES_DATA_REPORT.BillingDocumentType  = 'S1'  or
      ZI_SALES_DATA_REPORT.BillingDocumentType  = 'CBRE' or
      ZI_SALES_DATA_REPORT.BillingDocumentType  = 'G2' then
      - no_of_cb
      else no_of_cb end                                                                            as no_of_cb, //change on 12.05.2025
      //      no_of_cb,
      uom,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      round( mrp_value, 2 )                                                                        as mrp_value,
      case
      when ZI_SALES_DATA_REPORT.BillingDocumentType  = 'S1'  or
      ZI_SALES_DATA_REPORT.BillingDocumentType  = 'CBRE' or
      ZI_SALES_DATA_REPORT.BillingDocumentType  = 'G2' then
      - round( unit_price, 2 )
      else round( unit_price, 2 ) end                                                              as unit_price,
      //      inv_basic_value, comment on 12/05/2025
      case
            when ZI_SALES_DATA_REPORT.BillingDocumentType  = 'S1'  or
            ZI_SALES_DATA_REPORT.BillingDocumentType  = 'CBRE' or
            ZI_SALES_DATA_REPORT.BillingDocumentType  = 'G2' then
            - inv_basic_value
            else inv_basic_value end                                                               as inv_basic_value, // change on 12/05/2025
      item_transactioncurrency,
      igst,
      cgst,
      sgst,
      case
           when ZI_SALES_DATA_REPORT.BillingDocumentType  = 'S1'  or
           ZI_SALES_DATA_REPORT.BillingDocumentType  = 'CBRE' or
           ZI_SALES_DATA_REPORT.BillingDocumentType  = 'G2' then
           - igstvalue
           else igstvalue end                                                                      as igstvalue, // change on 12.05.2025
      case
           when ZI_SALES_DATA_REPORT.BillingDocumentType  = 'S1'  or
           ZI_SALES_DATA_REPORT.BillingDocumentType  = 'CBRE' or
           ZI_SALES_DATA_REPORT.BillingDocumentType  = 'G2' then
           - cgstvalue
           else cgstvalue end                                                                      as cgstvalue, //change on 12.05.2025

      case when
       ZI_SALES_DATA_REPORT.BillingDocumentType  = 'S1'  or
       ZI_SALES_DATA_REPORT.BillingDocumentType  = 'CBRE' or
       ZI_SALES_DATA_REPORT.BillingDocumentType  = 'G2'
       then - sgstvalue
       else sgstvalue
       end                                                                                         as sgstvalue, // change on 12.05.2025
      transactioncurrency,
      transaction_currency,
      trans_currency,
      roundup,
      discount_amount,
      Transactioncur,
      finalvalue,
      plant,
      ordertype,
      billtypedesc,
      invoiceno,
      CreationDate,
      invmonth,
      customerstate,
      zones,
      zonedescription,
      sales_district_description,
      customergroup1,
      customergroup2,
      custgstno,
      HSNcode,
      cashdiscount,
      postingstatus,
      headertext,
      currency,
      producthierarchy,
      cbsize * ( order_qty_in_cb - no_of_cb )                                                      as pendingqty,
      order_qty_in_cb - no_of_cb                                                                   as pendingqtyincb,
      case
      when DistributionChannel ='10' or DistributionChannel = '20'
      then round( ( ( order_qty_in_cb - no_of_cb ) * unit_price ), 2 )
      when DistributionChannel = '30'
      then
       round( ( ( cbsize * ( order_qty_in_cb - no_of_cb ) ) * unit_price ), 2 )
       else null end                                                                               as pending_order_basicvalue,
      ( round( ( ( ( cbsize * ( order_qty_in_cb - no_of_cb ) ) * unit_price ) * igst ),2 ) ) / 100 as pending_isgst_value,
      ( round( ( ( ( cbsize * ( order_qty_in_cb - no_of_cb ) ) * unit_price ) * sgst ),2 ) ) / 100 as pending_sgst_value,
      ( round( ( ( ( cbsize * ( order_qty_in_cb - no_of_cb ) ) * unit_price ) * cgst ),2 ) ) / 100 as pending_cgst_value,
      round_up,
      ''                                                                                           as final_value,
      reason_of_rejection,
      cb_size,
      exc_inv_no,
      exc_inv_dt,
      excise,
      vat,
      cst,
      add_others,
      discount_promotion,
      additional_vat,
      add_in_freight,
      add_in_insurance,
      tcs,
      DistributionChannel
}
