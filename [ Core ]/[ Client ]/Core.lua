--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
local Loc, InRange = nil, false
local Steam, CharID = nil, nil
local IsBankInUse = false
Money, Gold, BankMoney, BankGold = 0, 0, 0, 0
PromptBank = nil
OpenBankGroup = GetRandomIntInRange(0, 0xffffff)
--------------------------------------------------------------------------------
-- Blips
--------------------------------------------------------------------------------
CreateThread(function()
  for k,v in pairs(_Zones) do
    local blip = N_0x554d9d53f696d002(1664425300, v.Coords)
    SetBlipSprite(blip, -2128054417, 1)
		SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Bank')
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Check players distance
--------------------------------------------------------------------------------
CreateThread(function()
  while true do Wait(1000)
  local Ped = PlayerPedId()
  local pCoords = GetEntityCoords(ped)
    for k, v in pairs(_Zones) do
      local Dist = GetDistance(v.Coords)
      if Loc == nil and (Dist <= 3) then Loc = v.ID end
      if Loc == v.ID then
        if (Dist > 3) and InRange then
          Loc, InRange = nil, false
          Steam, CharID = nil, nil
          IsBankInUse = false
          Money, Gold, BankMoney, BankGold = 0, 0, 0, 0
          PromptBank = nil
          OpenBankGroup = GetRandomIntInRange(0, 0xffffff)
        end
        if (Dist <= 3) and not InRange then
          Loc = v.ID
          InRange = true
          TriggerEvent('DokusCore:Banking:C:StartBank', Ped)
        end
      end
    end
  end
end)
--------------------------------------------------------------------------------
-- Update DokusCore Hud
--------------------------------------------------------------------------------
-- function getLowest(Table)
--   local low = math.huge
--   local index
--   for i, v in pairs(Table) do
--     if v.Dist < low then
--       low = v.Dist
--       index = { Dist=low, Loc=v.ID}
--     end
--   end
--   return index
-- end
--
-- CreateThread(function()
--   while true do Wait(0)
--     local Number, Array = 0, {}
--     local Ped = PlayerPedId()
--     local pCoords = GetEntityCoords(ped)
--
--     for k, v in pairs(_Zones) do
--       local Dist = GetDistance(v.Coords)
--       table.insert(Array, { Loc = v.ID, Dist = Dist })
--     end
--
--     print(getLowest(Array).Dist, getLowest(Array).Loc)
--     Wait(30000)
--   end
-- end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RegisterNetEvent('DokusCore:Banking:C:StartBank')
AddEventHandler('DokusCore:Banking:C:StartBank', function(Ped)
  OpenBank()
  while InRange do Wait(0)
    local BankGroupName  = CreateVarString(10, 'LITERAL_STRING', "Bank")
    PromptSetActiveGroupThisFrame(OpenBankGroup, BankGroupName)
    local Promt = PromptHasHoldModeCompleted(PromptBank)
    if Promt then
      if not IsBankInUse then
        IsBankInUse = true
        local cData = TSC('DokusCore:S:Core:GetCoreUserData')
        Steam, CharID = cData.Steam, cData.CharID
        local bData = TSC('DokusCore:S:Core:DB:GetViaSteamAndCharID', { DB.Banks.Get, cData.Steam, cData.CharID })[1]
        Money, Gold, BankMoney, BankGold = bData.Money, bData.Gold, bData.BankMoney, bData.BankGold
        local array = { action = "showAccount", bank = BankMoney, money = Money, gold = Gold }
        local encoded = json.encode(array)
        SetNuiFocus(true, true)
        SendNuiMessage(encoded)
        Wait(2000)
        IsBankInUse = false
      end
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RegisterNUICallback('NUIFocusOff', function()
  SetNuiFocus(false, false)
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RegisterNUICallback('Deposit', function(Data)
  local DepMoney, DepGold = tonumber(Data.money), tonumber(Data.gold)
  local IsMoney, IsGold = (DepMoney > 0), (DepGold > 0)

  if IsMoney and IsGold then
    TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Withdraw', "Can't do a money and gold deposit at the same time!")
    return
  end

  if (DepMoney > 0) then
    if (Money >= DepMoney) then
      local MoneyPlus = (BankMoney + DepMoney)
      local MoneyMin  = (Money - DepMoney)
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetBankMoney, 'BankMoney', MoneyPlus, Steam, CharID })
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetMoney, 'Money', MoneyMin, Steam, CharID })
      Money, BankMoney = MoneyMin, MoneyPlus
      local array = { action = "updateNumbers", bank = BankMoney, money = Money, gold = Gold }
      local encoded = json.encode(array)
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Deposit', "Deposited $"..DepMoney)
      SendNuiMessage(encoded)
    else
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Deposit', "You've not have enough money to deposit!")
    end
  end

  if (DepGold > 0) then
    if (Gold >= DepGold) then
      local GoldPlus = (BankGold + DepGold)
      local GoldMin  = (Gold - DepGold)
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetBankGold, 'BankGold', GoldPlus, Steam, CharID })
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetGold, 'Gold', GoldMin, Steam, CharID })
      Gold, BankGold = GoldMin, GoldPlus
      local array = { action = "updateNumbers", bank = BankMoney, money = Money, gold = Gold }
      local encoded = json.encode(array)
      SendNuiMessage(encoded)
    else
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Deposit', "You've not have enough gold to deposit!")
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RegisterNUICallback('Withdraw', function(Data)
  local DepMoney, DepGold = tonumber(Data.money), tonumber(Data.gold)
  local IsMoney, IsGold = (DepMoney > 0), (DepGold > 0)

  if IsMoney and IsGold then
    TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Withdraw', "Can't do a money and gold transfer at the same time!")
    return
  end

  if IsMoney then
    if (BankMoney >= DepMoney) then
      local MoneyMin  = (BankMoney - DepMoney)
      local MoneyPlus = (Money + DepMoney)
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetBankMoney, 'BankMoney', MoneyMin, Steam, CharID })
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetMoney, 'Money', MoneyPlus, Steam, CharID })
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Withdraw', "You've withdrawed $"..DepMoney)
      Money, BankMoney = MoneyPlus, MoneyMin
      local array = { action = "updateNumbers", bank = BankMoney, money = Money, gold = Gold }
      local encoded = json.encode(array)
      SendNuiMessage(encoded)
    else
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Withdraw', "You've not have enough money on the bank!")
    end
  end

  if IsGold then
    if (BankGold >= DepGold) then
      local GoldMin  = (BankGold - DepGold)
      local GoldPlus = (Gold + DepGold)
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetBankGold, 'BankGold', GoldMin, Steam, CharID })
      TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', { DB.Banks.SetGold, 'Gold', GoldPlus, Steam, CharID })
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Withdraw', "You've withdrawed "..DepGold.." Gold")
      Gold, BankGold = GoldPlus, GoldMin
      local array = { action = "updateNumbers", bank = BankMoney, money = Money, gold = Gold }
      local encoded = json.encode(array)
      SendNuiMessage(encoded)
    else
      TriggerEvent('DokusCore:C:Core:ShowNote', 'Bank Withdraw', "You've not have enough gold on the bank!")
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------




































--------------------------------------------------------------------------------
