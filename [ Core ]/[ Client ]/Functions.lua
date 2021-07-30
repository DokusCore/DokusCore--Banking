--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
function OpenBank()
  CreateThread(function()
    local str = "Use the Bank"
    PromptBank = PromptRegisterBegin()
    PromptSetControlAction(PromptBank, 0xE8342FF2)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(PromptBank, str)
    PromptSetEnabled(PromptBank, true)
    PromptSetVisible(PromptBank, true)
    PromptSetHoldMode(PromptBank, true)
    PromptSetGroup(PromptBank, OpenBankGroup)
    PromptRegisterEnd(PromptBank)
  end)
end

function GetDistance(Coords)
  local Ped = PlayerPedId()
  local pCoords = GetEntityCoords(Ped)
  local Dist = Vdist(pCoords, Coords)
  return Dist
end


















--------------------------------------------------------------------------------
