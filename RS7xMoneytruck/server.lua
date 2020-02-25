ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

    for i=1, #xPlayers, 1 do

        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            CopsConnected = CopsConnected + 1
        end
    end
    SetTimeout(120 * 1000 , CountCops)
end

--SetTimeout(120 * 1000 , CountCops)
CountCops()

RegisterNetEvent('RS7x:Itemcheck')
AddEventHandler('RS7x:Itemcheck', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local isRobbing = true

    local item = xPlayer.getInventoryItem("advlockpick")
    if isRobbing and item.count > 0 and amount > 0 then
        CountCops()
        if CopsConnected >= Config.Copsneeded then
            --xPlayer.removeInventoryItem("advlockpick", amount)
            TriggerClientEvent('RS7x:startHacking',source,true)
            print('got item')
        else
            isRobbing = false
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = ("Not Enough Police") })
        end
    else
        isRobbing = false
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = ("You dont have the right tools for this") })
        print('no item')
    end
end)

RegisterNetEvent('RS7x:NotifyPolice')
AddEventHandler('RS7x:NotifyPolice', function(street1, street2)
    TriggerClientEvent('RS7x:NotifyPolice', source, 'Robbery In Progress : Security Truck | ' .. street1 .. " | " .. street2 .. ' ')
end)

function RandomItem()
	return Config.Items[math.random(#Config.Items)]
end

function RandomNumber()
	return math.random(1,10)
end

RegisterNetEvent('RS7x:Payout')
AddEventHandler('RS7x:Payout', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local Robbing = false
    local timer = 0
    Robbing = true
    while Robbing == true do
        timer = timer + 1000
        Citizen.Wait(1000)
        xPlayer.addInventoryItem(RandomItem(), RandomNumber())
        xPlayer.addMoney(math.random(300,2500))
        if timer == Config.Timer then
            break
        end
    end
end)