AddCSLuaFile()

STBTC2_PRICE = 0.0

stbtc = {}

local plyMeta = FindMetaTable( "Player" )

function plyMeta:SetBitcoin( btc )
    btc = math.max( btc, 0 ) --if its negative, fuck you

    if SERVER then
        sql.Query( "UPDATE st_btc_counts SET SteamID = '" .. self:SteamID64() .. "', Bitcoin = " .. btc .. " WHERE SteamID = '" .. self:SteamID64() .. "'" )
        self:SetNWFloat( "currBTC", btc )
    else
        ErrorNoHalt( "[STBTC2] Attempt to use SetBitcoin on client!" ) --guess its a debugging thing
    end
end

stbtc.SetBitcoin = function( id, btc )
    sql.Query( "UPDATE st_btc_counts SET SteamID = '" .. id .. "', Bitcoin = " .. btc .. " WHERE SteamID = '" .. id .. "'" )
end

function plyMeta:GetBitcoin()
    if SERVER then
        return math.Round( sql.Query( "SELECT SteamID, Bitcoin FROM st_btc_counts WHERE SteamID = '" .. self:SteamID64() .. "'" )[1][ "Bitcoin" ], 4 )
    elseif CLIENT then
        return math.Round( self:GetNWFloat( "currBTC", 0.0 ), 4 )
    else
        ErrorNoHalt( "[STBTC2] Somehow managed to be in neither CLIENT nor SERVER..." ) --you never know
    end
end

stbtc.GetBitcoin = function( id )
    return sql.Query( "SELECT SteamID, Bitcoin FROM st_btc_counts WHERE SteamID = '" .. id .. "'" )[1][ "Bitcoin" ]
end

function plyMeta:AddBitcoin( btc )
    if SERVER then
        local currBTC = sql.Query( "SELECT SteamID, Bitcoin FROM st_btc_counts WHERE SteamID = '" .. self:SteamID64() .. "'" )[1][ "Bitcoin" ]
        currBTC = math.max( currBTC + btc, 0 ) --if its negative, fuck you
        sql.Query( "UPDATE st_btc_counts SET SteamID = '" .. self:SteamID64() .. "', Bitcoin = " .. currBTC .. " WHERE SteamID = '" .. self:SteamID64() .. "'" )
        self:SetNWFloat( "currBTC", currBTC )
    else
        ErrorNoHalt( "[STBTC2] Attempt to use AddBitcoin on client!" ) --guess its a debugging thing
    end
end

stbtc.AddBitcoin = function( id, btc )
    local currBTC = sql.Query( "SELECT SteamID, Bitcoin FROM st_btc_counts WHERE SteamID = '" .. id .. "'" )[1][ "Bitcoin" ]
    currBTC = math.max( currBTC + btc, 0 ) --if its negative, fuck you
    sql.Query( "UPDATE st_btc_counts SET SteamID = '" .. id .. "', Bitcoin = " .. currBTC .. " WHERE SteamID = '" .. id .. "'" )
end

if SERVER then
    util.AddNetworkString( "STBTC2OpenMenu" ) --open bitminer menu, sv-cl
    util.AddNetworkString( "WithdrawBTCToWallet" ) --give player btc, cl-sv
	util.AddNetworkString( "STBTC2UpdatePrice" ) --update price of btc, sv-cl(all)
    util.AddNetworkString( "AskForBTCMarketData" ) --get market, cl-sv
    util.AddNetworkString( "GiveBTCMarketData" ) --send and show market, sv-cl
    util.AddNetworkString( "CreateBTCMarketListing" ) --send a new listing, cl-sv
    util.AddNetworkString( "AttemptToPurchaseBTC" ) --buy some btc, cl-sv
    util.AddNetworkString( "STBTC2SendBitcoin" ) --open send btc menu,

    local randomSnarks = { --lol
        "No, that doesn't work.",
        "Why would you try that?",
        "No.",
        "Don't be greedy.",
        "Nice try.",
        "I'm sure they'd appreciate that."
    }

    net.Receive( "STBTC2SendBitcoin", function( len, giver )
        local receiver = net.ReadEntity()
        local btc = net.ReadFloat()
        btc = math.Round( btc, 4 )

        if btc == 0 then
            DarkRP.notify( giver, 1, 5, "You cannot send no Bitcoin." )
        return end

        if btc < 0 then
            DarkRP.notify( giver, 1, 5, table.Random( randomSnarks ) )
        return end

        if giver:GetBitcoin() >= btc then
            giver:AddBitcoin( -btc )
            receiver:AddBitcoin( btc )
            DarkRP.notify( giver, 0, 5, "You sent " .. receiver:Name() .. " " .. math.Round( btc, 4 ) .. " BTC." )
            DarkRP.notify( receiver, 0, 5, giver:Name() .. " sent you " .. math.Round( btc, 4 ) .. " BTC." )
        else
            DarkRP.notify( giver, 1, 5, "You don't have enough Bitcoin!" )
        end
    end )

    net.Receive( "AttemptToPurchaseBTC", function( len, buyer )
        local index = net.ReadInt( 32 )
        local trans = net.ReadInt( 32 )
        local marketTab = file.Read( "stbtc2/market.txt" )
        marketTab = util.JSONToTable( marketTab )
        if trans == marketTab[ index ][ "transaction" ] then
            if buyer:SteamID64() == marketTab[ index ][ "id" ] then
                buyer:AddBitcoin( marketTab[ index ][ "btc" ] )
                DarkRP.notify( buyer, NOTIFY_GENERIC, 5, "You successfully cancelled your listing for " .. marketTab[ index ][ "btc" ] .. " BTC." )
                table.remove( marketTab, index )
                marketTab = util.TableToJSON( marketTab )
                file.Write("stbtc2/market.txt", marketTab )
            else
                if buyer:canAfford( math.ceil( marketTab[ index ][ "price" ] ) ) then
                    buyer:addMoney( -math.floor( marketTab[ index ][ "price" ] ) )
                    buyer:AddBitcoin( marketTab[ index ][ "btc" ] )
                    DarkRP.notify( buyer, NOTIFY_GENERIC, 5, "You successfully purchased " .. marketTab[ index ][ "btc" ] .. " BTC for $" .. math.floor( marketTab[ index ][ "price" ] ) .. "." )
                    if IsValid( player.GetBySteamID64( marketTab[ index ][ "id" ] ) ) then
                        player.GetBySteamID64( marketTab[ index ][ "id" ] ):addMoney( math.floor( marketTab[ index ][ "price" ] ) )
                        DarkRP.notify( player.GetBySteamID64( marketTab[ index ][ "id" ] ), NOTIFY_GENERIC, 5, "Your " .. marketTab[ index ][ "btc" ] .. " BTC was sold to " .. buyer:Name() .. "." )
                    else
                        DarkRP.notify( buyer, NOTIFY_GENERIC, 5, "The recipient was offline, they will receive the money when they log on." )
                        if file.Exists( "stbtc2/" .. marketTab[ index ][ "id" ] .. ".txt", "DATA" ) then
                            local amtOwed = file.Read( "stbtc2/" .. marketTab[ index ][ "id" ] .. ".txt" )
                            amtOwed = tonumber( amtOwed ) + math.floor( STBTC2_PRICE * marketTab[ index ][ "btc" ] )
                            file.Write("stbtc2/" .. marketTab[ index ][ "id" ] .. ".txt", amtOwed )
                        else
                            file.Write("stbtc2/" .. marketTab[ index ][ "id" ] .. ".txt", math.floor( STBTC2_PRICE * marketTab[ index ][ "btc" ] ) )
                        end
                    end
                    table.remove( marketTab, index )
                    marketTab = util.TableToJSON( marketTab )
                    file.Write("stbtc2/market.txt", marketTab )
                else
                    DarkRP.notify( buyer, NOTIFY_ERROR, 5, "You can't afford that listing." )
                end
            end
        else
            DarkRP.notify( buyer, NOTIFY_ERROR, 5, "That listing is no longer available." )
        end
    end )

    net.Receive( "CreateBTCMarketListing", function( len, ply )
        local btcam = net.ReadFloat()
        local askingprice = net.ReadFloat()
        btcam = math.Round( btcam, 4 )
        if btcam > tonumber( ply:GetBitcoin() ) then 
            ErrorNoHalt( "Floating point precision error!  Player has " .. ply:GetBitcoin() .. " but wants to sell " .. btcam .. "!")
            print( btcam )
            print( ply:GetBitcoin() )
        return end
        local marketTab = file.Read( "stbtc2/market.txt" )
        marketTab = util.JSONToTable( marketTab )
        table.insert( marketTab, { 
            ["id"] = ply:SteamID64(),
            ["btc"] = math.Round( btcam, 4 ),
            ["price"] = math.Round( askingprice, 4 ),
            ["transaction"] = cookie.GetNumber( "BTCTransactions" ) + 1
        } )
        ply:AddBitcoin( -btcam )
        marketTab = util.TableToJSON( marketTab )
        file.Write("stbtc2/market.txt", marketTab )
        cookie.Set( "BTCTransactions", cookie.GetNumber( "BTCTransactions" ) + 1 )
    end )

    net.Receive( "AskForBTCMarketData", function( len, ply )
        local marketTab = file.Read( "stbtc2/market.txt" )
        marketTab = util.Compress( marketTab )
        net.Start( "GiveBTCMarketData" )
            net.WriteData( marketTab, #marketTab )
        net.Send( ply )
    end )

    net.Receive( "WithdrawBTCToWallet", function( len, ply )
        local ent = net.ReadEntity()
        ply:AddBitcoin( math.Round( ent:GetNWFloat( "HeldBTC" ), 8 ) )
        ent:SetNWFloat( "HeldBTC", 0 )
    end )

    hook.Add( "InitPostEntity", "StartUpdatingBTCPrice2", function()
        STBTC2_PRICE = ST_CONFIGS.STBitMining2.BitcoinValue
    end )

    hook.Add( "Initialize", "SetupCleanBTCTable", function()
        if !sql.TableExists( "st_btc_counts" ) then
			sql.Query( "CREATE TABLE st_btc_counts( SteamID TEXT, Bitcoin FLOAT )" )
            MsgC( Color( 0, 255, 0 ), "[STBTC2] Successfully initialized an empty st_btc_counts table!\n" )
		end

        if !file.Exists("stbtc2", "DATA") then
            file.CreateDir("stbtc2")
            file.Write("stbtc2/market.txt", util.TableToJSON( {} ))
        end

        cookie.Set( "BTCTransactions", "0" )
    end )

    hook.Add( "PlayerInitialSpawn", "AssignBitcoinValue", function( ply )
        ply.retTable = sql.Query( "SELECT SteamID, Bitcoin FROM st_btc_counts WHERE SteamID = '" .. ply:SteamID64() .. "'" )
		if ply.retTable == nil then
			sql.Query( "INSERT INTO st_btc_counts( SteamID, Bitcoin ) VALUES( '" .. ply:SteamID64() .. "', 0 )" )
            MsgC( Color( 0, 255, 0 ), "[STBTC2] Added a new record for " .. ply:Name() .. "!\n" )
		end
		ply.currBTC = sql.Query( "SELECT SteamID, Bitcoin FROM st_btc_counts WHERE SteamID = '" .. ply:SteamID64() .. "'" )[1][ "Bitcoin" ]
        ply:SetNWFloat( "currBTC", ply.currBTC )
        MsgC( Color( 0, 255, 0 ), "[STBTC2] Assigned Bitcoin value to " .. ply:Name() .. "!\n" )
    end )

    hook.Add( "PlayerSpawn", "GiveMoneyOwed", function( ply )
        if file.Exists( "stbtc2/" .. ply:SteamID64() .. ".txt", "DATA" ) then
            local amtOwd = tonumber( file.Read( "stbtc2/" .. ply:SteamID64() .. ".txt" ) )
            ply:addMoney( amtOwd )
            DarkRP.notify( ply, NOTIFY_GENERIC, 5, "While you were offline, one or more of your Bitcoin listings was purchased." )
            DarkRP.notify( ply, NOTIFY_GENERIC, 5, "You were credited $" .. amtOwd .. "." )
            file.Delete( "stbtc2/" .. ply:SteamID64() .. ".txt" )
        end
    end )

    net.Receive( "STBTC2UpdatePrice", function( _, ply )
        net.Start( "STBTC2UpdatePrice" )
            net.WriteFloat( STBTC2_PRICE )
        net.Send( ply )
    end )
end

if CLIENT then
    
    net.Receive( "STBTC2UpdatePrice", function()
        local pric = net.ReadFloat()
        STBTC2_PRICE = math.Round( pric, 4 )
    end )

    hook.Add( "InitPostEntity", "AskForBTCPriceST2", function()
        net.Start( "STBTC2UpdatePrice" )
        net.SendToServer()
    end )

    surface.CreateFont( "BTCMed", {
        font = "Tahoma",
        size = 24,
        weight = 100
    } )

    surface.CreateFont( "BTCSmall", {
        font = "Tahoma",
        size = 18,
        weight = 100
    } )

    surface.CreateFont( "BTCMini", {
        font = "Tahoma",
        size = 8,
        weight = 100
    } )

    net.Receive( "STBTC2OpenMenu", function( len, ply )
        local typ = net.ReadInt( 4 )
        local ent = net.ReadEntity()

        local BitcoinWindow = vgui.Create( "DFrame" )
        BitcoinWindow:SetPos( 5, 5 )
        BitcoinWindow:SetSize( 400, 190 )
        BitcoinWindow:SetTitle( "" )
        BitcoinWindow:SetVisible( true )
        BitcoinWindow:SetDraggable( false )
        BitcoinWindow:ShowCloseButton( false )
        BitcoinWindow:MakePopup()
        BitcoinWindow:Center()
        BitcoinWindow.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 21, 22, 49, 255 ) )
            draw.SimpleText( "ST BITMINER 2.0 - MODEL ST" .. typ, "BTCMed", 5, 2 )
        end

        local CloseButton = vgui.Create( "DButton", BitcoinWindow )
        CloseButton:SetPos( 360, 0 )
        CloseButton:SetSize( 40, 20 )
        CloseButton:SetText( "X" )
        CloseButton:SetTextColor(Color(255,255,255))
        CloseButton.DoClick = function( self )
            BitcoinWindow:Close()
            surface.PlaySound("ui/buttonclick.wav")
        end
        CloseButton.Paint = function( self, w, h )
            if CloseButton:IsHovered() then
                draw.RoundedBox( 0, 0, 0, w, h, Color( 128, 0, 0, 255 ) )
            else
                draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 255 ) )
            end
            surface.SetDrawColor( color_black )
        end

        local PlyBalTitle = vgui.Create( "DLabel", BitcoinWindow )
        PlyBalTitle:SetPos( 15, 60 )
        PlyBalTitle:SetFont( "BTCSmall" )
        PlyBalTitle:SetTextColor( Color( 255, 255, 255 ) )
        PlyBalTitle:SetText( "WALLET: " )
        PlyBalTitle:SizeToContents()

        local PlyBalLabel = vgui.Create( "DLabel", BitcoinWindow )
        PlyBalLabel:SetPos( 100, 60 )
        PlyBalLabel:SetFont( "BTCSmall" )
        PlyBalLabel:SetTextColor( Color( 255, 255, 255 ) )
        PlyBalLabel:SetText( math.Round( LocalPlayer():GetBitcoin(), 4 ) .. " BTC" )
        PlyBalLabel:SizeToContents()
        function PlyBalLabel:Think()
            self:SetText( math.Round( LocalPlayer():GetBitcoin(), 4 ) .. " BTC" )
            self:SizeToContents()
        end

        local MinerBalTitle = vgui.Create( "DLabel", BitcoinWindow )
        MinerBalTitle:SetPos( 15, 85 )
        MinerBalTitle:SetFont( "BTCSmall" )
        MinerBalTitle:SetTextColor( Color( 255, 255, 255 ) )
        MinerBalTitle:SetText( "MINED: " )
        MinerBalTitle:SizeToContents()

        local MinerBalLabel = vgui.Create( "DLabel", BitcoinWindow )
        MinerBalLabel:SetPos( 100, 85 )
        MinerBalLabel:SetFont( "BTCSmall" )
        MinerBalLabel:SetTextColor( Color( 255, 255, 255 ) )
        MinerBalLabel:SetText( math.Round( ent:GetNWFloat( "HeldBTC" ), 4 ) .. " BTC" )
        MinerBalLabel:SizeToContents()
        function MinerBalLabel:Think()
            self:SetText( math.Round( ent:GetNWFloat( "HeldBTC" ), 4 ) .. " BTC" )
            self:SizeToContents()
        end

        local ToWalletButton = vgui.Create( "DButton", BitcoinWindow )
        ToWalletButton:SetPos( 285, 85 )
        ToWalletButton:SetFont( "BTCSmall" )
        ToWalletButton:SetTextColor( Color( 255, 255, 255 ) )
        ToWalletButton:SetText( "WITHDRAW" )
        ToWalletButton:SetSize( 100, 20 )
        function ToWalletButton:Paint( w, h )
            if self:IsHovered() then
                surface.SetDrawColor( Color( 128, 128, 128 ) )
            else
                surface.SetDrawColor( Color( 255, 255, 255 ) )
            end
            surface.DrawOutlinedRect( 0, 0, w, h)
        end
        function ToWalletButton:DoClick()
            surface.PlaySound( "buttons/lightswitch2.wav" )
            notification.AddLegacy( "Withdrew " .. math.Round( ent:GetNWFloat( "HeldBTC" ), 4 ) .. " BTC to your wallet.", NOTIFY_GENERIC, 5)
            net.Start( "WithdrawBTCToWallet" )
                net.WriteEntity( ent )
            net.SendToServer()
        end

        local MoneyBalLabel = vgui.Create( "DLabel", BitcoinWindow )
        MoneyBalLabel:SetPos( 100, 105 )
        MoneyBalLabel:SetFont( "BTCSmall" )
        MoneyBalLabel:SetTextColor( Color( 255, 255, 255 ) )
        MoneyBalLabel:SetText( "($" .. math.floor( ent:GetNWFloat( "HeldBTC" ) * STBTC2_PRICE ) .. ")" )
        MoneyBalLabel:SizeToContents()
        function MoneyBalLabel:Think()
            self:SetText( "($" .. math.floor( ent:GetNWFloat( "HeldBTC" ) * STBTC2_PRICE ) .. ")" )
            self:SizeToContents()
        end

        local ToMarketButton = vgui.Create( "DButton", BitcoinWindow )
        ToMarketButton:SetPos( 125, 150 )
        ToMarketButton:SetFont( "BTCSmall" )
        ToMarketButton:SetTextColor( Color( 255, 255, 255 ) )
        ToMarketButton:SetText( "SHOW MARKET" )
        ToMarketButton:SetSize( 150, 20 )
        function ToMarketButton:Paint( w, h )
            if self:IsHovered() then
                surface.SetDrawColor( Color( 128, 128, 128 ) )
            else
                surface.SetDrawColor( Color( 255, 255, 255 ) )
            end
            surface.DrawOutlinedRect( 0, 0, w, h)
        end
        function ToMarketButton:DoClick()
            surface.PlaySound( "buttons/lightswitch2.wav" )
            BitcoinWindow:Close()
            net.Start( "AskForBTCMarketData" )
            net.SendToServer()
        end
        
    end )

end