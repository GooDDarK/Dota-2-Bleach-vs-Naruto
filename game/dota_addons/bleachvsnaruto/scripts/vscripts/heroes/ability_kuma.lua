require('timers')

function bvo_kuma_skill_1(keys)
	local caster = keys.caster
	local forward = caster:GetForwardVector()

	local info = 
	{
		Ability = keys.ability,
    	EffectName = "particles/custom/kuma/bvo_kuma_skill_1_gale.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 1000,
    	fStartRadius = 256,
    	fEndRadius = 256,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = forward:Normalized() * 1200,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function bvo_kuma_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = (caster:GetIntellect() * multi) + damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_kuma_skill_2(params)
	local damage = params.damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local return_damage_percent = 15 / 100

	if attacker:HasModifier("item_doom_1_modifier_buff") then
		return
	end

	if damage > 1 and attacker and hero and attacker~=hero then
		local real_damage = damage * return_damage_percent
		local new_health = attacker:GetHealth() - real_damage
		if new_health > 1 then
			attacker:SetHealth(new_health)
		else
			attacker:Kill(ability, hero)
		end
	end
end

function bvo_kuma_skill_3(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local ability = keys.ability
    ability.point = point
end

function bvo_kuma_skill_3_cast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterPos = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
    	vSpawnOrigin = casterPos,
    	fDistance = 1000,
    	fStartRadius = 150,
    	fEndRadius = 250,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = forward * 1000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)

	--1
	local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 92 ) )
	local rotation = QAngle( 0, 90, 0 )
	local rot_vector = RotatePosition(casterPos, rotation, casterPos + forward * 100)
	dummy:SetAbsOrigin( dummy:GetAbsOrigin() + forward * 92)
	dummy:SetAbsOrigin( dummy:GetAbsOrigin() + (rot_vector - casterPos):Normalized() * 60)
	dummy:SetForwardVector(forward)
	dummy:SetOriginalModel("models/hero_kuma/kumaball.vmdl")
	dummy:SetModel("models/hero_kuma/kumaball.vmdl")
	dummy:SetModelScale(0.1)
	--2
	local dummy2 = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
	dummy2:AddAbility("custom_point_dummy")
	local abl = dummy2:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy2:SetAbsOrigin( Vector( dummy2:GetAbsOrigin().x, dummy2:GetAbsOrigin().y, dummy2:GetAbsOrigin().z + 92 ) )
	local rotation2 = QAngle( 0, -90, 0 )
	local rot_vector2 = RotatePosition(casterPos, rotation2, casterPos + forward * 100)
	dummy2:SetAbsOrigin( dummy2:GetAbsOrigin() + forward * 92)
	dummy2:SetAbsOrigin( dummy2:GetAbsOrigin() + (rot_vector2 - casterPos):Normalized() * 60)
	dummy2:SetForwardVector(forward)
	dummy2:SetOriginalModel("models/hero_kuma/kumaball.vmdl")
	dummy2:SetModel("models/hero_kuma/kumaball.vmdl")
	dummy2:SetModelScale(0.1)
	--motion
	local leap_direction = forward:Normalized()
	local leap_distance = 1000
	local leap_speed = 1200 * 1/30
	local leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if leap_traveled < leap_distance then
			local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
			dummy:SetAbsOrigin(new_pos)
			local new_pos = dummy2:GetAbsOrigin() + leap_direction * leap_speed
			dummy2:SetAbsOrigin(new_pos)
			leap_traveled = leap_traveled + leap_speed
			return 0.03
		else
			dummy:RemoveSelf()
			dummy2:RemoveSelf()
		end
	end)
end

function bvo_kuma_skill_3_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ((caster:GetIntellect() * multi) + damage) * 0.25,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_kuma_skill_4_init(keys)
	local target = keys.target
	local ability = keys.ability
	ability.target = target
end

function bvo_kuma_skill_4_heal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local heal_h = ability:GetLevelSpecialValueFor("int_heal", 0 )
	local heal_m = ability:GetLevelSpecialValueFor("int_mana", 0 )

	local int = caster:GetIntellect()
	
	local target = caster:FindAbilityByName("bvo_kuma_skill_4").target
	
	target:Heal(int * heal_h, caster)
	target:GiveMana(int * heal_m)
end

function bvo_kuma_skill_4_damage(keys)
	local caster = keys.caster
	local damage = keys.damage
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("reflect", ability:GetLevel() - 1) / 100

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            400,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		if not unit:HasModifier("bvo_rory_skill_4_modifier") then
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = damage * multi,
				damage_type = DAMAGE_TYPE_PURE,
			}
			ApplyDamage(damageTable)
		end
	end
end

function bvo_kuma_skill_5_dummy(keys)
	local caster = keys.caster
	local ability = keys.ability

	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	local pos = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z )
	dummy:SetAbsOrigin(pos + caster:GetForwardVector() * 64)
	dummy:SetForwardVector(caster:GetForwardVector())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	dummy:SetModel("models/hero_kuma/kumaball.vmdl")
	dummy:SetOriginalModel("models/hero_kuma/kumaball.vmdl")

	ability.dummy = dummy

	Timers:CreateTimer(0.2, function ()
		dummy:SetModelScale(0.75)
		local adjust = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z )
		dummy:SetAbsOrigin(adjust)
	end)
	Timers:CreateTimer(0.4, function ()
		dummy:SetModelScale(0.5)
		local adjust = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z )
		dummy:SetAbsOrigin(adjust)
	end)
	Timers:CreateTimer(0.65, function ()
		dummy:SetModelScale(0.35)
		local adjust = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 64 )
		dummy:SetAbsOrigin(adjust)
	end)
	Timers:CreateTimer(0.9, function ()
		dummy:SetModelScale(0.15)
		local adjust = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 64 )
		dummy:SetAbsOrigin(adjust)
	end)
	Timers:CreateTimer(1.15, function ()
		dummy:SetModelScale(0.05)
		local adjust = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z )
		dummy:SetAbsOrigin(adjust)
	end)
end

function bvo_kuma_skill_5_dead(keys)
	local ability = keys.ability
	ability.dummy:RemoveSelf()
end

function bvo_kuma_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = 1000 + (caster:GetIntellect() * multi),
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
	ability:ApplyDataDrivenModifier(caster, target, "bvo_kuma_skill_5_debuff_modifier", {duration=3.0} )
end