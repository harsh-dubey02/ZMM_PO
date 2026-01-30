@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'delivery address'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_DELIVERY_ADDR
  as select from I_PurchaseOrderItemAPI01 as poapi

  left outer join I_Plant as plant
    on plant.Plant = poapi.Plant

  left outer join I_Address_2 as addr
    on addr.AddressID =
       coalesce(
         poapi.ManualDeliveryAddressID,
         plant.AddressID
       )

  left outer join I_AddressPhoneNumber_2 as contact
    on contact.AddressID = addr.AddressID
{    @UI.facet: [

  {
  id : 'Header',
  purpose: #STANDARD,
  type: #IDENTIFICATION_REFERENCE,
  label: 'Purchase Order',
  position: 10
  }

  ]
    @UI.lineItem:       [{ position: 10, label: 'PurchaseOrder' }]
  @UI.identification: [{ position: 10, label: 'PurchaseOrder' }]
  @UI.selectionField: [{ position: 10 }]
    key poapi.PurchaseOrder,
        @UI.lineItem:       [{ position: 20, label: 'PurchaseOrderItem' }]
  @UI.identification: [{ position: 20, label: 'PurchaseOrderItem' }]
  @UI.selectionField: [{ position: 20 }]
    key poapi.PurchaseOrderItem,
    poapi.Plant,
    plant.Plant as pant1,
    poapi.ManualDeliveryAddressID,
            @UI.lineItem:       [{ position: 30, label: 'StreetName' }]
  @UI.identification: [{ position: 30, label: 'StreetName' }]
  @UI.selectionField: [{ position: 30 }]
      addr.StreetName,
              @UI.lineItem:       [{ position: 40, label: 'HouseNumber' }]
  @UI.identification: [{ position: 40, label: 'HouseNumber' }]
  @UI.selectionField: [{ position: 40 }]
      addr.HouseNumber,
      addr.CityName,
      addr.PostalCode,
      addr.Country,
      addr.Region,
              @UI.lineItem:       [{ position: 50, label: 'OrganizationName1' }]
  @UI.identification: [{ position: 50, label: 'OrganizationName1' }]
  @UI.selectionField: [{ position: 50 }]
      addr.OrganizationName1,
              @UI.lineItem:       [{ position: 60, label: 'AddresseeFullName' }]
  @UI.identification: [{ position: 60, label: 'AddresseeFullName' }]
  @UI.selectionField: [{ position: 60 }]
      addr.AddresseeFullName,
    @UI.lineItem:       [{ position: 70, label: 'PhonerNumber' }]
  @UI.identification: [{ position: 70, label: 'PhonerNumber' }]
  @UI.selectionField: [{ position: 70 }]   
      contact.PhoneAreaCodeSubscriberNumber,
          @UI.lineItem:       [{ position: 80, label: 'InternationalPhoneNumber' }]
  @UI.identification: [{ position: 80, label: 'InternationalPhoneNumber' }]
  @UI.selectionField: [{ position: 80 }]  
      contact.InternationalPhoneNumber,
                @UI.lineItem:       [{ position: 90, label: 'AddressID' }]
  @UI.identification: [{ position: 90, label: 'AddressID' }]
      addr.AddressID
}
