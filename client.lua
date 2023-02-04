QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    LotteryPed()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        LotteryPed()  
    end
end)

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        if DoesEntityExist(lotteryped) then
            DeletePed(lotteryped)
        end
	end 
end)

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

Citizen.CreateThread(function()
    
    exports['qb-target']:AddCircleZone("lotterymenuspot", Config.targetlocation, 2.0, {
		name="lotterymenuspot",
		debugPoly=false,
		useZ = true,
	}, {
		options = {
			{
				event = 'qb-lottery:menu',
				icon = "fa-solid fa-money-bill-trend-up",
				label = 'Open Lottery Menu',
			},
		},
		distance = 2.5
	})
end)

function LotteryPed()

    if not DoesEntityExist(lotteryped) then

        model = Config.PedModel

        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end

        LotteryPed = CreatePed(6, model, Config.PedLocation, false, true)
        

        SetEntityAsMissionEntity(lotteryped)
        SetPedFleeAttributes(lotteryped, 0, 0)
        SetBlockingOfNonTemporaryEvents(lotteryped, true)
        SetEntityInvincible(lotteryped, true)
        FreezeEntityPosition(lotteryped, true)

        -- You can use this to make the ped do an animation if you'd like
        -- loadAnimDict("timetable@ron@ig_3_couch")        
        -- TaskPlayAnim(lotteryped, "timetable@ron@ig_3_couch", "base", 8.0, 1.0, -1, 01, 0, 0, 0, 0)
    end
end

local lotterymenu = {
    {
        header = "Welcome to Los Santos Lottery!",
        isMenuHeader = true, 
    },
    {
        header = "Purchase a Lottery ticket for $"..Config.ticketprice..".",
        txt = "Purchasing this ticket gives you a chance to win the lottery!",
        params = {
            event = "qb-lottery:purchase",
            args = {
                number = 1,
            }
        }
    },
    {
        header = "Claim the Lottery prize!",
        txt = "If your number matches you will be given your winnings!",
        params = {
            event = "qb-lottery:claim",
            args = {
                number = 1,
            }
        }
    },
    -- {
    --     header = "temp", -- Used this for debugging purposes.
    --     txt = "Delete this before release bozo",
    --     params = {
    --         event = "qb-lottery:temp",
    --         args = {
    --             number = 1,
    --         }
    --     }
    -- },
}

RegisterNetEvent("qb-lottery:menu", function()
    exports['qb-menu']:openMenu(lotterymenu)
end)

-- RegisterNetEvent("qb-lottery:temp", function()
--     TriggerServerEvent('qb-lottery:choosewinner')
-- end)

RegisterNetEvent("qb-lottery:purchase", function()
    QBCore.Functions.TriggerCallback('qb-lottery:checkifpurchased', function(cb)
        if not cb then
            TriggerServerEvent("qb-lottery:purchaselottery")
        else
            QBCore.Functions.Notify('You have already purchased a lottery ticket. Good luck!', 'error',  7500)
        end
    end)
end)

RegisterNetEvent("qb-lottery:claim", function()
    TriggerServerEvent('qb-lottery:claimtotal')
end)