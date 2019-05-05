require('timers')

function bvo_crocodile_skill_1(keys)
	local caster = keys.caster
	local point = keys.target_points[1]

	local casterPos = caster:GetAbsOrigin()
	local front = caster:GetForwardVector()

	for i = 1, 10 do
		Timers:CreateTimer(0.075 * i, function()
			
			local forward = casterPos + front * 100 * i
			local dummy = CreateUnitByName("npc_dummy_unit", forward, false, nil, nil, caster:GetTeam())

			dummy:AddAbility("custom_point_dummy")

			local abl = dummy:FindAbilityByName("custom_point_dummy")
			if abl ~= nil then abl:SetLevel(1) end

			local particleName = "particles/units/heroes/hero_sandking/sandking_sandstorm_eruption_dust_low.vpcf"
			ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, dummy)

			Timers:CreateTimer(3.0, function()
				UTIL_Remove(dummy)
			end)

		end)
	end
end

function bvo_crocodile_skill_1_damage(keys)
    local caster = keys.caster
    local target = keys.target
    local multi = keys.multi

	local str = caster:GetStrength()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = str * multi,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_crocodile_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local str = caster:GetBaseStrength()
	local full_damage = str * 4

	local tick = 0
	Timers:CreateTimer(0.01, function()
		bvo_crocodile_skill_2_damage(caster, target, full_damage, tick, ability)
	end)
end

function bvo_crocodile_skill_2_damage(caster, target, full_damage, tick, ability)
	local tick_damage = full_damage / 30
	tick = tick + 1
	
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = tick_damage,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
	ability:ApplyDataDrivenModifier(caster, target, "bvo_crocodile_skill_2_stun_modifier", {duration=0.1} )

	if tick < 30 then
		Timers:CreateTimer(0.01, function()
			bvo_crocodile_skill_2_damage(caster, target, full_damage, tick, ability)
		end)
	end 
end

function bvo_crocodile_skill_3( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local duration = keys.duration

	-- Ability variables
	ability.point = point
	ability.leap_speed = 200 * 1/30
	ability.leap_traveled = 0

	--particle dummy
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_crocodile_skill_3_dummy_modifier", {} )
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_crocodile_skill_3_damage_dummy_modifier", {} )

	--particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf", PATTACH_CUSTOMORIGIN, dummy)
	ParticleManager:SetParticleControl(particle, 0, dummy:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(350, 350, 350))

	Timers:CreateTimer(duration, function()
		UTIL_Remove(dummy)
	end)
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	local leap_direction = (ability.point - caster:GetAbsOrigin()):Normalized()

	if caster:HasModifier("bvo_crocodile_skill_3_stun_modifier") then
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

function bvo_crocodile_skill_3_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local damage_tick = (damage + (caster:GetLevel() * 5)) / 4

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage_tick,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
end

function bvo_crocodile_skill_4_damage(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local multi = keys.multi

    ability.centerTarget = target

	local str = caster:GetBaseStrength()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = str * multi,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
end

function bvo_crocodile_skill_4_damage_aoe(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local multi = keys.multi

    if target == ability.centerTarget then return end

	local str = caster:GetBaseStrength()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = (str * multi) * 0.4,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
end

function bvo_crocodile_skill_5(keys)
    local caster = keys.caster
    local ability = keys.ability
    local health_damage = ability:GetLevelSpecialValueFor("health_damage", ability:GetLevel() - 1 )

    local max = caster:GetMaxHealth()
    local max_damage = max * 0.37
	
    bvo_crocodile_skill_5_damage_aoe(caster, max_damage, 0)
end

function bvo_crocodile_skill_5_damage_aoe(caster, damage, wave)
    wave = wave + 1
    if not caster:IsAlive() then return end
    local radius = 150 + wave * 100
	localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(damageTable)
	end
	--particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, radius))
	caster:EmitSound("Hero_Undying.Decay.Cast")

	damage = damage * 0.85

	if wave < 10 then
		Timers:CreateTimer(0.3, function ()
	    	bvo_crocodile_skill_5_damage_aoe(caster, damage, wave)
	    end)
	end
end