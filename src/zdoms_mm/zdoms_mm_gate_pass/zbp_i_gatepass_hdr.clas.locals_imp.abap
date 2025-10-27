    CLASS lhc_zi_gatepass_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS quantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_gatepass_item~quantity.

ENDCLASS.

CLASS lhc_zi_gatepass_item IMPLEMENTATION.

  METHOD quantity.

    READ ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
    ENTITY zi_gatepass_item
    FIELDS ( Quantity Totalreceivedqty )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_quantity)
    FAILED DATA(lt_qty_failed).

    LOOP AT lt_quantity ASSIGNING FIELD-SYMBOL(<fs_qty>).

      IF <fs_qty>-Totalreceivedqty > <fs_qty>-Quantity.

        APPEND VALUE #( %tky = <fs_qty>-%tky ) TO failed-zi_gatepass_item.

        APPEND VALUE #( %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
*                                 text     = | Received Quantity { <fs_qty>-Totalreceivedqty } is less than { <fs_qty>-Quantity } original quantity|
                                 text     = | Total Received Qty is Greater than original qty|
                               ) ) TO reported-zi_gatepass_item.

*  APPEND VALUE #( %msg = new_message(
*                           id       = |ZMM|
*                           number   = |004|
*                           severity =
*                         ) ) TO reported-zi_gatepass_item.


      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_GATEPASS_HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_gatepass_hdr RESULT result.
    METHODS setvendordetails FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_gatepass_hdr~setvendordetails.
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR zi_gatepass_hdr RESULT result.
*    METHODS print FOR MODIFY
*      IMPORTING keys FOR ACTION zi_gatepass_hdr~print.

    METHODS earlynumbering_cba_item FOR NUMBERING
      IMPORTING entities FOR CREATE zi_gatepass_hdr\_item.
*    METHODS earlynumbering_cba_item FOR NUMBERING
*      IMPORTING entities FOR CREATE zi_gatepass_hdr\_item.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_gatepass_hdr.

ENDCLASS.

CLASS lhc_ZI_GATEPASS_HDR IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA:LV_GatePassNo TYPE zi_gatepass_hdr-Gatepassnumber.
    SELECT MAX( Gatepassnumber ) FROM zmm_gateentryhdr "#EC CI_NOWHERE.
    INTO @LV_GatePassNo.
    IF LV_GatePassNo IS NOT INITIAL.
      LV_GatePassNo += 1.
    ELSE.
      LV_GatePassNo = 1.
    ENDIF.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      INSERT VALUE #( %cid            = <ls_entity>-%cid
                      Gatepassnumber        = LV_GatePassNo
                      Gatepasstype = <ls_entity>-Gatepasstype ) INTO TABLE mapped-zi_gatepass_hdr.
    ENDLOOP.
    CLEAR: LV_GatePassNo.
  ENDMETHOD.

  METHOD SetVendordetails.

    READ ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
     ENTITY zi_gatepass_hdr
       FIELDS ( Vendorcode Vendorname  )
       WITH CORRESPONDING #( keys )
     RESULT DATA(VendorData)
     FAILED DATA(read_failed).

    IF vendordata IS NOT INITIAL.
**********************************************************************
**=>Fetching the Quantity
**********************************************************************
      SELECT SINGLE FROM @vendordata AS _vendor
      LEFT OUTER JOIN ZI_SupplierDeatilsVH WITH PRIVILEGED ACCESS AS _supplier  ON _vendor~Vendorcode = _supplier~supplier

            FIELDS _supplier~Supplier,
            _supplier~BusinessPartnerName1,
            _supplier~GstNo,
            _supplier~state,
            _supplier~Address,
            _supplier~PostalCode,
            _supplier~Address1
             INTO  @DATA(lt_qty).

    ENDIF.




    LOOP AT VendorData ASSIGNING FIELD-SYMBOL(<fs_mat_data>).
*
      IF <fs_mat_data>-Vendorcode = lt_qty-Supplier.
        <fs_mat_data>-Vendorname = lt_qty-BusinessPartnerName1.
        <fs_mat_data>-Gstno      = lt_qty-GstNo.
        <fs_mat_data>-State      = lt_qty-state.
        <fs_mat_data>-Pincode    = lt_qty-PostalCode.
        <fs_mat_data>-Address    = lt_qty-Address1.

      ENDIF.

    ENDLOOP.
    DATA lt_mat_data_upd1 TYPE TABLE FOR UPDATE zi_gatepass_hdr.
    lt_mat_data_upd1 = CORRESPONDING #( vendordata ).


    MODIFY ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
              ENTITY zi_gatepass_hdr
              UPDATE
              FIELDS ( Vendorname Gstno State Address Pincode  )
               WITH CORRESPONDING #( lt_mat_data_upd1 )
               REPORTED DATA(modified).

    reported-zi_gatepass_hdr = CORRESPONDING #( modified-zi_gatepass_hdr ).



  ENDMETHOD.

*  METHOD earlynumbering_cba_Item.


*LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
*      LOOP AT <ls_entity>-%target ASSIGNING FIELD-SYMBOL(<ls_item_create>).
*        INSERT VALUE #( %cid            = <ls_item_create>-%cid
*                        DocumentNumber  = <ls_entity>-DocumentNumber
*                        ItemNumber      = lo_doc_handler->get_next_item_number( iv_doc_number = <ls_entity>-DocumentNumber ) ) INTO TABLE mapped-item.
*      ENDLOOP.
*    ENDLOOP.



*
*    READ ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
*       ENTITY zi_gatepass_hdr  BY \_item
*         FROM CORRESPONDING #( entities )
*         LINK DATA(booking_supplements)
*         FAILED DATA(failedItem) REPORTED DATA(reporteditem) .
*
*
**    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
**      INSERT VALUE #( %cid            = <ls_entity>-%key
**
**                      Gatepasstype = <ls_entity>-Gatepasstype ) INTO TABLE mapped-zi_gatepass_hdr.
**    ENDLOOP.
**    CLEAR: LV_GatePassNo.
*
*  ENDMETHOD.

  METHOD earlynumbering_cba_Item.

    DATA: lv_sl_no TYPE int1.


    READ ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
    ENTITY zi_gatepass_hdr BY \_item
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) GROUP BY <ls_entity>-Gatepassnumber.

      lv_sl_no = REDUCE #( INIT lv_max  = CONV int1( '0' )
                           FOR ls_link IN lt_link_data USING KEY entity
                           WHERE ( source-Gatepassnumber = <ls_entity>-Gatepassnumber
                                   AND source-Gatepasstype = <ls_entity>-Gatepasstype )
                           NEXT lv_max = COND int1( WHEN lv_max < ls_link-target-Slno
                                                    THEN ls_link-target-Slno
                                                    ELSE lv_max ) ).

      lv_sl_no = REDUCE #( INIT lv_max = lv_sl_no
                           FOR ls_ent IN entities USING KEY entity
                          WHERE ( Gatepassnumber = <ls_entity>-Gatepassnumber
                                  AND Gatepasstype = <ls_entity>-Gatepasstype )
                             FOR ls_item IN ls_ent-%target
                                  NEXT lv_max = COND int1( WHEN lv_max < ls_item-Slno
                                                   THEN ls_item-Slno
                                                   ELSE lv_max ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>) USING KEY entity
                                                         WHERE Gatepassnumber = <ls_entity>-Gatepassnumber AND Gatepasstype = <ls_entity>-Gatepasstype.

      ENDLOOP.

      LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_item_create>).


        IF <ls_item_create>-Slno IS INITIAL.

          lv_sl_no += 1.

          APPEND CORRESPONDING #( <ls_item_create> ) TO mapped-zi_gatepass_item ASSIGNING FIELD-SYMBOL(<fs_new_sl>).

          <fs_new_sl>-Slno = lv_sl_no.

        ENDIF.

*      MODIFY ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
*          ENTITY zi_gatepass_item
*          UPDATE FIELDS ( Slno )
*          WITH VALUE #( (
*              %tky                  = <ls_entity>-%tky
*              %data-Slno      = 1
*              %control-Slno   = if_abap_behv=>mk-on
*              ) ) .

*        <ls_item_create>-Slno = 01.





*      INSERT VALUE #( %cid            = <ls_item_create>-%cid
*                      Slno = 1 ) INTO TABLE mapped-zi_gatepass_item.


      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

*  METHOD get_instance_features.
*  ENDMETHOD.



*  METHOD print.
*
*    DATA: rt_table TYPE TABLE OF zcustom_ads.
*
*    CONSTANTS: lv_fname TYPE string VALUE 'GatePassEntry',
*               lv_tname TYPE string VALUE 'GatePassEntry'.
*
*    READ ENTITIES OF zi_gatepass_hdr IN LOCAL MODE
*    ENTITY zi_gatepass_hdr
*       ALL FIELDS WITH CORRESPONDING #( keys )
*       RESULT DATA(heads).
*
*    TRY.
*        DATA(ls_header) = heads[ 1 ].
*      CATCH cx_sy_itab_line_not_found.
*    ENDTRY.
*
*
*    TRY.
*        "Initialize Template Store Client
*        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
*
*    "name of the destination (in destination service instance) pointing to Forms Service by Adobe API service instance
*    iv_service_instance_name = 'ZSC_ASD_STORE'
*    iv_use_destination_service = abap_false ).
*
*
**        lv_fname = 'Inward'.
**        lv_tname = 'Inward'.
*
*        DATA(ls_template) = lo_store->get_template_by_name(
*            iv_get_binary = abap_true
*            iv_form_name = lv_fname    "GatePassEntry' "<= form object in template store
*            iv_template_name = lv_tname    "'GatePassEntry' "<= template (in form object) that should be used
*
*            ).
*
*        DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( 'ZUI_C_GATEPASS_ADS' ).
*        DATA(lt_keys)     = lo_fdp_util->get_keys( ).
*        lt_keys[ name = 'GATEPASSNUMBER' ]-value = ls_header-gatepassnumber.    "'9940E2EF70DD1EEE90B237547DF09ECC'.
*        lt_keys[ name = 'GATEPASSTYPE' ]-value  = ls_header-Gatepasstype.
*        DATA(lv_xml_final1) = lo_fdp_util->read_to_xml( lt_keys ).
*        DATA(lv_schema) = lo_fdp_util->get_xsd(  ).
*
*
**        cl_fp_ads_util=>render_4_pq(
**          EXPORTING
**          iv_locale = ''"'en_US'
**          iv_pq_name = 'PRINT_TICKET'           "'YO1CLNT100Q' "<= Name of the print queue where result should be stored
**          iv_xml_data = lv_xml_final1
**          iv_xdp_layout = ls_template-xdp_template
**          is_options = VALUE #(
**          trace_level = 4 "Use 0 in production environment
**          )
**          IMPORTING
**          ev_trace_string = DATA(lv_trace)
**          ev_pdl = DATA(lv_pdf)
**          ).
**
**        cl_print_queue_utils=>create_queue_item_by_data(
**            iv_qname = 'PRINT_TICKET'
**            iv_print_data = lv_pdf
**            iv_name_of_main_doc = 'Inward Ticket'
**    ).
*
*
*
*        "render PDF and get the PDF in binary base64 format
*        cl_fp_ads_util=>render_pdf(
*          EXPORTING
*            iv_xml_data     = lv_xml_final1
*            iv_xdp_layout   = ls_template-xdp_template
*            iv_locale       = 'en_US'
*          IMPORTING
*            ev_pdf          = DATA(lv_pdf_stream)
*            ev_pages        = DATA(lv_pages)
*            ev_trace_string = DATA(lv_trace)
*        ).
*
*        "decode binary data into BASE64 format
*        DATA(lv_pdf_stream_x) = cl_web_http_utility=>decode_x_base64( encoded = CONV string( lv_pdf_stream ) ).
*
*        APPEND VALUE zcustom_ads( stream_data = lv_pdf_stream ) TO rt_table.
*
*
*
*      CATCH cx_fp_fdp_error INTO DATA(lo_fdp).
*        DATA(message) =  lo_fdp->get_longtext(  ).
*        "          out->write( message ).
*        APPEND VALUE #(
*             %tky = ls_header-%tky
*             %msg = new_message_with_text(
*             severity = if_abap_behv_message=>severity-error
*             text     = |{ message }|
*          )
*
*          ) TO reported-zi_gatepass_hdr.
*        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-zi_gatepass_hdr.
*      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_error).
*        message =  lo_error->get_longtext(  ).
*        APPEND VALUE #(
*             %tky = ls_header-%tky
*             %msg = new_message_with_text(
*             severity = if_abap_behv_message=>severity-error
*             text     = |{ message }|
*          )
*
*          ) TO reported-zi_gatepass_hdr.
*      CATCH cx_fp_ads_util INTO DATA(lo_util).
*        message =  lo_util->get_longtext(  ).
*        APPEND VALUE #(
*             %tky = ls_header-%tky
*             %msg = new_message_with_text(
*             severity = if_abap_behv_message=>severity-error
*             text     = |{ message }|
*          )
*
*          ) TO reported-zi_gatepass_hdr.
*    ENDTRY.
*
*
*
*  ENDMETHOD.

ENDCLASS.
