@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for order attachment'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ORD_ATT
  provider contract transactional_query
  as projection on ZIR_ORD_att
{
  key FileId,
      Status,
      Criticality,
      FileStatus,
      CriticalityStatus,
      HideExcel,
      Attachment,
      Mimetype,
      Filename,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _ordtable : redirected to composition child ZC_ORD_TBL
}
