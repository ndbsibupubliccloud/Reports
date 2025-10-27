CLASS zcl_fi_customer_ledger DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_filters,
             CompanyCode TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             customer    TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             postingdate TYPE if_rap_query_filter=>ty_name_range_pairs-range,
           END OF ty_filters.

    TYPES : BEGIN OF ty_customer_ledger,
              CompanyCode                 TYPE bukrs,
              AccountingDocument          TYPE belnr_d,
              customer                    TYPE kunnr,
              FinancialAccountType        TYPE koart,
              customer_name               TYPE i_CUSTOMER-BPCUSTOMERName,
              AccountingDocumentType      TYPE blart,
              SpecialGLCode               TYPE I_GLAccountLineItem-SpecialGLCode,
              DocumentDate                TYPE I_GLAccountLineItem-DocumentDate,
              PostingDate                 TYPE I_GLAccountLineItem-PostingDate,
              DocumentItemText            TYPE sgtxt,
              AssignmentReference         TYPE I_GLAccountLineItem-AssignmentReference,
              ClearingDate                TYPE I_GLAccountLineItem-ClearingDate,
              ClearingJournalEntry        TYPE augbl,
              AmountInCompanyCodeCurrency TYPE I_GLAccountLineItem-AmountInCompanyCodeCurrency,
              CompanyCodeCurrency         TYPE I_GLAccountLineItem-CompanyCodeCurrency,
              DebitCreditCode             TYPE shkzg,
              OpeningBalance              TYPE I_GLAccountLineItem-AmountInCompanyCodeCurrency,
              amount                      TYPE I_GLAccountLineItem-AmountInCompanyCodeCurrency,
              ReferenceDoc                TYPE I_billingdocument-DocumentReferenceID,
            END OF ty_customer_ledger,

            tt_customer_ledger TYPE STANDARD TABLE OF  ty_customer_ledger WITH EMPTY KEY.


    DATA : Lt_customerLedger  TYPE TABLE OF ZI_customer_Ledger_report,
           lt_paged_data     TYPE TABLE OF ZI_customer_Ledger_report,
           ls_customer_ledger TYPE ZI_customer_Ledger_report,
           lr_postingdate     TYPE RANGE OF I_GLAccountLineItemRawData-PostingDate,
           lt_customer_ledger TYPE TABLE OF ZI_customer_Ledger_report, "added on 03/06/2025
           lt_final TYPE TABLE OF ZI_customer_Ledger_report,
           lt_final_customer TYPE TABLE OF ZI_customer_Ledger_report.


    METHODS:  read_filters         IMPORTING filters_pair  TYPE if_rap_query_filter=>tt_name_range_pairs
                                   RETURNING VALUE(result) TYPE ty_filters
                                   RAISING   cx_root.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FI_CUSTOMER_LEDGER IMPLEMENTATION.


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

    DATA(lv_posting_low) = lr_postingdate[ 1 ]-low.
    DATA(lv_posting_high) = lr_postingdate[ 1 ]-high.


    SELECT FROM I_GLAccountLineItemRawData AS _GLAccountLineItem
    LEFT OUTER JOIN i_billingdocument AS _billingheader ON _billingheader~BillingDocument = _GLAccountLineItem~ReferenceDocument
     FIELDS _GLAccountLineItem~CompanyCode,
            _GLAccountLineItem~AccountingDocument,
            _GLAccountLineItem~customer,
            _GLAccountLineItem~FinancialAccountType,
            _GLAccountLineItem~\_customer-CUSTOMERName AS customername,
            _GLAccountLineItem~AccountingDocumentType,
            _GLAccountLineItem~SpecialGLCode,
            _GLAccountLineItem~DocumentDate,
            _GLAccountLineItem~PostingDate,
            _GLAccountLineItem~DocumentItemText,
            _GLAccountLineItem~AssignmentReference,
            _GLAccountLineItem~ClearingDate,
            _GLAccountLineItem~ClearingJournalEntry,
            _GLAccountLineItem~AmountInCompanyCodeCurrency,
            _GLAccountLineItem~CompanyCodeCurrency,
            _GLAccountLineItem~DebitCreditCode,
            _billingheader~DocumentReferenceID
            WHERE customer    IN @filters-customer
              AND AccountingDocumentType IN ( 'DR' ,'DG', 'RV' , 'DZ', 'AB' )
              AND FinancialAccountType   = 'D'
              AND (
                   SpecialGLCode          = 'A' OR
                   SpecialGLCode          = 'H' OR
                   SpecialGLCode          = ' '
                   )
              AND PostingDate >= @lv_posting_low  AND   PostingDate <= @lv_posting_high
              AND SourceLedger           = '0L'
              AND _GLAccountLineItem~CompanyCode IN @filters-companycode
            INTO TABLE @DATA(lt_customerLedgerDetail).

    IF sy-subrc = 0.
      SELECT * FROM @lt_customerLedgerDetail AS customer
      WHERE FinancialAccountType   = 'D'
      INTO TABLE @DATA(lt_customerLedgerDetails).
    ENDIF.

    SELECT FROM I_GLAccountLineItemRawData AS _GLAccountLineItem
    FIELDS

           customer,
           AmountInCompanyCodeCurrency
           WHERE customer IN @filters-customer
             AND ClearingJournalEntry   = ''
             AND AccountingDocumentType IN ( 'DR' ,'DG', 'RV' , 'DZ' ,'AB' )
             AND  FinancialAccountType   = 'D'
             AND (
                   SpecialGLCode          = 'A' OR
                   SpecialGLCode          = 'H' OR
                   SpecialGLCode          = ' '
                  )
            AND SourceLedger           = '0L'
            AND PostingDate < @lv_posting_low
            AND CompanyCode IN @filters-companycode
           INTO TABLE @DATA(lt_customerLedger).


    IF sy-subrc = 0.

      SELECT SUM( AmountInCompanyCodeCurrency ) AS amount,
            customer
             FROM @lt_customerLedger AS _lt_customer
      GROUP BY customer
      INTO TABLE @DATA(lt_customer_ledger).

    ENDIF.

    DATA(Lt_customerLedgers) = VALUE tt_customer_ledger(  FOR ls_customerdetails IN  lt_customerLedgerDetails (
         CompanyCode                   =  ls_customerdetails-CompanyCode
         AccountingDocument            =  ls_customerdetails-AccountingDocument
         customer                      =  ls_customerdetails-customer
         FinancialAccountType          =  ls_customerdetails-FinancialAccountType
         customer_name                 =  ls_customerdetails-customername
         AccountingDocumentType        =  ls_customerdetails-AccountingDocumentType
         SpecialGLCode                 =  ls_customerdetails-SpecialGLCode
         DocumentDate                  =  ls_customerdetails-DocumentDate
         PostingDate                   =  ls_customerdetails-PostingDate
         DocumentItemText              =  ls_customerdetails-DocumentItemText
         AssignmentReference           =  ls_customerdetails-AssignmentReference
         ClearingDate                  =  ls_customerdetails-ClearingDate
         ClearingJournalEntry          =  ls_customerdetails-ClearingJournalEntry
         AmountInCompanyCodeCurrency   =  ls_customerdetails-AmountInCompanyCodeCurrency
         CompanyCodeCurrency           =  ls_customerdetails-CompanyCodeCurrency
         DebitCreditCode               =  ls_customerdetails-DebitCreditCode
         referencedoc                  = ls_customerdetails-DocumentReferenceID
         OpeningBalance                = VALUE #( lt_customer_ledger[ customer = ls_customerdetails-customer ]-amount OPTIONAL )
                                           ) ).

    IF sy-subrc = 0.
      SORT Lt_customerLedgers BY customer.
    ENDIF.

    LOOP AT lt_customerledgers ASSIGNING FIELD-SYMBOL(<fs_ledger>).

      DATA(lv_index) = sy-tabix.
      DATA(lv_index1) = lv_index + 1.
      DATA(lv_index2) = lv_index + 2.

      " Use VALUE ... OPTIONAL to safely access next entries
      DATA(lv_current) = lt_customerledgers[ lv_index ].
      DATA(lv_next)    = VALUE #( lt_customerledgers[ lv_index1 ] OPTIONAL ).
      DATA(lv_next2)   = VALUE #( lt_customerledgers[ lv_index2 ] OPTIONAL ).

      " First row logic
      IF lv_index = 1.
        IF lv_current-customer <> lv_next-customer.
          lt_customerledgers[ lv_index ]-amount = lv_current-openingbalance.
        ELSE.
          DATA(lv_amount1) = lv_current-amountincompanycodecurrency + lv_current-openingbalance.
          DATA(lv_amount)  = lv_amount1.
          lt_customerledgers[ lv_index ]-amount = lv_amount1.
        ENDIF.
      ENDIF.

      " Same customer logic
      IF lv_current-customer = lv_next-customer AND lv_next IS NOT INITIAL.
        lv_amount = lv_next-amountincompanycodecurrency + lv_amount.
        lt_customerledgers[ lv_index1 ]-amount = lv_amount.
      ENDIF.

      " Different customer and lookahead for next2
      IF lv_next IS NOT INITIAL AND lv_next2 IS NOT INITIAL.
        IF lv_current-customer <> lv_next-customer AND lv_next-customer <> lv_next2-customer.
          lt_customerledgers[ lv_index1 ]-amount = lv_next-openingbalance.
        ELSEIF lv_current-customer <> lv_next-customer.
          CLEAR lv_amount.
          lv_amount = lv_next-amountincompanycodecurrency + lv_next-openingbalance.
          lt_customerledgers[ lv_index1 ]-amount = lv_amount.
        ENDIF.
      ELSEIF lv_next IS NOT INITIAL AND lv_current-customer <> lv_next-customer.
        " Handle last line separately if needed
        lt_customerledgers[ lv_index1 ]-amount = lv_next-openingbalance.
      ENDIF.
    ENDLOOP.

**************************************
**To get the Previous date

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


**Append the previous date to the internal table
    Lt_final = VALUE #(  FOR ls_final IN  lt_customer_ledger ( OpeningBalance = ls_final-amount
                                                             Customer = ls_final-Customer
                                                             PostingDate = lv_prev_date ) ).

**To add the opening balance lineitems at the beginning along with previous date
    DATA(Lt_final_customer) = VALUE #( BASE lt_final
                                              FOR <fs_customerdetail> IN  lt_customerledgers (
                                                     CompanyCode                   =  <fs_customerdetail>-CompanyCode
                                                     AccountingDocument            =  <fs_customerdetail>-AccountingDocument
                                                     customer                      =  <fs_customerdetail>-customer
                                                     FinancialAccountType          =  <fs_customerdetail>-FinancialAccountType
                                                     customer_name                 =  <fs_customerdetail>-customer_name
                                                     AccountingDocumentType        =  <fs_customerdetail>-AccountingDocumentType
                                                     SpecialGLCode                 =  <fs_customerdetail>-SpecialGLCode
                                                     DocumentDate                  =  <fs_customerdetail>-DocumentDate
                                                     PostingDate                   =  <fs_customerdetail>-PostingDate
                                                     DocumentItemText              =  <fs_customerdetail>-DocumentItemText
                                                     AssignmentReference           =  <fs_customerdetail>-AssignmentReference
                                                     ClearingDate                  =  <fs_customerdetail>-ClearingDate
                                                     ClearingJournalEntry          =  <fs_customerdetail>-ClearingJournalEntry
                                                     AmountInCompanyCodeCurrency   =  <fs_customerdetail>-AmountInCompanyCodeCurrency
                                                     CompanyCodeCurrency           =  <fs_customerdetail>-CompanyCodeCurrency
                                                     DebitCreditCode               =  <fs_customerdetail>-DebitCreditCode
                                                     Amount                        = <fs_customerdetail>-amount

                                        ) ).

**************************************
    DATA(top)  = io_request->get_paging( )->get_page_size( ).
    DATA(skip) = io_request->get_paging( )->get_offset( ).


    LOOP AT Lt_final_customer ASSIGNING FIELD-SYMBOL(<fs_ledgerdata>) FROM skip + 1 TO skip + top.
      APPEND <fs_ledgerdata> TO lt_paged_data.
    ENDLOOP.

    IF top = -1.
      " No paging -> Return all records
      io_response->set_total_number_of_records( lines( Lt_final_customer ) ).
      io_response->set_data( Lt_final_customer ).
    ELSE.
   " Return paginated records
      io_response->set_total_number_of_records( lines( Lt_final_customer ) ).
      io_response->set_data( lt_paged_data ).
    ENDIF.
  ENDMETHOD.


  METHOD read_filters.
    result-companycode = VALUE #( filters_pair[ name = 'COMPANYCODE' ]-range OPTIONAL ).
    result-postingdate = VALUE #( filters_pair[ name = 'POSTINGDATE' ]-range OPTIONAL ).
    result-customer    = VALUE #( filters_pair[ name = 'CUSTOMER' ]-range OPTIONAL ).
  ENDMETHOD.
ENDCLASS.
