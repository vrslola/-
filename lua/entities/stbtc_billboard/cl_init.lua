include('shared.lua')

surface.CreateFont( "BTCHeaderFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 100,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = false,
} )

surface.CreateFont( "BTCValueFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 128,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = false,
} )

function ENT:Draw()

	self:DrawModel()
	--print(self:GetNWInt("multiplication"))
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
		
	local txt = "Current Bitcoin Value"
	
	surface.SetFont("BTCHeaderFont")
	local TextWidth = surface.GetTextSize(txt)
	surface.SetFont("BTCValueFont")
	local TextWidth2 = surface.GetTextSize("$" .. STBTC2_PRICE)
	
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 270)
		
	cam.Start3D2D(Pos + Ang:Up() - Ang:Right() * 15, Ang, 0.16)
		surface.SetDrawColor( 0, 0, 0 )
		surface.DrawRect( -691, -267, 1390, 720 )
		surface.SetDrawColor( 246, 149, 32 )
		surface.DrawRect( -691, -267, 1390, 135 )
		draw.SimpleText(txt, "BTCHeaderFont", -TextWidth*0.5, -245, Color(255,255,255))
		draw.SimpleText("$" .. string.Comma( STBTC2_PRICE ), "BTCValueFont", -TextWidth2*0.5, 75, Color(255,255,255))
	cam.End3D2D()

end

function ENT:Think()

end
