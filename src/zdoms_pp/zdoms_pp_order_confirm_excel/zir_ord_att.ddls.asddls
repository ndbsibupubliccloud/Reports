@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rootr View for Order attachment'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIR_ORD_att
  as select from ZI_ORD_att
  //composition of target_data_source_name as _association_name
  composition [0..*] of ZI_ORD_TBL as _ordtable
{
  key FileId,
      Status,
      case ZI_ORD_att.Status
             when 'N' then 0
             when 'F' then 1
             when 'E' then 1
             when 'S' then 3
             else 0
           end                                                                                         as Criticality,
      cast( case when Filename is initial and Status is      initial then 'File Not Uploaded'
                when Filename is not initial and  Status is initial  then 'File Uploaded'
                when Filename is initial then 'File Not Uploaded'
                when Status is not initial then 'File Processed' else ' ' end as abap.char( 20 ) )     as FileStatus,
      cast( case when Filename is initial and Status is initial then '1'
                 when Filename is not initial and  Status is initial  then '2'
                 when Filename is initial then '1'
                 when Status is not initial then '3' else ' ' end as abap.char( 2 ) )                  as CriticalityStatus,
      cast( case when Filename is not initial then ' ' else 'X' end as abap_boolean preserving type  ) as HideExcel,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{ mimeType: 'Mimetype',
                               fileName: 'Filename',
      //                                     acceptableMimeTypes: [ 'text/csv','text/plain' ],
      //      acceptableMimeTypes: [ 'xls' ],
                               contentDispositionPreference: #INLINE }
      Attachment,
      @Semantics.mimeType: true
      Mimetype,
      Filename,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt,
      _ordtable
      //    _association_name // Make association public
}
