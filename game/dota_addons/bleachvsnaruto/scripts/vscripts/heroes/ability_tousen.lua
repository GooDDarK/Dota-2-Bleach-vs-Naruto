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

function bvo_tousen_skill_1_damage_non(keys)
	local caster = keys.caster
	local target = keys.target

	if not target:IsHero() then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = 300,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end
end

function bvo_tousen_skill_1_damage_hero(keys)
	local caster = keys.attacker
	local target = keys.unit
	local damage = keys.damage

	if target:IsHero() and caster:IsHero() then
		target:RemoveModifierByName("bvo_tousen_skill_1_modifier")
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end
end

function bvo_tousen_skill_3_damage(keys)
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

function bvo_tousen_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()

	for i = 0, 6 do
		local rotation = QAngle( 0, -30 + 10 * i, 0 )
		local rot_vector = RotatePosition(casterPos, rotation, point)

		local info = 
		{
			Ability = keys.ability,
	    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
	    	vSpawnOrigin = casterPos,
	    	fDistance = 1400,
	    	fStartRadius = 125,
	    	fEndRadius = 250,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = (rot_vector - casterPos):Normalized() * 1800,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)
		--
		local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 92 ) )
		dummy:SetAbsOrigin( dummy:GetAbsOrigin() + forward * 48)
		dummy:SetForwardVector((rot_vector - casterPos):Normalized())
		dummy:SetOriginalModel("models/items/abaddon/weta_fractured_sword_of_eternity_weapon/weta_fractured_sword_of_eternity_weapon.vmdl")
		dummy:SetModel("models/items/abaddon/weta_fractured_sword_of_eternity_weapon/weta_fractured_sword_of_eternity_weapon.vmdl")
		dummy:SetModelScale(1.0)
		--motion
		local leap_direction = (rot_vector - casterPos):Normalized()
		local leap_distance = 1400
		local leap_speed = 1800 * 1/30
		local leap_traveled = 0
		Timers:CreateTimer(0.03, function()
			if leap_traveled < leap_distance then
				local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
				dummy:SetAbsOrigin(new_pos)
				leap_traveled = leap_traveled + leap_speed
				return 0.03
			else
				dummy:RemoveSelf()
			end
		end)
	end
end

function bvo_tousen_skill_4_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_tousen_skill_5(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()

	local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_tousen_skill_5_dummy", nil)
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_tousen_skill_5_dummy_self", nil)

	if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		local particle = ParticleManager:CreateParticleForTeam("particles/custom/tousen/tousen_skill_5.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_GOODGUYS)
		ParticleManager:SetParticleControl(particle, 0, dummy:GetAbsOrigin())

		local particle2 = ParticleManager:CreateParticleForTeam("particles/custom/tousen/tousen_skill_5_enemy.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_BADGUYS)
		ParticleManager:SetParticleControl(particle2, 0, dummy:GetAbsOrigin())

		dummy.bankaiVPCF1 = particle
		dummy.bankaiVPCF2 = particle2
	else
		local particle = ParticleManager:CreateParticleForTeam("particles/custom/tousen/tousen_skill_5.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_BADGUYS)
		ParticleManager:SetParticleControl(particle, 0, dummy:GetAbsOrigin())

		local particle2 = ParticleManager:CreateParticleForTeam("particles/custom/tousen/tousen_skill_5_enemy.vpcf", PATTACH_WORLDORIGIN, caster, DOTA_TEAM_GOODGUYS)
		ParticleManager:SetParticleControl(particle2, 0, dummy:GetAbsOrigin())

		dummy.bankaiVPCF1 = particle
		dummy.bankaiVPCF2 = particle2
	end

	ability.tether_ally = dummy
	--cast
end

function bvo_tousen_skill_5_checkDistance( event )
	local caster = event.caster
	local ability = event.ability

	if ability.tether_ally == nil then return end

	local distance = ( ability.tether_ally:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()
	if distance <= event.radius then
		return
	end

	bvo_tousen_skill_5_end(event)
end

function bvo_tousen_skill_5_end( event )
	local caster = event.caster
	local ability = event.ability

	if ability.tether_ally ~= nil and not ability.tether_ally:IsNull() then
		ParticleManager:DestroyParticle(ability.tether_ally.bankaiVPCF1, true)
		ParticleManager:DestroyParticle(ability.tether_ally.bankaiVPCF2, true)
		ability.tether_ally:RemoveSelf()
		ability.tether_ally = nil
		caster:RemoveModifierByName("bvo_tousen_skill_5_modifier")
		--end
	end
end