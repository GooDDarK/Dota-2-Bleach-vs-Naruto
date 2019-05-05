require('timers')

--skill 0
--[[Author: Pizzalol
	Date: 24.03.2015.
	Creates the land mine and keeps track of it]]
function LandMinesPlant( keys )
	local caster = keys.caster
	local target_point = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_land_mine = keys.modifier_land_mine
	local modifier_tracker = keys.modifier_tracker
	local modifier_caster = keys.modifier_caster
	local modifier_land_mine_invisibility = keys.modifier_land_mine_invisibility

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level) 
	local max_mines = ability:GetLevelSpecialValueFor("max_mines", ability_level) 
	local fade_time = ability:GetLevelSpecialValueFor("fade_time", ability_level)

	-- Create the land mine and apply the land mine modifier
	local land_mine = CreateUnitByName("npc_dota_techies_land_mine", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine, {})
	ability:ApplyDataDrivenModifier(caster, land_mine, modifier_caster, {duration=20.0})

	land_mine:SetOriginalModel("models/items/tuskarr/sigil/boreal_sigil/boreal_sigil.vmdl")
	land_mine:SetModel("models/items/tuskarr/sigil/boreal_sigil/boreal_sigil.vmdl")
	local adjust = Vector(target_point.x, target_point.y, target_point.z + 32)
	land_mine:SetAbsOrigin(adjust)

	-- Apply the tracker after the activation time
	Timers:CreateTimer(activation_time, function()
		ability:ApplyDataDrivenModifier(caster, land_mine, modifier_tracker, {})
	end)

	-- Apply the invisibility after the fade time
	Timers:CreateTimer(fade_time, function()
		ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine_invisibility, {})
	end)
end

function LandMinesDeath( keys )
	local unit = keys.unit

	local dummy = CreateUnitByName("npc_dummy_unit", unit:GetAbsOrigin(), false, nil, nil, unit:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	local particleName = "particles/units/heroes/hero_lich/lich_frost_nova.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, dummy )
	ParticleManager:SetParticleControl( pfx, 0, dummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pfx, 1, Vector(200,200,200) )
end

--[[Author: Pizzalol
	Date: 24.03.2015.
	Tracks if any enemy units are within the mine radius]]
function LandMinesTracker( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local trigger_radius = ability:GetLevelSpecialValueFor("small_radius", ability_level)

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, trigger_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		if target:IsAlive() then
			target:ForceKill(true) 
		end
	end
end

function LandMinesForceKill(keys)
	local target = keys.target
	if target:IsAlive() then
		target:ForceKill(true) 
	end
end

--skill 1
--[[
	Author: Ractidous
	Date: 26.01.2015.
	Create the particle effect.
]]
function FireEffect_IcePath( event )
	local caster		= event.caster
	local ability		= event.ability
	local pathLength	= ability:GetCastRange()
	local pathDelay		= event.path_delay
	local pathDuration	= event.duration
	local pathRadius	= event.path_radius

	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * pathLength

	ability.ice_path_stunStart	= GameRules:GetGameTime() + pathDelay
	ability.ice_path_stunEnd	= GameRules:GetGameTime() + pathDelay + pathDuration

	ability.ice_path_startPos	= startPos * 1
	ability.ice_path_endPos		= endPos * 1

	ability.ice_path_startPos.z = 0
	ability.ice_path_endPos.z = 0

	-- Create ice_path
	local particleName = "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, startPos )

	ability.pfxIcePath = pfx

	-- Create ice_path_b
	particleName = "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( pathDelay + pathDuration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 9, startPos )

	-- Generate projectiles
	if pathRadius < 32 then
		print( "Set the proper value of path_radius in ice_path_datadriven." )
		return
	end

	local projectileRadius = pathRadius * math.sqrt(2)
	local numProjectiles = math.floor( pathLength / (pathRadius*2) ) + 1
	local stepLength = pathLength / ( numProjectiles - 1 )

	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * (i-1) * stepLength

		ProjectileManager:CreateLinearProjectile( {
			Ability				= ability,
			EffectName			= "",
			vSpawnOrigin		= projectilePos,
			fDistance			= 64,
			fStartRadius		= projectileRadius,
			fEndRadius			= projectileRadius,
			Source				= caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			fExpireTime			= ability.ice_path_stunEnd,
			bDeleteOnHit		= false,
			vVelocity			= Vector( 0, 0, 0 ),	-- Don't move!
			bProvidesVision		= true,
			iVisionRadius		= 150,
			iVisionTeamNumber	= caster:GetTeamNumber(),
		} )
	end
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Destroy ice_path manually in order to show its endcap effects.
]]
function FireEffect_Destroy_IcePath_A( event )
	local caster		= event.caster
	local ability		= event.ability
	local pfxIcePath	= ability.pfxIcePath

	ParticleManager:DestroyParticle( pfxIcePath, false )

	ability.pfxIcePath = nil
end

--[[
	Author: Ractidous
	Data: 27.01.2015.
	Apply a dummy modifier that periodcally checks whether the target is within the ice path.
]]
function ApplyDummyModifier( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local modifierName = event.modifier_name

	local duration = ability.ice_path_stunEnd - GameRules:GetGameTime()

	ability:ApplyDataDrivenModifier( caster, target, modifierName, { duration = duration } )
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Check whether the target is within the ice path, and apply stun and damage if neccesary.
]]
function CheckIcePath( event )
	local caster		= event.caster
	local target		= event.target
	local ability		= event.ability
	local pathRadius	= event.path_radius

	local stunModifierName	= "modifier_ice_path_stun_datadriven"

	if GameRules:GetGameTime() < ability.ice_path_stunStart then
		-- Not yet.
		return
	end

	if target:HasModifier( stunModifierName ) then
		-- Already stunned.
		return
	end

	local targetPos = target:GetAbsOrigin()
	targetPos.z = 0

	local distance = DistancePointSegment( targetPos, ability.ice_path_startPos, ability.ice_path_endPos )
	if distance < pathRadius then
		local duration = ability.ice_path_stunEnd - GameRules:GetGameTime()
		ability:ApplyDataDrivenModifier( caster, target, stunModifierName, { duration = duration } )
	end
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Distance between a point and a segment.
]]
function DistancePointSegment( p, v, w )
	local l = w - v
	local l2 = l:Dot( l )
	t = ( p - v ):Dot( w - v ) / l2
	if t < 0.0 then
		return ( v - p ):Length2D()
	elseif t > 1.0 then
		return ( w - p ):Length2D()
	else
		local proj = v + t * l
		return ( proj - p ):Length2D()
	end
end

--skill 3
function bvo_aokiji_skill_3(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dur = keys.duration

	local dummy = CreateUnitByName("npc_dummy_unit", target:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_aokiji_skill_3_aura_modifier", {duration=dur} )
end

function bvo_aokiji_skill_3_end(keys)
	local target = keys.target
	target:RemoveSelf()
end

function bvo_aokiji_skill_3_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = (damage + 5 * caster:GetLevel()) / 2,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
	--
	target:EmitSound("Hero_Ancient_Apparition.ColdFeetTick")
end

function bvo_aokiji_skill_5_cast(keys)
	local caster = keys.caster
	local multi = keys.multi
	local ability = keys.ability
	ability.hitUnits = {}
	--ability.ringDummys = {}

	local wave = 0
	Timers:CreateTimer(0.12, function()
		if wave < 5 then
			wave = wave + 1
			local radius = wave * 340
			localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			            caster:GetAbsOrigin(),
			            nil,
			            radius,
			            DOTA_UNIT_TARGET_TEAM_ENEMY,
			            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			            DOTA_UNIT_TARGET_FLAG_NONE,
			            FIND_ANY_ORDER,
			            false)

			--particle dummy
			caster:EmitSound("Hero_Ancient_Apparition.IceBlast.Target")
			local shards = 8 * wave
			for i = 1, shards do
				local point_projectile = caster:GetAbsOrigin() + Vector(radius, 0, 0)
				local rotation = QAngle( 0, i * (360 / shards), 0 )
				local rot_vector = RotatePosition(caster:GetAbsOrigin(), rotation, point_projectile)
				local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, nil, nil, caster:GetTeam())
				dummy.angle = i * (360 / shards)
				dummy:AddAbility("custom_point_dummy")
				local abl = dummy:FindAbilityByName("custom_point_dummy")
				if abl ~= nil then abl:SetLevel(1) end
				dummy:SetModel("models/heroes/crystal_maiden/crystal_maiden_ice.vmdl")
				dummy:SetOriginalModel("models/heroes/crystal_maiden/crystal_maiden_ice.vmdl")
				dummy:SetModelScale(10.0)
				local vec_up = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z - 60)
				dummy:SetAbsOrigin(vec_up)
				ability:ApplyDataDrivenModifier(caster, dummy, "bvo_aokiji_skill_5_dummy_modifier", {duration=6.0} )
				--table.insert(ability.ringDummys, dummy)
			end
			--
			for _,target in pairs(localUnits) do
				local flag = false
				for _,hit in pairs(ability.hitUnits) do
					if target == hit then flag = true end
				end
				if not flag then
					local damageTable = {
						victim = target,
						attacker = caster,
						damage = 2000 + multi * caster:GetLevel(),
						damage_type = DAMAGE_TYPE_PHYSICAL,
					}
					ApplyDamage(damageTable)
					ability:ApplyDataDrivenModifier(caster, target, "bvo_aokiji_skill_5_freeze_modifier", {duration=4.0} )
					table.insert(ability.hitUnits, target)
				end
			end
			return 0.12
		else
			return nil
		end
	end)
end

function bvo_aokiji_skill_5_dummy(keys)
	local caster = keys.target

	local vec_up = Vector( caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z - 10)
	caster:SetAbsOrigin(vec_up)
end

function bvo_aokiji_skill_5_dummy_end(keys)
	local caster = keys.target
	caster:RemoveSelf()
end