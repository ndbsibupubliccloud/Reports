CLASS lhc_zi_ord_tbl DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ord_tbl RESULT result.

ENDCLASS.

CLASS lhc_zi_ord_tbl IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zir_ord_att DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZIR_ORD_att RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZIR_ORD_att RESULT result.

    METHODS uploadExcelData FOR MODIFY
      IMPORTING keys FOR ACTION ZIR_ORD_att~uploadExcelData RESULT result.

    METHODS fields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZIR_ORD_att~fields.

    METHODS FillFileStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZIR_ORD_att~FillFileStatus.

    METHODS FillSelectedStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZIR_ORD_att~FillSelectedStatus.

    METHODS callAPI FOR DETERMINE ON SAVE
      IMPORTING keys FOR ZIR_ORD_att~callAPI.

    CONSTANTS c_days TYPE i VALUE 2.
    DATA: lv_5per_qty TYPE p DECIMALS 3,
          lv_act_qty  TYPE p DECIMALS 3.



ENDCLASS.

CLASS lhc_zir_ord_att IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    FIELDS ( FileId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_fileid).

    result = VALUE #( FOR ls_fileid IN lt_fileid ( %key = ls_fileid-%key
                                                    %is_draft = ls_fileid-%is_draft
                                                    %features-%action-uploadExcelData = COND #( WHEN ls_fileid-%is_draft = '00'
                                                                                              THEN if_abap_behv=>fc-f-read_only
                                                                                              ELSE if_abap_behv=>fc-f-unrestricted ) ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD uploadExcelData.
*&---------------------------------------------------------------------*
*& DOMS
*&---------------------------------------------------------------------*
* Report/WRICEF:FS_PP_11
* Description: BDC FOR CO11N (ZCO11N)
* Created By:CB9980000014
* Created On: May 14, 2025
* Transaction Code:
* Tvarvc/Other:
* Custom Table:ZEXCEL_ORD_ATT & ZEXCEL_ORD_TBL
*&---------------------------------------------------------------------*
*&                    Modification Log
*&---------------------------------------------------------------------*
* Date       Developer   Transport #    Description                    *
* 05/14/25   MANISH M    MCUK900054      Initial program development    *
* MM/DD/YY   XXXXXX      MCUKxxxxx      Acceptance                     *
*&---------------------------------------------------------------------*
** Read the parent instance
    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
           ENTITY ZIR_ORD_att
           ALL FIELDS WITH
           CORRESPONDING #( keys )
           RESULT DATA(lt_attachment_data).

** Get attachment value from the instance
    DATA(lv_attachment) = lt_attachment_data[ 1 ]-attachment.
** Get File Id value from the instance
    DATA(file_id)    = lt_attachment_data[ 1 ]-FileId.

    TYPES: BEGIN OF ty_excel,
             order              TYPE string,
             operation          TYPE string,
             partial            TYPE string,
             final              TYPE string,
             autofinal          TYPE string,
             yieldtobeconfirmed TYPE string,
             confirmedscrap     TYPE string,
             rework             TYPE string,
             executionstart     TYPE string,
             finishdate         TYPE string,
             postingdate        TYPE string,
           END OF ty_excel,

           tt_excel TYPE STANDARD TABLE OF ty_excel.

    DATA: lt_rows TYPE tt_excel.

    DATA: rows            TYPE STANDARD TABLE OF string,
          content         TYPE string,
          conv            TYPE REF TO cl_abap_conv_codepage,
          ls_excel_data   TYPE zexcel_ord_tbl,
          lt_excel_data   TYPE STANDARD TABLE OF zexcel_ord_tbl,
          lt_ord_Data     TYPE TABLE FOR CREATE ZIR_ORD_att\_ordtable,
          lo_table_descr  TYPE REF TO cl_abap_tabledescr,
          lo_struct_descr TYPE REF TO cl_abap_structdescr,
          lv_yield        TYPE char13,
          lv_scrap        TYPE char13,
          lv_rework       TYPE char13.

** Convert excel file into internal table in string

    DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attachment )->read_access( ).
    DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

* Split the string table to rows
    DATA(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_rows ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).



    " Get number of columns in upload file for validation
    TRY.
        lo_table_descr ?= cl_abap_tabledescr=>describe_by_data( p_data = lt_rows ).
        lo_struct_descr ?= lo_table_descr->get_table_line_type( ).
        DATA(lv_no_of_cols) = lines( lo_struct_descr->components ).
      CATCH cx_sy_move_cast_error.
        "Implement error handling
    ENDTRY.

    FIELD-SYMBOLS: <lfs_col_header> TYPE string.
    "Validate Header record
    DATA(ls_header) = VALUE #( lt_rows[ 1 ] OPTIONAL ).
    DATA(lv_has_error) = abap_false.
    IF ls_header IS NOT INITIAL.
      DO lv_no_of_cols TIMES.
        DATA(lv_index) = sy-index.
        ASSIGN COMPONENT lv_index OF STRUCTURE ls_header TO <lfs_col_header>.
        CHECK <lfs_col_header> IS ASSIGNED.
        DATA(lv_value) = to_upper( <lfs_col_header> ).
*        DATA(lv_has_error) = abap_false.
        CASE lv_index.
*          WHEN 1.
*            lv_has_error = COND #( WHEN lv_value <> 'FILEID' THEN abap_true ELSE lv_has_error ).
          WHEN 1.
            lv_has_error = COND #( WHEN lv_value <> 'ORDER' THEN abap_true ELSE lv_has_error ).
          WHEN 2.
            lv_has_error = COND #( WHEN lv_value <> 'OPERATION' THEN abap_true ELSE lv_has_error ).
          WHEN 3.
            lv_has_error = COND #( WHEN lv_value <> 'PARTIAL' THEN abap_true ELSE lv_has_error ).
          WHEN 4.
            lv_has_error = COND #( WHEN lv_value <> 'FINAL' THEN abap_true ELSE lv_has_error ).
          WHEN 5.
            lv_has_error = COND #( WHEN lv_value <> 'AUTOFINAL' THEN abap_true ELSE lv_has_error ).
          WHEN 6.
            lv_has_error = COND #( WHEN lv_value <> 'YIELDTOBECONFIRMED' THEN abap_true ELSE lv_has_error ).
          WHEN 7.
            lv_has_error = COND #( WHEN lv_value <> 'CONFIRMEDSCRAP' THEN abap_true ELSE lv_has_error ).
          WHEN 8.
            lv_has_error = COND #( WHEN lv_value <> 'REWORK' THEN abap_true ELSE lv_has_error ).
          WHEN 9.
            lv_has_error = COND #( WHEN lv_value <> 'EXECUTIONSTART' THEN abap_true ELSE lv_has_error ).
          WHEN 10.
            lv_has_error = COND #( WHEN lv_value <> 'FINISHDATE' THEN abap_true ELSE lv_has_error ).
          WHEN 11.
            lv_has_error = COND #( WHEN lv_value <> 'POSTINGDATE' THEN abap_true ELSE lv_has_error ).
          WHEN 15. "More than 15 columns (error)
            lv_has_error = abap_true.
        ENDCASE.
        IF lv_has_error = abap_true.
          APPEND VALUE #( %tky = lt_attachment_data[ 1 ]-%tky ) TO failed-zir_ord_att.

          APPEND VALUE #( %state_area  = 'mandatory_check'

           %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                         text = 'Process is not maintained in Process Table' ) ) TO reported-zir_ord_att.

          UNASSIGN <lfs_col_header>.
          EXIT.
        ENDIF.
        UNASSIGN <lfs_col_header>.
      ENDDO.
    ENDIF.

** Delete duplicate records and header row of excel
    DELETE ADJACENT DUPLICATES FROM lt_excel_data.
    DELETE lt_rows INDEX 1.
    DELETE lt_rows WHERE order IS INITIAL.

** Process the rows and append to the internal table
    LOOP AT lt_rows INTO DATA(ls_row).
      ls_excel_data-file_id        = file_id. "ls_row-file_id.
      ls_excel_data-mfgorder       = ls_row-order.
      ls_excel_data-order_id       = ls_row-operation.
      ls_excel_data-partial_cnf    = ls_row-partial.
      lv_yield                     = ls_row-yieldtobeconfirmed.
      lv_scrap                     = ls_row-confirmedscrap.
      lv_rework                    = ls_row-rework.
      ls_excel_data-final_cnf      = ls_row-final.
      ls_excel_data-auto_cnf       = ls_row-autofinal.
      ls_excel_data-partial_cnf    = ls_row-partial.
      ls_excel_data-execution_date = ls_row-executionstart.
      ls_excel_data-finish_date    = ls_row-finishdate.
      ls_excel_data-posting_dt     = ls_row-postingdate.
      ls_excel_data-mfgorder       = |{ ls_excel_data-mfgorder ALPHA = IN }|.
      ls_excel_data-yield_cnf      = CONV #( lv_yield ).
      ls_excel_data-cnf_scrap      = CONV #( lv_scrap ).
      ls_excel_data-rework         = CONV #( lv_rework ).

      APPEND ls_excel_data TO lt_excel_data.
      CLEAR: ls_row, ls_excel_data.

    ENDLOOP.

** Prepare the datatypes to store the data from internal table lt_excel_data to child entity through EML
    lt_ord_data = VALUE #(
        (   %cid_ref  = keys[ 1 ]-%cid_ref
            %is_draft = keys[ 1 ]-%is_draft
            FileId    = keys[ 1 ]-FileId
            %target   = VALUE #(
                FOR ls_excel IN lt_excel_data (
                        %cid             = keys[ 1 ]-%cid_ref
                        %is_draft        = keys[ 1 ]-%is_draft
                        FileId           = ls_excel-file_id
                        Mfgorder         = ls_excel-mfgorder
                        orderid          = ls_excel-order_id
                        PartialCnf       = ls_excel-partial_cnf
                        FinalCnf         = ls_excel-final_cnf
                        AutoCnf          = ls_excel-auto_cnf
                        YieldCnf         = ls_excel-yield_cnf
                        CnfScrap         = ls_excel-cnf_scrap
                        Rework           = ls_excel-rework
                        Unit             = ls_excel-unit
                        ExecutionDate    = ls_excel-execution_date
                        Finishdate       = ls_excel-finish_date
                        PostingDt        = ls_excel-posting_dt
*                    )
                    %control = VALUE #(
*                        EndUser         = if_abap_behv=>mk-on
                        FileId           = if_abap_behv=>mk-on
                        Mfgorder         = if_abap_behv=>mk-on
                        OrderId          = if_abap_behv=>mk-on
                        PartialCnf       = if_abap_behv=>mk-on
                        FinalCnf         = if_abap_behv=>mk-on
                        AutoCnf          = if_abap_behv=>mk-on
                        YieldCnf         = if_abap_behv=>mk-on
                        CnfScrap         = if_abap_behv=>mk-on
                        Rework           = if_abap_behv=>mk-on
                        Unit             = if_abap_behv=>mk-on
                        ExecutionDate    = if_abap_behv=>mk-on
                        Finishdate       = if_abap_behv=>mk-on
                        Postingdt        = if_abap_behv=>mk-on

                    )
                )
            )
        )
    ).



***************


    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    BY \_ordtable
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_excel).

    IF lt_excel IS NOT INITIAL.
** Delete already existing entries from child entity
      MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
      ENTITY zi_ord_tbl
      DELETE FROM VALUE #( FOR ls_excel1 IN lt_excel (
       %is_draft = ls_excel1-%is_draft
                                                       %key      = ls_excel1-%key ) )
      MAPPED DATA(lt_mapped_delete)
      REPORTED DATA(lt_reported_delete)
      FAILED DATA(lt_failed_delete).
    ENDIF.

    "Add New Entry for excel data (Association)
    MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    CREATE BY \_ordtable
     AUTO FILL CID
     WITH lt_ord_data.

    APPEND VALUE #( %tky = lt_attachment_data[ 1 ]-%tky ) TO mapped-ZIR_ORD_att.

    "if new entry is added
    IF reported-ZIR_ORD_att IS INITIAL.
      APPEND VALUE #( %tky = lt_attachment_data[ 1 ]-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text = 'Excel Data Uploaded' )
                     ) TO reported-ZIR_ORD_att.

    ENDIF.

    MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    UPDATE FROM VALUE #( (
    %is_draft = keys[ 1 ]-%is_draft
                           FileId  = ls_excel_data-file_id
                           Status     =  'P'
                           FileStatus = 'excel file uploaded'
                           %control  = VALUE #( Status = if_abap_behv=>mk-on
                                                 FileStatus = if_abap_behv=>mk-on ) ) )
    MAPPED DATA(lt_mapped_update)
    REPORTED DATA(lt_reported_update)
    FAILED DATA(lt_failed_update).

    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_file_status).


    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
       ENTITY ZIR_ORD_att
       ALL FIELDS WITH
       CORRESPONDING #( keys )
       RESULT DATA(lt_file).

    result = VALUE #( FOR ls_file IN lt_file ( %tky   = ls_file-%tky
                                               %param = ls_file ) ).

  ENDMETHOD.

  METHOD fields.
**=> Reading the fields of excel

    SELECT  FROM zexcel_ord_att                         "#EC CI_NOWHERE
      FIELDS @abap_true
       INTO @DATA(lv_valid).
    ENDSELECT.

    IF lv_valid <> abap_true.
    ENDIF.

    MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    UPDATE FROM VALUE #( FOR key IN keys ( FileId        = key-FileId
                                           Status          = 'S' " Accepted
                                           %control-status = if_abap_behv=>mk-on ) ).

    IF keys[ 1 ]-%is_draft = '01'.

      MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
      ENTITY ZIR_ORD_att
      EXECUTE uploadexceldata
      FROM CORRESPONDING #( keys ).
    ENDIF.


  ENDMETHOD.

  METHOD FillFileStatus.

    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
       ENTITY ZIR_ORD_att FIELDS (  FileStatus )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_user).

    "Update File Status
    LOOP AT lt_user INTO DATA(ls_user).
      MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
      ENTITY ZIR_ORD_att
      UPDATE FIELDS ( FileStatus Status )
      WITH VALUE #( (
          %tky                  = ls_user-%tky
          %data-FileStatus      = 'File Not Selected'
          %control-FileStatus   = if_abap_behv=>mk-on
          ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD FillSelectedStatus.

    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
         ENTITY ZIR_ORD_att BY \_ordtable
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_existing_XLData).

    IF lt_existing_xldata IS NOT INITIAL.
      MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
      ENTITY zi_ord_tbl DELETE FROM VALUE #(
        FOR ls_data IN lt_existing_XLData (
          %key        = ls_data-%key ) ).
*          %is_draft   = lwa_data-%is_draft ) ).
    ENDIF.

    "Read XL_Head Entities and change file status
    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_xlhead).

    "Update File Status
    LOOP AT lt_xlhead INTO DATA(ls_xlhead).
      MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
      ENTITY ZIR_ORD_att
      UPDATE FIELDS ( FileStatus )
      WITH VALUE #( (
          %tky                  = ls_xlhead-%tky
          %data-FileStatus      = COND #(
                                    WHEN ls_xlhead-Attachment IS INITIAL
                                    THEN 'File Not Selected'
                                    ELSE 'File Selected' )
          %control-FileStatus   = if_abap_behv=>mk-on
          ) ).
    ENDLOOP.


  ENDMETHOD.

  METHOD callAPI.

**********************************************************************
***=> Reading the orders data from the Excel and storing in the Final result table
    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
    ENTITY ZIR_ORD_att
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(it_result)
    ENTITY ZIR_ORD_att BY \_ordtable
    ALL FIELDS WITH CORRESPONDING #( keys )
    LINK DATA(link)
    RESULT DATA(final_result)
    FAILED DATA(failed_data)
    REPORTED DATA(reported_data).

**    INSERT INITIAL LINE INTO final_result INDEX 1.
*    DATA(ls_first) = final_result[ 1 ].
*    CLEAR: ls_first-YieldCnf.
*    INSERT ls_first INTO final_result INDEX 2.

*    SORT final_result BY Mfgorder DESCENDING.

**=> Checking whether data present in final result or not
    IF final_result IS INITIAL.
      RETURN.
    ENDIF.

**=> Data Declarations

    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.
    DATA lt_plantstor  TYPE TABLE FOR CREATE zc_pp_plantstrloc.
    DATA lt_all_confirmations TYPE TABLE FOR CREATE i_productionordconfirmationtp.
    DATA lt_all_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_ProdnOrdConfMatlDocItm.
    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
*        DATA lt_target TYPE SORTED TABLE OF LineType WITH UNIQUE KEY %target.
    DATA lt_target LIKE <ls_matldocitm>-%target.

**=> Looping the final result i.e based on Each order
    LOOP AT final_result ASSIGNING FIELD-SYMBOL(<fs_final>).

      IF <fs_final>-Mfgorder IS INITIAL OR <fs_final>-OrderId IS INITIAL.
        APPEND VALUE #( %tky = <fs_final>-%tky ) TO failed_data-zi_ord_tbl.
        APPEND VALUE #( %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Missing mandatory OrderID or OrderOperation for Order: { <fs_final>-Mfgorder }| ) ) TO reported-zi_ord_tbl.
        CONTINUE.
      ENDIF.

      READ ENTITIES OF i_ProductionOrdConfirmationTP FORWARDING PRIVILEGED
      ENTITY ProductionOrderConfirmation
      EXECUTE GetConfProposal
      FROM VALUE #(
          ( %param-OrderID = <fs_final>-Mfgorder
            %param-OrderOperation = <fs_final>-OrderId
            %param-ConfirmationYieldQuantity = <fs_final>-YieldCnf
            %param-ConfirmationScrapQuantity = <fs_final>-CnfScrap
            %param-OrderConfirmationRecordType = 'X'
            %param-Sequence = '000000'
*            %param-activityistobeproposed = abap_true
            %param-quantityistobeproposed = abap_true ) )
      RESULT DATA(lt_confproposal)
      REPORTED DATA(lt_reported_conf).

**=> Looping the data based on the confirmation group details fetched from above lt_confproposals
      LOOP AT lt_confproposal ASSIGNING FIELD-SYMBOL(<ls_confproposal>).
        CLEAR lt_target.

        APPEND INITIAL LINE TO lt_confirmation ASSIGNING FIELD-SYMBOL(<ls_confirmation>).
        DATA(lv_conf_cid) = |Conf{ sy-tabix }{ sy-index }|.
        <ls_confirmation>-%cid = lv_conf_cid.
*        <ls_confirmation>-%cid = 'Conf' && sy-tabix.
        <ls_confirmation>-%data = CORRESPONDING #( <ls_confproposal>-%param ).
        <ls_confirmation>-FinalConfirmationType = <fs_final>-FinalCnf.
        <ls_confirmation>-PostingDate  = <fs_final>-PostingDt.
        lv_act_qty = <ls_confirmation>-ConfirmationYieldQuantity.
        <ls_confirmation>-ConfirmationYieldQuantity = <fs_final>-YieldCnf.
*        <ls_confirmation>-

        IF <fs_final>-YieldCnf IS INITIAL OR <fs_final>-YieldCnf = 0.
          APPEND VALUE #( %tky = <fs_final>-%tky ) TO failed_data-zi_ord_tbl.
          APPEND VALUE #( %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-warning
            text = |Yield quantity missing or zero for Order: { <fs_final>-Mfgorder }| ) ) TO reported-zi_ord_tbl.
          CONTINUE.
        ENDIF.


        READ ENTITIES OF i_productionordconfirmationtp FORWARDING PRIVILEGED
        ENTITY productionorderconfirmation
        EXECUTE getgdsmvtproposal
        FROM VALUE #( ( confirmationgroup = <ls_confproposal>-confirmationgroup
*        %param-confirmationyieldquantity = <ls_confproposal>-%param-confirmationyieldquantity ) )
        %param-confirmationyieldquantity = <ls_confirmation>-ConfirmationYieldQuantity ) )

        RESULT DATA(lt_gdsmvtproposal)
        REPORTED DATA(lt_reported_gdsmvt).


        IF lt_gdsmvtproposal IS NOT INITIAL.
*              CLEAR lt_target.
*          CLEAR lt_target.
**=> Looping on the Goods movement available for the above order based on the confirmation group
          LOOP AT lt_gdsmvtproposal ASSIGNING FIELD-SYMBOL(<ls_gdsmvtproposal>) WHERE confirmationgroup = <ls_confproposal>-confirmationgroup.
            APPEND INITIAL LINE TO lt_target ASSIGNING FIELD-SYMBOL(<ls_target>).
            <ls_target> = CORRESPONDING #( <ls_gdsmvtproposal>-%param ).
            <ls_target>-%cid = 'Item' && sy-tabix.

*            READ ENTITIES OF zc_pp_plantstrloc
*            ENTITY zc_pp_plantstrloc
*            FROM VALUE #( ( Plant = <ls_target>-Plant
*                            StorageLocation = <ls_target>-StorageLocation ) )
*            RESULT DATA(ls_result).
*
*            IF ls_result IS INITIAL.
*              APPEND VALUE #( %tky = <fs_final>-%tky ) TO failed_data-zi_ord_tbl.
*              APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |No Plant/storage loc exists for { <fs_final>-Mfgorder } { <ls_target>-ReservationItem }| ) ) TO reported-zi_ord_tbl.
*              CONTINUE.
*            ENDIF.
          ENDLOOP.

**=> appending the Item level data to matldocitm
          APPEND VALUE #( %cid_ref = <ls_confirmation>-%cid
          %target = lt_target
          confirmationgroup = <ls_confproposal>-confirmationgroup ) TO lt_matldocitm.
        ELSE.
          CONTINUE. " Skip current loop iteration if no goods movement proposals found
        ENDIF.
      ENDLOOP.

**=> Checking whether header(lt_confirmation) and item level(lt_matldocitm) data is present
      IF lt_confirmation IS NOT INITIAL AND lt_matldocitm IS NOT INITIAL.

**=> Confirmation of order
        MODIFY ENTITIES OF i_productionordconfirmationtp FORWARDING PRIVILEGED
        ENTITY productionorderconfirmation
        CREATE FROM lt_confirmation
        CREATE BY \_prodnordconfmatldocitm FROM lt_matldocitm
        MAPPED DATA(lt_mapped)
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

*        COMMIT ENTITIES.
      ENDIF.

      READ ENTITIES OF zc_pp_plantstrloc
                    ENTITY zc_pp_plantstrloc
                    FROM VALUE #( FOR ls_target IN lt_target
                                  ( %key-Plant = ls_target-Plant
                                    %key-StorageLocation = ls_target-StorageLocation ) )
                    RESULT DATA(lt_result).

      IF lt_mapped IS NOT INITIAL.

        DATA(lv_SystemDate) = cl_abap_context_info=>get_system_date( ).
        DATA(lv_date) = CONV datum( lv_SystemDate - c_days ).

        lv_5per_qty = ( lv_act_qty / 100 ) * 5.

**=>Checking whether the posting date Validation that should not be less than 3 days
        IF <ls_confirmation>-PostingDate < lv_date.
          APPEND VALUE #( %tky = <fs_final>-%tky ) TO failed_data-zi_ord_tbl.
          APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Posting Date is less than 3 days for{ <fs_final>-Mfgorder }| ) ) TO reported-zi_ord_tbl.
        ENDIF.
**=>Checking the Quantity should not be less than or greater than 5% than the original quantity
*        IF <ls_confirmation>-ConfirmationYieldQuantity NOT BETWEEN ( lv_act_qty - lv_5per_qty ) AND ( lv_5per_qty + lv_act_qty ).
*
*          APPEND VALUE #( %tky = <fs_final>-%tky ) TO failed_data-zi_ord_tbl.
*          APPEND VALUE #( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Qty less than or greater than 5% for{ <fs_final>-Mfgorder }| ) ) TO reported-zi_ord_tbl.
*
*        ENDIF.

        IF reported-zi_ord_tbl IS INITIAL.
          MODIFY ENTITIES OF ZIR_ORD_att IN LOCAL MODE
             ENTITY zi_ord_tbl
             UPDATE FIELDS ( status )
             WITH VALUE #( (
                 %tky                  = <fs_final>-%tky
                 %data-Status      = 'Confirmed'
                 %control-Status   = if_abap_behv=>mk-on
                 ) ) .

        ENDIF.

      ENDIF.
*      ENDIF.
**=> Clearing all the internal tables after the confirmation of one order
      CLEAR lt_target.
      CLEAR lt_confirmation.
      CLEAR lt_matldocitm.
      CLEAR lt_gdsmvtproposal.
      CLEAR lt_mapped.
      CLEAR lt_failed.
      CLEAR lt_reported.

***=> ending of one Production order
*    ENDIF. "postingdate
    ENDLOOP.





  ENDMETHOD.

*  METHOD callAPI.
*
***********************************************************************
****=> Reading the orders data from the Excel and storing in the Final result table
*    READ ENTITIES OF ZIR_ORD_att IN LOCAL MODE
*    ENTITY ZIR_ORD_att
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(it_result)
*    ENTITY ZIR_ORD_att BY \_ordtable
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    LINK DATA(link)
*    RESULT DATA(final_result)
*    FAILED DATA(failed_data)
*    REPORTED DATA(reported_data).
*
***    INSERT INITIAL LINE INTO final_result INDEX 1.
**    DATA(ls_first) = final_result[ 1 ].
**    CLEAR: ls_first-YieldCnf.
**    INSERT ls_first INTO final_result INDEX 2.
*
**    SORT final_result BY Mfgorder DESCENDING.
*
***=> Checking whether data present in final result or not
*    IF final_result IS INITIAL.
*      RETURN.
*    ENDIF.
*
***=> Data Declarations
*
*    DATA lt_confirmation TYPE TABLE FOR CREATE i_productionordconfirmationtp.
*    DATA lt_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_prodnordconfmatldocitm.
*    DATA lt_plantstor  TYPE TABLE FOR CREATE zc_pp_plantstrloc.
*    DATA lt_all_confirmations TYPE TABLE FOR CREATE i_productionordconfirmationtp.
*    DATA lt_all_matldocitm TYPE TABLE FOR CREATE i_productionordconfirmationtp\_ProdnOrdConfMatlDocItm.
*    FIELD-SYMBOLS <ls_matldocitm> LIKE LINE OF lt_matldocitm.
**        DATA lt_target TYPE SORTED TABLE OF LineType WITH UNIQUE KEY %target.
*    DATA lt_target LIKE <ls_matldocitm>-%target.
*
*    LOOP AT final_result ASSIGNING FIELD-SYMBOL(<fs_final>).
*      zcl_ord_confirmation=>order_confirmation(
*        EXPORTING
*          mfg_order   = <fs_final>-Mfgorder
*          orderid     = <fs_final>-OrderId
*          yieldconf   = <fs_final>-YieldCnf
*          finalconf   = <fs_final>-FinalCnf
*          postingdate = <fs_final>-PostingDt
**      RECEIVING
**        et_data     =
*      ).
*    ENDLOOP.
*
*  ENDMETHOD.



ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
