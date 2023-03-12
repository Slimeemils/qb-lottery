# qb-lottery
Lottery resource for QB. Set to automatically determine a winner every 14 days. Basically a money sink that allows players to purchase tickets, and the total amount goes into a fund. On the 14th day the winning number is chosen. If someone has that ticket they will receive 50% of the total, and the other 50% will go to a government job.

Add this to whatever inventory script you use in html>js>app.js
If you search "markedbills" you will be able to find where it needs to go.
```
} else if (itemData.name == "lotteryticket") {
            $(".item-info-title").html('<p>' + itemData.label + '</p>')
            $(".item-info-description").html('<p><strong>Number: </strong><span>'+ itemData.info.label + '</span></p>');
```

Add this to your items.lua & add the image in the images folder to your inventory.
```
	["lotteryticket"]          = {["name"] = "lotteryticket",                  ["label"] = "Lottery Ticket", 		["weight"] = 1,  ["type"] = "item", 		["image"] = "lotteryticket.png",                  ["unique"] = true, 	["useable"] = false, 	["shouldClose"] = false, ["combinable"] = nil,   ["description"] = "Your Lottery ticket number is: "},

```
Add SQL to database
