@AbapCatalog.sqlViewName: 'ZSOHDRITEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Orders with Header and Item Data'
@Metadata.ignorePropagatedAnnotations: true
define view ZC_SALESORDER  as select from I_SalesDocument as a
    inner join I_SalesDocumentItem as b
      on a.SalesDocument = b.SalesDocument

{
    key a.SalesDocument           as SalesOrder,       // Sales Order Number
    key b.SalesDocumentItem            as ItemNumber,      // Item Number
    a.SalesDocumentDate               as CreatedOn,        // Creation Date
    a.CreatedByUser               as CreatedBy,        // Created By User
    a.SalesDocumentType               as SalesDocType,     // Sales Document Type
    a.SalesOrganization               as SalesOrg,         // Sales Organization
    a.DistributionChannel               as DistChannel,      // Distribution Channel
    b.Division                          as Division,
    b.Material                as Material,        // Material Number
    b.OrderQuantity               as OrderQty,        // Order Quantity
    b.OrderQuantityUnit                as SalesUnit,       // Sales Unit
    b.MaterialGroup           as MaterialGroup //Material Group
}
