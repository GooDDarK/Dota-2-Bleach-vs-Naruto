require('timers')

function Blink(keys)
    local ability = keys.ability
	local caster = keys.caster
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
		FindClearSpaceForUnit(caster, casterPos, false)
    	return
	end

	if caster:HasModifier("bvo_hollow_skill_3_modifier") or caster:HasModifier("bvo_hollow_skill_3_perma_modifier") then
		--local abl_i0 = caster:FindAbilityByName("bvo_hollow_skill_0")
		--abl_i0:EndCooldown()
		--abl_i0:StartCooldown(4.0)
	end
end

function bvo_hollow_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local targetPos = target:GetAbsOrigin()

	local level = 0
	if caster:HasModifier("bvo_hollow_skill_3_modifier") or caster:HasModifier("bvo_hollow_skill_3_perma_modifier") then
		level = caster:FindAbilityByName("bvo_hollow_skill_3"):GetLevel()
	end

	FindClearSpaceForUnit(caster, targetPos, false)
	ProjectileManager:ProjectileDodge(caster)

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)

	caster:MoveToTargetToAttack(target)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")
end

function bvo_hollow_skill_3(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_hollow_skill_3_modifier") then return end
	
	caster:SetModel("models/heroes/anime/bleach/ichigo/hollow_ichigo/hollow_ichigo.vmdl")
	caster:SetOriginalModel("models/heroes/anime/bleach/ichigo/hollow_ichigo/hollow_ichigo.vmdl")
	
	caster:SetModelScale(1.0)
end

function bvo_hollow_skill_3_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel("models/hero_ichigo/hero_ichigo_base.vmdl")
	caster:SetOriginalModel("models/hero_ichigo/hero_ichigo_base.vmdl")
	
	caster:SetModelScale(0.80)

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_hollow_skill_3v2(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_hollow_skill_3_modifier") then return end
	
	caster:SetModel("models/hero_hollow/hero_hollow_bankai_base.vmdl")
	caster:SetOriginalModel("models/hero_hollow/hero_hollow_bankai_base.vmdl")
end

function bvo_hollow_skill_3v2_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel("models/hero_hollow/hero_hollow_base.vmdl")
	caster:SetOriginalModel("models/hero_hollow/hero_hollow_base.vmdl")

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	local difference = target:GetAbsOrigin() - caster:GetAbsOrigin()

	ability.leap_distance = difference:Length2D()

	ability.leap_speed = 1500 * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		--local cast = caster:FindAbilityByName("bvo_hollow_skill_4_extra")
		--cast:SetLevel(caster:FindAbilityByName("bvo_hollow_skill_4"):GetLevel())
		caster:CastAbilityNoTarget(cast, caster:GetPlayerID())
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

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

function bvo_hollow_skill_5 (keys)
	local caster = keys.caster
	local abl_i4 = caster:FindAbilityByName("bvo_hollow_skill_5")

	local target = keys.target
	local point = target:GetAbsOrigin()

	FindClearSpaceForUnit(caster, point, false)

	local i4_level = abl_i4:GetLevel()
	local cast_skill = caster:FindAbilityByName("bvo_hollow_skill_5_extra")
	cast_skill:SetLevel(i4_level)
	local caster_teamNo = caster:GetTeamNumber()
	caster:CastAbilityOnPosition(point, cast_skill, caster_teamNo)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_Slark.Attack")
	Timers:CreateTimer(0.5, function()
		bvo_hollow_skill_5_jump(caster, keys.jumps - 1, target)
	end)
end

function bvo_hollow_skill_5_jump (caster, jumps, target)
	jumps = jumps - 1

	local abl_i4 = caster:FindAbilityByName("bvo_hollow_skill_5")

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            500,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
	            FIND_ANY_ORDER,
	            false)

	if #localUnits > 0 then
		for _,unit in pairs(localUnits) do
			FindClearSpaceForUnit(caster, unit:GetAbsOrigin(), false)

			local i4_level = abl_i4:GetLevel()
			local cast_skill = caster:FindAbilityByName("bvo_hollow_skill_5_extra")
			cast_skill:SetLevel(i4_level)
			local caster_teamNo = caster:GetTeamNumber()
			caster:CastAbilityOnTarget(unit, cast_skill, caster_teamNo)
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:EmitSound("Hero_Slark.Attack")

			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)

			target = unit
			break
		end
	else
		jumps = 0
		caster:RemoveModifierByName("bvo_hollow_skill_5_modifier")
	end

	if jumps > 0 then
		Timers:CreateTimer(0.5, function()
			bvo_hollow_skill_5_jump(caster, jumps, target)
		end)
	end
end