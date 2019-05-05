function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	
	local difference = point - casterPos

	if difference:Length2D() > 600 then
		point = casterPos + (point - casterPos):Normalized() * 600
	end

	FindClearSpaceForUnit(caster, point, false)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
		FindClearSpaceForUnit(caster, casterPos, false)
    	return
	end
	FindClearSpaceForUnit(caster, casterPos, false)

	if caster.wing_dummy ~= nil and not caster.wing_dummy:IsNull() then
		caster.wing_dummy:RemoveNoDraw()
	end
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = (point - caster:GetAbsOrigin()):Normalized()

	difference = point - casterPos

	ability.leap_distance = difference:Length2D()
	ability.leap_speed = (difference:Length2D() / 20)
	ability.leap_traveled = 0
	ability.leap_z = 0
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled == nil then
		caster:InterruptMotionControllers(true)
		return
	end

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		if caster.wing_dummy ~= nil and not caster.wing_dummy:IsNull() then
			caster.wing_dummy:AddNoDraw()
		end
		Timers:CreateTimer(3.0, function ()
			instant_anti_stuck( caster )
		end)
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled == nil then
		return
	end
	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end

function bvo_robin_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + caster:GetIntellect() * 1,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_robin_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            FIND_UNITS_EVERYWHERE,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local mods = unit:FindAllModifiers()
		local use_mod = ""
		for _,mod in pairs(mods) do
			if mod:GetName() == "bvo_robin_skill_4_modifier" or mod:GetName() == "bvo_robin_skill_2_modifier" or mod:GetName() == "bvo_robin_skill_1_modifier" then
				use_mod = mod:GetName()
			end
		end

		if use_mod ~= "" then
			local damage = 0
			local damage_type = 0
			if use_mod == "bvo_robin_skill_1_modifier" then
				damage = 400
				damage_type = 2
				unit:RemoveModifierByName("bvo_robin_skill_1_modifier")
			elseif use_mod == "bvo_robin_skill_2_modifier" then
				damage = 500
				damage_type = 2
				unit:RemoveModifierByName("bvo_robin_skill_2_modifier")
			elseif use_mod == "bvo_robin_skill_4_modifier" then
				damage = 700
				damage_type = 1
				unit:RemoveModifierByName("bvo_robin_skill_4_modifier")
			end
			
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = damage + ( caster:GetIntellect() + ( caster:GetLevel() * ability:GetLevel() ) ),
				damage_type = damage_type,
			}
			ApplyDamage(damageTable)

			ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
		end
	end
end

function bvo_robin_skill_5(keys)
	local caster = keys.caster
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	for wave = 1, 3 do
		local radius = wave * 200
		local shards = 4 * wave
		for i = 1, shards do
			local point_projectile = caster:GetAbsOrigin() + Vector(radius, 0, 0)
			local rotation = QAngle( 0, i * (360 / shards), 0 )
			local rot_vector = RotatePosition(caster:GetAbsOrigin(), rotation, point_projectile)
			local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, nil, nil, caster:GetTeam())
			dummy:AddAbility("custom_point_dummy")
			local abl = dummy:FindAbilityByName("custom_point_dummy")
			if abl ~= nil then abl:SetLevel(1) end
			ability:ApplyDataDrivenModifier(caster, dummy, "bvo_robin_skill_5_dummy_modifier", {duration=0.8} )
		end
	end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		            caster:GetAbsOrigin(),
		            nil,
		            600,
		            DOTA_UNIT_TARGET_TEAM_ENEMY,
		            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		            FIND_ANY_ORDER,
		            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = caster:GetIntellect() * multi,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end
end

function bvo_robin_skill_5_dummy(keys)
	local caster = keys.target
	caster:RemoveSelf()
end

--
function instant_anti_stuck(stuckUnit)
    local hero = stuckUnit
    local base_point = Vector( 0, 0, 0 )
    if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        base_point = Entities:FindByName( nil, "RADIANT_BASE"):GetAbsOrigin()
    else
        base_point = Entities:FindByName( nil, "DIRE_BASE"):GetAbsOrigin()
    end
    
    --anti abuse
    local IsHeroStuck = false
    local stuckPoint = hero:GetAbsOrigin()
    if not GridNav:CanFindPath(base_point, stuckPoint) then
        IsHeroStuck = true
    end

    --except areas with teleporter
    local forgotten_point = Entities:FindByName( nil, "TELE_POINT_8"):GetAbsOrigin()
    local infernal_point = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
    local rapier_point = Entities:FindByName( nil, "TELE_POINT_9"):GetAbsOrigin()
    local duel_point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN"):GetAbsOrigin()
    local skeleton_point = Entities:FindByName( nil, "POINT_SKELETON_CENTER"):GetAbsOrigin()

	if GridNav:CanFindPath(forgotten_point, stuckPoint) or GridNav:CanFindPath(infernal_point, stuckPoint) or GridNav:CanFindPath(rapier_point, stuckPoint) or GridNav:CanFindPath(skeleton_point, stuckPoint) then
		IsHeroStuck = false
	end

    if GridNav:CanFindPath(duel_point, stuckPoint) then
        IsHeroStuck = false
    end

    if IsHeroStuck then
        FindClearSpaceForUnit(hero, base_point, false)
    end
end