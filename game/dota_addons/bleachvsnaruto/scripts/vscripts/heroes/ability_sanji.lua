require('timers')

function bvo_sanji_skill_1(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi

	local multi2 = 1
	if caster:HasModifier("bvo_sanji_skill_3_modifier") or caster:HasModifier("bvo_sanji_skill_3_perma_modifier") then multi2 = 1.2 end
	--damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
	--
	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
	target.leap_direction = -difference:Normalized()
	target.leap_speed = 150 * 1/30
end

function KnockbackTarget( keys )
	local owner = keys.caster
	local caster = keys.target

	local new_pos = caster:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	if caster:HasModifier("bvo_sanji_skill_1_stun_modifier") then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_sanji_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local multi2 = 1
	if caster:HasModifier("bvo_sanji_skill_3_modifier") or caster:HasModifier("bvo_sanji_skill_3_perma_modifier") then multi2 = 1.2 end

	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
	target.leap_direction = -difference:Normalized()
	target.leap_speed = 100 * 1/30

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	caster:SetForwardVector(difference)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_ElderTitan.Attack")
	--damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
	ability:ApplyDataDrivenModifier(caster, target, "bvo_sanji_skill_2_stun_modifier", {duration=0.15} )

	local strike = 0
	Timers:CreateTimer(0.15, function()
		if strike < 4 then
			strike = strike + 1
			if not caster:IsAlive() or caster:IsStunned() then return nil end
			if not target:IsAlive() or target:IsInvisible() then return nil end

			FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
			caster:SetForwardVector(difference)
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:EmitSound("Hero_ElderTitan.Attack")
			--damage
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
			ability:ApplyDataDrivenModifier(caster, target, "bvo_sanji_skill_2_stun_modifier", {duration=0.15} )
			return 0.15
		else
			return nil
		end
	end)
end

function KnockbackTarget2( keys )
	local owner = keys.caster
	local caster = keys.target

	local new_pos = caster:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	if caster:HasModifier("bvo_sanji_skill_2_stun_modifier") then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_sanji_skill_3(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_sanji_skill_3_modifier") then return end

	local level2 = caster:FindAbilityByName("bvo_sanji_skill_4_off"):GetLevel()
	caster:SwapAbilities("bvo_sanji_skill_4", "bvo_sanji_skill_4_off", true, true)
	caster:FindAbilityByName("bvo_sanji_skill_4"):SetLevel(level2)
	caster:FindAbilityByName("bvo_sanji_skill_4_off"):SetHidden(true)

	local level3 = caster:FindAbilityByName("bvo_sanji_skill_5_off"):GetLevel()
	caster:SwapAbilities("bvo_sanji_skill_5", "bvo_sanji_skill_5_off", true, true)
	caster:FindAbilityByName("bvo_sanji_skill_5"):SetLevel(level3)
	caster:FindAbilityByName("bvo_sanji_skill_5_off"):SetHidden(true)
end

function bvo_sanji_skill_3_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	local off_sync1 = caster:FindAbilityByName("bvo_sanji_skill_4"):GetCooldownTimeRemaining()
	local off_sync2 = caster:FindAbilityByName("bvo_sanji_skill_5"):GetCooldownTimeRemaining()

	local level2 = caster:FindAbilityByName("bvo_sanji_skill_4"):GetLevel()
	caster:SwapAbilities("bvo_sanji_skill_4", "bvo_sanji_skill_4_off", true, true)
	caster:FindAbilityByName("bvo_sanji_skill_4_off"):SetLevel(level2)
	caster:FindAbilityByName("bvo_sanji_skill_4"):SetHidden(true)

	local level3 = caster:FindAbilityByName("bvo_sanji_skill_5"):GetLevel()
	caster:SwapAbilities("bvo_sanji_skill_5", "bvo_sanji_skill_5_off", true, true)
	caster:FindAbilityByName("bvo_sanji_skill_5_off"):SetLevel(level3)
	caster:FindAbilityByName("bvo_sanji_skill_5"):SetHidden(true)

	caster:FindAbilityByName("bvo_sanji_skill_4_off"):StartCooldown(off_sync1)
	caster:FindAbilityByName("bvo_sanji_skill_5_off"):StartCooldown(off_sync2)

	StopSoundEvent("Hero_DoomBringer.ScorchedEarthAura", caster)

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_sanji_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	ability.hitList = {}

	for i = 0, 2 do
		local rotation = QAngle( 0, -25 + 25 * i, 0 )
		local rot_vector = RotatePosition(caster:GetAbsOrigin(), rotation, point)

		local info = 
		{
			Ability = keys.ability,
	    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
	    	vSpawnOrigin = caster:GetAbsOrigin(),
	    	fDistance = 1200,
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
			vVelocity = (rot_vector - caster:GetAbsOrigin()):Normalized() * 1200,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

function bvo_sanji_skill_4_damage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	for _,hit in pairs(ability.hitList) do
		if hit == target then return end
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)

	table.insert(ability.hitList, target)
end

function bvo_sanji_skill_4_clear(keys)
	local ability = keys.ability

	ability.hitList = {}
end

function bvo_sanji_skill_5(keys)
	local caster = keys.caster
	local target = keys.target

	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
	target.leap_direction = -difference:Normalized()
	target.leap_speed = 750 * 1/30

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_ElderTitan.Attack")
end

function KnockbackTarget3( keys )
	local owner = keys.caster
	local caster = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local new_pos = caster:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	if caster:HasModifier("bvo_sanji_skill_5_stun_modifier") then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:RemoveModifierByName("bvo_sanji_skill_5_stun_modifier")
			--
			local damageTable = {
				victim = caster,
				attacker = owner,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
			--
			local particleName = "particles/units/heroes/hero_lina/lina_spell_light_strike_array_explosion.vpcf"
			ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			caster:EmitSound("Ability.LightStrikeArray")
			--
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		local damageTable = {
			victim = caster,
			attacker = owner,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
		--
		local particleName = "particles/units/heroes/hero_lina/lina_spell_light_strike_array_explosion.vpcf"
		ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
		caster:EmitSound("Ability.LightStrikeArray")
		--
		caster:InterruptMotionControllers(true)
	end
end

function bvo_sanji_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("multi", ability:GetLevel() - 1 )
	local ability_2nd = caster:FindAbilityByName("bvo_sanji_skill_3")

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end