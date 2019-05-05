require('timers')

function kailin_boss_ai_init(keys)
	local caster = keys.caster

	caster.state = "idle"
	print('AI: idle')
end

function kailin_boss_ai(keys)
	local caster = keys.caster

	--chase and return aggro
	local AQRange = 1200

	if caster.hasAggroOn ~= nil then
		local difference = caster:GetAbsOrigin() - caster.spawnOrigin
		if difference:Length2D() > AQRange then
			caster.hasAggroOn = nil
			caster:SetForceAttackTarget(nil)
			caster.returning = true
			caster:MoveToPosition(caster.spawnOrigin)
		end
	end

	if caster.returning then
		local difference = caster:GetAbsOrigin() - caster.spawnOrigin
		if difference:Length2D() < 250 then
			caster.returning = false
		end
	end

	if caster.hasAggroOn ~= nil then
		if not caster.hasAggroOn:IsAlive() then
			caster.hasAggroOn = nil
			caster:SetForceAttackTarget(nil)
			caster.returning = true
		end
	end

	for _,unit in pairs(_G.tHeroesRadiant) do
		if caster:GetRangeToUnit(unit) < AQRange and caster.hasAggroOn == nil and not caster.returning and unit:IsAlive() then
			caster.hasAggroOn = unit
			caster:SetForceAttackTarget(unit)
			return
		end
	end

	for _,unit in pairs(_G.tHeroesDire) do
		if caster:GetRangeToUnit(unit) < AQRange and caster.hasAggroOn == nil and not caster.returning and unit:IsAlive() then
			caster.hasAggroOn = unit
			caster:SetForceAttackTarget(unit)
			return
		end
	end

	--cast spells
	if caster.state == "casting" then return end
	local skill_1 = caster:FindAbilityByName("bvo_kailin_skill_1")
	local skill_2 = caster:FindAbilityByName("bvo_kailin_skill_2_prep")
	local castSkil = nil
	local skillAoE = nil
	if skill_1:IsCooldownReady() then
		castSkill = skill_1
		skillAoE = 800
	end
	if skill_2:IsCooldownReady() then
		castSkill = skill_2
		skillAoE = 600
	end

	if castSkill == nil or skillAoE == nil then return end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            skillAoE,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_ANY_ORDER,
	            false)

	if #localUnits > 0 then
		for _,heroTarget in pairs(localUnits) do
			caster.state = "casting"
			if castSkill == skill_1 then
				caster:CastAbilityOnPosition(heroTarget:GetAbsOrigin(), castSkill, caster:GetTeamNumber())
				print('AI: casting skill1')
			elseif castSkill == skill_2 then
				caster:CastAbilityNoTarget(castSkill, caster:GetTeamNumber())
				print('AI: casting skill2')
			end
			break
		end
	end
end

function bvo_kailin_skill_1(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local originalPos = caster:GetAbsOrigin()

	local strike = 0
	Timers:CreateTimer(0.1, function()
		if strike < 20 then
			strike = strike + 1
			local rotation = QAngle( 0, RandomInt(0, 360), 0 )
			local rot_vector = RotatePosition(point, rotation, point + Vector(0, 600, 0))
			local middle_point = point - rot_vector

			FindClearSpaceForUnit(caster, point + middle_point, false)
			caster:SetForwardVector(-middle_point:Normalized())
			caster:StartGesture(ACT_DOTA_ATTACK)
			local info = 
			{
				Ability = ability,
		    	EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		    	vSpawnOrigin = point + middle_point,
		    	fDistance = 1200,
		    	fStartRadius = 128,
		    	fEndRadius = 128,
		    	Source = caster,
		    	bHasFrontalCone = false,
		    	bReplaceExisting = false,
		    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		    	fExpireTime = GameRules:GetGameTime() + 10.0,
				bDeleteOnHit = false,
				vVelocity = -middle_point:Normalized() * 2000,
				bProvidesVision = false,
				iVisionRadius = 1000,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			projectile = ProjectileManager:CreateLinearProjectile(info)
			return 0.1
		else
			FindClearSpaceForUnit(caster, originalPos, false)
			caster:RemoveModifierByName("bvo_kailin_skill_1_modifier")
			caster.state = "idle"
			print('AI: skill1 -> idle')
			return nil
		end
	end)
end

function bvo_kailin_skill_2_prep(keys)
	local caster = keys.caster
	local ability = keys.ability
	local tell = 0
	Timers:CreateTimer(0.5, function()
		if tell < 3 then
			tell = tell + 1
			local particleName = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_shock.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			return 0.5
		else
			local particleName = "particles/units/heroes/hero_centaur/centaur_warstomp_shockwave.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl( particle, 0, Vector(900, 0, 900) )
			--
			local skill_2 = caster:FindAbilityByName("bvo_kailin_skill_2")
			caster:CastAbilityNoTarget(skill_2, caster:GetTeamNumber())
			ability:StartCooldown(40.0)
			return nil
		end
	end)
end

function bvo_kailin_skill_2(keys)
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local ability = keys.ability

	ability.point = point
	caster.state = "idle"
	print('AI: skill2 -> idle')
end

function bvo_kailin_skill_2_mc(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local difference = ability.point - target:GetAbsOrigin()
	ability.leap_distance = 1600
	target.leap_direction = -difference:Normalized()
	target.leap_speed = 3000 * 1/30
	target.leap_traveled = 0
end

function PointVacuum( keys )
	local owner = keys.caster
	local caster = keys.target
	local ability = keys.ability

	local new_pos = caster:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	if caster.leap_traveled < ability.leap_distance then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:RemoveModifierByName("bvo_kailin_skill_2_stun_modifier")
			ability:ApplyDataDrivenModifier(owner, caster, "bvo_kailin_skill_2_slow_modifier", {duration=5.0} )
			--
			local particleName = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl( particle, 0, Vector(600, 0, 600) )
			--
			local damageTable = {
				victim = caster,
				attacker = owner,
				damage = 2000,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)
			--
			caster:InterruptMotionControllers(true)
		else
			caster.leap_traveled = caster.leap_traveled + caster.leap_speed
			caster:SetAbsOrigin(new_pos)
		end
	else
		--
		local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		dummy:SetModel("models/hero_kailin/hero_kailin_base.vmdl")
		dummy:SetOriginalModel("models/hero_kailin/hero_kailin_base.vmdl")
		dummy:SetModelScale(2.25)
		local vec_for = owner:GetAbsOrigin() - caster:GetAbsOrigin()
		dummy:SetForwardVector(vec_for)
		dummy:StartGesture(ACT_DOTA_ATTACK)
		Timers:CreateTimer(0.75, function ()
			dummy:RemoveSelf()
		end)
		--
		local damageTable = {
			victim = caster,
			attacker = owner,
			damage = 2000,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
		--
		local particleName = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl( particle, 0, Vector(600, 0, 600) )
		--
		caster:RemoveModifierByName("bvo_kailin_skill_2_stun_modifier")
		ability:ApplyDataDrivenModifier(owner, caster, "bvo_kailin_skill_2_slow_modifier", {duration=5.0} )
		--
		caster:InterruptMotionControllers(true)
	end
end

function bvo_kailin_skill_3(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damage = keys.damage
	
	if damage > 800 then
		damage = damage - 800
		--if damage > caster:GetHealth() then return end
		caster:Heal(damage, caster)
	end
end

function bvo_kailin_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	if ability:IsCooldownReady() then
		caster:Heal(caster:GetMaxHealth() * 0.1, caster)
	end
end

function bvo_kailin_skill_4_hit(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	ability:StartCooldown(5.0)
end