@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
/*------------------------------------------------------------------------
    File        : promotions.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Mon Dec 04 10:30:03 AEDT 2023
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

define temp-table Promotions no-undo
  field prom_nbr                 as int64
  field prom_area                as character
  field prom_name                as character
  field prom_img_name            as character
  field prom_img_url             as character
  field prom_active_start_date   as date
  field prom_active_end_date     as date.  

define temp-table ResponseMessage no-undo
  field MessageDesc     as character.
  
@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure GetPromotions: 
  define input parameter  SessionID      as character no-undo.  
  define output parameter table          for Promotions.  
  define output parameter ResponseID     as integer no-undo.    
  define output parameter table          for ResponseMessage.
end procedure.

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure GetPromotion: 
  define input parameter  SessionID      as character no-undo.
  define input parameter  id             as int64 no-undo.  
  define output parameter table          for Promotions.  
  define output parameter ResponseID     as integer no-undo.    
  define output parameter table          for ResponseMessage.
end procedure.

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure AddPromotion:
  define input parameter  SessionID      as character no-undo.
  define input parameter  table          for Promotions.
  define output parameter prom_nbr       as int64 no-undo.
  define output parameter ResponseID     as integer no-undo.
  define output parameter table          for ResponseMessage.
end procedure.   

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure UpdatePromotions:
  define input parameter  SessionID      as character no-undo.  
  define input parameter  id             as int64 no-undo.
  define input parameter  table          for Promotions.
  define output parameter ResponseID     as integer no-undo.    
  define output parameter table          for ResponseMessage.
end procedure. 

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure DeletePromotions:
  define input parameter  SessionID      as character no-undo.  
  define input parameter  id             as int64 no-undo.
  define output parameter ResponseID     as integer no-undo.    
  define output parameter table          for ResponseMessage.
end procedure. 

 
