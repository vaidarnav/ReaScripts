-- @version 1.01
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @description Remove parameter modulation from last touched FX parameter
-- @changelog
--    - remove confirm dialog
  
  for key in pairs(reaper) do _G[key]=reaper[key]  end  
  ----------------------------------------------------  
  local function GetFxNamebyGUID(guid, fx_names)
    for key in pairs(fx_names) do
      if guid:match(key) then return fx_names[key] end
    end
  end
  reaper.ClearConsole()
  ----------------------------------------------------
  local function msg(s) ShowConsoleMsg(s..'\n') end
  ----------------------------------------------------
  function RemovePM(tr,  fxnumber, paramnumber)
    data = {}
    if not tr then return end
    local fx_guid =  reaper.TrackFX_GetFXGUID( tr, fxnumber):gsub('[{}-]','')
    -- chunk stuff
      local _, chunk = GetTrackStateChunk(  tr, '', false )
      local t= {} for line in chunk:gmatch('[^\n\r]+') do t[#t+1] = line end
      for i = 1, #t do 
        if t[i]:match('FXID') and t[i]:gsub('[{}-]','') and t[i]:gsub('[{}-]',''):match(fx_guid) then search_PM = true end
        if search_PM and (t[i]:match('<PROGRAMENV '..paramnumber) or t[i]:match('<PARMENV') )then erase_chunk = true end
        if erase_chunk and t[i]:find('>') then erase_chunk = false t[i] = '' break end
        if erase_chunk then t[i] = '' end        
      end
      
    -- apply
      --msg(table.concat(t, '\n'))
      SetTrackStateChunk(  tr, table.concat(t, '\n'), true )
    
  end
  ----------------------------------------------------------------
  
  local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
  local st = 'Remove parameter modulation from last touched FX parameter'
  
  if retval then
    local tr =  reaper.CSurf_TrackFromID( tracknumber, false )
    --[[local ret = MB( 'Remove modulation from '..
      ({GetTrackName( tr, '' )})[2]..' / '..
      ({TrackFX_GetFXName( tr, fxnumber, '' )})[2]..' / '..
      ({TrackFX_GetParamName( tr, fxnumber, paramnumber, '' )})[2]..
      ' ?', st, 4 )
    if ret == 6 then ]] 
      reaper.Undo_BeginBlock()
      RemovePM(tr, fxnumber, paramnumber)       
      reaper.Undo_EndBlock(st, 1)
    --end
  end