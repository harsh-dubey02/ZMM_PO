@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View For PO'
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@UI.presentationVariant: [{
    maxItems: 10
}]

define root view entity ZC_PO
  provider contract transactional_query
  as projection on ZI_PO
{
    key PurchaseOrder,
        CreationDate,
        PaymentTerms,
        SupplierQuotationExternalID,
        PurchaseOrderDate,
        IncotermsClassification,
        base64,
        m_ind
}
