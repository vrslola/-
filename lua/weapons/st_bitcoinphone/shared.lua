SWEP.Category = "STBitMiners 2"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Bitcoin Tablet"
SWEP.Base = "weapon_base"
SWEP.Author = "SweptThrone"
SWEP.Contact = "\ndiscord.sweptthr.one"
SWEP.Purpose = "View Bitcoin."
SWEP.Instructions = "Left click for market.\nRight click to send."
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 70
SWEP.Slot = 1
SWEP.Primary.Ammo = nil
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.Ammo = nil
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.LastNet = 0
SWEP.ShowWorldModel = false
SWEP.HoldType = "slam"


function SWEP:Think()
	
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_SLAM_THROW_DRAW )
	return true
end

function SWEP:PrimaryAttack()
	if CLIENT then
		if CurTime() >= self.LastNet + 1 then
			surface.PlaySound( "buttons/button19.wav" )
			net.Start( "AskForBTCMarketData" )
			net.SendToServer()
			self.LastNet = CurTime()
		end
	end
end

function SWEP:Holster()
return true end

function SWEP:SecondaryAttack()
	if CLIENT then
		if CurTime() >= self.LastNet + 1 then
			--STBTC2SendBitcoin
			local SendBTCWindow = vgui.Create( "DFrame" )
			SendBTCWindow:SetPos( 5, 5 )
			SendBTCWindow:SetSize( 600, 400 )
			SendBTCWindow:SetTitle( "" )
			SendBTCWindow:SetVisible( true )
			SendBTCWindow:SetDraggable( false )
			SendBTCWindow:ShowCloseButton( false )
			SendBTCWindow:MakePopup()
			SendBTCWindow:Center()
			SendBTCWindow.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 21, 22, 49, 255 ) )
				draw.SimpleText( "BITCOIN TRANSFER", "BTCMed", 5, 2 )
			end

			local CloseButton = vgui.Create( "DButton", SendBTCWindow )
			CloseButton:SetPos( 560, 0 )
			CloseButton:SetSize( 40, 20 )
			CloseButton:SetText( "X" )
			CloseButton:SetTextColor(Color(255,255,255))
			CloseButton.DoClick = function( self )
				SendBTCWindow:Close()
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

			local PlyBalDisplay = vgui.Create( "DLabel", SendBTCWindow )
			PlyBalDisplay:SetPos( 5, 30 )
			PlyBalDisplay:SetFont( "BTCSmall" )
			PlyBalDisplay:SetTextColor( Color( 255, 255, 255 ) )
			PlyBalDisplay:SetText( "WALLET: " .. math.Round( LocalPlayer():GetBitcoin(), 4 ) .. " BTC" )
			PlyBalDisplay:SizeToContents()

			local BTCValDisplay = vgui.Create( "DLabel", SendBTCWindow )
			BTCValDisplay:SetPos( 415, 30 )
			BTCValDisplay:SetFont( "BTCSmall" )
			BTCValDisplay:SetTextColor( Color( 255, 255, 255 ) )
			BTCValDisplay:SetText( "BTC VALUE: $" .. math.Round( STBTC2_PRICE, 4 ) )
			BTCValDisplay:SizeToContents()
			function BTCValDisplay:Think()
				self:SetText( "BTC VALUE: $" .. math.Round( STBTC2_PRICE, 4 ) )
				self:SizeToContents()
			end

			if #player.GetAll() <= 1 then --how do you get 0 players? idk
				local NoMarketLabel = vgui.Create( "DLabel", SendBTCWindow )
				NoMarketLabel:SetPos( 15, 60 )
				NoMarketLabel:SetFont( "BTCSmall" )
				NoMarketLabel:SetTextColor( Color( 255, 255, 255 ) )
				NoMarketLabel:SetText( "There are no players to send Bitcoin to!" )
				NoMarketLabel:SizeToContents()
			else
				--id, btc
				local nameHeader = vgui.Create( "DLabel", SendBTCWindow )
				nameHeader:SetPos( 15, 60 )
				nameHeader:SetFont( "BTCSmall" )
				nameHeader:SetTextColor( Color( 255, 255, 255 ) )
				nameHeader:SetText( "RECIPIENT" )
				nameHeader:SizeToContents()

				local btcHeader = vgui.Create( "DLabel", SendBTCWindow )
				btcHeader:SetPos( 200, 60 )
				btcHeader:SetFont( "BTCSmall" )
				btcHeader:SetTextColor( Color( 255, 255, 255 ) )
				btcHeader:SetText( "AMOUNT" )
				btcHeader:SizeToContents()

				local MarketScroller = vgui.Create( "DScrollPanel", SendBTCWindow )
				MarketScroller:SetSize( 600, 270 )
				MarketScroller:SetPos( 0, 80 )

				i = 1
				for k,v in pairs( player.GetAll() ) do
					if v != LocalPlayer() then
						local nameLabel = MarketScroller:Add( "DLabel" )
						--nameLabel:SetPos( 15, 60 + ( i * 20 ) )
						nameLabel:SetPos( 15, (i-1) * 20 )
						nameLabel:SetFont( "BTCSmall" )
						nameLabel:SetTextColor( Color( 255, 255, 255 ) )
						nameLabel.ent = v
						nameLabel:SetText( v:Name() )
						nameLabel:SizeToContents()

						local btcTextBox = MarketScroller:Add( "DTextEntry" )
						--btcTextBox:SetPos( 200, 60 + ( i * 20 ) )
						btcTextBox:SetPos( 200, (i-1) * 20 )
						btcTextBox:SetSize( 150, 20 )
						btcTextBox:SetFont( "BTCSmall" )
						btcTextBox:SetTextColor( Color( 0, 0, 0 ) )
						btcTextBox:SetText( "0" )

						local sendButton = MarketScroller:Add( "DButton" )
						--sendButton:SetPos( 510, 60 + ( i * 20 ) )
						sendButton:SetPos( 510, (i-1) * 20 )
						sendButton:SetFont( "BTCSmall" )
						sendButton:SetTextColor( Color( 255, 255, 255 ) )
						sendButton:SetText( "SEND" )
						sendButton:SetSize( 75, 20 )
						sendButton.ent = v
						sendButton.btc = tonumber( btcTextBox:GetValue() )
						function sendButton:Paint( w, h )
							if self:IsHovered() then
								surface.SetDrawColor( Color( 128, 128, 128 ) )
							else
								surface.SetDrawColor( Color( 255, 255, 255 ) )
							end
							surface.DrawOutlinedRect( 0, 0, w, h)
						end
						function sendButton:DoClick()
							if type( tonumber( btcTextBox:GetValue() ) ) != "number" then
								surface.PlaySound( "buttons/button16.wav" )
								btcTextBox:SetText( "0" )
							else
								net.Start( "STBTC2SendBitcoin" )
									net.WriteEntity( self.ent, 32 )
									net.WriteFloat( tonumber( btcTextBox:GetValue() ) )
								net.SendToServer()
								SendBTCWindow:Close()
							end
						end
						i = i+1
					end
				end
			end

			local BTCWord = vgui.Create( "DLabel", SendBTCWindow )
			BTCWord:SetPos( 245, 360 )
			BTCWord:SetFont( "BTCMed" )
			BTCWord:SetTextColor( Color( 255, 255, 255 ) )
			BTCWord:SetText( "BTC <=> $" )
			BTCWord:SizeToContents()

			local MoneyBox

			local SellBox = vgui.Create( "DTextEntry", SendBTCWindow )
			SellBox:SetPos( 15, 360 )
			SellBox:SetSize( 200, 25 )
			SellBox:SetText( "0" )
			SellBox:SetFont( "BTCMed" )
			function SellBox:OnChange()
				if type( tonumber( self:GetValue() ) ) == "number" then
					MoneyBox:SetText( math.Round( STBTC2_PRICE * self:GetValue() ) )
				end
			end

			MoneyBox = vgui.Create( "DTextEntry", SendBTCWindow )
			MoneyBox:SetPos( 385, 360 )
			MoneyBox:SetSize( 200, 25 )
			MoneyBox:SetText( "0" )
			MoneyBox:SetFont( "BTCMed" )
			function MoneyBox:OnChange()
				if type( tonumber( self:GetValue() ) ) == "number" then
					SellBox:SetText( math.Round( self:GetValue() / STBTC2_PRICE, 4 ) )
				end
			end
			self.LastNet = CurTime()
		end
	end
end

SWEP.VElements = {
	["BTCHead"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.037, 4.171, -5.939), angle = Angle(-0.124, 132.697, -88.72), size = 0.05, draw_func = function( wep )
		draw.SimpleText( "WALLET", "BTCSmall", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end},
	["phone"] = { type = "Model", model = "models/props_phx/rt_screen.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.414, 2.95, 1.118), angle = Angle(0.882, -137.377, 180), size = Vector(0.243, 0.104, 0.243), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["BTCHead+"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.037, 4.171, -2.618), angle = Angle(-0.124, 132.697, -88.72), size = 0.05, draw_func = function( wep )
		draw.SimpleText( "VALUE", "BTCSmall", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end},
	["BTCHead+++"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.258, 5.378, -7.479), angle = Angle(-0.124, 132.697, -88.72), size = 0.05, draw_func = function( wep )
		draw.SimpleText( "ST BitMiner 2.0", "BTCMini", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		--draw.SimpleText( "$" .. math.Round( STBTC2_PRICE, 4 ), "BTCSmall", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end},
	["BTCHead++"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.037, 4.171, -5.023), angle = Angle(-0.124, 132.697, -88.72), size = 0.05, draw_func = function( wep )
		draw.SimpleText( math.Round( LocalPlayer():GetBitcoin(), 4 ) .. " BTC", "BTCSmall", 0, 0, Color( 192, 192, 192 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end},
	["WalletValue"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.037, 4.171, -4.123), angle = Angle(-0.124, 132.697, -88.72), size = 0.05, draw_func = function( wep )
		draw.SimpleText( "($" .. math.floor( LocalPlayer():GetBitcoin() * STBTC2_PRICE ) .. ")", "BTCSmall", 0, 0, Color( 192, 192, 192 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end},
	["OSLabel"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.037, 4.171, -1.63), angle = Angle(-0.124, 132.697, -88.72), size = 0.05, draw_func = function( wep )
		--draw.SimpleText( "STBitMiners 2.0", "BTCSmall", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText( "$" .. math.Round( STBTC2_PRICE, 4 ), "BTCSmall", 0, 0, Color( 192, 192, 192 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end}
}

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger41"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 19.499, 0) },
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 9.909, 0) },
	["ValveBiped.Bip01_L_Finger11"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 27.784, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-4.158, 4.809, 0) },
	["Detonator"] = { scale = Vector(0.165, 0.165, 0.165), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(-2.612, -0.843, -5.224), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(-3.711, 0.354, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger12"] = { scale = Vector(0.814, 0.814, 0.814), pos = Vector(0, 0, 0), angle = Angle(0, 16.229, 0) },
	["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.WElements = {
	["phone"] = { type = "Model", model = "models/props_phx/rt_screen.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.686, 6.454, -3.007), angle = Angle(0, 180, 90), size = Vector(0.163, 0.163, 0.163), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


function SWEP:Initialize()
	self:SetHoldType( "slam" )
	// other initialize code goes here
	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end
end
function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end
function SWEP:OnRemove()
	self:Holster()
end
if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)
		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}
			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end
		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end