
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "BitMiner ST3"
ENT.Author = "SweptThrone"
ENT.Spawnable = true
ENT.AdminSpawnable = true 
ENT.Category = "STBitMining 2"
ENT.EntHealth = 50

if SERVER then

    function ENT:Initialize()
        self:SetModel("models/props_lab/reciever01a.mdl") 
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetUseType( SIMPLE_USE )
        self.runSound = CreateSound(self, Sound("ambient/levels/canals/generator_ambience_loop1.wav"))
	    self.runSound:SetSoundLevel(52)
		self.runSound:PlayEx(1, 100)
        self:SetNWFloat( "HeldBTC", 0.0 )
        local phys = self:GetPhysicsObject()
        if phys and phys:IsValid() then
            phys:Wake()
        end

        timer.Create( "BitcoinMine" .. self:EntIndex(), ST_CONFIGS[ "STBitMining2" ][ "ModelST3Delay" ], 0, function()
            self:SetNWFloat( "HeldBTC", self:GetNWFloat( "HeldBTC" ) + ST_CONFIGS[ "STBitMining2" ][ "ModelST3Value" ] )
        end )
    end

    function ENT:OnRemove()
        if self.runSound then
            self.runSound:Stop()
        end
        timer.Remove( "BitcoinMine" .. self:EntIndex() )
    end

    function ENT:Use( act, ply )
        net.Start( "STBTC2OpenMenu" )
            net.WriteInt( 3, 4 )
            net.WriteEntity( self )
        net.Send( ply )
    end
    
    
    function ENT:OnTakeDamage( dmg )
        self.EntHealth = self.EntHealth - dmg:GetDamage()
        if self.EntHealth <= 0 then self:EmitSound( "physics/metal/metal_box_break" .. math.random( 1, 2 ) .. ".wav" ) self:Remove() end
    end

end

if CLIENT then
    
    function ENT:Initialize()
    end

    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:Think()
    end 

end