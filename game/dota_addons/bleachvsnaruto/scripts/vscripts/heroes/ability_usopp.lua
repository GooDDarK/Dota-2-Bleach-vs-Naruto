require('timers')

function bvo_usopp_skill_0_stop(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability.damageTaken = 0
	
	caster.bvo_usopp_skill_0_hp_old = caster:GetHealth()
	caster.bvo_usopp_skill_0_hp = caster:GetHealth()

	caster:Stop()
end

function bvo_usopp_skill_0_switch(keys)
	local caster = keys.caster
	local target = keys.target

	caster:SwapAbilities("bvo_usopp_skill_0", "bvo_usopp_skill_0_use", true, true)
	caster:FindAbilityByName("bvo_usopp_skill_0"):SetHidden(true)
end

function bvo_usopp_skill_0_use(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = caster:FindAbilityByName("bvo_usopp_skill_0").damageTaken
	if damage == nil then damage = 0 end

	--_G:PlaySoundFile("BleachVsOnePieceReborn.UsoppSkill0", caster)

	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
	caster.usopp_0_direction = difference:Normalized()
	caster.usopp_0_speed = 1000 * 1/30
	target.usopp_0_direction = -difference:Normalized()
	target.usopp_0_speed = 1000 * 1/30

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)

	local damageTable2 = {
		victim = caster,
		attacker = caster,
		damage = damage * 0.3,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable2)

	caster:SwapAbilities("bvo_usopp_skill_0", "bvo_usopp_skill_0_use", true, true)
	caster:FindAbilityByName("bvo_usopp_skill_0_use"):SetHidden(true)
end

function KnockbackTarget( keys )
	local owner = keys.caster
	local caster = keys.target

	local new_pos = caster:GetAbsOrigin() + caster.usopp_0_direction * caster.usopp_0_speed
	if caster:HasModifier("bvo_usopp_skill_0_use_stun_modifier") then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:RemoveModifierByName("bvo_usopp_skill_0_use_stun_modifier")
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_usopp_skill_1_sound( keys )
	--_G:PlaySoundFile("BleachVsOnePieceReborn.UsoppSkill1", keys.caster)
end

function bvo_usopp_skill_1_stop( keys )
	--[[
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		caster:StopSound("BleachVsOnePieceReborn.UsoppSkill1")
	end
	]]
end

function bvo_usopp_skill_1(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local ability = keys.ability
    ability.point = point

    local distance = point - caster:GetAbsOrigin()
	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_batrider/batrider_flamebreak.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = distance:Length2D(),
    	fStartRadius = 64,
    	fEndRadius = 64,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_NONE,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 2000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

function bvo_usopp_skill_1_hit(keys)
	local caster = keys.caster
    local ability = keys.ability

    local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            ability.point,
	            nil,
	            250,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		ability:ApplyDataDrivenModifier(caster, unit, "bvo_usopp_skill_1_modifier", {duration=5.0} )
	end
	--
	local dummy = CreateUnitByName("npc_dummy_unit", ability.point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:EmitSound("Hero_Batrider.Flamebreak.Impact")
	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)
end

function bvo_usopp_skill_2(keys)
	local caster = keys.caster
    local target = keys.target

    local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetAgility() * 0.5,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_usopp_skill_3(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local ability = keys.ability
    ability.point = point

	--_G:PlaySoundFile("BleachVsOnePieceReborn.UsoppSkill3", caster)
end

function bvo_usopp_skill_3_cast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local point = ability.point

    local distance = point - caster:GetAbsOrigin()
	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_batrider/batrider_flamebreak.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = distance:Length2D(),
    	fStartRadius = 64,
    	fEndRadius = 64,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_NONE,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

function bvo_usopp_skill_3_hit(keys)
	local caster = keys.caster
    local ability = keys.ability
    local damage = keys.damage

    localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            ability.point,
	            nil,
	            250,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		ability:ApplyDataDrivenModifier(caster, unit, "bvo_usopp_skill_3_stun_modifier", {duration=1.0} )
		--
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage / 6,
			damage_type = DAMAGE_TYPE_PURE,
		}

		ApplyDamage(damageTable)
	end
	--
	local dummy = CreateUnitByName("npc_dummy_unit", ability.point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:EmitSound("Hero_Batrider.Flamebreak.Impact")
	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)
end

function bvo_usopp_skill_4_sound( keys )
	--_G:PlaySoundFile("BleachVsOnePieceReborn.UsoppSkill4", keys.caster)
end

function bvo_usopp_skill_4_stop( keys )
	--[[
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		caster:StopSound("BleachVsOnePieceReborn.UsoppSkill4")
	end
	]]
end

function bvo_usopp_skill_4_hit(keys)
	local caster = keys.caster
	local target = keys.target
    local multi = keys.multi

  	local damageTable = {
		victim = target,
		attacker = caster,
		damage = (caster:GetAgility() * multi) + 500,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_usopp_skill_5_sound( keys )
	--_G:PlaySoundFile("BleachVsOnePieceReborn.UsoppSkill5", keys.caster)
end

function bvo_usopp_skill_5_stop( keys )
	--[[
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		caster:StopSound("BleachVsOnePieceReborn.UsoppSkill5")
	end
	]]
end

function bvo_usopp_skill_5(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local ability = keys.ability
    ability.point = point

    local distance = point - caster:GetAbsOrigin()
	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_batrider/batrider_flamebreak.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = distance:Length2D(),
    	fStartRadius = 64,
    	fEndRadius = 64,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_NONE,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 2000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

function bvo_usopp_skill_5_hit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local point = ability.point

    --
    localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            ability.point,
	            nil,
	            450,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = 1400 + (40 * caster:GetLevel()),
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(damageTable)
	end
    --
    local castABL = caster:FindAbilityByName("bvo_usopp_skill_5_extra")
    castABL:SetLevel(ability:GetLevel())

    for i = 0, 4 do
	    local rotation = QAngle( 0, 72 * i, 0 )
		local rot_vector = RotatePosition(point, rotation, point + Vector(0, 100, 0))

		local info = 
		{
			Ability = castABL,
	    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
	    	vSpawnOrigin = point,
	    	fDistance = 1000,
	    	fStartRadius = 250,
	    	fEndRadius = 250,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = (rot_vector - point):Normalized() * 1200,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
	--
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:EmitSound("Ability.LightStrikeArray")
	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)
end

function bvo_usopp_skill_5_hit2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "bvo_usopp_skill_5_modifier", {duration=12.0} )
end

function bvo_usopp_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi

	multi = multi / 100

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = target:GetMaxHealth() * multi,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
end