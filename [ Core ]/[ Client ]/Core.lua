--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
-- Varables
local Loc, InRange = nil, false
local Steam, CharID = nil, nil
local BankInUse = false
local PluginReady = false
PromptBank, AliveNPCs = nil, {}
OpenBankGroup = GetRandomIntInRange(0, 0xffffff)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Create the map markers and spawn the bank npcs
--------------------------------------------------------------------------------
CreateThread(function()
  if (_Modules.Banking) then
    for k,v in pairs(_Banking.Zones) do
      local blip = N_0x554d9d53f696d002(1664425300, v.Coords)
      SetBlipSprite(blip, -2128054417, 1)
  		SetBlipScale(blip, 0.2)
      Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Bank')
    end

    for k,v in pairs(_Banking.NPCs) do
      SpawnStoreNPC(v.Hash, v.Coords, v.Heading)
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Check players distance from the banks
--------------------------------------------------------------------------------
CreateThread(function()
  -- First check if the core is ready to pass data
  if (_Modules.Banking) then
    local Ready = TSC('DokusCore:Core:System:IsCoreReady')
    while not Ready do Wait(1000) end
    while Ready do Wait(1000)
      for k,v in pairs(_Banking.Zones) do
        local Dist = GetDistance(v.Coords)
        if ((Loc == nil) and (Dist <= 3)) then Loc = v.ID end
        if (Loc == v.ID) then

          -- When in range and leaving the area
          if ((Dist > 3) and (InRange)) then
            Loc, InRange = nil, false
            PromptBank = nil
            OpenBankGroup = GetRandomIntInRange(0, 0xffffff)
          end

          -- When not in range and entering the area
          if ((Dist <= 3) and not (InRange)) then
            InRange = true
            TriggerEvent('DokusCore:Banking:StartBank')
          end
        end
      end
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start Banking code when user is in range
--------------------------------------------------------------------------------
RegisterNetEvent('DokusCore:Banking:StartBank')
AddEventHandler('DokusCore:Banking:StartBank', function()
  local Core = TSC('DokusCore:Core:GetCoreUserData')
  Steam, CharID = Core.Steam, Core.CharID
  local Data = TSC('DokusCore:Core:DBGet:Settings', { 'user', { Steam } })
  OpenBank(Data.Result[1].Language)
  while InRange do Wait(0)
    local BankGroupName  = CreateVarString(10, 'LITERAL_STRING', _('Banking_Title', Data.Result[1].Language))
    PromptSetActiveGroupThisFrame(OpenBankGroup, BankGroupName)
    local Prompt = PromptHasHoldModeCompleted(PromptBank)
    if ((Prompt) and not (BankInUse)) then
      BankInUse = true
      local Bank = TSC('DokusCore:Core:DBGet:Banks', { 'user', { Steam, CharID } })
      if (Bank.Exist) then
        local Data = Bank.Result[1]
        local Money, Gold, BankMoney, BankGold = Data.Money, Data.Gold, Data.BankMoney, Data.BankGold
        local array = { action = "showAccount", bank = string.upper(Loc), money = Money, gold = Gold }
        local encoded = json.encode(array)
        SetNuiFocus(true, true)
        SendNuiMessage(encoded)
        Wait(2000)
        BankInUse = false
      end
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- When the user makes his or her's deposit
--------------------------------------------------------------------------------
RegisterNUICallback('Deposit', function(Data)
  if not (TransIsMade) then
    TransIsMade = true
    local DepMoney, DepGold = tonumber(Data.money), tonumber(Data.gold)
    local IsMoney, IsGold = (DepMoney > 0), (DepGold > 0)
    local Bank = TSC('DokusCore:Core:DBGet:Banks', { 'user', { Steam, CharID } })
    local Data = Bank.Result[1]
    local Money, Gold, BankMoney, BankGold = Data.Money, Data.Gold, Data.BankMoney, Data.BankGold

    -- -- Do money transaction
    if (IsMoney) then
      if (Money >= DepMoney) then
        TriggerEvent('DokusCore:Core:Notify', "You've transacted $"..DepMoney.." to your bank account", 'TopRight', 10000)
        TSC('DokusCore:Core:DBSet:Bank', { 'Deposit', 'Money', { Steam, CharID, DepMoney } })
      else
        TriggerEvent('DokusCore:Core:Notify', 'Not enough money in your wallet. $'..Money..' left', 'TopRight', 10000)
      end
    end

    -- Do gold transaction
    if (IsGold) then
      if (Gold >= DepGold) then
        TriggerEvent('DokusCore:Core:Notify', "You've transacted $"..DepGold.." to your bank account", 'TopRight', 10000)
        TSC('DokusCore:Core:DBSet:Bank', { 'Deposit', 'Gold', { Steam, CharID, DepGold } })
      else
        TriggerEvent('DokusCore:Core:Notify', 'Not enough gold in your wallet. '..BankGold..' Gold left', 'TopRight', 10000)
      end
    end

    -- Update the bank hud
    if (Bank.Exist) then
      local Bank = TSC('DokusCore:Core:DBGet:Banks', { 'user', { Steam, CharID } })
      local Data = Bank.Result[1]
      local Money, Gold, BankMoney, BankGold = Data.Money, Data.Gold, Data.BankMoney, Data.BankGold
      local array = { action = "showAccount", bank = string.upper(Loc), money = Money, gold = Gold }
      local encoded = json.encode(array)
      SetNuiFocus(true, true)
      SendNuiMessage(encoded)
      Wait(2000)
    end

    -- Update the Hud
    TSC('DokusCore:Core:Hud:Update')
    TransIsMade = false
  else
    TriggerEvent('DokusCore:Core:Notify', "You're trying to deposit to fast, give it a moment!", 'TopRight', 10000)
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- When the user makes his or her's withdraw
--------------------------------------------------------------------------------
RegisterNUICallback('Withdraw', function(Data)
  if not (TransIsMade) then
    TransIsMade = true
    local DepMoney, DepGold = tonumber(Data.money), tonumber(Data.gold)
    local IsMoney, IsGold = (DepMoney > 0), (DepGold > 0)
    local Bank = TSC('DokusCore:Core:DBGet:Banks', { 'user', { Steam, CharID } })
    local Data = Bank.Result[1]
    local Money, Gold, BankMoney, BankGold = Data.Money, Data.Gold, Data.BankMoney, Data.BankGold
    -- -- Do money transaction
    if (IsMoney) then
      if (BankMoney >= DepMoney) then
        TSC('DokusCore:Core:DBSet:Bank', { 'Withdraw', 'Money', { Steam, CharID, DepMoney } })
        TriggerEvent('DokusCore:Core:Notify', "You've transacted $"..DepMoney.." to your wallet", 'TopRight', 10000)
      else
        TriggerEvent('DokusCore:Core:Notify', 'Not enough money in the bank. $'..BankMoney..' left', 'TopRight', 10000)
      end
    end

    -- Do gold transaction
    if (IsGold) then
      if (BankGold >= DepGold) then
        TSC('DokusCore:Core:DBSet:Bank', { 'Withdraw', 'Gold', { Steam, CharID, DepGold } })
        TriggerEvent('DokusCore:Core:Notify', "You've transacted "..DepGold.." Gold to your wallet", 'TopRight', 10000)
      else
        TriggerEvent('DokusCore:Core:Notify', 'Not enough gold in the bank. '..BankGold..' Gold left', 'TopRight', 10000)
      end
    end

    -- Update the bank hud
    if (Bank.Exist) then
      local Bank = TSC('DokusCore:Core:DBGet:Banks', { 'user', { Steam, CharID } })
      local Data = Bank.Result[1]
      local Money, Gold, BankMoney, BankGold = Data.Money, Data.Gold, Data.BankMoney, Data.BankGold
      local array = { action = "showAccount", bank = BankMoney, money = Money, gold = Gold }
      local encoded = json.encode(array)
      SetNuiFocus(true, true)
      SendNuiMessage(encoded)
      Wait(2000)
    end

    -- Update the Hud
    TSC('DokusCore:Core:Hud:Update')
    TransIsMade = false
  else
    TriggerEvent('DokusCore:Core:Notify', "You're trying to withdraw to fast, give it a moment!", 'TopRight', 10000)
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- When the user closes the bank account window
--------------------------------------------------------------------------------
RegisterNUICallback('NUIFocusOff', function()
  SetNuiFocus(false, false)
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Delete all NPCs when the resource stops
--------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  for k,v in pairs(AliveNPCs) do DeleteEntity(v) end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



































--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
