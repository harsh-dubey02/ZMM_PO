@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for PO'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_PO 
as select from I_PurchaseOrderAPI01 as a
left outer join ztb_mm_po_n as b on a.PurchaseOrder = b.purchaseorder
{   key a.PurchaseOrder,
    a.CreationDate,
    a.PaymentTerms,
    a.SupplierQuotationExternalID,
    a.PurchaseOrderDate,
//    a.PurgReleaseTimeTotalAmount,
    a.IncotermsClassification,
    b.base64_3 as base64,
     b.m_ind
    
}
where
     a.PurchaseOrderType = 'ZDOM'
  or a.PurchaseOrderType = 'ZCON'
  or a.PurchaseOrderType = 'ZSPA'
  or a.PurchaseOrderType = 'ZIMP'
  or a.PurchaseOrderType = 'ZSUB'
  or a.PurchaseOrderType = 'ZSTO'
  or a.PurchaseOrderType = 'ZRET'
  or a.PurchaseOrderType = 'ZCAP';

