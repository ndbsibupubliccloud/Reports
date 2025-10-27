CLASS zcl_pp_get_bom_components DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    CLASS-METHODS get_bom_component FOR TABLE FUNCTION zi_bom_components.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PP_GET_BOM_COMPONENTS IMPLEMENTATION.


  METHOD get_bom_component
           BY DATABASE FUNCTION FOR HDB
           LANGUAGE SQLSCRIPT
           USING  ZI_BillOfMaterial_ML.
*** variable declaration
    declare lv_count integer;
    declare lv_level integer;

***initialize the BOM Level = 1
    lv_level = 1;
***select the data for 1st Level BOM
    root_bom = select   mandt,
                        Material,
                        Plant,
                        BOMStatus,
                        AlternativeBOM,
                        MaterialDescription,
                       '' as subBOM,
                       '' as SubBOMDesc,
                       subalternativebom,
                        Quantity,
                        BaseUOM,
                        BOMComponent,
                        componentdescription as ComponentDescription,
                        ComponentQty,
                        ComponentUOM,
                        ValidityStartDate,
                        ValidityEndDate,
                        :lv_level as bomlevel,
                        CreationOn
                        from ZI_BillOfMaterial_ML
                        where mandt    = :p_clnt
                        and plant    = :p_werks
                        and material = :p_matnr;
*                        and bomstatus = :p_status;
***pass the selected BOM data into OUT_BOM
    out_bom = select * from :root_bom;
***select the components from the 1st Level BOM
    components = select BOMcomponent,
                        Material,
                        MaterialDescription,
                        AlternativeBOM,
                        componentdescription from :root_bom;
***select the count of components from the 1st Level BOM
    select count ( * ) into lv_count from :components;
***if the components are found, check for next level BOM data
    while :lv_count > 0 do
***increment the BOM level
        lv_level = lv_level + 1;
***select the data for the BOM of components
        child_bom = select  mandt,
                            b.material,
                            a.Plant,
                            a.BOMStatus,
                            b.AlternativeBOM,
*                            a.MaterialDescription,
                            b.MaterialDescription,
                            b.BOMcomponent as subBOM,
                            b.componentdescription as SubBOMDesc,
                            a.subalternativebom,
                            a.Quantity,
                            a.BaseUOM,
                            a.BOMComponent,
                            a.componentdescription,
                            a.ComponentQty,
                            a.ComponentUOM,
                            a.ValidityStartDate,
                            a.ValidityEndDate,
                            :lv_level as bomlevel,
                            a.creationon
                             from ZI_BillOfMaterial_ML as a
                             inner join :components as b
                               on  a.plant    = :p_werks
                            and a.material = b.BOMcomponent;
*                           and  a.bomstatus = :p_BOMStatus;
***select the components from the above selected child BOM
        components = select bomcomponent,
                            material,
                            MaterialDescription,
                            AlternativeBOM,
                            componentdescription from :child_bom;
***select the count of components from the above selected child BOM
*** if the count of component from this level is 0, then while loop will be terminated
        select count ( * ) into lv_count from :components;
***merge the BOM data (OUT_BOM) with the components from current level in selection
        out_bom = select * from:out_bom
                    union all
                  select * from :child_bom;
    end while;

***return the data back to table function using RETURN
    return select * from :out_bom order by Plant,Material;



  endmethod.
ENDCLASS.
