CLASS zcl_fi_vendor_ledger DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_filters,
             CompanyCode TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             Supplier    TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             postingdate TYPE if_rap_query_filter=>ty_name_range_pairs-range,
           END OF ty_filters.

    TYPES : BEGIN OF ty_vendor_ledger,
              CompanyCode                 TYPE bukrs,
              AccountingDocument          TYPE belnr_d,
              Supplier                    TYPE lifnr,
              FinancialAccountType        TYPE koart,
              Supplier_name               TYPE i_supplier-BPSupplierName,
              AccountingDocumentType      TYPE blart,
              SpecialGLCode               TYPE I_GLAccountLineItem-SpecialGLCode,
              DocumentDate                TYPE I_GLAccountLineItem-DocumentDate,
              PostingDate                 TYPE I_GLAccountLineItem-PostingDate,
              PurchasingDocument          TYPE ebeln,
              DocumentItemText            TYPE sgtxt,
              AssignmentReference         TYPE I_GLAccountLineItem-AssignmentReference,
              ClearingDate                TYPE I_GLAccountLineItem-ClearingDate,
              ClearingJournalEntry        TYPE augbl,
              AmountInCompanyCodeCurrency TYPE I_GLAccountLineItem-AmountInCompanyCodeCurrency,
              CompanyCodeCurrency         TYPE I_GLAccountLineItem-CompanyCodeCurrency,
              DebitCreditCode             TYPE shkzg,
              OpeningBalance              TYPE I_GLAccountLineItem-AmountInCompanyCodeCurrency,
              amount                      TYPE I_GLAccountLineItem-AmountInCompanyCodeCurrency,
              tds_amount                  TYPE I_OperationalAcctgDocItem-AmountInBalanceTransacCrcy,
            END OF ty_vendor_ledger,

            tt_vendor_ledger TYPE STANDARD TABLE OF  ty_vendor_ledger WITH EMPTY KEY.


    DATA : Lt_VendorLedger  TYPE TABLE OF ZI_Vendor_Ledger_report,
           lt_paged_data    TYPE TABLE OF ZI_Vendor_Ledger_report,
*           lt_paged_data    TYPE tt_vendor_ledger,
           ls_vendor_ledger TYPE ZI_Vendor_Ledger_report,
           lr_postingdate   TYPE RANGE OF I_GLAccountLineItemRawData-PostingDate,
           lt_final         TYPE TABLE OF ZI_Vendor_Ledger_report, " added
           Lt_final_vendor  TYPE TABLE OF ZI_Vendor_Ledger_report . "added


    METHODS:  read_filters         IMPORTING filters_pair  TYPE if_rap_query_filter=>tt_name_range_pairs
                                   RETURNING VALUE(result) TYPE ty_filters
                                   RAISING   cx_root.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FI_VENDOR_LEDGER IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TRY.
        DATA(filters_pair) = io_request->get_filter( )->get_as_ranges( ).
      CATCH  cx_sy_ref_is_initial INTO DATA(lv_ref).
        lv_ref->get_longtext(  ).
      CATCH cx_rap_query_filter_no_range INTO DATA(error).
        error->get_longtext(  ).
        RETURN.
    ENDTRY.

    TRY.
        DATA(filters) = read_filters( filters_pair ).
      CATCH cx_root INTO DATA(lv_root).
        lv_root->get_longtext(  ).
    ENDTRY.

    DATA(lt_postingdate)  = filters-postingdate.

    lr_postingdate = VALUE #(  FOR ls IN  lt_postingdate (
                                      sign   = 'I'
                                      option =  'BT'
                                      low    =  ls-low
                                      high   =  ls-high ) ).

    DATA(lv_posting_low) = VALUE #( lr_postingdate[ 1 ]-low OPTIONAL ).
    DATA(lv_posting_high) = VALUE #( lr_postingdate[ 1 ]-high OPTIONAL ).


    SELECT FROM I_OperationalAcctgDocItem AS _GLAccountLineItem
     FIELDS CompanyCode,
            AccountingDocument,
            AccountingDocumentItem,
            Supplier,
            FinancialAccountType,
            _GLAccountLineItem~\_Supplier-SupplierName AS suppliername,
            AccountingDocumentType,
            SpecialGLCode,
            DocumentDate,
            PostingDate,
            PurchasingDocument,
            DocumentItemText,
            AssignmentReference,
            ClearingDate,
            ClearingJournalEntry,
            AmountInCompanyCodeCurrency,
            CompanyCodeCurrency,
            DebitCreditCode,
            AmountInBalanceTransacCrcy  "added
        WHERE supplier IN @filters-supplier
         AND AccountingDocumentType IN ( 'KR' ,'KZ', 'RE' , 'ZP', 'SA', 'KG' , 'AB', 'AA' )
         AND  FinancialAccountType   = 'K'
         AND (
              SpecialGLCode          = 'A' OR
              SpecialGLCode          = 'H' OR
              SpecialGLCode          = ' '
             )
         AND PostingDate >= @lv_posting_low  AND   PostingDate <= @lv_posting_high
*         AND PostingDate in @filters-postingdate
         AND CompanyCode IN @filters-companycode
             INTO TABLE @DATA(lt_VendorLedgerDetail).

    IF sy-subrc = 0.
      SELECT * FROM @lt_VendorLedgerDetail AS vendor
      WHERE FinancialAccountType   = 'K'
      INTO TABLE @DATA(lt_VendorLedgerDetails).
    ENDIF.

    SELECT FROM I_OperationalAcctgDocItem AS _GLAccountLineItem
    FIELDS
           Supplier,
           AmountInCompanyCodeCurrency
           WHERE
            supplier IN @filters-supplier
             AND AccountingDocumentType IN ( 'KR' ,'KZ', 'RE' , 'ZP', 'SA', 'KG' , 'AB', 'AA' )
             AND FinancialAccountType   = 'K'
             AND (
                  SpecialGLCode          = 'A' OR
                  SpecialGLCode          = 'H' OR
                  SpecialGLCode          = ' '
                  )
             AND PostingDate < @lv_posting_low
             AND CompanyCode IN @filters-companycode
                 INTO TABLE @DATA(lt_VendorLedger).

    IF sy-subrc = 0.

      SELECT SUM( AmountInCompanyCodeCurrency ) AS amount,
             Supplier
             FROM @lt_VendorLedger AS _lt_vendor
      GROUP BY Supplier
      INTO TABLE @DATA(lt_vendor_ledger).

    ENDIF.

**To get with holding tax amount
    SELECT   whldgtaxamtincocodecrcy AS tds_amount,
               _withitem~accountingdocument,
               _withitem~AccountingDocumentitem
     FROM I_Withholdingtaxitem AS _withitem
     INNER JOIN @lt_VendorLedgerDetail AS _vendorledger
      ON _withitem~AccountingDocument  = _vendorledger~AccountingDocument
     AND _withitem~CompanyCode         = _vendorledger~CompanyCode
     AND _withitem~AccountingDocumentItem = _vendorledger~AccountingDocumentItem
     INTO TABLE @DATA(lt_tds_amount).
    IF sy-subrc = 0 .
    ENDIF.

**To get the purchasing document
    SELECT FROM I_OperationalAcctgDocItem AS _GLAccountLineItem
         FIELDS PurchasingDocument,
                AccountingDocument
                FOR ALL ENTRIES IN @lt_VendorLedgerDetail
                WHERE AccountingDocument = @lt_VendorLedgerDetail-AccountingDocument
                AND PurchasingDocument IS NOT INITIAL
                INTO TABLE @DATA(lt_PODOC).

    DATA(Lt_VendorLedgers) = VALUE tt_vendor_ledger(  FOR ls_vendordetails IN  lt_VendorLedgerDetails (
         CompanyCode                   =  ls_vendordetails-CompanyCode
         AccountingDocument            =  ls_vendordetails-AccountingDocument
         Supplier                      =  ls_vendordetails-Supplier
         FinancialAccountType          =  ls_vendordetails-FinancialAccountType
         Supplier_name                 =  ls_vendordetails-suppliername
         AccountingDocumentType        =  ls_vendordetails-AccountingDocumentType
         SpecialGLCode                 =  ls_vendordetails-SpecialGLCode
         DocumentDate                  =  ls_vendordetails-DocumentDate
         PostingDate                   =  ls_vendordetails-PostingDate
         PurchasingDocument                = VALUE #( lt_PODOC[ AccountingDocument = ls_vendordetails-AccountingDocument ]-PurchasingDocument OPTIONAL )
         DocumentItemText              =  ls_vendordetails-DocumentItemText
         AssignmentReference           =  ls_vendordetails-AssignmentReference
         ClearingDate                  =  ls_vendordetails-ClearingDate
         ClearingJournalEntry          =  ls_vendordetails-ClearingJournalEntry
         AmountInCompanyCodeCurrency   =  ls_vendordetails-AmountInCompanyCodeCurrency
         CompanyCodeCurrency           =  ls_vendordetails-CompanyCodeCurrency
         DebitCreditCode               =  ls_vendordetails-DebitCreditCode
         tds_amount                    = VALUE #( lt_tds_amount[ accountingdocument = ls_vendordetails-AccountingDocument
                                                                 AccountingDocumentitem = ls_vendordetails-AccountingDocumentItem ]-tds_amount OPTIONAL )
         OpeningBalance                = VALUE #( lt_vendor_ledger[ supplier = ls_vendordetails-supplier ]-amount OPTIONAL )
                                           ) ).

    IF sy-subrc = 0.
      SORT Lt_VendorLedgers BY supplier.
    ENDIF.

    LOOP AT lt_vendorledgers ASSIGNING FIELD-SYMBOL(<fs_ledger>).
      DATA(lv_index) = sy-tabix.
      DATA(lv_index1) = lv_index + 1.
      DATA(lv_index2) = lv_index + 2.

      " Use VALUE ... OPTIONAL to safely access next entries
      DATA(lv_current) = lt_vendorledgers[ lv_index ].
      DATA(lv_next)    = VALUE #( lt_vendorledgers[ lv_index1 ] OPTIONAL ).
      DATA(lv_next2)   = VALUE #( lt_vendorledgers[ lv_index2 ] OPTIONAL ).

      " First row logic
      IF lv_index = 1.
        IF lv_current-supplier <> lv_next-supplier.
          lt_vendorledgers[ lv_index ]-amount = lv_current-openingbalance.
        ELSE.
          DATA(lv_amount1) = lv_current-amountincompanycodecurrency + lv_current-openingbalance.
          DATA(lv_amount)  = lv_amount1.
          lt_vendorledgers[ lv_index ]-amount = lv_amount1.
        ENDIF.
      ENDIF.

      " Same supplier logic
      IF lv_current-supplier = lv_next-supplier AND lv_next IS NOT INITIAL.
        lv_amount = lv_next-amountincompanycodecurrency + lv_amount.
        lt_vendorledgers[ lv_index1 ]-amount = lv_amount.
      ENDIF.

      " Different supplier and lookahead for next2
      IF lv_next IS NOT INITIAL AND lv_next2 IS NOT INITIAL.
        IF lv_current-supplier <> lv_next-supplier AND lv_next-supplier <> lv_next2-supplier.
          lt_vendorledgers[ lv_index1 ]-amount = lv_next-openingbalance.
        ELSEIF lv_current-supplier <> lv_next-supplier.
          CLEAR lv_amount.
          lv_amount = lv_next-amountincompanycodecurrency + lv_next-openingbalance.
          lt_vendorledgers[ lv_index1 ]-amount = lv_amount.
        ENDIF.
      ELSEIF lv_next IS NOT INITIAL AND lv_current-supplier <> lv_next-supplier.
        " Handle last line separately if needed
        lt_vendorledgers[ lv_index1 ]-amount = lv_next-openingbalance.
      ENDIF.
    ENDLOOP.

    DATA(lv_year)  = lv_posting_low+0(4).
    DATA(lv_month) = lv_posting_low+4(2).
    DATA(lv_day)   = lv_posting_low+6(2).

    " Subtract 1 day manually
    lv_day = lv_day - 1.

    IF lv_day = 0.
      " Move to previous month
      lv_month = lv_month - 1.

      IF lv_month = 0.
        lv_month = 12.
        lv_year = lv_year - 1.
      ENDIF.

      " Determine number of days in the previous month
      CASE lv_month.
        WHEN 1 OR 3 OR 5 OR 7 OR 8 OR 10 OR 12.
          lv_day = 31.
        WHEN 4 OR 6 OR 9 OR 11.
          lv_day = 30.
        WHEN 2.
          " Leap year check
          IF ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ) OR ( lv_year MOD 400 = 0 ).
            lv_day = 29.
          ELSE.
            lv_day = 28.
          ENDIF.
      ENDCASE.
    ENDIF.

    " Format back to DATS
    DATA(lv_prev_date) = |{ lv_year  WIDTH = 4 }{ lv_month  WIDTH = 2 }{ lv_day  WIDTH = 2 }|.



    Lt_final = VALUE #(  FOR ls_final IN  lt_vendor_ledger ( OpeningBalance = ls_final-amount
                                                             Supplier = ls_final-Supplier
                                                             PostingDate = lv_prev_date ) ).

    DATA(Lt_final_vendor) = VALUE #( BASE lt_final
                                              FOR ls_vendordetail IN  lt_vendorledgers (
                                                     CompanyCode                   =  ls_vendordetail-CompanyCode
                                                     AccountingDocument            =  ls_vendordetail-AccountingDocument
                                                     supplier                      =  ls_vendordetail-supplier
                                                     FinancialAccountType          =  ls_vendordetail-FinancialAccountType
                                                     supplier_name                 =  ls_vendordetail-supplier_name
                                                     AccountingDocumentType        =  ls_vendordetail-AccountingDocumentType
                                                     SpecialGLCode                 =  ls_vendordetail-SpecialGLCode
                                                     DocumentDate                  =  ls_vendordetail-DocumentDate
                                                     PostingDate                   =  ls_vendordetail-PostingDate
                                                     PurchasingDocument            =  ls_vendordetail-PurchasingDocument
                                                     DocumentItemText              =  ls_vendordetail-DocumentItemText
                                                     AssignmentReference           =  ls_vendordetail-AssignmentReference
                                                     ClearingDate                  =  ls_vendordetail-ClearingDate
                                                     ClearingJournalEntry          =  ls_vendordetail-ClearingJournalEntry
                                                     AmountInCompanyCodeCurrency   =  ls_vendordetail-AmountInCompanyCodeCurrency
                                                     CompanyCodeCurrency           =  ls_vendordetail-CompanyCodeCurrency
                                                     DebitCreditCode               =  ls_vendordetail-DebitCreditCode
                                                     tds_amount                    = ls_vendordetail-tds_amount
                                                      Amount                        = ls_vendordetail-amount
                                        ) ).


    DATA(top)  = io_request->get_paging( )->get_page_size( ).
    DATA(skip) = io_request->get_paging( )->get_offset( ).

    LOOP AT Lt_final_vendor ASSIGNING FIELD-SYMBOL(<fs_ledgerdata>) FROM skip + 1 TO skip + top.
      APPEND <fs_ledgerdata> TO lt_paged_data.
    ENDLOOP.

    IF top = -1.
      " No paging -> Return all records
      io_response->set_total_number_of_records( lines( Lt_final_vendor ) ).
      io_response->set_data( Lt_final_vendor ).
    ELSE.
*  " Return paginated records
      io_response->set_total_number_of_records( lines( Lt_final_vendor ) ).
      io_response->set_data( lt_paged_data ).

    ENDIF.

  ENDMETHOD.


  METHOD read_filters.
    result-companycode = VALUE #( filters_pair[ name = 'COMPANYCODE' ]-range OPTIONAL ).
    result-postingdate = VALUE #( filters_pair[ name = 'POSTINGDATE' ]-range OPTIONAL ).
    result-supplier    = VALUE #( filters_pair[ name = 'SUPPLIER' ]-range OPTIONAL ).
  ENDMETHOD.
ENDCLASS.
