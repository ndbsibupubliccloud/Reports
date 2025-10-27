@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for Get BOM Components( Multi Level )'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZR_BOM_COMPONENTS
  with parameters
    p_matnr : matnr,
    p_werks : werks_d
  //    @EndUserText.label: 'BOM Status'
  //    //  @Consumption.filter: { selectionType: #SINGLE, mandatory: true, defaultValue: 'Active' }
  //    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_BOMSTATUS_VH', element: 'text' } }]
  //    p_status : zd_bomstatus1

  as select from ZI_BOM_Components( p_clnt: $session.client, p_matnr: $parameters.p_matnr, p_werks:$parameters.p_werks )
  //                                    p_status :$parameters.p_status )
  //  as select from ZI_BOM_Components( p_clnt: $session.client, p_werks:$parameters.p_werks )
{
  key                Material,
  key                Plant,
  key                BOMComponent,
  key                AlternativeBOM,
  key                BOMStatus,
  key                subBOM,
                     MaterialDescription,
                     SubBOMDesc,
                     SUBAlternativeBOM,
                     @Semantics.quantity.unitOfMeasure: 'BaseUOM'
                     Quantity,
                     BaseUOM,
                     ComponentDescription,
                     @Semantics.quantity.unitOfMeasure: 'ComponentUOM'
                     ComponentQty,
                     ComponentUOM,
                     @EndUserText.label: 'Validity Start Date'
                     ValidityStartDate,
                     @EndUserText.label: 'Validity End Date'
                     ValidityEndDate,
                     @EndUserText.label: 'BOM Level'
                     BOMLevel,
                     creationon
}
