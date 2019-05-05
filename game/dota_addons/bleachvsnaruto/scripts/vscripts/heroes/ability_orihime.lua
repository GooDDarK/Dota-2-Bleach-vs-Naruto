require('timers')

particle_names = {base = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_base_attack.vpcf"}
projectile_speeds = {base = 900}

function findProjectileInfo(class_name)
	if particle_names[class_name] ~= nil then
		return particle_names[class_name], projectile_speeds[class_name]
	end

	particle_names[class_name] = particle_names["base"]
	projectile_speeds[class_name] = projectile_speeds["base"]

	return particle_names[class_name], projectile_speeds[class_name]
end

function moon_glaive_start_create_dummy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Create the dummy unit which keeps track of bounces
	local dummy = CreateUnitByName( "npc_dummy_unit", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
	dummy:AddAbility("bvo_orihime_skill_0_dummy")
	local dummy_ability =  dummy:FindAbilityByName("bvo_orihime_skill_0_dummy")
	dummy_ability:ApplyDataDrivenModifier( caster, dummy, "modifier_moon_glaive_dummy_unit", {} )

	local bouncedTargets = {}
	table.insert(bouncedTargets, target)
	-- Ability variables
	dummy_ability.damage = caster:GetAverageTrueAttackDamage(caster)
	dummy_ability.bounceTable = bouncedTargets
	dummy_ability.bounceCount = 0
	dummy_ability.maxBounces = ability:GetLevelSpecialValueFor("bounces", ability_level)
	dummy_ability.bounceRange = ability:GetLevelSpecialValueFor("range", ability_level) 
	dummy_ability.dmgMultiplier = ability:GetLevelSpecialValueFor("damage_reduction_percent", ability_level) / 100
	dummy_ability.original_ability = ability

	dummy_ability.particle_name, dummy_ability.projectile_speed = findProjectileInfo(caster:GetClassname())
	dummy_ability.projectileFrom = target
	dummy_ability.projectileTo = nil

	-- Find the closest target that fits the search criteria
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local bounce_targets = FindUnitsInRadius(caster:GetTeamNumber(), dummy:GetAbsOrigin(), nil, dummy_ability.bounceRange, iTeam, iType, iFlag, FIND_CLOSEST, false)

	-- It has to be a target different from the current one
	for _,v in pairs(bounce_targets) do
		if v ~= target then
			dummy_ability.projectileTo = v
		end
		for _,b in pairs(bouncedTargets) do
			if v == b then dummy_ability.projectileTo = nil end
		end
		if dummy_ability.projectileTo ~= nil then break end
	end

	-- If we didnt find a new target then kill the dummy and end the function
	if dummy_ability.projectileTo == nil then
		killDummy(dummy, dummy)
	else
	-- Otherwise continue with creating a bounce projectile
		table.insert(dummy_ability.bounceTable, dummy_ability.projectileTo)

		dummy_ability.bounceCount = dummy_ability.bounceCount + 1
		local info = {
        Target = dummy_ability.projectileTo,
        Source = dummy_ability.projectileFrom,
        EffectName = dummy_ability.particle_name,
        Ability = dummy_ability,
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = dummy_ability.projectile_speed,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    	}
    	ProjectileManager:CreateTrackingProjectile( info )
    end
end

function moon_glaive_bounce( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	-- Initialize the damage table
	local damage_table = {}
	damage_table.attacker = caster:GetOwner()
	damage_table.victim = target
	damage_table.ability = ability.original_ability
	damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
	damage_table.damage = ability.damage

	ApplyDamage(damage_table)
	-- Save the new damage for future bounces
	ability.damage = damage_table.damage

	-- If we exceeded the bounce limit then remove the dummy and stop the function
	if ability.bounceCount >= ability.maxBounces then
		killDummy(caster,caster)
		return
	end

	-- Reset target data and find new targets
	ability.projectileFrom = ability.projectileTo
	ability.projectileTo = nil

	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local bounce_targets = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, ability.bounceRange, iTeam, iType, iFlag, FIND_CLOSEST, false)

	-- Find a new target that is not the current one
	for _,v in pairs(bounce_targets) do
		if v ~= target then
			ability.projectileTo = v
		end
		for _,b in pairs(ability.bounceTable) do
			if v == b then ability.projectileTo = nil end
		end
		if ability.projectileTo ~= nil then break end
	end

	-- If we didnt find a new target then kill the dummy
	if ability.projectileTo == nil then
		killDummy(caster, caster)
	else
	-- Otherwise increase the bounce count and create a new bounce projectile
		table.insert(ability.bounceTable, ability.projectileTo)

		ability.bounceCount = ability.bounceCount + 1
		local info = {
	        Target = ability.projectileTo,
	        Source = ability.projectileFrom,
	        EffectName = ability.particle_name,
	        Ability = ability,
	        bDodgeable = false,
	        bProvidesVision = false,
	        iMoveSpeed = ability.projectile_speed,
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    	}
    	ProjectileManager:CreateTrackingProjectile( info )
    end
end

function killDummy(caster, target)
	if caster:GetClassname() == "npc_dota_base_additive" then
		caster:RemoveSelf()
	elseif target:GetClassname() == "npc_dota_base_additive" then
		target:RemoveSelf()
	end
end

function bvo_orihime_skill_2_init(keys)
	keys.ability.target = keys.target
end

function bvo_orihime_skill_2(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damage = keys.damage
	local ability = keys.ability
	local block = ability:GetLevelSpecialValueFor("damage_block", ability:GetLevel() - 1 )
	local int_block = caster:GetIntellect()
	local target = ability.target

	if target:GetHealth() > 0 then
		
		local true_damage = damage - block

		if true_damage < 0 then
			true_damage = 0
		end

		local new_health = ability.bvo_orihime_skill_2_hp_old - true_damage
		if new_health <= 1 then
			target:Kill(ability, attacker)
		else
			ability.bvo_orihime_skill_2_hp_old = new_health
			ability.bvo_orihime_skill_2_hp = new_health
			target:SetHealth(new_health)
		end

	end
end

function bvo_orihime_skill_3_init(keys)
	local target = keys.target
	local ability = keys.ability
	ability.target = target
end

function bvo_orihime_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability

	local int = caster:GetIntellect()
	
	local target = caster:FindAbilityByName("bvo_orihime_skill_3").target
	local heal = ability:GetLevelSpecialValueFor("heal", (ability:GetLevel() - 1))
	local mana_regen = ability:GetLevelSpecialValueFor("mana_regen", (ability:GetLevel() - 1))
	
	--target:Heal(heal, heal)
	target:GiveMana(mana_regen)
end

function bvo_orihime_skill_5_cast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]

	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", (ability:GetLevel() - 1))

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	dummy:AddAbility("bvo_orihime_skill_5_dummy_aura")
	dummy:FindAbilityByName("bvo_orihime_skill_5_dummy_aura"):SetLevel(1)
	dummy:FindAbilityByName("bvo_orihime_skill_5_dummy_aura").casterOwner = caster

	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end

function bvo_orihime_skill_5_good(keys)
	local ability = keys.ability
	local target = keys.target

	if ability ~= nil then
		local owner = ability.casterOwner
		local int = owner:GetIntellect()

		target:Heal(int, owner)
		target:GiveMana(int * 0.5)
	end
end

function bvo_orihime_skill_5_bad(keys)
	local ability = keys.ability
	local target = keys.target

	if ability ~= nil then
		local owner = ability.casterOwner
		local int = owner:GetIntellect()

		local damageTable = {
			victim = target,
			attacker = owner,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}

		ApplyDamage(damageTable)

		local current = target:GetMana()
		local burned = current - (int * 1)
		if burned < 0 then burned = 0 end
		target:SetMana(burned)
	end
end