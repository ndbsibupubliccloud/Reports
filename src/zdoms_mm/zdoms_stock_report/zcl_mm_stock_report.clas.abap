CLASS zcl_mm_stock_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    TYPES: BEGIN OF ty_matplant,
             material TYPE matnr,
             plant    TYPE werks_d,
           END OF ty_matplant.

    DATA: lt_unique_mat TYPE SORTED TABLE OF ty_matplant WITH UNIQUE KEY material plant.

    TYPES: BEGIN OF ty_filters,
             Plant    TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             Material TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             pdate    TYPE if_rap_query_filter=>ty_name_range_pairs-range,

           END OF ty_filters.
    TYPES: BEGIN OF ty_po_data,
             max_date     TYPE I_PurchaseOrderItemAPI01-PurgDocPriceDate,
             net_amount   TYPE I_PurchaseOrderItemAPI01-NetAmount,
             price_amount TYPE I_PurchaseOrderItemAPI01-NetPriceAmount,
           END OF ty_po_data.


    DATA: lt_paged_data TYPE TABLE OF ZI_STOCK_Custom,
          lt_stock      TYPE TABLE OF ZI_STOCK_Custom.

    METHODS:  read_filters IMPORTING filters_pair  TYPE if_rap_query_filter=>tt_name_range_pairs
                           RETURNING VALUE(result) TYPE ty_filters
                           RAISING   cx_root.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MM_STOCK_REPORT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_elements)    = io_request->get_sort_elements( ).

**==>Gets the filters as ranges from the request.
    TRY.
        DATA(filters_pair) = io_request->get_filter( )->get_as_ranges( ).
      CATCH  cx_sy_ref_is_initial INTO DATA(lv_ref).
        lv_ref->get_longtext(  ).
      CATCH cx_rap_query_filter_no_range INTO DATA(error).
        error->get_longtext(  ).
        RETURN.
    ENDTRY.
*     CALL METHOD cl_abap_datfm=>add_to_date

**==>Reads the collection of filters from the filter pairs.
    TRY.
        DATA(filters) = read_filters( filters_pair ).
      CATCH cx_root INTO DATA(lv_root).
        lv_root->get_longtext(  ).
    ENDTRY.


    DATA(ls_date) =  filters-pdate[ sign = 'I' option = 'EQ' ]-low.

    DATA: lv_month      TYPE n LENGTH 2,
          lv_month_3m   TYPE n LENGTH 2,
          lv_month_2m   TYPE n LENGTH 2,
          lv_month_1m   TYPE n LENGTH 2,
          lv_year       TYPE i,
          lv_year_3m    TYPE i,
          lv_year_2m    TYPE i,
          lv_year_1m    TYPE i,
          lv_day        TYPE n LENGTH 2,
          lv_3e         TYPE d,
          lv_3s         TYPE d,
          lv_2e         TYPE d,
          lv_2s         TYPE d,
          lv_1e         TYPE d,
          lv_1s         TYPE d,
          lv_currmon    TYPE  d,
          lv_date_tmp   TYPE d,
          lv_next_month TYPE d.

* Extract year, month, day from ls_date (assumed as YYYYMMDD string)
    lv_year  = ls_date+0(4).
    lv_month = ls_date+4(2).
    lv_day   = ls_date+6(2).

    lv_currmon = |{ lv_year }{ lv_month }01|.

    " --- 3 months back ---
    lv_year_3m = lv_year.
    lv_month_3m = lv_month - 3.
    IF lv_month_3m < 1.
      lv_month_3m = lv_month_3m + 12.
      lv_year_3m = lv_year_3m - 1.
    ENDIF.

    lv_3s = |{ lv_year_3m }{ lv_month_3m }01|.

* Calculate last day of 3 months back month
    lv_date_tmp = lv_3s + 31.
    lv_next_month = |{ lv_date_tmp+0(6) }01|.
    lv_3e = lv_next_month - 1.

    " --- 2 months back ---
    lv_year_2m = lv_year.
    lv_month_2m = lv_month - 2.
    IF lv_month_2m < 1.
      lv_month_2m = lv_month_2m + 12.
      lv_year_2m = lv_year_2m - 1.
    ENDIF.

    lv_2s = |{ lv_year_2m }{ lv_month_2m }01|.

    lv_date_tmp = lv_2s + 31.
    lv_next_month = |{ lv_date_tmp+0(6) }01|.
    lv_2e = lv_next_month - 1.

    " --- 1 month back ---
    lv_year_1m = lv_year.
    lv_month_1m = lv_month - 1.
    IF lv_month_1m < 1.
      lv_month_1m = lv_month_1m + 12.
      lv_year_1m = lv_year_1m - 1.
    ENDIF.

    lv_1s = |{ lv_year_1m }{ lv_month_1m }01|.

    lv_date_tmp = lv_1s + 31.
    lv_next_month = |{ lv_date_tmp+0(6) }01|.
    lv_1e = lv_next_month - 1.



    SELECT FROM I_Product AS _pro
             LEFT OUTER JOIN I_ProductPlantBasic  AS _plant ON _plant~Product = _pro~Product
             LEFT OUTER JOIN I_ProductText        AS _text  ON _text~Product  = _pro~Product
             LEFT OUTER JOIN I_MaterialDocumentItem_2 AS _matdoc ON _matdoc~Material = _pro~Product
                                                                 AND _matdoc~Plant  = _plant~Plant
*                                                                 AND _matdoc~DebitCreditCode = 'H'
             FIELDS _pro~product    AS Material,
                    _plant~Plant    AS Plant,
                    _text~ProductName AS Materialdesc,
*                    SUM( _matdoc~QuantityInBaseUnit ) AS stock,
                     _matdoc~QuantityInBaseUnit  AS stock,
                     _matdoc~DebitCreditCode,
                    _plant~SafetyStockQuantity AS bufferstock,
                    _matdoc~StorageLocation
             WHERE _pro~product IN @filters-material AND _plant~Plant IN @filters-plant
*             AND _matdoc~PostingDate BETWEEN @lv_3e AND @ls_date                      "commented on 11AUG2025
                   AND _text~Language = @sy-langu
                   AND ( _pro~ProductType = 'ROH' OR _pro~ProductType = 'VERP' )
                   AND ( substring( _matdoc~StorageLocation, 1, 1 ) = 'R' " <--- Only storage locations starting with 'R'
                          OR substring( _matdoc~StorageLocation, 1, 1 ) = 'P' )
*                   GROUP BY _pro~product,
*                    _plant~Plant,
*                    _text~ProductName,
*                     _plant~SafetyStockQuantity
             INTO TABLE @DATA(lt_mat).

**=> deleting lt_mat for some storage locations on 13AUG2025
    SORT lt_mat BY material plant StorageLocation.
    DELETE lt_mat WHERE StorageLocation = 'RJER' OR StorageLocation = 'RJM1'
                   OR StorageLocation = 'RJM2'   OR StorageLocation = 'RJM3'
                  OR StorageLocation = 'RJM4'  OR StorageLocation = 'RJM5'
                  OR StorageLocation = 'RJP1' OR StorageLocation = 'RJP2'
                   OR StorageLocation = 'RJSK' OR StorageLocation = 'RJAD'.
    IF lt_mat IS NOT INITIAL.

      SELECT FROM I_ProductSupplyPlanning WITH PRIVILEGED ACCESS     "I_ProductSupplyPlanning,I_ProductPlantMRP
      FIELDS product, plant,SafetyDuration
      FOR ALL ENTRIES IN @lt_mat
      WHERE Product = @lt_mat-material
      AND   Plant   = @lt_mat-plant
      INTO TABLE @DATA(lt_days).


      SELECT FROM I_PurchaseOrderItemAPI01 AS _po
     INNER JOIN I_PurchaseOrderAPI01 AS _pohead ON _po~PurchaseOrder = _pohead~PurchaseOrder
*                                                AND ( _pohead~PurchaseOrderType <> 'ZSTO' OR _pohead~PurchaseOrderType <> 'ZST3' )
*         LEFT OUTER JOIN I_MaterialDocumentItem_2 AS _matdoc ON _po~PurchaseOrder = _matdoc~PurchaseOrder
*         LEFT OUTER JOIN I_MaterialDocumentItem_2 AS _matdoc ON _matdoc~PurchaseOrder = _po~PurchaseOrder
*                                                             AND _po~PurchaseOrderItem = _matdoc~PurchaseOrderItem
*                                                             AND _matdoc~DebitCreditCode = 'H'
        FIELDS _po~Material,
         _po~Plant,
         _po~OrderQuantity,
         _po~PurchaseOrderQuantityUnit,
         _po~NetPriceAmount,
         _po~NetAmount,
*         _matdoc~QuantityInBaseUnit,
*         _matdoc~DebitCreditCode,       "added on 11AUG2025
         _po~PurgDocPriceDate,
         _po~PurchaseOrder,
         _po~PurchaseOrderItem,
         _pohead~PurchasingProcessingStatus,
         _pohead~PurchaseOrderType

    FOR ALL ENTRIES IN @lt_mat
    WHERE _po~Material = @lt_mat-Material
    AND _po~Plant    = @lt_mat-Plant
    AND _pohead~PurchasingProcessingStatus = '05'
*    AND _po~PurchasingDocumentDeletionCode <> 'L'
*     AND ( _pohead~PurchaseOrderType <> 'ZSTO' OR _pohead~PurchaseOrderType <> 'ZST3' )
*    AND ( _matdoc~DebitCreditCode = 'S' OR _matdoc~DebitCreditCode = 'H' )
    INTO TABLE @DATA(lt_po).
      DELETE lt_po WHERE PurchaseOrderType = 'ZSTO' OR PurchaseOrderType = 'ZST3'.
      SELECT FROM  @lt_po AS _poi
      LEFT OUTER JOIN I_MaterialDocumentItem_2 AS _matdoc ON _poi~PurchaseOrder = _matdoc~PurchaseOrder
                                                          AND _poi~PurchaseOrderItem = _matdoc~PurchaseOrderItem
      FIELDS _matdoc~QuantityInBaseUnit,
             _matdoc~DebitCreditCode,
             _matdoc~Material,
             _matdoc~Plant,
             _matdoc~PurchaseOrder,
             _matdoc~DebitCreditCode AS creditcode
*      FOR ALL ENTRIES IN @lt_po
*      WHERE PurchaseOrder = @lt_po-PurchaseOrder
*      AND   PurchaseOrderItem = @lt_po-PurchaseOrderItem
      INTO TABLE @DATA(lt_qty).

      SELECT FROM I_MaterialDocumentItem_2 AS _matdoc
      FIELDS _matdoc~material, _matdoc~plant,_matdoc~QuantityInBaseUnit,_matdoc~PostingDate
      FOR ALL ENTRIES IN @lt_mat
      WHERE Material = @lt_mat-material
      AND   Plant    = @lt_mat-plant
      AND ( GoodsMovementType = '261' OR GoodsMovementType = '262'
            OR GoodsMovementType = '309' OR GoodsMovementType = '310' )
      AND PostingDate BETWEEN @lv_3e AND @ls_date
      AND DebitCreditCode = 'H'
      INTO TABLE @DATA(lt_matdoc).
      SORT lt_matdoc BY Material PostingDate ASCENDING.

    ENDIF.

*    lt_unique_mat = VALUE #( FOR line IN lt_mat
*                             ( Material = line-material
*                               Plant    = line-plant ) ).

    LOOP AT lt_mat ASSIGNING FIELD-SYMBOL(<fs_mat>).
*    LOOP AT lt_unique_mat ASSIGNING FIELD-SYMBOL(<fs_mat>).
      DATA(ls_final) = VALUE zi_stock_custom(
        material             = <fs_mat>-material
        plant                = <fs_mat>-plant
        material_description = <fs_mat>-materialdesc
*        stock                = <fs_mat>-stock
        bufferstock          = <fs_mat>-bufferstock
      ).
*      DATA(ls_final) = VALUE ZI_STOCK_Custom( ).
*      READ TABLE lt_mat INTO DATA(ls_meta)
*           WITH KEY material = <fs_mat>-material
*                    plant    = <fs_mat>-plant.
*      IF sy-subrc = 0.
*        ls_final-material_description = ls_meta-materialdesc.
*        ls_final-bufferstock          = ls_meta-bufferstock.
*      ENDIF.

      DATA(lv_net_stock) = REDUCE f(
       INIT total = 0
       FOR st IN lt_mat
       WHERE ( material = <fs_mat>-material AND plant = <fs_mat>-plant )
       NEXT total = COND f(
         WHEN st-debitcreditcode = 'S' THEN total + st-stock
         WHEN st-debitcreditcode = 'H' THEN total - st-stock
         ELSE total )
     ).

      ls_final-stock = lv_net_stock.

**=> stock days
      ls_final-bufferdays = REDUCE #( INIT b TYPE I_ProductPlantMRP-SafetyDuration
                                      FOR ls_n IN lt_days
                                      WHERE ( Product = <fs_mat>-material
                                              AND Plant = <fs_mat>-plant  )
                                       NEXT b = ls_n-SafetyDuration ).

      ls_final-previous3 = REDUCE #( INIT a TYPE i
                                      FOR ls_p3 IN lt_matdoc
                                      WHERE ( Material = <fs_mat>-material
                                              AND Plant = <fs_mat>-plant
                                              AND PostingDate BETWEEN lv_3s AND lv_3e  )
                                       NEXT a = ls_p3-QuantityInBaseUnit + a ).

      ls_final-previous2 = REDUCE #( INIT a TYPE i
                                     FOR ls_p3 IN lt_matdoc
                                     WHERE ( Material = <fs_mat>-material
                                             AND Plant = <fs_mat>-plant
                                             AND PostingDate BETWEEN lv_2s AND lv_2e  )
                                      NEXT a = ls_p3-QuantityInBaseUnit + a ).

      ls_final-previous1 = REDUCE #( INIT a TYPE i
                                      FOR ls_p3 IN lt_matdoc
                                      WHERE ( Material = <fs_mat>-material
                                              AND Plant = <fs_mat>-plant
                                              AND PostingDate BETWEEN lv_1s AND lv_1e  )
                                       NEXT a = ls_p3-QuantityInBaseUnit + a ).
      ls_final-Currentqty = REDUCE #( INIT a TYPE i
                                      FOR ls_p3 IN lt_matdoc
                                      WHERE ( Material = <fs_mat>-material
                                              AND Plant = <fs_mat>-plant
*                                              AND PostingDate = ls_date  )
                                              AND PostingDate BETWEEN lv_currmon AND ls_date )               " Added on 13aug2025
                                       NEXT a = ls_p3-QuantityInBaseUnit + a ).
 " change of  logic on 25aug2025
      " Count how many previous months have data
      DATA(lv_months_with_data) = 0.
      IF ls_final-previous1 > 0.
        lv_months_with_data = lv_months_with_data + 1.
      ENDIF.
      IF ls_final-previous2 > 0.
        lv_months_with_data = lv_months_with_data + 1.
      ENDIF.
      IF ls_final-previous3 > 0.
        lv_months_with_data = lv_months_with_data + 1.
      ENDIF.


*      " Calculate Average Consumption
      DATA(ls_f) = ls_final-previous3 + ls_final-previous2 + ls_final-previous1.   "Added on 11AUG2025

*      ls_final-avgconsumption = ls_f / 78 * 26.

      IF ls_f <> 0.
*        ls_final-avgconsumption = ( ls_f / 78 ) * 26.     "Commented on 25aug2025
        ls_final-avgconsumption = ls_f / lv_months_with_data.
      ELSE.
        ls_final-avgconsumption = 0.
      ENDIF.
**=> end of logic 25aug2025
      " Calculated safety stock
*      ls_final-safety_stock = ( ls_final-avgconsumption / 26 ). " *  ls_final-shzet.

      IF ls_final-avgconsumption <> 0.
        ls_final-safety_stock = ( ls_final-avgconsumption / 26 ) * ls_final-bufferdays.
      ELSE.
        ls_final-safety_stock = 0.
      ENDIF.

*      DATA(ls_stockdays) =  ( ls_final-stock / ls_final-avgconsumption ) * 26.

      IF ls_final-avgconsumption <> 0.
        ls_final-stockdays = ( ls_final-stock / ls_final-avgconsumption ) * 26.
      ELSE.
        ls_final-stockdays = 0.
      ENDIF.

      DATA(ls_po_data) = REDUCE ty_po_data(
  INIT s = VALUE ty_po_data( max_date = '00000000'
                             net_amount = 0
                             price_amount = 0 )
  FOR wa IN lt_po
  WHERE ( Material = <fs_mat>-Material AND Plant = <fs_mat>-Plant )
  NEXT s = COND ty_po_data(
    WHEN wa-PurgDocPriceDate > s-max_date
    THEN VALUE ty_po_data(
      max_date     = wa-PurgDocPriceDate
*      net_amount   = wa-NetAmount
      net_amount   = wa-NetPriceAmount     " Changed on 11AUG2025
*      price_amount = wa-NetPriceAmount )
      price_amount = wa-NetAmount / wa-OrderQuantity / wa-NetPriceAmount )
    ELSE s )
).

      ls_final-lastporate = ls_po_data-net_amount.
      ls_final-priceunit = ls_po_data-price_amount.

      DATA(lv_total_orderqty) = REDUCE #(
        INIT t TYPE I_PurchaseOrderItemAPI01-OrderQuantity
        FOR wa IN lt_po
        WHERE ( Material = <fs_mat>-Material AND Plant = <fs_mat>-Plant )
        NEXT t = t + wa-OrderQuantity
      ).

      DATA(lv_total_received_qty) = REDUCE #(
        INIT to TYPE I_MaterialDocumentItem_2-QuantityInBaseUnit
        FOR wb IN lt_qty
        WHERE ( Material = <fs_mat>-Material AND Plant = <fs_mat>-Plant )
        NEXT to = COND f(
          WHEN wb-DebitCreditCode = 'S' THEN to + wb-QuantityInBaseUnit
          WHEN wb-DebitCreditCode = 'H' THEN to - wb-QuantityInBaseUnit
          ELSE to )
      ).

      ls_final-pendingpo = lv_total_orderqty - lv_total_received_qty.

      ls_final-pouom = REDUCE #(
                          INIT x TYPE I_PurchaseOrderItemTP_2-PurchaseOrderQuantityUnit
                          FOR wa IN lt_po
                          WHERE ( Material = <fs_mat>-Material AND Plant = <fs_mat>-Plant )
                          NEXT x = wa-PurchaseOrderQuantityUnit
                        ).

      " Remarks
*      IF ls_final-labst < ls_final-cal_safe AND ( ls_final-menge_po IS INITIAL OR ls_final-menge_po = 0 ).
*        ls_final-remarks = 'Issue PO'.
*      ELSEIF ls_final-labst < ls_final-cal_safe AND ls_final-menge_po > 0.
*        ls_final-remarks = 'Check PO'.
*      ELSE.
*        ls_final-remarks = ''.
*      ENDIF.
*
*      " NIL Stock + Consumption" current quantity newly added  "
      IF ls_final-stock IS INITIAL AND ls_final-avgconsumption IS INITIAL
      AND ls_final-Currentqty IS INITIAL .   " added logic on 25aug2025
        ls_final-nilstock = 'YES'.
      ELSE.
        ls_final-nilstock = 'NO'.
      ENDIF.

      IF ls_final-stock < ls_final-bufferstock AND ls_final-pendingpo = 0.
        ls_final-Remarks = 'ISSUE PO'.
      ELSEIF ls_final-stock < ls_final-bufferstock.
        ls_final-Remarks = 'CHECK PO'.
      ENDIF.

      " Stock Days
*      TYPES: f_tab_type TYPE STANDARD TABLE OF f WITH EMPTY KEY.
*
*      DATA(lv_max_consp) = REDUCE f( INIT max = 0
*                                     FOR val IN VALUE f_tab_type( ( ls_final-previous3 ) ( ls_final-previous2 )
*                                                                   ( ls_final-previous1 ) ( ls_final-Currentqty ) )
*                                     NEXT max = COND #( WHEN val > max THEN val ELSE max ) ).
*      IF lv_max_consp > 0.
*        ls_final-stock_days = ( ls_final-labst / lv_max_consp ) * 30.
*      ENDIF.

      APPEND ls_final TO lt_paged_data.
      CLEAR ls_po_data.
*      CLEAR ls_stockdays.
      CLEAR ls_final.
      CLEAR ls_f.
      DELETE lt_mat WHERE material = <fs_mat>-material AND plant = <fs_mat>-plant.
    ENDLOOP.

**==>Counts the number of rows obtained in lt_BOMDATA.
    DATA(max_rows) = lines( lt_paged_data ).
    "Calculate max index for pagination
    DATA(max_index) = COND int8( WHEN top IS NOT INITIAL AND top > 0
                                 THEN top + skip
                                 ELSE 0 ).

**==>Selects records from the lt_BOMDATA table with applied filters.
    SELECT  FROM @lt_paged_data AS _Stockdata
    FIELDS *
            WHERE Material IN @filters-material
            AND Plant IN  @filters-plant
*            AND pdate  BETWEEN @lv_3e AND @ls_date
            INTO TABLE @DATA(ap_records)
            UP TO @max_index ROWS.
    IF sy-subrc = 0 AND skip IS NOT INITIAL.
      DELETE ap_records TO skip.
    ENDIF.
    SORT ap_records BY Plant Material.

    "Apply filter on the Key fields to prevent the object page(Single Record) loading issue in the UI
    IF lines( ap_records ) = 1.
      max_rows = 1.
    ENDIF.


    io_response->set_total_number_of_records( CONV #( max_rows ) ).
    io_response->set_data( ap_records ).


  ENDMETHOD.


  METHOD read_filters.

    result-material  = VALUE #( filters_pair[ name = 'MATERIAL' ]-range OPTIONAL ).
    result-plant = VALUE #( filters_pair[ name = 'PLANT' ]-range OPTIONAL ).
    result-pdate = VALUE #( filters_pair[ name = 'PDATE' ]-range OPTIONAL ).


  ENDMETHOD.
ENDCLASS.
