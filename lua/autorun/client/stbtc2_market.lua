net.Receive( "GiveBTCMarketData", function( len )
    local dat = net.ReadData( len )
    dat = util.Decompress( dat )
    dat = util.JSONToTable( dat )

    local MarketWindow = vgui.Create( "DFrame" )
    MarketWindow:SetPos( 5, 5 )
    MarketWindow:SetSize( 600, 400 )
    MarketWindow:SetTitle( "" )
    MarketWindow:SetVisible( true )
    MarketWindow:SetDraggable( false )
    MarketWindow:ShowCloseButton( false )
    MarketWindow:MakePopup()
    MarketWindow:Center()
    MarketWindow.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 21, 22, 49, 255 ) )
        draw.SimpleText( "BITCOIN MARKET", "BTCMed", 5, 2 )
    end

    local CloseButton = vgui.Create( "DButton", MarketWindow )
    CloseButton:SetPos( 560, 0 )
    CloseButton:SetSize( 40, 20 )
    CloseButton:SetText( "X" )
    CloseButton:SetTextColor(Color(255,255,255))
    CloseButton.DoClick = function( self )
        MarketWindow:Close()
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

    local PlyBalDisplay = vgui.Create( "DLabel", MarketWindow )
    PlyBalDisplay:SetPos( 5, 30 )
    PlyBalDisplay:SetFont( "BTCSmall" )
    PlyBalDisplay:SetTextColor( Color( 255, 255, 255 ) )
    PlyBalDisplay:SetText( "WALLET: " .. math.Round( LocalPlayer():GetBitcoin(), 4 ) .. " BTC" )
    PlyBalDisplay:SizeToContents()

    local BTCValDisplay = vgui.Create( "DLabel", MarketWindow )
    BTCValDisplay:SetPos( 415, 30 )
    BTCValDisplay:SetFont( "BTCSmall" )
    BTCValDisplay:SetTextColor( Color( 255, 255, 255 ) )
    BTCValDisplay:SetText( "BTC VALUE: $" .. math.Round( STBTC2_PRICE, 4 ) )
    BTCValDisplay:SizeToContents()
    function BTCValDisplay:Think()
        self:SetText( "BTC VALUE: $" .. math.Round( STBTC2_PRICE, 4 ) )
        self:SizeToContents()
    end

    if dat[1] == nil then
        local NoMarketLabel = vgui.Create( "DLabel", MarketWindow )
        NoMarketLabel:SetPos( 15, 60 )
        NoMarketLabel:SetFont( "BTCSmall" )
        NoMarketLabel:SetTextColor( Color( 255, 255, 255 ) )
        NoMarketLabel:SetText( "There's nothing on the market!" )
        NoMarketLabel:SizeToContents()
    else
        --id, btc
        local nameHeader = vgui.Create( "DLabel", MarketWindow )
        nameHeader:SetPos( 15, 60 )
        nameHeader:SetFont( "BTCSmall" )
        nameHeader:SetTextColor( Color( 255, 255, 255 ) )
        nameHeader:SetText( "SELLER" )
        nameHeader:SizeToContents()

        local btcHeader = vgui.Create( "DLabel", MarketWindow )
        btcHeader:SetPos( 200, 60 )
        btcHeader:SetFont( "BTCSmall" )
        btcHeader:SetTextColor( Color( 255, 255, 255 ) )
        btcHeader:SetText( "AMOUNT" )
        btcHeader:SizeToContents()

        local costHeader = vgui.Create( "DLabel", MarketWindow )
        costHeader:SetPos( 350, 60 )
        costHeader:SetFont( "BTCSmall" )
        costHeader:SetTextColor( Color( 255, 255, 255 ) )
        costHeader:SetText( "PRICE" )
        costHeader:SizeToContents()

        local MarketScroller = vgui.Create( "DScrollPanel", MarketWindow )
        MarketScroller:SetSize( 600, 270 )
        MarketScroller:SetPos( 0, 80 )

        i = 1
        for k,v in pairs( dat ) do
            local nameLabel = MarketScroller:Add( "DLabel" )
            --nameLabel:SetPos( 15, 60 + ( i * 20 ) )
            nameLabel:SetPos( 15, (i-1) * 20 )
            nameLabel:SetFont( "BTCSmall" )
            nameLabel:SetTextColor( Color( 255, 255, 255 ) )
            nameLabel.id = v["id"]
            if IsValid( player.GetBySteamID64( v["id"] ) ) then
                nameLabel:SetText( player.GetBySteamID64( v["id"] ):Name() )
            else
                nameLabel:SetText( v["id"] )
            end
            nameLabel:SizeToContents()
            function nameLabel:DoClick()
                if !IsValid( player.GetBySteamID64( v["id"] ) ) then
                    gui.OpenURL( "https://steamcommunity.com/id/" .. v["id"] )
                end
            end

            local btcLabel = MarketScroller:Add( "DLabel" )
            --btcLabel:SetPos( 200, 60 + ( i * 20 ) )
            btcLabel:SetPos( 200, (i-1) * 20 )
            btcLabel:SetFont( "BTCSmall" )
            btcLabel:SetTextColor( Color( 255, 255, 255 ) )
            btcLabel:SetText( v["btc"] )
            btcLabel:SizeToContents()

            local costLabel = MarketScroller:Add( "DLabel" )
            --costLabel:SetPos( 350, 60 + ( i * 20 ) )
            costLabel:SetPos( 350, (i-1) * 20 )
            costLabel:SetFont( "BTCSmall" )
            costLabel:SetTextColor( Color( 255, 255, 255 ) )
            costLabel:SetText( "$" .. math.ceil( v["price"] ) )
            costLabel:SizeToContents()

            local buyButton = MarketScroller:Add( "DButton" )
            --buyButton:SetPos( 510, 60 + ( i * 20 ) )
            buyButton:SetPos( 510, (i-1) * 20 )
            buyButton:SetFont( "BTCSmall" )
            buyButton:SetTextColor( Color( 255, 255, 255 ) )
            if LocalPlayer():SteamID64() == v["id"] then
                buyButton:SetText( "CANCEL" )
            else
                buyButton:SetText( "BUY" )
            end
            buyButton:SetSize( 75, 20 )
            buyButton.id = v["id"]
            buyButton.btc = v["btc"]
            function buyButton:Paint( w, h )
                if self:IsHovered() then
                    surface.SetDrawColor( Color( 128, 128, 128 ) )
                else
                    surface.SetDrawColor( Color( 255, 255, 255 ) )
                end
                surface.DrawOutlinedRect( 0, 0, w, h)
            end
            function buyButton:DoClick()
                net.Start( "AttemptToPurchaseBTC" )
                    net.WriteInt( k, 32 )
                    net.WriteInt( v["transaction"], 32 )
                net.SendToServer()
                MarketWindow:Close()
            end
            i = i+1
        end
    end

    local BTCWord = vgui.Create( "DLabel", MarketWindow )
    BTCWord:SetPos( 225, 360 )
    BTCWord:SetFont( "BTCMed" )
    BTCWord:SetTextColor( Color( 255, 255, 255 ) )
    BTCWord:SetText( "BTC @ $0" )
    BTCWord:SizeToContents()

    local AttemptSell

    local SellBox = vgui.Create( "DTextEntry", MarketWindow )
    SellBox:SetPos( 15, 360 )
    SellBox:SetSize( 200, 25 )
    SellBox:SetText( "0" )
    SellBox:SetFont( "BTCMed" )
    function SellBox:OnChange()
        if type( tonumber( self:GetValue() ) ) == "number" then
            BTCWord:SetText( "BTC @ $" .. math.Round( STBTC2_PRICE * self:GetValue(), 4 ) )
            BTCWord:SizeToContents()
        end
    end
    function SellBox:OnEnter()
        AttemptSell()
    end

    AttemptSell = function()
        if type( tonumber( SellBox:GetValue() ) ) != "number" then
            surface.PlaySound( "buttons/button10.wav" )
            notification.AddLegacy( "Error with your input: It's not a number." , NOTIFY_ERROR, 5)
            return
        end
        if tonumber( SellBox:GetValue() ) <= 0 then
            surface.PlaySound( "buttons/button10.wav" )
            notification.AddLegacy( "Error with your input: It's less than or equal to 0." , NOTIFY_ERROR, 5)
            return
        end
        if tonumber( SellBox:GetValue() ) > math.Round( tonumber( LocalPlayer():GetBitcoin() ), 4 ) then
            surface.PlaySound( "buttons/button10.wav" )
            notification.AddLegacy( "You don't have enough Bitcoin." , NOTIFY_ERROR, 5)
            return
        end
        net.Start( "CreateBTCMarketListing" )
            net.WriteFloat( tonumber( SellBox:GetValue() ) )
            net.WriteFloat( tonumber( math.Round( STBTC2_PRICE * tonumber( SellBox:GetValue() ), 4 ) ) )
        net.SendToServer()
        notification.AddLegacy( "You successfully listed " .. tonumber( SellBox:GetValue() ) .. " BTC on the market." , NOTIFY_GENERIC, 5)
        surface.PlaySound( "buttons/button14.wav" )
        MarketWindow:Close()
    end
    
    local SellButton = vgui.Create( "DButton", MarketWindow )
    SellButton:SetPos( 485, 360 )
    SellButton:SetSize( 100, 25 )
    SellButton:SetFont( "BTCMed" )
    SellButton:SetTextColor( Color( 255, 255, 255 ) )
    SellButton:SetText( "LIST" )
    function SellButton:Paint( w, h )
        if self:IsHovered() then
            surface.SetDrawColor( Color( 128, 128, 128 ) )
        else
            surface.SetDrawColor( Color( 255, 255, 255 ) )
        end
        surface.DrawOutlinedRect( 0, 0, w, h)
    end
    function SellButton:DoClick()
        AttemptSell()
    end

end )