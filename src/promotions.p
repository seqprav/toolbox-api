
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

function fn_add_error_msgs returns logical
(   input pic-field  as character,
    input pic-error  as character) forward.

define temp-table Promotions no-undo
  field prom_nbr                 as int64
  field prom_area                as character
  field prom_name                as character
  field prom_img_name            as character
  field prom_img_url             as character
  field prom_active_start_date   as date
  field prom_active_end_date     as date.  

define temp-table ResponseMessage no-undo
  field fieldName     as character
  field fieldError    as character
  index idx-fieldName is unique fieldname.

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure GetPromotions: 
  define input parameter  SessionID      as character    no-undo.
  define output parameter table          for Promotions.  
  define output parameter ResponseID     as integer      no-undo.    
  define output parameter table          for ResponseMessage.

  empty temp-table promotions.
  empty temp-table ResponseMessage.
  
  for each promotions_draft no-lock:
    create promotions.
    buffer-copy promotions_draft to promotions.
  end.           
  
  ResponseID = 0.
  return '200'.   
       
end procedure.

procedure GetPromotion: 
  define input parameter  SessionID      as character    no-undo.
  define input parameter  id             as int64        no-undo.  
  define output parameter table          for Promotions.  
  define output parameter ResponseID     as integer      no-undo.    
  define output parameter table          for ResponseMessage.
  
  empty temp-table promotions.
  empty temp-table ResponseMessage.
  
  if not can-find(first promotions_draft where promotions_draft.prom_nbr = id) then do:
    dynamic-function('fn_add_error_msgs', 'not-found', substitute('Promotion with id: &1 does not exist', id) ). 
    return '404'.    
  end.    
  
  find first promotions_draft where promotions_draft.prom_nbr = id no-lock no-error.
  if available promotions_draft then do:
    create promotions.
    buffer-copy promotions_draft to promotions.
  end.    
  
end procedure.

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure AddPromotion:
  define input parameter  SessionID      as character no-undo.
  define input parameter  table          for Promotions.
  define output parameter prom_nbr       as int64 no-undo.
  define output parameter ResponseID     as integer no-undo.
  define output parameter table          for ResponseMessage.

  define buffer upd_promotions           for promotions_draft.
  
  empty temp-table ResponseMessage.

  find first promotions no-error.
  if not available promotions then do:
    dynamic-function('fn_add_error_msgs', 'ERROR! ' + 'The request body for the Promotion is empty or malformed!' ).  
    return '406'. /*(406 - not acceptable). The standard is 400 but not using it as we're using 400 in the forntend to project the erros on the screen - might revise in the future if needed*/  
  end. 
  
  if promotions.prom_area = ''                 then dynamic-function('fn_add_error_msgs', 'prom_area', 'Area is a mandatory field'). 
  if promotions.prom_name = ''                 then dynamic-function('fn_add_error_msgs', 'prom_name','Name is a mandatory field'). 
  if promotions.prom_img_name = ''             then dynamic-function('fn_add_error_msgs', 'prom_img_name','Image Name is a mandatory field'). 
  if promotions.prom_img_url = ''              then dynamic-function('fn_add_error_msgs', 'prom_img_url','Image Url is a mandatory field'). 
  if promotions.prom_active_start_date = ?     then dynamic-function('fn_add_error_msgs', 'prom_active_start_date','Active start date is a mandatory field'). 
  if promotions.prom_active_start_date < today then dynamic-function('fn_add_error_msgs', 'prom_active_start_date','Active start date cannot be lesser than today').
  if promotions.prom_active_end_date = ?       then dynamic-function('fn_add_error_msgs', 'prom_active_end_date','Active End Date is a mandatory field'). 
  if promotions.prom_active_start_date > promotions.prom_active_end_date then dynamic-function('fn_add_error_msgs', 'prom_active_start_date','Active start date cannot be greater than end date').
    
  if can-find(first ResponseMessage) then return '400'.

  do for upd_promotions transaction on error undo, throw:

    create upd_promotions.
    buffer-copy promotions to upd_promotions
          assign upd_promotions.prom_nbr              = next-value(promotions_seq)
                 upd_promotions.prom_cr_tmpstmp       = datetime(today, mtime)
                 upd_promotions.prom_last_upd_tmpstmp = upd_promotions.prom_cr_tmpstmp
                 prom_nbr                             = upd_promotions.prom_nbr.


    /***************************************************Error handlers***********************************************************/
   catch eAnySysError as Progress.Lang.SysError:
     dynamic-function('fn_add_error_msgs', 'ERROR! ' + eAnySysError:GetMessage(1)).
     ResponseID = 1.
     return '500'.
   end catch.

  end.
   /********************************************************************************************************************************/

  ResponseID = 0.
  message substitute('Promotion with id: &1 was successfully created!', prom_nbr).
  return '201'.

end procedure.

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure UpdatePromotions:
  define input parameter  SessionID      as character   no-undo.  
  define input parameter  id             as int64       no-undo.
  define input parameter  table          for Promotions.
  define output parameter ResponseID     as integer     no-undo.    
  define output parameter table          for ResponseMessage.
  
  define buffer upd_promotions     for promotions_draft.
  empty temp-table ResponseMessage.
  
  if not can-find(first promotions_draft where promotions_draft.prom_nbr = id) then do:
    dynamic-function('fn_add_error_msgs', 'not-found', substitute('Promotion with id: &1 does not exist', id) ). 
    return '404'.    
  end.    

  find first promotions no-error.
  if not available promotions then do:
    dynamic-function('fn_add_error_msgs', 'ERROR! ' + 'The request body for the Promotion is empty or malformed!' ).  
    return '406'. /*(406 - not acceptable). The standard is 400 but not using it as we're using 400 in the forntend to project the erros on the screen - might revise in the future if needed*/  
  end. 

  if promotions.prom_area = ''                 then dynamic-function('fn_add_error_msgs', 'prom_area', 'Area is a mandatory field'). 
  if promotions.prom_name = ''                 then dynamic-function('fn_add_error_msgs', 'prom_name','Name is a mandatory field'). 
  if promotions.prom_img_name = ''             then dynamic-function('fn_add_error_msgs', 'prom_img_name','Image Name is a mandatory field'). 
  if promotions.prom_img_url = ''              then dynamic-function('fn_add_error_msgs', 'prom_img_url','Image Url is a mandatory field'). 
  if promotions.prom_active_start_date = ?     then dynamic-function('fn_add_error_msgs', 'prom_active_start_date','Active start date is a mandatory field'). 
  if promotions.prom_active_start_date < today then dynamic-function('fn_add_error_msgs', 'prom_active_start_date','Active start date cannot be lesser than today').
  if promotions.prom_active_end_date = ?       then dynamic-function('fn_add_error_msgs', 'prom_active_end_date','Active End Date is a mandatory field'). 
  if promotions.prom_active_start_date > promotions.prom_active_end_date then dynamic-function('fn_add_error_msgs', 'prom_active_start_date','Active start date cannot be greater than end date').
 
  if can-find(first ResponseMessage) then return '400'.
      
  do for upd_promotions transaction on error undo, throw:
      
    find upd_promotions where upd_promotions.prom_nbr = id exclusive-lock no-error.
    if available upd_promotions then 
      buffer-copy Promotions except Promotions.prom_nbr to upd_promotions
            assign upd_promotions.prom_last_upd_tmpstmp = datetime(today, mtime).

      
    /***************************************************Error handlers***********************************************************/
      
    catch eAnySysError as Progress.Lang.SysError:
      dynamic-function('fn_add_error_msgs', 'ERROR! ' + eAnySysError:GetMessage(1)).
      ResponseID = 1.
      return '500'.
    end catch.
      
   /********************************************************************************************************************************/
      
  end. /*do for upd_promotions*/

  ResponseID = 0.
  message substitute('Promotion with id: &1 was successfully updated!', id).
  return '204'.
    
end procedure.  

@openapi.openedge.export(type="REST", useReturnValue="true", writeDataSetBeforeImage="false").
procedure DeletePromotions:
  define input parameter  SessionID      as character    no-undo.
  define input parameter  id             as int64        no-undo.  
  define output parameter ResponseID     as integer      no-undo.    
  define output parameter table          for ResponseMessage.

  empty temp-table ResponseMessage.
  
  if not can-find(first promotions_draft where promotions_draft.prom_nbr = id) then do:
    dynamic-function('fn_add_error_msgs', 'not-found', substitute('Promotion with id: &1 does not exist', id) ). 
    return '404'.    
  end.    
  
  find first promotions_draft where promotions_draft.prom_nbr = id exclusive-lock no-error.
  if available promotions_draft then 
    delete promotions_draft.

  ResponseID = 0.
  message substitute('Promotion with id: &1 was successfully deleted!', id).
  return '204'.    
     
end procedure. 

function fn_add_error_msgs returns logical
(   input pic-field  as character,
    input pic-error  as character).
    
   find ResponseMessage where ResponseMessage.fieldName = pic-field no-error.
   if not available ResponseMessage then do:
     create ResponseMessage.
     assign ResponseMessage.fieldName = pic-field.
   end.  
   ResponseMessage.fieldError = if ResponseMessage.fieldError  = '' then pic-error 
                                else ResponseMessage.fieldError + ',' + pic-error.    

  return true. 
end function.
