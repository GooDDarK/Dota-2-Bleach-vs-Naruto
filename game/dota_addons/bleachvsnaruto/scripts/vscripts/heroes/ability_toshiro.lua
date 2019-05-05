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
end

function bvo_toshiro_skill_1(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dur = 1.5

	if caster:HasModifier("bvo_toshiro_skill_3_modifier") or caster:HasModifier("bvo_toshiro_skill_3_perma_modifier") then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = 125,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		dur = dur + 1
		ApplyDamage(damageTable)
	end
	ability:ApplyDataDrivenModifier(caster, target, "bvo_toshiro_skill_1_slow", {duration=dur} )
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	local leap_direction = (ability.point - caster:GetAbsOrigin()):Normalized()

	if caster:HasModifier("bvo_toshiro_skill_2_stun_modifier") then
		local new_pos = caster:GetAbsOrigin() + leap_direction * ability.leap_speed
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_toshiro_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local damage_min = keys.damage_min
	local damage_max = keys.damage_max

	local damage = RandomInt(damage_min, damage_max)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_toshiro_skill_2_bankai(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	-- Clears any current command and disjoints projectiles
	caster:Stop()
	-- Ability variables
	ability.point = point
	ability.leap_speed = 400 * 1/30
	ability.leap_traveled = 0
	
	ability.ringDummys = {}
	--particle dummy
	for i = 1, 8 do
		local point_projectile = point + Vector(400, 0, 0)
		local rotation = QAngle( 0, i * 45, 0 )
		local rot_vector = RotatePosition(point, rotation, point_projectile)
		local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, nil, nil, caster:GetTeam())
		dummy.angle = i * 45
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		dummy:SetModel("models/heroes/crystal_maiden/crystal_maiden_ice.vmdl")
		dummy:SetOriginalModel("models/heroes/crystal_maiden/crystal_maiden_ice.vmdl")
		dummy:SetModelScale(2.5)
		local vec_up = Vector( point.x, point.y, point.z + 160)
		dummy:SetAbsOrigin(vec_up)
		table.insert(ability.ringDummys, dummy)
	end

	bvo_toshiro_skill_2_bankai_dummy_rotate(ability, point, 400)

	Timers:CreateTimer(1.5, function()
		for _,dummy in pairs(ability.ringDummys) do
			UTIL_Remove(dummy)
		end
		ability.ringDummys = nil
	end)
end

function bvo_toshiro_skill_2_bankai_dummy_rotate(ability, point, range)
	if ability.ringDummys ~= nil then
		for _,dummy in pairs(ability.ringDummys) do
			if dummy ~= nil and not dummy:IsNull() then
				local point_projectile = point + Vector(range, 0, 0)
				range = range - 1
				local speed = 4
				local rotation = QAngle( 0, dummy.angle + speed, 0 )
				dummy.angle = dummy.angle + speed
				local rot_vector = RotatePosition(point, rotation, point_projectile)
				dummy:SetAbsOrigin(rot_vector)
			end
		end
		Timers:CreateTimer(0.03, function()
			bvo_toshiro_skill_2_bankai_dummy_rotate(ability, point, range)
		end)
	end
end

function bvo_toshiro_skill_3(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_toshiro_skill_3_modifier") then return end

	--model dummy
	if caster.dummy_wings == nil then
		local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
		dummy:SetForwardVector(caster:GetForwardVector())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		dummy:SetModel("models/hero_toshiro/toshiro_wings_base.vmdl")
		dummy:SetOriginalModel("models/hero_toshiro/toshiro_wings_base.vmdl")
		dummy:SetModelScale(1.0)
		local vec_up = Vector( caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + 100)
		dummy:SetAbsOrigin(vec_up)
		dummy:SetParent(caster, "follow_origin")
		dummy:StartGesture(ACT_DOTA_IDLE)
		caster.dummy_wings = dummy
		caster.dummy_wings.parent = caster
	end
end

function bvo_toshiro_skill_3_end(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:RemoveModifierByName("bvo_toshiro_skill_3_aura_modifier")

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	else
		caster.dummy_wings:RemoveSelf()
		caster.dummy_wings = nil
	end
end

function bvo_toshiro_skill_4_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal4( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		local new_pos = caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
			ability.leap_traveled = ability.leap_traveled + ability.leap_speed
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_toshiro_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- Clears any current command and disjoints projectiles
	caster:Stop()

	-- Ability variables
	ability.leap_direction = caster:GetForwardVector()

	ability.leap_distance = 1000
	ability.leap_speed = 2000 * 1/30
	ability.leap_traveled = 0
end

function bvo_toshiro_skill_5_main(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = keys.multi
	ability.target = target

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)

	--particle dummy
	local dummy = CreateUnitByName("npc_dummy_unit", target:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:SetModel("models/heroes/crystal_maiden/crystal_maiden_ice.vmdl")
	dummy:SetOriginalModel("models/heroes/crystal_maiden/crystal_maiden_ice.vmdl")
	dummy:SetModelScale(20.0)
	local vec_up = Vector( target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z - 300)
	dummy:SetAbsOrigin(vec_up)

	dummy:EmitSound("Hero_Ancient_Apparition.IceBlast.Target")

	Timers:CreateTimer(4.0, function ()
		dummy:RemoveSelf()
	end)
end

function bvo_toshiro_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = keys.multi
	if ability.target == target then return end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end