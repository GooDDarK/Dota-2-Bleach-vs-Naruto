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

	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then
		--local abl_i0 = caster:FindAbilityByName("bvo_ichigo_skill_0")
		--abl_i0:EndCooldown()
		--abl_i0:StartCooldown(3.5)
	end
end

function ichigo_skill_1_b(keys)
	local caster = keys.caster
	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then
		local enemy = keys.target
		local e_damage = keys.e_damage

		local damageTable = {
			victim = enemy,
			attacker = caster,
			damage = e_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
 
		ApplyDamage(damageTable)
	end
end

function ichigo_skill_1 (keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()

	local particleName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"
	local dbl_chance = 6
	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then
		dbl_chance = 8
		particleName = "particles/custom/ichigo/ichigo_shockwave.vpcf"
	end

	local info = 
	{
		Ability = ability,
    	EffectName = particleName,
    	vSpawnOrigin = casterPos,
    	fDistance = 800,
    	fStartRadius = 300,
    	fEndRadius = 300,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1200,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)

	if ability:GetName() == "bvo_ichigo_skill_4_extra" then return end
	if caster:HasModifier("bvo_ichigo_skill_2_modifier") then
		local rnd_level = caster:FindAbilityByName("bvo_ichigo_skill_2"):GetLevel()
		local chance = rnd_level * dbl_chance
		local roll = RandomInt(1, 100)
		if roll > chance then
			return
		end
		Timers:CreateTimer(0.1, function ()
			caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
			caster:EmitSound("Hero_Magnataur.ShockWave.Particle")
			ProjectileManager:CreateLinearProjectile(info)
		end)
	end
end

function ichigo_skill_2_b (keys)
	local caster = keys.caster
	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then
		local abl_i2 = caster:FindAbilityByName("bvo_ichigo_skill_2")
		abl_i2:ApplyDataDrivenModifier(caster, caster, "bvo_ichigo_skill_2_modifier_b", {} )
	end
end

function ichigo_skill_3(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then return end

	caster:SetModel("models/hero_ichigo/hero_ichigo_bankai_base.vmdl")
	caster:SetOriginalModel("models/hero_ichigo/hero_ichigo_bankai_base.vmdl")
end

function ichigo_skill_3_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel("models/hero_ichigo/hero_ichigo_base.vmdl")
	caster:SetOriginalModel("models/hero_ichigo/hero_ichigo_base.vmdl")

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function ichigo_skill_4 (keys)
	local caster = keys.caster
	local abl_i4 = caster:FindAbilityByName("bvo_ichigo_skill_4")

	local target = keys.target
	local point = target:GetAbsOrigin()

	FindClearSpaceForUnit(caster, point, false)

	local i4_level = abl_i4:GetLevel()
	local cast_skill = caster:FindAbilityByName("bvo_ichigo_skill_4_extra")
	cast_skill:SetLevel(i4_level)
	local caster_teamNo = caster:GetTeamNumber()
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:CastAbilityOnPosition(point, cast_skill, caster_teamNo)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_Juggernaut.Attack")

	Timers:CreateTimer(0.5, function()
		ichigo_skill_4_jump(caster, keys.jumps - 1, target)
	end)
end

function ichigo_skill_4_jump (caster, jumps, target)
	jumps = jumps - 1

	local abl_i4 = caster:FindAbilityByName("bvo_ichigo_skill_4")

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
			local cast_skill = caster:FindAbilityByName("bvo_ichigo_skill_4_extra")
			cast_skill:SetLevel(i4_level)
			local caster_teamNo = caster:GetTeamNumber()
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:CastAbilityOnTarget(unit, cast_skill, caster_teamNo)
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:EmitSound("Hero_Juggernaut.Attack")

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
		caster:RemoveModifierByName("bvo_ichigo_skill_4_modifier")
	end

	if jumps > 0 then
		Timers:CreateTimer(0.5, function()
			ichigo_skill_4_jump(caster, jumps, target)
		end)
	end
end

function ichigo_skill_5 (keys)
	local caster = keys.caster
	local cast_skill = caster:FindAbilityByName("bvo_ichigo_skill_5")
	if caster:GetHealthPercent() < 41 then
		caster:RemoveModifierByName("bvo_ichigo_skill_3_modifier")
		cast_skill:ApplyDataDrivenModifier(caster, caster, "bvo_ichigo_skill_5_modifier", {} )

		caster:FindAbilityByName("bvo_ichigo_skill_1"):SetHidden(true)
		caster:FindAbilityByName("bvo_ichigo_skill_2"):SetHidden(true)
		caster:FindAbilityByName("bvo_ichigo_skill_3"):SetHidden(true)
		caster:FindAbilityByName("bvo_ichigo_skill_4_off"):SetHidden(true)
		caster:FindAbilityByName("bvo_ichigo_skill_5_off"):SetHidden(true)
		caster:FindAbilityByName("bvo_ichigo_skill_0"):SetHidden(true)

		caster.ichigo_l1 = caster:FindAbilityByName("bvo_ichigo_skill_1"):GetLevel()
		caster.ichigo_l2 = caster:FindAbilityByName("bvo_ichigo_skill_2"):GetLevel()

		caster:RemoveAbility("bvo_ichigo_skill_1")
		caster:RemoveAbility("bvo_ichigo_skill_2")
		caster:RemoveAbility("bvo_ichigo_skill_0")

		caster:AddAbility("bvo_ichigo_skill_5_cero")
		caster:FindAbilityByName("bvo_ichigo_skill_5_cero"):SetLevel(1)
		caster:AddAbility("bvo_ichigo_skill_5_getsuga")
		caster:FindAbilityByName("bvo_ichigo_skill_5_getsuga"):SetLevel(1)
		caster:AddAbility("bvo_ichigo_skill_5_sonido")
		caster:FindAbilityByName("bvo_ichigo_skill_5_sonido"):SetLevel(1)

		caster:SetModel("models/hero_ichigo/hero_ichigo_hollow_base.vmdl")
		caster:SetOriginalModel("models/hero_ichigo/hero_ichigo_hollow_base.vmdl")
	else
		caster:GiveMana(275)
		cast_skill:EndCooldown()
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
	end
end

function ichigo_skill_5_end(keys)
	local caster = keys.caster

	caster:RemoveAbility("bvo_ichigo_skill_5_sonido")
	caster:RemoveAbility("bvo_ichigo_skill_5_getsuga")
	caster:RemoveAbility("bvo_ichigo_skill_5_cero")

	if caster.ichigo_l1 ~= nil then
		caster:AddAbility("bvo_ichigo_skill_1")
		caster:FindAbilityByName("bvo_ichigo_skill_1"):SetLevel(caster.ichigo_l1)
		caster:AddAbility("bvo_ichigo_skill_2")
		caster:FindAbilityByName("bvo_ichigo_skill_2"):SetLevel(caster.ichigo_l2)
		caster:AddAbility("bvo_ichigo_skill_0")
		caster:FindAbilityByName("bvo_ichigo_skill_0"):SetLevel(1)

		caster.ichigo_l1 = nil
		caster.ichigo_l2 = nil
	end
	--caster:FindAbilityByName("bvo_ichigo_skill_1"):SetHidden(false)
	--caster:FindAbilityByName("bvo_ichigo_skill_2"):SetHidden(false)
	caster:FindAbilityByName("bvo_ichigo_skill_3"):SetHidden(false)
	caster:FindAbilityByName("bvo_ichigo_skill_4_off"):SetHidden(false)
	caster:FindAbilityByName("bvo_ichigo_skill_5_off"):SetHidden(false)
	--caster:FindAbilityByName("bvo_ichigo_skill_0"):SetHidden(false)

	caster:SetModel("models/hero_ichigo/hero_ichigo_base.vmdl")
	caster:SetOriginalModel("models/hero_ichigo/hero_ichigo_base.vmdl")
end

function bvo_ichigo_skill_5_cero(keys)
	local caster = keys.caster
	local ability = keys.ability

	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	--particle
	ability.particle0 = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_lightning.vpcf", PATTACH_CUSTOMORIGIN, dummy)
	ParticleManager:SetParticleControlEnt(ability.particle0, 0, dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", dummy:GetAbsOrigin(), true)

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 1200,
    	fStartRadius = 300,
    	fEndRadius = 300,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector():Normalized() * 1200,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
	--motion
	local leap_direction = caster:GetForwardVector()
	local leap_distance = 1200
	local leap_speed = 2000 * 1/30
	local leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if leap_traveled < leap_distance then
			local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
			dummy:SetAbsOrigin(new_pos)
			leap_traveled = leap_traveled + leap_speed
			return 0.03
		else
			ParticleManager:DestroyParticle(ability.particle0, false)
			dummy:RemoveSelf()
		end
	end)
end

function ichigo_skill_5_cero_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function ichigo_skill_5_getsuga(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end