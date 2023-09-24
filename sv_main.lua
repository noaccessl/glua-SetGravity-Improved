--[[---------------------------------------------------------------------------
	Predefines
---------------------------------------------------------------------------]]
local _R = debug.getregistry()

local ENTITY = _R.Entity
local GetPhysicsObject = ENTITY.GetPhysicsObject
local GetPhysicsObjectNum = ENTITY.GetPhysicsObjectNum

local VECTOR = _R.Vector
local MulVector = VECTOR.Mul

local PHYSOBJ = _R.PhysObj

local IsValid = PHYSOBJ.IsValid
local IsMoveable = PHYSOBJ.IsMoveable
local IsMotionEnabled = PHYSOBJ.IsMotionEnabled
local IsGravityEnabled = PHYSOBJ.IsGravityEnabled
local EnableGravity = PHYSOBJ.EnableGravity
local GetMass = PHYSOBJ.GetMass
local ApplyForceCenter = PHYSOBJ.ApplyForceCenter

local GetWorldGravity = physenv.GetGravity
local GetTickInterval = engine.TickInterval

ENTITY.SetGravityInternal = ENTITY.SetGravityInternal or ENTITY.SetGravity


--[[---------------------------------------------------------------------------
	SetGravity
---------------------------------------------------------------------------]]
function ENTITY:SetGravity( flGravityMultiplier )

	if self:IsWorld() then
		return
	end

	if self:IsPlayer() then
		return self:SetGravityInternal( flGravityMultiplier )
	end

	local numObjects = self:GetPhysicsObjectCount()

	if numObjects > 1 then

		hook.Add( 'Tick', self, function( ent )

			if flGravityMultiplier == 1 then

				for i = 0, numObjects - 1 do

					local phys = GetPhysicsObjectNum( ent, i )

					if phys then
						EnableGravity( phys, true )
					end

				end

				hook.Remove( 'Tick', ent )

				return

			end

			for i = 0, numObjects - 1 do

				local phys = GetPhysicsObjectNum( ent, i )

				if not phys then

					hook.Remove( 'Tick', ent )
					break

				end

				if not IsMotionEnabled( phys ) then
					continue
				end

				if IsGravityEnabled( phys ) then
					EnableGravity( phys, false )
				end

				if flGravityMultiplier == 0 then
					continue
				end

				local vecGravity = GetWorldGravity()
				MulVector( vecGravity, flGravityMultiplier * GetTickInterval() * GetMass( phys ) )

				ApplyForceCenter( phys, vecGravity )

			end

		end )

		return

	end

	hook.Add( 'Tick', self, function( ent )

		local phys = GetPhysicsObject( ent )

		if not IsValid( phys ) or not IsMoveable( phys ) then
			return hook.Remove( 'Tick', ent )
		end

		if flGravityMultiplier == 1 then

			EnableGravity( phys, true )
			hook.Remove( 'Tick', ent )

			return

		end

		if not IsMotionEnabled( phys ) then
			return
		end

		if IsGravityEnabled( phys ) then
			EnableGravity( phys, false )
		end

		if flGravityMultiplier == 0 then
			return
		end

		local vecGravity = GetWorldGravity()
		MulVector( vecGravity, flGravityMultiplier * GetTickInterval() * GetMass( phys ) )

		ApplyForceCenter( phys, vecGravity )

	end )

end
