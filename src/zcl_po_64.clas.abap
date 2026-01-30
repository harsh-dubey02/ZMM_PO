CLASS zcl_po_64 DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

 METHODS escape_xml
  IMPORTING
    iv_in         TYPE any
  RETURNING
    VALUE(rv_out) TYPE string.


    METHODS get_pdf_64
      IMPORTING
                VALUE(io_purchaseorder) TYPE i_purchaseorderapi01-purchaseorder
      RETURNING VALUE(pdf_64)           TYPE string.

    DATA : lv_item   TYPE string,
           lv_header TYPE string,
           lv_footer TYPE string,
           lv_xml    TYPE string.

    DATA lv_amt_word TYPE string.
    DATA lv_total TYPE p LENGTH 15 DECIMALS 3 VALUE 0.
    DATA lv_amt TYPE p LENGTH 15 DECIMALS 3 VALUE 0.
    DATA lv_grandtotal TYPE p LENGTH 15 DECIMALS 3 VALUE 0.



    DATA: lv_vend_nm_xml       TYPE string,
          lv_vend_addr_xml     TYPE string,
          lv_bill_addr_xml     TYPE string,
          lv_del_addr_xml      TYPE string,
          lv_del_addr1_xml     TYPE string,
          lv_mat_descr_xml     TYPE string,
          lv_manfname_xml      TYPE string,
          lv_conditiontext_xml TYPE string,
          lv_des               TYPE string.

    "Local helper to escape XML


    TYPES: BEGIN OF ty_header,
             po_no(35)                   TYPE c,
             po_date(10)                 TYPE c,
             qtn_ref(10)                 TYPE c,
             pr_no(10)                   TYPE c,
             pr_dt(10)                   TYPE c,
             req_nm(30)                  TYPE c,
             vend_nm(30)                 TYPE c,
             vend_addr(100)              TYPE c,
             bill_nm(30)                 TYPE c,
             bill_addr(100)              TYPE c,
             del_addr(100)               TYPE c,
             del_addr1(100)              TYPE c,
             vend_email(100)             TYPE c,
             vend_cont(10)               TYPE c,
             vend_gst(20)                TYPE c,
             vend_cert(20)               TYPE c,
             inco_term(50)               TYPE c,
             pay_term(50)                TYPE c,
             grand_tot                   TYPE p LENGTH 15 DECIMALS 3,
             mat_descr                   TYPE string,
             amountinwords               TYPE string,
             supplier(50)                TYPE c,
             lastchangedatetime          TYPE i_purchaserequisitionapi01-lastchangedatetime,
             yy1_certificatedocument_pdh TYPE i_purchaseorderapi01-yy1_certficatedocument_pdh,
             yy1_contractvalidity_pdh    TYPE i_purchaseorderapi01-yy1_contractvalidity_pdh,
             yy1_corporateguarantee_pdh  TYPE i_purchaseorderapi01-yy1_corporateguarantee_pdh,
             yy1_installationcommis_pdh  TYPE i_purchaseorderapi01-yy1_installationcommis_pdh,
             yy1_modeofshipment_pdh      TYPE i_purchaseorderapi01-yy1_modeofshipment_pdh,
             yy1_remarks_pdh             TYPE i_purchaseorderapi01-yy1_remarks_pdh,
             yy1_salescontractnumbe_pdh  TYPE i_purchaseorderapi01-yy1_salescontractnumbe_pdh,
*             YY1_ServiceText1_PDH        TYPE i_purchaseorderapi01-YY1_ServiceText1_PDH,
             yy1_tdstcsdeduction_pdh     TYPE i_purchaseorderapi01-yy1_tdstcsdeduction_pdh,
             yy1_tofro1_pdh              TYPE i_purchaseorderapi01-yy1_tofro1_pdh,
             yy1_warrantyguarantee_pdh   TYPE i_purchaseorderapi01-yy1_warrantyguarantee_pdh,
*             YY1_ServiceText2_PDH        TYPE i_purchaseorderapi01-YY1_ServiceText2_PDH,
             billto                      TYPE i_purchaseorderitemapi01-plant,
*             manufacturerno              TYPE I_PurchaseOrderItemAPI01-YY1_ManufacturerNoA1_PDI,
             amount                      TYPE p LENGTH 15 DECIMALS 3,
             cash_discount_1             TYPE i_purordpricingelementtp_2-conditionamount,
             tax                         TYPE i_purordpricingelementtp_2-conditionamount,
             manual_gross_price          TYPE i_purordpricingelementtp_2-conditionamount,
             discount_quantity           TYPE i_purordpricingelementtp_2-conditionamount,
             absolute_discount           TYPE i_purordpricingelementtp_2-conditionamount,
             freight_quantity_1          TYPE i_purordpricingelementtp_2-conditionamount,
             freight_value_1             TYPE i_purordpricingelementtp_2-conditionamount,
             discount_on_gross           TYPE i_purordpricingelementtp_2-conditionamount,
             insurance                   TYPE i_purordpricingelementtp_2-conditionamount,
             packing                     TYPE i_purordpricingelementtp_2-conditionamount,
             del_to                      TYPE i_address_2-organizationname1,
             bill_gst                    TYPE i_in_businessplacetaxdetail-in_gstidentificationnumber,
           END OF ty_header.
    DATA: gs_header TYPE ty_header.

    DATA : iv_num   TYPE string,
           rv_words TYPE string,
           iv_level TYPE i.

    METHODS num2words
      IMPORTING
        iv_num          TYPE string OPTIONAL
      CHANGING
        iv_level        TYPE i OPTIONAL
      RETURNING
        VALUE(rv_words) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_po_64 IMPLEMENTATION.


  METHOD get_pdf_64.


    SELECT  *
      FROM i_purchaseorderitemapi01
      WHERE purchaseorder = @io_purchaseorder
      INTO TABLE @DATA(it_po_item_pant).
    READ TABLE it_po_item_pant INTO DATA(wa_po_item_pant) WITH KEY  purchaseorder = io_purchaseorder.

    SELECT SINGLE taxcodename
          FROM i_taxcodetext
          WITH PRIVILEGED ACCESS
         WHERE taxcode = @wa_po_item_pant-taxcode
          INTO @DATA(wa_tax_code).

    DATA(lv_tax_text) = wa_tax_code.

    SPLIT lv_tax_text AT '=' INTO lv_tax_text DATA(lv_dummy).
*CONDENSE lv_tax_text NO-GAPS.


    SELECT SINGLE *
   FROM zc_manuf_dtls_n
  WHERE manfno = @wa_po_item_pant-yy1_manufacturerno1_pdi
   INTO @DATA(wa_po_manuf).


    SELECT SINGLE * FROM i_purchaseorderitemnotetp_2
    WHERE purchaseorder = @io_purchaseorder
    INTO @DATA(wa_longtxt).


    SELECT SINGLE *
   FROM i_purchaseorderapi01
   WHERE purchaseorder = @io_purchaseorder
   INTO @DATA(wa_po).

    DATA:    lv_items TYPE string.


    gs_header-po_no     = wa_po-purchaseorder.
    gs_header-po_date   = |{ wa_po-purchaseorderdate+6(2) }/{ wa_po-purchaseorderdate+4(2) }/{ wa_po-purchaseorderdate+0(4) }|.
    gs_header-inco_term = wa_po-incotermsclassification.
    gs_header-pay_term  = wa_po-paymentterms.
    gs_header-qtn_ref   = wa_po-supplierquotationexternalid.
    gs_header-grand_tot = wa_po-purgreleasetimetotalamount.
    gs_header-supplier  = wa_po-supplier.
    gs_header-billto  = wa_po_item_pant-plant.
    gs_header-yy1_certificatedocument_pdh  = wa_po-yy1_certficatedocument_pdh.
    gs_header-yy1_contractvalidity_pdh  = wa_po-yy1_contractvalidity_pdh.
    gs_header-yy1_corporateguarantee_pdh  = wa_po-yy1_corporateguarantee_pdh.
    gs_header-yy1_installationcommis_pdh  = wa_po-yy1_installationcommis_pdh.
    gs_header-yy1_modeofshipment_pdh  = wa_po-yy1_modeofshipment_pdh.
    gs_header-yy1_remarks_pdh  = wa_po-yy1_remarks_pdh.
    gs_header-yy1_salescontractnumbe_pdh  = wa_po-yy1_salescontractnumbe_pdh.
*      gs_header-yy1_servicetext1_pdh  = wa_po-YY1_ServiceText1_PDH.
    gs_header-yy1_tdstcsdeduction_pdh  = wa_po-yy1_tdstcsdeduction_pdh.
    gs_header-yy1_tofro1_pdh  = wa_po-yy1_tofro1_pdh.
    gs_header-yy1_warrantyguarantee_pdh  = wa_po-yy1_warrantyguarantee_pdh.
*      gs_header-YY1_ServiceText2_PDH  = wa_po-YY1_ServiceText2_PDH.

*    DATA: lv_insurance          TYPE decfloat34,
*          lv_insurance1         TYPE decfloat34,
*          lv_packing            TYPE decfloat34,
*          lv_tax                TYPE decfloat34,
*          lv_freight_qty        TYPE decfloat34,
*          lv_freight            TYPE decfloat34,
*          lv_freight_value      TYPE decfloat34,
*          zfqu                  TYPE decfloat34,
*          lv_abs_discount       TYPE decfloat34,
*          lv_disc_on_gross      TYPE decfloat34,
*          lv_disc_quantity      TYPE decfloat34,
*          lv_packing_forwarding TYPE decfloat34,
*          lv_packing_charges TYPE decfloat34,
*          lv_frate              TYPE p LENGTH 15 DECIMALS 2 VALUE 0,
*          lv_rate               TYPE decfloat34,
*          lv_rate1              TYPE decfloat34,
*          lv_total_rate         TYPE decfloat34,
*          lv_total_rate1        TYPE decfloat34,
*          lv_cash_discount      TYPE decfloat34.


    "--------------------------------------------------------
    "querry for payment terms description
    "--------------------------------------------------------
    SELECT SINGLE *
FROM i_paymenttermsconditionstext
WHERE paymentterms = @wa_po-paymentterms
INTO @DATA(wa_payment).
    "--------------------------------------------------------
    "START OF VENDOR NAME AND ADDRESS
    "--------------------------------------------------------

    SELECT SINGLE organizationbpname1
      FROM i_supplier
      WHERE supplier = @wa_po-supplier
      INTO @DATA(lv_vendor_name).

    SELECT SINGLE *
       FROM i_supplier
       WHERE supplier = @wa_po-supplier
       INTO @DATA(lv_vendor_email).

    SELECT SINGLE * FROM i_addressemailaddress_2
   WITH PRIVILEGED ACCESS
   WHERE addressid = @lv_vendor_email-addressid
   INTO @DATA(wa_vendor_email).
    gs_header-vend_nm = lv_vendor_name.

    " Get only required fields from I_Supplier
    SELECT SINGLE streetname, cityname, postalcode,taxnumber3,phonenumber1,sortfield
      FROM i_supplier
      WHERE supplier = @wa_po-supplier
      INTO @DATA(ls_supplier_addr).


    " Concatenate only streetname, cityname, and postalcode
    gs_header-vend_addr =
      |{ ls_supplier_addr-streetname },  { ls_supplier_addr-cityname }, { ls_supplier_addr-postalcode }|.
    CONDENSE gs_header-vend_addr.


    "-------------------------------------------------------
    "START OF BILLING NAME AND ADDRESS
    "--------------------------------------------------------


    SELECT SINGLE plantname
      FROM zi_plant1
      WHERE plant = @wa_po_item_pant-plant
      INTO @DATA(lv_bill_to).


    gs_header-bill_nm = lv_bill_to.



    " Get only required fields from I_Supplier
    SELECT SINGLE streetname, cityname, postalcode
      FROM zi_plant1
      WHERE plant = @wa_po_item_pant-plant
      INTO @DATA(ls_bill_addr).
    .
    " Concatenate only streetname, cityname, and postalcode
    gs_header-bill_addr =
      |{ ls_bill_addr-streetname }, { ls_bill_addr-cityname }, { ls_bill_addr-postalcode }|.
    CONDENSE gs_header-bill_addr.


    SELECT SINGLE businessplace
       FROM zi_plant1
       WHERE plant = @wa_po_item_pant-plant
       INTO @DATA(lv_zi_plant1).


    SELECT SINGLE in_gstidentificationnumber
      FROM i_in_businessplacetaxdetail
      WHERE businessplace = @lv_zi_plant1
      INTO @DATA(lv_bill_gst).


    gs_header-bill_gst = lv_bill_gst.


    "--------------------------------------------------------
    "START OF DELIVERY NAME AND ADDRESS
    "--------------------------------------------------------

    SELECT SINGLE * FROM i_supplier
    WHERE supplier = @wa_po_item_pant-subcontractor
    INTO @DATA(wa_subcontractor).

    SELECT SINGLE * FROM i_address_2
    WITH PRIVILEGED ACCESS
    WHERE addressid = @wa_subcontractor-addressid
    INTO @DATA(wa_subcon_addr).

    SELECT SINGLE phoneareacodesubscribernumber FROM i_addressphonenumber_2
    WITH PRIVILEGED ACCESS
    WHERE addressid = @wa_subcontractor-addressid
    INTO @DATA(ls_subcon_phone).

    DATA : sub_addr(100) TYPE c,
           sub_nm(100)   TYPE c.

    sub_addr =
         |{ wa_subcon_addr-streetname }, { wa_subcon_addr-cityname } { wa_subcon_addr-postalcode }|.
    CONDENSE gs_header-del_addr.

    sub_nm = wa_subcon_addr-organizationname1.


    SELECT SINGLE * FROM i_address_2
     WITH PRIVILEGED ACCESS
     WHERE addressid = @wa_po_item_pant-manualdeliveryaddressid
     INTO @DATA(wa_manual_addr).

    SELECT SINGLE phoneareacodesubscribernumber FROM i_addressphonenumber_2
    WITH PRIVILEGED ACCESS
    WHERE addressid = @wa_manual_addr-addressid
    INTO @DATA(ls_manual_phone).

    DATA : manual_addr(100) TYPE c,
           manual_nm(100)   TYPE c.

    manual_addr =
         |{ wa_manual_addr-streetname }, { wa_manual_addr-cityname } { wa_manual_addr-postalcode }|.
    CONDENSE gs_header-del_addr.

    manual_nm = wa_manual_addr-organizationname1.

    SELECT SINGLE * FROM i_plant
    WHERE plant = @wa_po_item_pant-plant
    INTO @DATA(wa_plant).

    SELECT SINGLE * FROM i_address_2
     WITH PRIVILEGED ACCESS
     WHERE addressid = @wa_plant-addressid
     INTO @DATA(wa_plant_addr).

    SELECT SINGLE phoneareacodesubscribernumber FROM i_addressphonenumber_2
    WITH PRIVILEGED ACCESS
    WHERE addressid = @wa_plant_addr-addressid
    INTO @DATA(ls_plant_phone).

    DATA : plant_addr(100) TYPE c,
           plant_nm(100)   TYPE c.

    plant_addr =
         |{ wa_plant_addr-streetname }, { wa_plant_addr-cityname } { wa_plant_addr-postalcode }|.
    CONDENSE gs_header-del_addr.

    plant_nm = wa_plant_addr-organizationname1.


    DATA: lv_del_name  TYPE string,
          lv_del_addr  TYPE string,
          lv_del_phone TYPE string.
    CLEAR: lv_del_name, lv_del_addr, lv_del_phone.

    "------------------------------------------------
    " CASE 1 – Subcontractor (highest priority)
    "------------------------------------------------
    IF wa_subcontractor-addressid IS NOT INITIAL.

      lv_del_name  = sub_nm.
      lv_del_addr  = sub_addr.
      lv_del_phone = ls_subcon_phone.

      "------------------------------------------------
      " CASE 2 – Manual Delivery Address
      "------------------------------------------------
    ELSEIF wa_po_item_pant-manualdeliveryaddressid IS NOT INITIAL.

      lv_del_name  = manual_nm.
      lv_del_addr  = manual_addr.
      lv_del_phone = ls_manual_phone.

      "------------------------------------------------
      " CASE 3 – Plant Address (fallback)
      "------------------------------------------------
    ELSEIF wa_plant-addressid IS NOT INITIAL.

      lv_del_name  = plant_nm.
      lv_del_addr  = plant_addr.
      lv_del_phone = ls_plant_phone.

    ENDIF.



    "--------------------------------------------------------
    "start of fetching i_purchaseorderitemapi01
    "--------------------------------------------------------
    DATA: it_po_item TYPE TABLE OF i_purchaseorderitemapi01,
          wa_po_item TYPE i_purchaseorderitemapi01.

    SELECT *
      FROM i_purchaseorderitemapi01
      WHERE purchaseorder = @wa_po-purchaseorder
      INTO TABLE @it_po_item.



    SELECT SINGLE effectiveamount
      FROM i_purchaseorderitemapi01
      WHERE purchaseorder = @io_purchaseorder
      INTO @DATA(ls_effamt).


    gs_header-amountinwords = ls_effamt.


    "--------------------------------------------------------
    "start of fetching I_PurOrdPricingElementTP_2 for condition types
    "--------------------------------------------------------



    IF it_po_item IS NOT INITIAL.

      DATA(lv_purreq) = VALUE #( it_po_item[ 1 ]-purchaserequisition DEFAULT space ).
      DATA(lv_reqname) = VALUE #( it_po_item[ 1 ]-requisitionername DEFAULT space ).

      IF lv_purreq IS NOT INITIAL.
        SELECT SINGLE lastchangedatetime
          FROM i_purchaserequisitionapi01
          WHERE purchaserequisition = @lv_purreq
          INTO @gs_header-lastchangedatetime.
      ENDIF.
    ENDIF.

    IF gs_header-lastchangedatetime IS NOT INITIAL.
      DATA(lv_lrdt) = CONV string( gs_header-lastchangedatetime ).
      lv_lrdt = |{ lv_lrdt+6(2) }/{ lv_lrdt+4(2) }/{ lv_lrdt+2(2) }|.
    ENDIF.


    "--------------------------------------------------------
    "START OF FETCHING PRODUCT DESCRIOTION
    "--------------------------------------------------------
    IF it_po_item IS NOT INITIAL.
      SELECT product, productdescription
        FROM i_productdescription
        FOR ALL ENTRIES IN @it_po_item
        WHERE product = @it_po_item-material
        INTO TABLE @DATA(it_mat_des).
    ENDIF.
    "--------------------------------------------------------
    "END OF FETCHING PRODUCT DESCRIOTION
    "--------------------------------------------------------


    DATA: lv_sr TYPE i.
    DATA: lv_manfname     TYPE string,
          lv_payment_term TYPE string,
          curry type I_PurchaseOrderAPI01-DocumentCurrency,
          lv_qtn_date     TYPE i_purchaseorderapi01-yy1_qtndate_pdh.
    DATA ls_manufacturer TYPE zc_mat_linkage.

    lv_qtn_date = |{ wa_po-yy1_qtndate_pdh+6(2) }/{ wa_po-yy1_qtndate_pdh+4(2) }/{ wa_po-yy1_qtndate_pdh+2(4) }|.
    curry = wa_po-DocumentCurrency.


    DATA(lv_header) =
      |<form1>| &&
      |   <Purcahseorder>| &&
      |      <To>| &&
      |         <vendor_nm>{ gs_header-vend_nm }</vendor_nm>| &&
      |         <ven_addrs>{ gs_header-vend_addr }</ven_addrs>| &&
      |         <EMAIL>{ wa_vendor_email-emailaddress }</EMAIL>| &&
      |         <contact>{ ls_supplier_addr-phonenumber1 }</contact>| &&
      |         <gst>{ ls_supplier_addr-taxnumber3 }</gst>| &&
      |         <po_num>{ wa_po-purchaseorder }</po_num>| &&
      |         <po_date>{ gs_header-po_date }</po_date>| &&
      |         <qtn_ref>{ wa_po-yy1_qtnref_pdh }</qtn_ref>| &&
      |         <qtn_dt>{ lv_qtn_date }</qtn_dt>| &&
      |         <pr_no>{ lv_purreq }</pr_no>| &&
      |         <pr_dt>{ lv_lrdt }</pr_dt>| &&
      |         <delivry_at>{ lv_del_name }</delivry_at>| &&
      |         <delvry_addrs>{ lv_del_addr }</delvry_addrs>| &&
      |         <delvry_conct>{ lv_del_phone }</delvry_conct>| &&
      |         <totalsubform>| &&
      |            <bill_to>{ gs_header-bill_nm }</bill_to>| &&
      |            <bill_address>{ gs_header-bill_addr }</bill_address>| &&
      |            <gst_no>{ gs_header-bill_gst }</gst_no>| &&
      |         </totalsubform>| &&
      |         <department>{ lv_reqname }</department>| &&
      |         <Table1>| &&
      |            <HeaderRow/>|.

    DATA lv_payment_text TYPE string.

    IF wa_payment-paymenttermsconditiondesc IS NOT INITIAL.
      lv_payment_text = wa_payment-paymenttermsconditiondesc.
    ELSE.
      lv_payment_text = wa_po-yy1_remarks_pdh.
    ENDIF.

    LOOP AT it_po_item INTO wa_po_item.
      lv_sr = lv_sr + 1.

      "==================================================
      " Declarations
      "==================================================
      DATA:
        lv_insurance          TYPE decfloat34,
        lv_insurance1         TYPE decfloat34,
        lv_tax                TYPE decfloat34,
        lv_freight_qty        TYPE decfloat34,
        lv_freight_value      TYPE decfloat34,
        zfqu                  TYPE decfloat34,
        lv_packing_forwarding TYPE decfloat34,
        lv_packing_charges    TYPE decfloat34,
        "Discounts & rates
        lv_abs_discount       TYPE decfloat34,
        lv_disc_on_gross      TYPE decfloat34,
        lv_disc_quantity      TYPE decfloat34,
        lv_cash_discount      TYPE decfloat34,
        lv_rate               TYPE decfloat34,
        lv_rate1              TYPE decfloat34,
        lv_frate              TYPE decfloat34,
        lv_discount           TYPE decfloat34,
        "Totals
        lv_freight            TYPE decfloat34,
        total_amount          TYPE decfloat34,
        total_charges         TYPE decfloat34,
        lv_total              TYPE decfloat34,
        lv_subtotal           TYPE decfloat34,
        lv_grandtotal         TYPE decfloat34,
        tax                   TYPE decfloat34,
        lv_packing            TYPE decfloat34,
        lv_custom             TYPE decfloat34,


        "Formatted strings
        lv_total_str          TYPE string,
        lv_subtotal_str       TYPE string,
        lv_grandtotal_str     TYPE string,
        lv_amount_string      TYPE string,

        "Text helpers
        lv_service_text       TYPE string,
        lv_text               TYPE string,
        lv_item_row           TYPE string.

      "==================================================
      " Fetch pricing conditions
      "==================================================
      SELECT
          purchaseorder,
          conditiontype,
          conditionamount,
          purchaseorderitem,
          conditionrateamount,
          conditionbasevalue
        FROM i_purordpricingelementtp_2
        WHERE purchaseorder     = @wa_po_item-purchaseorder
          AND purchaseorderitem = @wa_po_item-purchaseorderitem
        INTO TABLE @DATA(it_prcd).

      "==================================================
      " Clear ITEM-level accumulators
      "==================================================
      CLEAR:

        lv_abs_discount,
        lv_disc_on_gross,
        lv_disc_quantity,
        lv_cash_discount.


      "==================================================
      " Process pricing conditions
      "==================================================
      LOOP AT it_prcd INTO DATA(wa_prcd).

        DATA:lv_cond_amt TYPE decfloat34.
        DATA:lv_rate_amt TYPE decfloat34.

        lv_cond_amt = CONV decfloat34( wa_prcd-conditionamount ).
        lv_rate_amt = CONV decfloat34( wa_prcd-conditionrateamount ).

        CASE wa_prcd-conditiontype.

          WHEN 'ZINS'. lv_insurance += lv_cond_amt.
          WHEN 'ZIN1'. lv_insurance1 += lv_cond_amt.
          WHEN 'TTX1'. lv_tax += lv_cond_amt.
          WHEN 'ZFVA'. lv_freight_qty += lv_cond_amt.
          WHEN 'ZFA1'. lv_freight_value += lv_cond_amt.
          WHEN 'ZFQU'. zfqu += lv_cond_amt.
          WHEN 'ZPCK'. lv_packing_forwarding += lv_cond_amt.
          WHEN 'ZPAK'. lv_packing_charges += lv_cond_amt.

            "Discounts
          WHEN 'DRV1'. lv_abs_discount   += lv_cond_amt.
          WHEN 'DRG1'. lv_disc_on_gross  += lv_cond_amt.
          WHEN 'DRQ1'. lv_disc_quantity += lv_cond_amt.
          WHEN 'ZDRV'. lv_cash_discount += lv_cond_amt.

            "Rates
          WHEN 'PMP0'. lv_rate  = lv_rate_amt.
          WHEN 'PPR0'. lv_rate1 = lv_rate_amt.

             "custom
             WHEN 'ZCUS'. lv_custom += lv_cond_amt.


        ENDCASE.

      ENDLOOP.

      "==================================================
      " Final rate & discount (priority)
      "==================================================
      lv_frate = COND decfloat34(
        WHEN lv_rate  IS NOT INITIAL THEN lv_rate
        WHEN lv_rate1 IS NOT INITIAL THEN lv_rate1
        ELSE 0 ).

      lv_discount = COND decfloat34(
        WHEN lv_abs_discount   IS NOT INITIAL THEN lv_abs_discount
        WHEN lv_disc_on_gross  IS NOT INITIAL THEN lv_disc_on_gross
        WHEN lv_disc_quantity IS NOT INITIAL THEN lv_disc_quantity
        WHEN lv_cash_discount IS NOT INITIAL THEN lv_cash_discount
        ELSE 0 ).

      "==================================================
      " Freight & totals
      "==================================================
      lv_freight =
          lv_freight_qty
        + lv_freight_value
        + zfqu.

      tax = lv_tax.

      total_amount =
          ( lv_frate * wa_po_item-orderquantity )
        + lv_discount.

      total_charges =
          lv_insurance
        + lv_insurance1
        + lv_packing_forwarding
        + lv_packing_charges
        + lv_freight.

      lv_total      += total_amount.
      lv_subtotal   = lv_total + total_charges + lv_custom.
      lv_grandtotal = lv_subtotal + tax.

      lv_packing = lv_packing_charges + lv_packing_forwarding.

      "==================================================
      " Formatting amounts
      "==================================================
      lv_total_str = |{ lv_total }|.
*CONDENSE lv_total_str.
*REPLACE REGEX '(\.[0-9]+)0+$' IN lv_total_str WITH '\1'.
*REPLACE REGEX '\.$' IN lv_total_str WITH ''.

      lv_subtotal_str = |{ lv_subtotal }|.
*CONDENSE lv_subtotal_str.
*REPLACE REGEX '(\.[0-9]+)0+$' IN lv_subtotal_str WITH '\1'.
*REPLACE REGEX '\.$' IN lv_subtotal_str WITH ''.

      lv_grandtotal_str = |{ lv_grandtotal }|.
*CONDENSE lv_grandtotal_str.
*REPLACE REGEX '(\.[0-9]+)0+$' IN lv_grandtotal_str WITH '\1'.
*REPLACE REGEX '\.$' IN lv_grandtotal_str WITH ''.

      "==================================================
      " Amount in words
      "==================================================
      lv_amount_string = lv_grandtotal_str.
      lv_amt_word = num2words( iv_num = lv_amount_string ).

      "==================================================
      " Text handling
      "==================================================


      SELECT SINGLE *
      FROM zc_mat_linkage
      WHERE manfno = @wa_po_item-yy1_manufacturerno1_pdi
      INTO @ls_manufacturer.

      lv_manfname = COND string(
                            WHEN ls_manufacturer-manfnm IS NOT INITIAL
                            THEN ls_manufacturer-manfnm
                            ELSE '' ).
      CLEAR:ls_manufacturer-manfnm.


*      DATA(lv_del_addr) = COND string(
*                            WHEN gs_header-del_addr IS NOT INITIAL
*                            THEN gs_header-del_addr
*                            ELSE gs_header-bill_addr ).

      "Get description
      DATA(wa_mat_des) = VALUE #( it_mat_des[ product = wa_po_item-material ] OPTIONAL ).
      IF wa_mat_des IS NOT INITIAL.
        gs_header-mat_descr = wa_mat_des-productdescription.
      ENDIF.
      CLEAR wa_mat_des.

      "Remove leading zeros from material
      DATA(lv_material_nozero) = wa_po_item-material.
      SHIFT lv_material_nozero LEFT DELETING LEADING '0'.

      SELECT SINGLE * FROM i_incotermsclassificationtext
      WHERE incotermsclassification = @wa_po-incotermsclassification
      INTO @DATA(wa_incoterms).

      lv_conditiontext_xml = me->escape_xml( wa_longtxt-plainlongtext ).
      lv_des = me->escape_xml( gs_header-mat_descr ).

      IF wa_longtxt IS NOT INITIAL.
        lv_service_text = lv_conditiontext_xml.
      ENDIF.

      lv_text = lv_service_text.
      REPLACE ALL OCCURRENCES OF REGEX '([.])'
        IN lv_text
        WITH '$1' && cl_abap_char_utilities=>cr_lf.

      "==================================================
      " Material formatting
      "==================================================
      lv_material_nozero = wa_po_item-material.
      SHIFT lv_material_nozero LEFT DELETING LEADING '0'.

      "==================================================
      " XML Row
      "==================================================
      lv_item_row =
        |<Row1>| &&
        |<sr_no>{ lv_sr }</sr_no>| &&
        |<mat_code>{ lv_material_nozero }</mat_code>| &&
        |<descr>{ lv_des }</descr>| &&
        |<Manufacturer>{ lv_manfname }</Manufacturer>| &&
        |<uom>{ wa_po_item-purchaseorderquantityunit }</uom>| &&
        |<qty>{ wa_po_item-orderquantity }</qty>| &&
        |<rate>{ lv_frate }</rate>| &&
        |<discount>{ lv_discount }</discount>| &&
        |<amt>{ total_amount }</amt>| &&
        |</Row1>|.

      lv_items &&= lv_item_row.
      CLEAR lv_item_row.

    ENDLOOP.


*DATA:lv_inco_term TYPE string.
*
*lv_inco_term = wa_incoterms-incotermsclassificationname.
*lv_inco_term = me->escape_xml( lv_inco_term ).

    DATA(lv_footer) =
      |         </Table1>| &&
      |         <totalsubform>| &&
      |            <total>{ lv_total_str }</total>| &&
      |            <Insurance>{ lv_packing }</Insurance>| &&
      |            <sub_tot>{ lv_subtotal_str }</sub_tot>| &&
      |            <GST>{ tax }</GST>| &&
      |            <grnd_tot>{ lv_grandtotal_str } { curry }</grnd_tot>| &&
      |        <gst_info>{ lv_tax_text }</gst_info>| &&
      |        <freight>{ lv_freight }</freight>| &&
      |         </totalsubform>| &&
      |         <AMT_WORDSUBFORM>| &&
      |            <amt_word>{ lv_amt_word }</amt_word>| &&
    |         </AMT_WORDSUBFORM>| &&
|            <conditiontext>{ me->escape_xml( lv_text ) }</conditiontext>| &&
|               <del_dt_tc>{ me->escape_xml( wa_po-yy1_deliverydate_pdh ) }</del_dt_tc>| &&
|               <inco_term_tc>{ me->escape_xml( wa_incoterms-incotermsclassificationname ) }</inco_term_tc>| &&
|               <pay_term_tc>{ me->escape_xml( lv_payment_text ) }</pay_term_tc>| &&
|               <to_fro_tc>{ me->escape_xml( gs_header-yy1_tofro1_pdh ) }</to_fro_tc>| &&
|              <tds_desctn_tc>{ me->escape_xml( gs_header-yy1_tdstcsdeduction_pdh ) }</tds_desctn_tc>| &&
|               <corp_grnte_tc>{ me->escape_xml( gs_header-yy1_corporateguarantee_pdh ) }</corp_grnte_tc>| &&
|               <install_tc>{ me->escape_xml( gs_header-yy1_installationcommis_pdh ) }</install_tc>| &&
|              <warranty_tc>{ me->escape_xml( gs_header-yy1_warrantyguarantee_pdh ) }</warranty_tc>| &&
|               <shipment_tc>{ me->escape_xml( gs_header-yy1_modeofshipment_pdh ) }</shipment_tc>| &&
|               <doc_tc>{ me->escape_xml( gs_header-yy1_certificatedocument_pdh ) }</doc_tc>| &&
|               <sale_contr_tc>{ me->escape_xml( gs_header-yy1_salescontractnumbe_pdh ) }</sale_contr_tc>| &&
|               <contrct_tc>{ me->escape_xml( gs_header-yy1_contractvalidity_pdh ) }</contrct_tc>| &&
|               <remark_tc></remark_tc>| &&
|         <certificate_no>{ me->escape_xml( ls_supplier_addr-sortfield ) }</certificate_no>| &&
      |      </To>| &&
      |   </Purcahseorder>| &&
      |</form1>|.




    lv_xml = |{ lv_header }{ lv_items }{ lv_footer }|.


    "--------------------------------------------------------
    "start of getpdf
    "--------------------------------------------------------

    CALL METHOD zadobe_ads_class=>getpdf
      EXPORTING
        template = 'ZMM_PO/ZMM_PO'
        xmldata  = lv_xml
      RECEIVING
        result   = DATA(lv_result).

    IF lv_result IS NOT INITIAL.
      pdf_64 = lv_result.
    ENDIF.

  ENDMETHOD.


METHOD escape_xml.

  rv_out = |{ iv_in }|.   " explicit conversion to STRING

  IF rv_out IS INITIAL.
    RETURN.
  ENDIF.

  " Replace must be done in order to avoid double-escaping
  REPLACE ALL OCCURRENCES OF '&' IN rv_out WITH '&amp;'.
  REPLACE ALL OCCURRENCES OF '<' IN rv_out WITH '&lt;'.
  REPLACE ALL OCCURRENCES OF '>' IN rv_out WITH '&gt;'.
  REPLACE ALL OCCURRENCES OF '"' IN rv_out WITH '&quot;'.

ENDMETHOD.



  METHOD num2words.

    TYPES: BEGIN OF str_d,
             num   TYPE i,
             word1 TYPE string,
             word2 TYPE string,
           END OF str_d.
    TYPES : BEGIN OF ty_value,
              num  TYPE i,
              word TYPE c LENGTH 20,
            END OF ty_value.
    DATA : lt_d TYPE TABLE OF ty_value,
           ls_d TYPE ty_value.

    DATA: ls_h TYPE str_d,
          ls_k TYPE str_d,
          ls_m TYPE str_d,
          ls_b TYPE str_d,
          ls_t TYPE str_d,
          ls_o TYPE str_d.

    DATA lv_int TYPE i.
    DATA lv_int1 TYPE i.
    DATA lv_int2 TYPE i.
    DATA lv_dec_s TYPE string.
    DATA lv_dec   TYPE i.
    DATA lv_wholenum TYPE i.
    DATA lv_inp1 TYPE string.
    DATA lv_inp2 TYPE string.
    DATA lv_dec_words TYPE c LENGTH 255.

    IF iv_num IS INITIAL.
      RETURN.
    ENDIF.

    lt_d = VALUE #(
      ( num = 0 word = 'Zero' )
      ( num = 1 word = 'One' )
      ( num = 2 word = 'Two' )
      ( num = 3 word = 'Three' )
      ( num = 4 word = 'Four' )
      ( num = 5 word = 'Five' )
      ( num = 6 word = 'Six' )
      ( num = 7 word = 'Seven' )
      ( num = 8 word = 'Eight' )
      ( num = 9 word = 'Nine' )
      ( num = 10 word = 'Ten' )
      ( num = 11 word = 'Eleven' )
      ( num = 12 word = 'Twelve' )
      ( num = 13 word = 'Thirteen' )
      ( num = 14 word = 'Fourteen' )
      ( num = 15 word = 'Fifteen' )
      ( num = 16 word = 'Sixteen' )
      ( num = 17 word = 'Seventeen' )
      ( num = 18 word = 'Eighteen' )
      ( num = 19 word = 'Nineteen' )
      ( num = 20 word = 'Twenty' )
      ( num = 30 word = 'Thirty' )
      ( num = 40 word = 'Fourty' )
      ( num = 50 word = 'Fifty' )
      ( num = 60 word = 'Sixty' )
      ( num = 70 word = 'Seventy' )
      ( num = 80 word = 'Eighty' )
      ( num = 90 word = 'Ninety' )
    ).

    " Use Lakhs/Crores (Indian numbering system)
    ls_h-num = 100.
    ls_h-word1 = 'Hundred'.
    ls_h-word2 = 'Hundred'.

    ls_k-num = ls_h-num * 10.
    ls_k-word1 = 'Thousand'.
    ls_k-word2 = 'Thousand'.

    ls_m-num = ls_k-num * 100.
    ls_m-word1 = 'Lakh'.
    ls_m-word2 = 'Lakh'.

    ls_b-num = ls_m-num * 100.
    ls_b-word1 = 'Crore'.
    ls_b-word2 = 'Crore'.

    SPLIT iv_num AT '.' INTO lv_inp1 lv_inp2.

    lv_int = lv_inp1.
    lv_wholenum = lv_int.

    IF iv_level IS INITIAL.
      IF lv_inp2 IS NOT INITIAL.
        CONDENSE lv_inp2.
        lv_dec_s   = lv_inp2.
        lv_dec     = lv_inp2.
      ENDIF.
    ENDIF.
    iv_level = iv_level + 1.

    " Whole Number converted to Words
    IF lt_d IS NOT INITIAL.
      IF lv_int <= 20.
        READ TABLE lt_d INTO ls_d WITH KEY num = lv_int.
        rv_words = ls_d-word.
      ELSEIF lv_int < 100 AND lv_int > 20.
        DATA(mod) = lv_int MOD 10.
        DATA(floor) = floor( lv_int DIV 10 ).
        IF mod = 0.
          READ TABLE lt_d INTO ls_d WITH KEY num = lv_int.
          rv_words = ls_d-word.
        ELSE.
          READ TABLE lt_d INTO ls_d WITH KEY num = floor * 10.
          DATA(pos1) = ls_d-word.
          READ TABLE lt_d INTO ls_d WITH KEY num = mod.
          DATA(pos2) = ls_d-word.
          rv_words = |{ pos1 } | && |{ pos2 } |.
        ENDIF.
      ELSE.
        IF lv_int < ls_k-num.
          ls_o = ls_h.
        ELSEIF lv_int < ls_m-num.
          ls_o = ls_k.
        ELSEIF lv_int < ls_b-num.
          ls_o = ls_m.
        ELSE.
          ls_o = ls_b.
        ENDIF.
        mod = lv_int MOD ls_o-num.
        floor = floor( iv_num DIV ls_o-num ).
        lv_inp1 = floor.
        lv_inp2 = mod.

        IF mod = 0.
          DATA(output2) = num2words( EXPORTING iv_num = lv_inp1
                                     CHANGING iv_level = iv_level ).
          rv_words = |{ output2 } | && |{ ls_o-word1 } |.
        ELSE.
          output2 = num2words( EXPORTING iv_num = lv_inp1
                               CHANGING iv_level = iv_level ).
          DATA(output3) = num2words( EXPORTING iv_num = lv_inp2
                                     CHANGING iv_level = iv_level ).
          rv_words = |{ output2 } | && |{ ls_o-word2 } | && |{ output3 } |.
        ENDIF.
      ENDIF.

      iv_level = iv_level - 1.
      IF iv_level IS INITIAL.
        rv_words = |{ rv_words }|.
        IF lv_dec <= 20.
          READ TABLE lt_d REFERENCE INTO DATA(ls_d2) WITH KEY num = lv_dec.
          IF sy-subrc = 0.
            lv_dec_words = |{ ls_d2->word }|.
          ENDIF.
        ELSEIF lv_dec < 100 AND lv_dec > 20.
          DATA(mod1) = lv_dec MOD 10.
          DATA(floor1) = floor( lv_dec DIV 10 ).
          IF mod1 = 0.
            READ TABLE lt_d REFERENCE INTO ls_d2 WITH KEY num = lv_dec.
            IF sy-subrc = 0.
              lv_dec_words = ls_d2->word.
            ENDIF.
          ELSE.
            READ TABLE lt_d REFERENCE INTO ls_d2 WITH KEY num = floor1 * 10.
            IF sy-subrc = 0.
              DATA(pos1_d) = ls_d2->word.
            ENDIF.
            READ TABLE lt_d REFERENCE INTO ls_d2 WITH KEY num = mod1.
            IF sy-subrc = 0.
              DATA(pos2_d) = ls_d2->word.
            ENDIF.
            IF pos1_d IS NOT INITIAL AND pos2_d IS NOT INITIAL.
              lv_dec_words = |{ pos1_d } | && |{ pos2_d } |.
            ENDIF.
          ENDIF.
        ENDIF.
        IF lv_dec > 0.
          rv_words = |{ rv_words } And { lv_dec_words } Paise Only|.
        ELSE.
          rv_words = |{ rv_words } Only|.
        ENDIF.

        CONDENSE rv_words.

      ENDIF.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
