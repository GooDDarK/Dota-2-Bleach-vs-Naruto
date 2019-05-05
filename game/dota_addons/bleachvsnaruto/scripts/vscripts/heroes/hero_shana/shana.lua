
LinkLuaModifier( "modifier_movespeed_cap_low", "libraries/modifiers/modifier_movespeed_cap_low.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Renders the fissure particle and applies all the instant aoe effects around the fissure]]
function CreateFissure(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local fissure_range = ability:GetLevelSpecialValueFor("fissure_range", (ability:GetLevel() -1))
	local fissure_radius = ability:GetLevelSpecialValueFor("fissure_radius", (ability:GetLevel() -1))
	local fissure_duration = ability:GetLevelSpecialValueFor("fissure_duration", (ability:GetLevel() -1))
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	local width = ability:GetLevelSpecialValueFor("width", (ability:GetLevel() -1))
	local offset = ability:GetLevelSpecialValueFor("offset", (ability:GetLevel() -1))
	
	-- Position and direction variables
	local direction = caster:GetForwardVector()
	local startPos = caster:GetAbsOrigin() + direction * offset
	local endPos = caster:GetAbsOrigin() + direction * fissure_range
	
	-- Renders the fissure particle in a line
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, startPos)
	ParticleManager:SetParticleControl(particle, 1, endPos)
	ParticleManager:SetParticleControl(particle, 2, Vector(fissure_duration, 0, 0 ))
	
	-- Units to be moved by the fissure
	local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	
	-- Loops through targets
	for i,unit in ipairs(units) do
		-- Does not move the caster
		if unit ~= caster then
			-- The target's distance and direction from the front of the fissure
			local target_vector_distance = unit:GetAbsOrigin() - startPos
			local target_distance = (target_vector_distance):Length2D()
			local target_direction = (target_vector_distance):Normalized()
		
			-- Get the target's angle in relation to the front of the fissure
			local target_angle_radian = math.atan2(target_direction.y, target_direction.x)
			
			-- Gets the direction of the fissure in the world
			local fissure_angle_radian = math.atan2(direction.y, direction.x)
		
			-- Gets the distance from the front of the fissure to the point on the fissure perpendicular to the target
			local perpen_distance = math.abs(math.cos(fissure_angle_radian - target_angle_radian)) * target_distance
			
			-- Gets the position of the the perpendicular point
			local perpen_position = startPos + perpen_distance * direction
		
			-- Gets the distance and direction the target will move
			local motion_vector_distance = unit:GetAbsOrigin() - perpen_position
			local motion_distance = width
			local motion_direction = (motion_vector_distance):Normalized()
		
			-- Moves the target
			unit:SetAbsOrigin(unit:GetAbsOrigin() + motion_distance * motion_direction)
		end
	end
	
	-- Units to be stunned and damaged by the fissure
	units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, fissure_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	
	-- Loops through the targets
	for j,unit in ipairs(units) do
		-- Applies the stun modifier to the target
		unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
		-- Applies the damage to the target
		ApplyDamage({victim = unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
	end
	
	ability.startPos = startPos
	ability.endPos = endPos
	ability.direction = direction
end

function getattacker(keys)
	local attacker = keys.attacker

	print(attacker:GetUnitName())

end



--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Checks if the target is facing against the fissure and applies an extreme slowing modifier if it is]]
function CheckPosition(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("fissure_range", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("fissure_duration", ability:GetLevel() -1)
	local width = ability:GetLevelSpecialValueFor("width", ability:GetLevel() -1)
	
	-- Gets the direction variable
	local direction = ability.direction
	
	-- Sets a buffer around the front and the back of the fissure
	local startPos = ability.startPos - direction * 20
	local endPos = ability.endPos + direction * 20
	
	-- Units within range of the fissure block
	local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, width + 20, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	
	-- Loops through the targets
	for i,unit in ipairs(units) do
		-- Ensures calculations are only done once per unit
		if target == unit then
			-- The target's distance and direction from the front of the fissure
			local target_vector_distance = target:GetAbsOrigin() - ability.startPos
			local target_distance = (target_vector_distance):Length2D()
			local target_direction = (target_vector_distance):Normalized()
	
			-- Get the target's angle in relation to the front of the fissure
			local target_angle_radian = math.atan2(target_direction.y, target_direction.x)
			
			-- Converts to degrees (0-360)
			local target_angle_from_fissure = math.deg(target_angle_radian) + 180
		
			-- Get's the direction of the fissure in the world
			local fissure_angle_radian = math.atan2(direction.y, direction.x)
			
			-- Converts to degrees (0-360)
			local fissure_angle = math.deg(fissure_angle_radian) + 180
			
			-- Gets the distance from the front of the fissure to the point on the fissure perpendicular to the target
			local perpen_distance = math.abs(math.sin(fissure_angle_radian - target_angle_radian)) * target_distance
	
			-- The angle the target's facing in the world
			local target_angle = target:GetAnglesAsVector().y
			
			-- Checks if the target is on the right of the fissure (from the front perspective), less than 20 units from it, and facing it (within 90 degrees)
			if (target_angle_from_fissure - fissure_angle) < 0 and perpen_distance <= width + 20 and ((target_angle - fissure_angle < 0 and target_angle - fissure_angle > -180) or (target_angle - fissure_angle > 180)) then
				-- Removes the movespeed minimum
				if target:HasModifier("modifier_movespeed_cap_low") == false then
					target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
				end
				-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fissure_block",{})
			-- Checks if the target is on the left of the fissure, less than 20 units from it, and facing it (within 90 degrees)
			elseif (target_angle_from_fissure - fissure_angle) > 0 and perpen_distance <= width + 20 and ((target_angle - fissure_angle > 0 and target_angle - fissure_angle < 180) or (target_angle - fissure_angle < -180)) then
				-- Removes the movespeed minimum
				if target:HasModifier("modifier_movespeed_cap_low") == false then
					target:AddNewModifier(caster, nil, "modifier_movespeed_cap_low", {Duration = duration})
				end
				-- Slows the target to 0.1 movespeed (equivalent to an invisible wall)
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fissure_block",{})
			else
				-- Removes the slowing debuffs, so the unit can move freely
				if target:HasModifier("modifier_fissure_block") then
					target:RemoveModifierByName("modifier_fissure_block")
					target:RemoveModifierByName("modifier_movespeed_cap_low")
				end
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Ensures no units still have the slow modifiers when the fissure is gone]]
function RemoveModifiers(keys)
	local target = keys.target

	target:RemoveModifierByName("modifier_fissure_block")
	target:RemoveModifierByName("modifier_movespeed_cap_low")
end
function StopSound( event )
	local target = event.target
	target:StopSound("Hero_ShadowShaman.Shackles")
end

function IncreaseStackCount( event )
    -- Variables
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
	local ability_level = ability:GetLevel() - 1
    local dur = ability:GetLevelSpecialValueFor("Duration", (ability:GetLevel() - 1))

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)
	local modifierCount = caster:GetModifierCount()
	local maxStack = ability:GetLevelSpecialValueFor("shana_fire", (ability:GetLevel() - 1))
	local currentStack = 0
	local modifierBuffName = "modifier_shana"
	local modifierStackName = "modifier_shana_count"
	local modifierName

    -- Always remove the stack modifier
	target:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		target:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, target, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		target:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, target, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		target:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, target, modifierBuffName, {})
		end
	end
end



function modifier_flamefly_mana_cost(keys)
local  caster = keys.caster
local  ability = keys.ability
local mana_cost = keys.ManaCostPerSecond
local modfier = keys.modfier
-- local modifier_flamewing = keys.modifier_flamewing
if not caster:HasModifier(modfier) then
	if caster:GetMana() >= mana_cost then
	caster:SpendMana(mana_cost, ability)
	else
	ability:ToggleAbility()
end

else
print("has talent")
end

end

function neverdie(keys)
local  caster = keys.caster
local  ability = keys.ability
local modfier = keys.modfier
-- local modifier_flamewing = keys.modifier_flamewing
if caster:HasModifier(modfier) then
ability:ApplyDataDrivenModifier(caster, caster, "modifier_brakesky_3", {})
end

end

function Alastor(keys)
local  caster = keys.caster
local  ability = keys.ability
local modfier = keys.modfier
local player = caster:GetPlayerID()
local origin = caster:GetAbsOrigin()
local unit_name = keys.unit_name

local ability_level = ability:GetLevel() - 1
local alastortime = ability:GetLevelSpecialValueFor("alastortime", ability_level)
caster.shana_Alastor = nil
-- local modifier_flamewing = keys.modifier_flamewing
if caster:HasModifier(modfier) then
caster:EmitSound("Hero_Gyrocopter.CallDown.Damage")
    caster.shana_Alastor = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    caster.shana_Alastor:SetOwner(caster)
	caster.shana_Alastor:SetControllableByPlayer(player, true)
	caster.shana_Alastor:AddNewModifier(caster, ability, "modifier_kill", {duration = alastortime})
end

end

function Alastordie(keys)
local  caster = keys.caster
local  ability = keys.ability
-- local modifier_flamewing = keys.modifier_flamewing
if caster.shana_Alastor ~= nil then
caster.shana_Alastor:RemoveSelf()
end
print("alastor die")
end

function shana_died(keys)
	if keys.ability:GetToggleState() == true then
		keys.ability:ToggleAbility()
	end
end




function conviction_target( keys )
	keys.caster.conviction_target = keys.target
end

function level_judgment( keys )

  local conviction = keys.caster:FindAbilityByName("conviction_datadriven")
	local judgment_level = keys.ability:GetLevel()
	
	if conviction ~= nil and conviction:GetLevel() ~= judgment_level then
		conviction:SetLevel(judgment)
end

end

function level_conviction( keys )

  local judgment = keys.caster:FindAbilityByName("judgment_datadriven")
	local conviction_level = keys.ability:GetLevel()
	
	if judgment ~= nil and judgment:GetLevel() ~= conviction_level then
		judgment:SetLevel(conviction)
end

end

function truered( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ability_level = ability:GetLevel() - 1
	local redtruelevel = ability:GetLevelSpecialValueFor("redtruelevel", ability_level)
	local flamewing = "flamewing"
	local shana_empty_1 = "shana_empty_1"
	local alasterhand = "alasterhand"
	local shanatruered = "shanatruered"
	local ability_name_1 = keys.ability_name_1
	local ability_name_2 = keys.ability_name_2
	local ability_name_3 = keys.ability_name_3
	local ability_name_4 = keys.ability_name_4
	local ability_name_5 = keys.ability_name_5
	local ability_handle_1 = caster:FindAbilityByName(ability_name_1)	
	local ability_handle_2 = caster:FindAbilityByName(ability_name_2)	
	local ability_handle_3 = caster:FindAbilityByName(ability_name_3)	
	local ability_handle_4 = caster:FindAbilityByName(ability_name_4)	
	local ability_handle_5 = caster:FindAbilityByName(ability_name_5)	
	local maxStack = ability:GetLevelSpecialValueFor("shana_truered", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_truered"
	local modifierStackName = "modifier_truered_count"
	local modifierName
	local one = 1

	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	end
	local up_level = ability_level + 1
	if redtruelevel >= 1 then
		local flamewing_handle = caster:FindAbilityByName(flamewing)
		flamewing_handle:SetLevel(up_level)
		if redtruelevel == 2 then
		caster:SwapAbilities(alasterhand, keys.ability:GetAbilityName(), true, false) 
		local ability_handle = caster:FindAbilityByName(alasterhand)
		ability_handle:SetLevel(2)
		end
end


end
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	--local ability_name2 = event.ability_name2
	--local ability_name3 = event.ability_name3
	local ability_handle = caster:FindAbilityByName(ability_name)	
	--local ability_handle2 = caster:FindAbilityByName(ability_name2)	
	--local ability_handle3 = caster:FindAbilityByName(ability_name3)	
	local ability_level = ability_handle:GetLevel()
	--local ability_level2 = ability_handle2:GetLevel()
	--local ability_level3 = ability_handle3:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end

	--if ability_level2 ~= this_abilityLevel then
		--ability_handle2:SetLevel(this_abilityLevel)
	--end

	--if ability_level3 ~= this_abilityLevel then
		--ability_handle3:SetLevel(this_abilityLevel)
	--end
end
function truered2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ability_level = ability:GetLevel() - 1
	local redtruelevelup = ability:GetLevelSpecialValueFor("redtruelevelup", ability_level)
	local flyflame = "flyflame"
	local judgment = "judgment"
	local Conviction = "Conviction"
	local stop = "phoenix_sun_ray_stop_datadriven"
	
	local maxStack = ability:GetLevelSpecialValueFor("shana_truered", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_truered"
	local modifierStackName = "modifier_truered_count"
	local modifierName

	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	end
	local up_level = ability_level + 1
	if redtruelevelup == 1 then
		local flyflame_handle = caster:FindAbilityByName(flyflame)
		flyflame_handle:SetLevel(up_level)
		local judgment_handle = caster:FindAbilityByName(judgment)
		judgment_handle:SetLevel(up_level)
		local Conviction_handle = caster:FindAbilityByName(Conviction)
		Conviction_handle:SetLevel(up_level)
		local stop_handle = caster:FindAbilityByName(stop)
		stop_handle:SetLevel(up_level)
end

end

function AssassinateCast( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_shrapnel = keys.modifier_shrapnel
	local modifier_target = keys.modifier_target
	local modifier_caster = keys.modifier_caster
	local modifier_cast_check = keys.modifier_cast_check

	-- Parameters
	local regular_range = ability:GetLevelSpecialValueFor("regular_range", ability_level)
	local cast_distance = ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()

	-- Check if the target can be assassinated, if not, stop casting and move closer
	if cast_distance > regular_range and not target:HasModifier(modifier_judgment_rage) then

		-- Start moving
		caster:MoveToPosition(target:GetAbsOrigin())
		Timers:CreateTimer(0.1, function()

			-- Update distance between caster and target
			cast_distance = ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()

			-- If it's not a legal cast situation and no other order was given, keep moving
			if cast_distance > regular_range and not target:HasModifier(modifier_judgment_rage) and not caster.stop_assassinate_cast then
				return 0.1

			-- If another order was given, stop tracking the cast distance
			elseif caster.stop_assassinate_cast then
				caster:RemoveModifierByName(modifier_cast_check)
				caster.stop_assassinate_cast = nil

			-- If all conditions are met, cast Assassinate again
			else
				caster:CastAbilityOnTarget(target, ability, caster:GetPlayerID())
			end
		end)
		return nil
	end

	-- Play the pre-cast sound
	caster:EmitSound("Ability.AssassinateLoad")

	-- Mark the target with the crosshair
	ability:ApplyDataDrivenModifier(caster, target, modifier_target, {})

	-- Apply the caster modifiers
	ability:ApplyDataDrivenModifier(caster, caster, modifier_caster, {})
	caster:RemoveModifierByName(modifier_cast_check)

	-- Memorize the target
	caster.assassinate_target = target
end

function AssassinateCastCheck( keys )
	local caster = keys.caster
	caster.stop_assassinate_cast = true
end

function AssassinateStop( keys )
	local caster = keys.caster
	local target_modifier = keys.target_modifier
	caster.assassinate_target:RemoveModifierByName(target_modifier)
	caster.assassinate_target = nil
end

function AssassinateParticleStart( keys )
	local caster = keys.caster
	local target = keys.target
	local particle_debuff = keys.particle_debuff
	
	-- Create the crosshair particle
	target.assassinate_crosshair_pfx = ParticleManager:CreateParticleForTeam(particle_debuff, PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeam())
	ParticleManager:SetParticleControl(target.assassinate_crosshair_pfx, 0, target:GetAbsOrigin())
end

function AssassinateParticleEnd( keys )
	local target = keys.target
	
	-- Destroy the crosshair particle
	ParticleManager:DestroyParticle(target.assassinate_crosshair_pfx, true)
	ParticleManager:ReleaseParticleIndex(target.assassinate_crosshair_pfx)
	target.assassinate_crosshair_pfx = nil
end

function Assassinate( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Parameters
	local bullet_duration = ability:GetLevelSpecialValueFor("projectile_travel_time", ability_level)
	local spill_range = ability:GetLevelSpecialValueFor("spill_range", ability_level)
	local bullet_radius = ability:GetLevelSpecialValueFor("aoe_size", ability_level)
	local bullet_direction = ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized()
	bullet_direction = Vector(bullet_direction.x, bullet_direction.y, 0)
	local bullet_distance = ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D() + spill_range
	local bullet_speed = bullet_distance / bullet_duration

	-- Create the real, invisible projectile
	local assassinate_projectile = {
		Ability				= ability,
		EffectName			= "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_explode_b_b_ti_5_gold.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= bullet_distance,
		fStartRadius		= bullet_radius,
		fEndRadius			= bullet_radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
	--	fExpireTime			= ,
		bDeleteOnHit		= false,
		vVelocity			= bullet_direction * bullet_speed,
		bProvidesVision		= false,
	--	iVisionRadius		= ,
	--	iVisionTeamNumber	= caster:GetTeamNumber(),
	}

	ProjectileManager:CreateLinearProjectile(assassinate_projectile)

	-- Create the fake, visible projectile
	assassinate_projectile = {
		Target = target,
		Source = caster,
		Ability = nil,	
		EffectName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_explode_b_b_ti_5_gold.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit = true,
		iMoveSpeed = bullet_speed,
		bProvidesVision = false,
		bDodgeable = true,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}

	ProjectileManager:CreateTrackingProjectile(assassinate_projectile)
end

function AssassinateHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_slow = keys.modifier_slow

	-- Parameters
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	

	-- Play sound
	target:EmitSound("Hero_Sniper.AssassinateDamage")

	-- Scepter damage and debuff


	-- Apply damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Grant short-lived vision
	ability:CreateVisibilityNode(target:GetAbsOrigin(), 500, 1.0)

	-- Ministun
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = 0.1})

	-- Fire particle
	local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
end

function DoHealthCost( event )
    -- Variables
    local caster = event.caster
    local ability = event.ability
    local health_cost = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
    local health = caster:GetHealth()
    local new_health = (health - health_cost)

    -- "do damage"
    -- aka set the casters HP to the new value
    -- ModifyHealth's third parameter lets us decide if the healthcost should be lethal
    caster:ModifyHealth(new_health, ability, false, 0)
end
function WhirlingAxesRanged( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local axe_width = ability:GetLevelSpecialValueFor("axe_width", ability_level) 
	local axe_speed = ability:GetLevelSpecialValueFor("axe_speed", ability_level) 
	local axe_range = ability:GetLevelSpecialValueFor("axe_range", ability_level) 
	local axe_spread = ability:GetLevelSpecialValueFor("axe_spread", ability_level) 
	local axe_count = ability:GetLevelSpecialValueFor("axe_count", ability_level)
	local fly_flame = keys.fly_flame
	caster.whirling_axes_ranged_hit_table = {}

	-- Vision
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)

	-- Initial angle calculation
	local angle = axe_spread / axe_count -- The angle between the axes
	local direction = (target_point - caster_location):Normalized()
	local axe_angle_count = math.floor(axe_count / 2) -- Number of axes for each direction
	local angle_left = QAngle(0, angle, 0) -- Rotation angle to the left
	local angle_right = QAngle(0, -angle, 0) -- Rotation angle to the right

	-- Check if its an uneven number of axes
	-- If it is then create the middle axe
if axe_count % 2 ~= 0 then
		local projectileTable =
		{
			EffectName = fly_flame,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end

	local new_angle = QAngle(0,0,0) -- Rotation angle

	-- Create axes that spread to the right
	for i = 1, axe_angle_count do
		-- Angle calculation		
		new_angle.y = angle_right.y * i

		-- Calculate the new position after applying the angle and then get the direction of it			
		local position = RotatePosition(caster_location, new_angle, target_point)	
		local position_direction = (position - caster_location):Normalized()

		-- Create the axe projectile
		local projectileTable =
		{
			EffectName = fly_flame,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = position_direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end

	-- Create axes that spread to the left
	for i = 1, axe_angle_count do
		-- Angle calculation
		new_angle.y = angle_left.y * i

		-- Calculate the new position after applying the angle and then get the direction of it	
		local position = RotatePosition(caster_location, new_angle, target_point)	
		local position_direction = (position - caster_location):Normalized()

		-- Create the axe projectile
		local projectileTable =
		{
			EffectName = fly_flame,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = position_direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end


--[[Author: Pizzalol
	Date: 18.03.2015.
	Checks if the target has been hit before and then does logic according to that]]
function WhirlingAxesRangedHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound = keys.sound

	local axe_damage = ability:GetLevelSpecialValueFor("axe_damage", ability_level)

	-- Check if the target has been hit before
	local hit_check = false

	for _,unit in ipairs(caster.whirling_axes_ranged_hit_table) do
		if unit == target then
			hit_check = true
			break
		end
	end

	-- If the target hasnt been hit before then insert it into the hit table to keep track of it
	if not hit_check then
		table.insert(caster.whirling_axes_ranged_hit_table, target)

		-- Play the sound
		EmitSoundOn(sound, target)

		-- Initialize the damage table and deal damage to the target
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = axe_damage

		ApplyDamage(damage_table)
	end
end

function bsdamge(keys)

  local caster = keys.caster
  local target = keys.target
  local ability = keys.ability
  local ability_level = ability:GetLevel() - 1
  local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

  local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage

		ApplyDamage(damage_table)

		end
--[[
	Author: Ractidous
	Date: 28.01.2015.
	Cast Sun Ray
]]
function CastSunRay( event )

	local caster	= event.caster
	local ability	= event.ability
    local this_abilityLevel = ability:GetLevel()
	local pathLength					= event.path_length
	local numThinkers					= event.num_thinkers
	local thinkerStep					= event.thinker_step
	local thinkerRadius					= event.thinker_radius
	local forwardMoveSpeed				= event.forward_move_speed
	local turnRateInitial				= event.turn_rate_initial
	local turnRate						= event.turn_rate
	local initialTurnDuration			= event.initial_turn_max_duration
	local modifierCasterName			= event.modifier_caster_name
	local modifierThinkerName			= event.modifier_thinker_name
	local modifierIgnoreTurnRateName	= event.modifier_ignore_turn_rate_limit_name
		

	local casterOrigin	= caster:GetAbsOrigin()

	caster.sun_ray_is_moving = false
	caster.sun_ray_hp_at_start = caster:GetHealth()

	-- Create thinkers
	local vThinkers = {}
	for i=1, numThinkers do
		local thinker = CreateUnitByName( "npc_dota_invisible_vision_source", casterOrigin, false, caster, caster, caster:GetTeam() )
		vThinkers[i] = thinker

		thinker:SetDayTimeVisionRange( thinkerRadius )
		thinker:SetNightTimeVisionRange( thinkerRadius )

		ability:ApplyDataDrivenModifier( caster, thinker, modifierThinkerName, {} )
	end

	local endcap = vThinkers[numThinkers]

	-- Create particle FX
	local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )

	-- Attach a loop sound to the endcap
	local endcapSoundName = "Hero_Phoenix.SunRay.Beam"
	StartSoundEvent( endcapSoundName, endcap )

	-- Swap sub ability
	local main_ability_name	= ability:GetAbilityName()
	local sub_ability_name	= event.sub_ability_name
	local covearth	= event.toggle_move_empty_ability_name
	local ability_handle = caster:FindAbilityByName(covearth)
	-- local covsky	= event.toggle_move_ability_name

	local modifier_flamewing = event.modifier_flamewing

	if caster:HasItemInInventory("item_radiance") then
	--	if caster:HasModifier(modifier_flamewing) then
		caster:SwapAbilities( main_ability_name, covearth, false, true )
		ability_handle:SetLevel(this_abilityLevel)
	-- else
        -- caster:SwapAbilities( main_ability_name, covsky, false, true )
		-- end
	 else
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
	-- print(ability:GetAbilityName())
	 end
	
	


	--
	-- Note: The turn speed
	--
	--  Original's actual turn speed = 277.7735 (at initial) and 22.2218 [deg/s].
	--  We can achieve this weird value by using this formula.
	--	  actual_turn_rate = turn_rate / (0.0333..) * 0.03
	--
	--  And, initial turn buff ends when the delta yaw gets 0 or 0.75 seconds elapsed.
	--
	turnRateInitial	= turnRateInitial	/ (1/30) * 0.03
	turnRate		= turnRate			/ (1/30) * 0.03

	-- Update
	local deltaTime = 0.03

	local lastAngles = caster:GetAngles()
	local isInitialTurn = true
	local elapsedTime = 0.0

	caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )

		-- OnInterrupted :
		--  Destroy FXs and the thinkers.
		if not caster:HasModifier( modifierCasterName ) then
			ParticleManager:DestroyParticle( pfx, false )
			StopSoundEvent( endcapSoundName, endcap )

			for i=1, numThinkers do
				vThinkers[i]:RemoveSelf()
			end

			return nil
		end

		--
		-- "MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE" is seems to be broken.
		-- So here we fix the yaw angle manually in order to clamp the turn speed.
		--
		-- If the hero has "modifier_ignore_turn_rate_limit_datadriven" modifier,
		-- we shouldn't change yaw from here.
		--

		-- Calculate the turn speed limit.
		local deltaYawMax
		if isInitialTurn then
			deltaYawMax = turnRateInitial * deltaTime
		else
			deltaYawMax = turnRate * deltaTime
		end

		-- Calculate the delta yaw
		local currentAngles	= caster:GetAngles()
		local deltaYaw		= RotationDelta( lastAngles, currentAngles ).y
		local deltaYawAbs	= math.abs( deltaYaw )

		if deltaYawAbs > deltaYawMax and not caster:HasModifier( modifierIgnoreTurnRateName ) then
			-- Clamp delta yaw
			local yawSign = (deltaYaw < 0) and -1 or 1
			local yaw = lastAngles.y + deltaYawMax * yawSign

			currentAngles.y = yaw	-- Never forget!

			-- Update the yaw
			caster:SetAngles( currentAngles.x, currentAngles.y, currentAngles.z )
		end

		lastAngles = currentAngles

		-- Update the turning state.
		elapsedTime = elapsedTime + deltaTime

		if isInitialTurn then
			if deltaYawAbs == 0 then
				isInitialTurn = false
			end
			if elapsedTime >= initialTurnDuration then
				isInitialTurn = false
			end
		end

		-- Current position & direction
		local casterOrigin	= caster:GetAbsOrigin()
		local casterForward	= caster:GetForwardVector()

		-- Move forward
		if caster.sun_ray_is_moving then
			casterOrigin = casterOrigin + casterForward * forwardMoveSpeed * deltaTime
			casterOrigin = GetGroundPosition( casterOrigin, caster )
			caster:SetAbsOrigin( casterOrigin )
		end

		-- Update thinker positions
		local endcapPos = casterOrigin + casterForward * pathLength
		endcapPos = GetGroundPosition( endcapPos, nil )
		endcapPos.z = endcapPos.z + 92
		endcap:SetAbsOrigin( endcapPos )

		for i=1, numThinkers-1 do
			local thinker = vThinkers[i]
			thinker:SetAbsOrigin( casterOrigin + casterForward * ( thinkerStep * (i-1) ) )
		end

		-- Update particle FX
		ParticleManager:SetParticleControl( pfx, 1, endcapPos )

		return deltaTime

	end, 0.0 )

end




--[[
	Author: Ractidous
	Date: 29.01.2015.
	Swap the abilities back to the original states.
]]
function EndSunRay( event )
	local caster	= event.caster
	local ability	= event.ability
	local stopsun	= event.sub_ability_name
	local Conviction	= event.Conviction
	local covearth	= event.toggle_move_empty_ability_name
	--local covsky	= event.toggle_move_ability_name

    --if caster:HasAbility(stopsun) then
	caster:SwapAbilities( Conviction, stopsun, true, false )
	--end
	--if caster:HasAbility(covearth) then
	--caster:SwapAbilities( Conviction, covearth, true, false )
	--end
	-- if caster:HasAbility(covsky) then
	-- caster:SwapAbilities( ability:GetAbilityName(), covsky, true, false )
-- end

end

function swapconv( event )
	local caster	= event.caster
	local ability	= event.ability
	local Conviction	= event.Conviction

    --if caster:HasAbility(stopsun) then
	caster:SwapAbilities( Conviction,ability:GetAbilityName(), true, false )
	--end
	--if caster:HasAbility(covearth) then
	--caster:SwapAbilities( Conviction, covearth, true, false )
	--end
	-- if caster:HasAbility(covsky) then
	-- caster:SwapAbilities( ability:GetAbilityName(), covsky, true, false )
-- end

end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Toggle move.
]]
function ToggleMove( event )
	local caster = event.caster
	caster.sun_ray_is_moving = not caster.sun_ray_is_moving
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Check current states, and interrupt the sun ray if the caster is getting disabled.
]]
function CheckToInterrupt( event )
	local caster	= event.caster

	if caster:IsSilenced() or 
	   caster:IsStunned() or caster:IsHexed() or caster:IsFrozen() or caster:IsNightmared() or caster:IsOutOfGame() then
		-- Interrupt the ability
		caster:RemoveModifierByName( event.modifier_caster_name )
	end
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Check whether the target is within the sun ray, and apply the damage if neccesary.
]]
function CheckForCollision( event )

	local caster			= event.caster
	local target			= event.target
	local ability			= event.ability

	local pathLength		= event.path_length
	local pathRadius		= event.path_radius

	local tickInterval		= event.tick_interval
	local baseDamage		= event.base_dmg
	local hpPercentDamage	= event.hp_perc_dmg
	local allyHealFactor	= event.ally_heal

	-- Calculate distance
	local pathStartPos	= caster:GetAbsOrigin() * Vector( 1, 1, 0 )
	local pathEndPos	= pathStartPos + caster:GetForwardVector() * pathLength

	local distance = DistancePointSegment( target:GetAbsOrigin() * Vector( 1, 1, 0 ), pathStartPos, pathEndPos )
	if distance > pathRadius then
		return
	end

	-- Calculate damage
	local damage = baseDamage + target:GetMaxHealth() * hpPercentDamage / 100
	damage = damage * tickInterval

	-- Check team
	local isEnemy = caster:IsOpposingTeam( target:GetTeamNumber() )

	if isEnemy then

		-- Remove HP
		ApplyDamage( {
			victim		= target,
			attacker	= caster,
			damage		= damage,
			damage_type	= DAMAGE_TYPE_PURE,
		} )

		-- Fire burn particle
		local pfx = ParticleManager:CreateParticle( event.particle_burn_name, PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControlEnt( pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex( pfx )

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

--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]


--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end		

function GenerateShrapnelPoints( keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
        local radius = keys.Radius or 400        local count = keys.Count or 3
        local caster = keys.caster
 
        -- 之后我们获取施法者，也就是火枪面向的单位向量，和他的原点
        -- 之后把他的面向单位向量*2000，乘出来的结果就是英雄所面向的
        -- 2000距离的向量，再加上原点的位置，那么得到的就是英雄前方2000的那个点。
        local caster_fv = caster:GetForwardVector()
        local caster_origin = caster:GetOrigin()
        local center = caster_origin + caster_fv * 900
        -- 我们要做的散弹是发射Count个弹片，所以我们就进行Count次循环
        -- 之后在center，也就是我们上面所计算出来的，英雄面前2000距离的位置
        -- 周围radius距离里面随机一个点，并把他放到result这个表里面去
        local result = {}
        for i = 1, count do
                -- 这里先使用一个RandomFloat来获取一个从0到半径值的随机半径
                --  之后用RandomVector函数来在这个半径的圆周上获取随机一个点，
                -- 这样最后得到的vec就是那么一个圆形范围里面的随机一个点了。
                local random = RandomFloat(0, radius)
                local vec = center + RandomVector(random)
                table.insert(result,vec)
        end
        -- 之后我们把这个地点列表返回给KV
        -- 举一反三的话，我们也可以做出比如说，向周围三百六十度，每间隔60度的方向各释放一个线性投射物的东西
        -- 这个大家自己试验就好
        return result
end

function OnShrapnelStart(keys)
        local caster = keys.caster
        local point = keys.target_points[1]
        local ability = keys.ability
        if not ( caster and point and ability ) then return end
        CreateDummyAndCastAbilityAtPosition(caster, "sniper_shrapnel", ability:GetLevel(), point, 30, false)
end

function CreateDummyAndCastAbilityAtPosition(owner, ability_name, ability_level, position, release_delay, scepter)
        local dummy = CreateUnitByNameAsync("npc_dummy", owner:GetOrigin(), false, owner, owner, owner:GetTeam(),
                function(unit)
                        print("unit created")
                        unit:AddAbility(ability_name)
                        unit:SetForwardVector((position - owner:GetOrigin()):Normalized())
                        local ability = unit:FindAbilityByName(ability_name)
                        ability:SetLevel(ability_level)
                        ability:SetOverrideCastPoint(0)
 
                        if scepter then
                                local item = CreateItem("item_ultimate_scepter", unit, unit)        
                                unit:AddItem(item)
                        end
 
                        unit:SetContextThink(DoUniqueString("cast_ability"),
                                function()
                                        unit:CastAbilityOnPosition(position, ability, owner:GetPlayerID())
                                end,
                        0)
                        unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)
 
                        return unit
                end
        )
end

function OnShrapnelStart(keys)
local caster = keys.caster
local target = keys.target
local modifierflyName			= keys.modifier_fly_name
local modifierearthName			= keys.modifier_earth_name
local modifiercovniceName			= keys.modifier_covnice_name

if caster:HasModifier( modifierflyName ) then
   if not caster:HasModifier( modifierearthName )   then
  if not caster:HasModifier( modifiercovniceNam ) then
   ability:ApplyDataDrivenModifier(caster, target, modifierearthName, {})
   end
end
end
if not caster:HasModifier( modifierflyName ) then
   if caster:HasModifier( modifierearthName ) then
   ability:ApplyDataDrivenModifier(caster, target, modifiercovniceName, {})
end

end

end

function flame_guard_stop_listening( keys )
	StopSoundEvent( "Hero_EmberSpirit.FlameGuard.Loop", keys.target )
	keys.target.take_next = nil
	keys.target.listener = false
end

function Onhithero(keys)
local caster = keys.caster
local target = keys.target
local ability = keys.ability
local modifierName = keys.modifier
local need = ability:GetLevelSpecialValueFor( "need", ability:GetLevel() - 1 )
local flyflame = "flyflame"
local shana_empty_2 = "shana_empty_2"

if study == nil then
 study = no
  end
if target:IsHero() and study == no then
if caster:HasModifier( modifierName ) then
  local current_stack = caster:GetModifierStackCount( modifierName, ability )
  ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
  caster:SetModifierStackCount( modifierName, ability, current_stack + 1 )
  else
  ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
		caster:SetModifierStackCount( modifierName, ability, 1 )
		end
end
if current_stack == need then
local study = yes
caster:SwapAbilities(flyflame, shana_empty_2, true, false) 
end


end

function Onhithero3(keys)
local caster = keys.caster
local target = keys.target
local ability = keys.ability
local modifierName = keys.modifier
local need = ability:GetLevelSpecialValueFor( "need", ability:GetLevel() - 1 )
local shana_empty_3 = "shana_empty_4"
local judgment = "Conviction"

if study == nil then
 study = no
  end

if target:IsHero() and study == no then
if target:HasModifier( modifierName ) then
  local current_stack = caster:GetModifierStackCount( modifierName, ability )
  ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
  caster:SetModifierStackCount( modifierName, ability, current_stack + 1 )
  else
  ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
		caster:SetModifierStackCount( modifierName, ability, 1 )
		end
end
if current_stack == need then
local study = yes
caster:SwapAbilities(Conviction, shana_empty_4, true, false) 
end


end

function Onhithero2(keys)
local caster = keys.caster
local target = keys.target
local ability = keys.ability
local modifierName = keys.modifier
local need = ability:GetLevelSpecialValueFor( "need", ability:GetLevel() - 1 )
local shana_empty_3 = "shana_empty_3"
local judgment = "judgment"

if study == nil then
 study = no
  end
if target:IsHero() and study == no then
if target:HasModifier( modifierName ) then
  local current_stack = caster:GetModifierStackCount( modifierName, ability )
  ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
  caster:SetModifierStackCount( modifierName, ability, current_stack + 1 )
  else
  ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
		caster:SetModifierStackCount( modifierName, ability, 1 )
		end
end
if current_stack == no then
local study = yes
caster:SwapAbilities(judgment, shana_empty_3, true, false) 
end


end

function GiveVision(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("delay", (ability:GetLevel() -1))
	
	AddFOWViewer(caster:GetTeam(), point, sight_radius, sight_duration, false)
end



