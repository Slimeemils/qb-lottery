QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(1000*60)
    local check = 'placeholder'
    local reset = MySQL.query.await('SELECT * FROM lotterytotal where lotto = ?', {check})
    local math = reset[1].day + 1
    local resetday = 14
        if os.date('%H:%M') == Config.ResetQuest then
            if reset[1].day ~= resetday then
                MySQL.Async.execute("UPDATE lotterytotal SET day = '"..math.."'")
            else
                TriggerEvent('qb-lottery:choosewinner')
            end
        end
    end
end)

RegisterNetEvent("qb-lottery:choosewinner", function()
    local winningticket = math.random(1,200)
    local check = 'placeholder'
    local result = MySQL.query.await('SELECT * FROM lotterytotal where lotto = ?', {check})
    local amount = result[1].total/2
    local reset = 1
    MySQL.Async.execute("UPDATE lotterytotal SET winner = '"..winningticket.."'")
    TriggerClientEvent('QBCore:Notify', -1, 'Lottery winner has been chosen!!')
    exports['qb-management']:AddMoney(Config.governementjob, amount)
    MySQL.Async.execute("UPDATE lotterytotal SET total = '"..amount.."'")
    MySQL.Async.execute("UPDATE lotterytotal SET day = '"..reset.."'")
end)

RegisterNetEvent("qb-lottery:claimtotal", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local Item = Player.Functions.GetItemByName("lotteryticket")
    local check = 'placeholder'
    local result = MySQL.query.await('SELECT * FROM lotterytotal where lotto = ?', {check})
    local amount = result[1].total
    local winningnumber = result[1].winner
    local reset = 0
    if Item ~= nil then
        local ticketnumber = Item.info.label
        print(ticketnumber)
        print(result[1].winner)
        if ticketnumber == winningnumber then
            Player.Functions.AddMoney('cash', amount, "lotterywinnings")
            Player.Functions.RemoveItem('lotteryticket', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lotteryticket'], "remove")
            MySQL.Async.execute("UPDATE lotterytotal SET total = '"..reset.."'")
            MySQL.Async.execute("UPDATE lotterytotal SET winner = '"..reset.."'")
            MySQL.query('DELETE FROM lottery WHERE cid = ?', {cid})
        else
            TriggerClientEvent('QBCore:Notify', src, 'Sorry but this ticket doesn\'t match.')
            Player.Functions.RemoveItem('lotteryticket', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lotteryticket'], "remove")
            MySQL.query('DELETE FROM lottery WHERE cid = ?', {cid})
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have a lottery ticket to turn in.')
    end
end)

RegisterNetEvent("qb-lottery:purchaselottery", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local cost = Config.ticketprice
    local ticketnumber = math.random(1,200)
    local info = {
        label = ticketnumber
    }
	
    if Player.Functions.RemoveMoney('bank', cost, "lottery") then
        MySQL.insert("INSERT INTO `lottery` (`cid`) VALUES ('"..cid.."')")
        local check = 'placeholder'
        local totalamount = MySQL.query.await('SELECT * FROM lotterytotal where lotto = ?', {check})
        local newamount = totalamount[1].total + cost
        MySQL.update("UPDATE lotterytotal SET total = '"..newamount.."' WHERE lotto = '"..check.."'")     
        Player.Functions.AddItem('lotteryticket', 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lotteryticket'], "add")
    elseif Player.Functions.RemoveMoney('cash', cost, "lottery") then
        MySQL.insert("INSERT INTO `lottery` (`cid`) VALUES ('"..cid.."')")
        local check = 'placeholder'
        local totalamount = MySQL.query.await('SELECT * FROM lotterytotal where lotto = ?', {check})
        local newamount = totalamount[1].total + cost
        MySQL.update("UPDATE lotterytotal SET total = '"..newamount.."' WHERE lotto = '"..check.."'")
        Player.Functions.AddItem('lotteryticket', 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lotteryticket'], "add")
    else   
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have enough money..')
    end
end)

QBCore.Functions.CreateCallback('qb-lottery:checkifpurchased', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT cid FROM lottery WHERE cid = @cid', { ['@cid'] = Player.PlayerData.citizenid })

    if result[1] ~= nil then
        cb(true)
    else
        cb(false)
    end
end)
