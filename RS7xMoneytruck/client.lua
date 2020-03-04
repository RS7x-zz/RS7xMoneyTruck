
ESX =  nil

local pos = GetEntityCoords(GetPlayerPed(-1),  true)
local s1, s2 = GetStreetNameAtCoord( pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
local street1 = GetStreetNameFromHashKey(s1)
local street2 = GetStreetNameFromHashKey(s2)


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

function removeblip(Blip)
  RemoveBlip(Blip)
end

RegisterNetEvent('RS7x:Blip')
AddEventHandler('RS7x:Blip', function(x,y,z)
    if ESX.PlayerData.job.name == 'police' then
      local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
      local transT = 250
      Blip = AddBlipForCoord(x,y,z)
        SetBlipSprite(Blip,  477)
        SetBlipColour(Blip,  1)
        SetBlipAlpha(Blip,  transT)
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 1.2)
        SetBlipFlashes(Blip, true)
        SetBlipAsShortRange(Blip,  true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Robbery In Progress | Money Truck')
        EndTextCommandSetBlipName(Blip)
    end
end)

function DrawText3Ds(x,y,z,text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 370
  DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

RegisterNetEvent('animation:rob')
AddEventHandler('animation:rob', function()
    local Ped = GetPlayerPed(-1)
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end

    while isRobbing == true do
        if not IsEntityPlayingAnim(Ped, "mini@repair", "fixing_a_player", 3) then
            ClearPedSecondaryTask(Ped)
            TaskPlayAnim(Ped, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    ClearPedTasksImmediately(Ped)
end)

RegisterNetEvent('animation:hack')
AddEventHandler('animation:hack', function()
    local Ped = GetPlayerPed(-1)
    RequestAnimDict("anim@heists@humane_labs@emp@hack_door")
    while not HasAnimDictLoaded("anim@heists@humane_labs@emp@hack_door") do
        Citizen.Wait(0)
    end

    while Hacking == true do
        if not IsEntityPlayingAnim(Ped, "anim@heists@humane_labs@emp@hack_door", "hack_loop", 3) then
            ClearPedSecondaryTask(Ped)
            TaskPlayAnim(Ped, "anim@heists@humane_labs@emp@hack_door", "hack_loop", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    ClearPedTasksImmediately(Ped)
end)

RegisterNetEvent('RS7x:getReward')
AddEventHandler('RS7x:getReward', function()
  local pos = GetEntityCoords(GetPlayerPed(-1))
  local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.001, 0, 70)

    if vehicle == GetHashKey('stockade') or GetEntityModel(vehicle) then
      createped()
      pedSpawned = true
      TriggerServerEvent('RS7x:NotifyPolice', street1, street2)
    end
    Citizen.Wait(0)
    SetVehicleDoorOpen(vehicle, 2, false, false)
    SetVehicleDoorOpen(vehicle, 3, false, false)
end)

function hasRobbed(hasRobbed)
  if hasRobbed == true then
    Citizen.Wait(Config.Timeout * 1000)
    hasRobbed = false
  else
    hasRobbed = false
  end
end

Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    local pos = GetEntityCoords(GetPlayerPed(-1))
    local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.001, 0, 70)
    local dstCheck = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, GetEntityCoords(vehicle), true)
    local text = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -4.25, 0.0)
 
    if DoesEntityExist(vehicle) then
      if  GetEntityModel(vehicle) == GetHashKey('stockade') and not isRobbing and not Timeout then
          if dstCheck < 5.0 then
            if IsControlJustReleased(0, 38) then
              TriggerServerEvent('RS7x:Itemcheck', 1)
            end
          end
      end
      if pedSpawned == true then
        DrawText3Ds(text.x, text.y, text.z, "~r~[E]~w~ To Rob")
        if IsControlJustReleased(0,38) then
          TriggerEvent('animation:rob')
          exports['progressBars']:startUI(Config.Timer * 1000, "Grabbing Cash/Items")
          TriggerServerEvent('RS7x:Payout')
          Wait(Config.Timer * 1000)
          finished = true
        end
        if finished == true then
          SetPedAsNoLongerNeeded(gaurd)
          SetPedAsNoLongerNeeded(guard2)
          SetPedAsNoLongerNeeded(guard3)
          pedSpawned = false
          isRobbing = false
          hasRobbed(true)
          RemoveBlip(Blip)
          --return
        end
      end
    end
  end
end)

function createped()

  local pos = GetEntityCoords(GetPlayerPed(-1))
  local hashKey = GetHashKey("s_m_m_security_01")
  local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.001, 0, 70)
  local pedSpawned = false
  local pedType = 5

  RequestModel(hashKey)
  while not HasModelLoaded(hashKey) do
      RequestModel(hashKey)
      Citizen.Wait(100)
  end

  print('Spawning Peds?')

  guard = CreatePedInsideVehicle(vehicle, pedType, hashKey, 2, 1, 1)
  guard2 = CreatePedInsideVehicle(vehicle, pedType, hashKey, 1, 1, 1)
  guard3 =  CreatePedInsideVehicle(vehicle, pedType, hashKey, 0, 1, 1)
--////////////
--  Guard 1
--///////////
  SetPedShootRate(guard,  750)
  SetPedCombatAttributes(guard, 46, true)
  SetPedFleeAttributes(guard, 0, 0)
  SetPedAsEnemy(guard,true)
  SetPedMaxHealth(guard, 900)
  SetPedAlertness(guard, 3)
  SetPedCombatRange(guard, 0)
  GiveWeaponToPed(guard, GetHashKey("WEAPON_SMG"), 5000, true, true)
  SetPedRelationshipGroupHash( gaurd, GetHashKey("HATES_PLAYER"))

  --////////////
  --  Guard 2
  --///////////
  SetPedShootRate(guard2,  750)
  SetPedCombatAttributes(guard2, 46, true)
  SetPedFleeAttributes(guard2, 0, 0)
  SetPedAsEnemy(guard2,true)
  SetPedMaxHealth(guard2, 900)
  SetPedAlertness(guard2, 3)
  SetPedCombatRange(guard2, 0)
  GiveWeaponToPed(guard2, GetHashKey("WEAPON_SMG"), 5000, true, true)
  SetPedRelationshipGroupHash( guard2, GetHashKey("HATES_PLAYER"))

  --////////////
  --  Guard3
  --///////////
  SetPedShootRate(guard3,  750)
  SetPedCombatAttributes(guard3, 46, true)
  SetPedFleeAttributes(guard3, 0, 0)
  SetPedAsEnemy(guard3,true)
  SetPedMaxHealth(guard3, 900)
  SetPedAlertness(guard3, 3)
  SetPedCombatRange(guard3, 0)
  GiveWeaponToPed(guard3, GetHashKey("WEAPON_SMG"), 5000, true, true)
  SetPedRelationshipGroupHash( guard3, GetHashKey("HATES_PLAYER"))
end

RegisterNetEvent('RS7x:startHacking')
AddEventHandler('RS7x:startHacking', function(cb)
  cb = true
  isRobbing = true
  Hacking = true
    if isRobbing == true then
      print('started')
      TriggerEvent('mhacking:seqstart', 6, Config.Hackingtime, cb1)
    end
end)

RegisterNetEvent('RS7x:NotifyPolice')
AddEventHandler('RS7x:NotifyPolice', function(msg)
  if ESX.PlayerData.job.name == 'police' then
    TriggerEvent('RS7x:Blip', pos.x,pos.y,pos.z)
    TriggerEvent('chat:addMessage', {
    template = '<div class="chat-message emergency">[Dispatch]: ' .. msg .. ' </div>',
    args = { msg }
    });
  end
end)

function cb1(success, timeremaining)
  if success then
    TriggerEvent('RS7x:getReward')
    Hacking = false
  else
    --TriggerEvent('RS7x:getReward')
    TriggerEvent('mhacking:hide')
    Hacking = false
  end
end