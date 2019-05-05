require('timers')
require('lib/duel_lib')

function bvo_yoruichi_skill_1(keys)
	local caster = keys.caster
	local ability = keys.ability
	local distance = keys.distance

	local speed = 1000
	if caster:HasModifier("bvo_yoruichi_skill_4_modifier") or caster:HasModifier("bvo_yoruichi_skill_4_perma_modifier") then speed = 1500 end
	local info = 
	{
		Ability = ability,
    	EffectName = "particles/econ/items/puck/puck_merry_wanderer/puck_illusory_orb_merry_wanderer.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = distance,
    	fStartRadius = 150,
    	fEndRadius = 150,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector():Normalized() * speed,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ability.projectile = ProjectileManager:CreateLinearProjectile(info)
	ability.point = caster:GetAbsOrigin()
	ability.max = distance
	caster:EmitSound("Hero_Puck.EtherealJaunt")
end

function bvo_yoruichi_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = keys.multi

	if target:IsHero() then
		if not caster:IsStunned() and caster:IsAlive() then
			local dif = ability.point - target:GetAbsOrigin()
			local upto = dif:Length2D() / ability.max

			FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
			ProjectileManager:ProjectileDodge(caster)

			caster:StartGesture(ACT_DOTA_ATTACK)
			ProjectileManager:DestroyLinearProjectile(ability.projectile)
			--damage
			caster:MoveToTargetToAttack(target)
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = (multi * caster:GetAgility()) * upto,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			ApplyDamage(damageTable)

			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, Vector(275, 0, 275))
			caster:EmitSound("Hero_Centaur.HoofStomp")

			ability:ApplyDataDrivenModifier(caster, target, "bvo_yoruichi_skill_1_stun_modifier", {duration=1.0} )
		end
	else
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = 300,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
		target:EmitSound("Hero_Puck.IIllusory_Orb_Damage")
	end
end

function bvo_yoruichi_skill_2_hit_s(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability

	if not attacker:IsHero() then
		return
	end

	local check = 450
	if caster:HasModifier("bvo_yoruichi_skill_4_modifier") or caster:HasModifier("bvo_yoruichi_skill_4_perma_modifier") then check = 600 end
	local dif = caster:GetAbsOrigin() - attacker:GetAbsOrigin()
	if dif:Length2D() < check then
		caster:SetForwardVector(-dif:Normalized())
	end
end

function bvo_yoruichi_skill_2_hit(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability

	if not attacker:IsHero() then
		caster:InterruptMotionControllers(false)
		attacker:InterruptMotionControllers(false)
		return
	end

	local check = 450
	local speed = 2250
	if caster:HasModifier("bvo_yoruichi_skill_4_modifier") or caster:HasModifier("bvo_yoruichi_skill_4_perma_modifier") then
		check = 600
		speed = 3375
	end
	local dif = caster:GetAbsOrigin() - attacker:GetAbsOrigin()
	if dif:Length2D() < check then
		caster:RemoveModifierByName("bvo_yoruichi_skill_2_modifier")

		attacker.direction_y2 = -dif:Normalized()
		attacker.speed_y2 = speed * 1/30

		caster.direction_y2 = -dif:Normalized()
		local extra = (dif:Length2D() / 8) * 30
		caster.speed_y2 = (speed + extra) * 1/30

		ability:ApplyDataDrivenModifier(caster, caster, "bvo_yoruichi_skill_2_stun_modifier", {duration=0.2} )
		ability:ApplyDataDrivenModifier(caster, attacker, "bvo_yoruichi_skill_2_stun_modifier", {duration=0.2} )

		caster:StartGesture(ACT_DOTA_ATTACK)
	else
		caster:InterruptMotionControllers(false)
		attacker:InterruptMotionControllers(false)
	end
end

function KnockbackTarget( keys )
	local owner = keys.caster
	local caster = keys.target
	local ability = keys.ability

	if caster:HasModifier("bvo_yoruichi_skill_2_stun_modifier") then
		local new_pos = caster:GetAbsOrigin() + caster.direction_y2 * caster.speed_y2
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
			if caster:GetClassname() ~= "npc_dota_hero_spectre" then
				local multi = 5
				local dur = 0.85
				if caster:HasModifier("bvo_yoruichi_skill_4_modifier") or caster:HasModifier("bvo_yoruichi_skill_4_perma_modifier") then
					multi = 6
					dur = 1.4
				end
				local damageTable = {
					victim = caster,
					attacker = owner,
					damage = owner:GetBaseAgility() * multi,
					damage_type = DAMAGE_TYPE_PURE,
				}
				ApplyDamage(damageTable)
				ability:ApplyDataDrivenModifier(owner, caster, "bvo_yoruichi_skill_2_stun2_modifier", {duration=dur} )
				owner:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")
			end
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
		if caster:GetClassname() ~= "npc_dota_hero_spectre" then
			local multi = 5
			local dur = 0.85
			if caster:HasModifier("bvo_yoruichi_skill_4_modifier") or caster:HasModifier("bvo_yoruichi_skill_4_perma_modifier") then
				multi = 6
				dur = 1.4
			end
			local damageTable = {
				victim = caster,
				attacker = owner,
				damage = owner:GetBaseAgility() * multi,
				damage_type = DAMAGE_TYPE_PURE,
			}
			ApplyDamage(damageTable)
			ability:ApplyDataDrivenModifier(owner, caster, "bvo_yoruichi_skill_2_stun2_modifier", {duration=dur} )
			owner:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")
		end
	end
end

function bvo_yoruichi_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	if caster:HasModifier("bvo_yoruichi_skill_4_modifier") then multi = multi + 1 end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetAgility() * multi,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)

	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_Spectre.Attack")

	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )

	Timers:CreateTimer(0.25, function()
		bvo_yoruichi_skill_3_jump(caster, keys.jumps - 1, multi, target)
	end)
end

function bvo_yoruichi_skill_3_jump(caster, jumps, multi, target)
	jumps = jumps - 1

	if not caster:IsAlive() or caster:IsStunned() then return end

	localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
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

			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = caster:GetAgility() * multi,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)

			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:EmitSound("Hero_Spectre.Attack")

			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, unit:GetAbsOrigin() )
			target = unit
			break
		end
	else
		jumps = 0
	end

	if jumps > 0 then
		Timers:CreateTimer(0.25, function()
			bvo_yoruichi_skill_3_jump(caster, jumps, multi, target)
		end)
	end
end

function bvo_yoruichi_skill_4(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_yoruichi_skill_4_modifier") then return end

	local level3 = caster:FindAbilityByName("bvo_yoruichi_skill_5_off"):GetLevel()
	caster:SwapAbilities("bvo_yoruichi_skill_5", "bvo_yoruichi_skill_5_off", true, true)
	caster:FindAbilityByName("bvo_yoruichi_skill_5"):SetLevel(level3)
	caster:FindAbilityByName("bvo_yoruichi_skill_5_off"):SetHidden(true)
end

function bvo_yoruichi_skill_4_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	local off_sync1 = caster:FindAbilityByName("bvo_yoruichi_skill_5"):GetCooldownTimeRemaining()

	local level3 = caster:FindAbilityByName("bvo_yoruichi_skill_5"):GetLevel()
	caster:SwapAbilities("bvo_yoruichi_skill_5", "bvo_yoruichi_skill_5_off", true, true)
	caster:FindAbilityByName("bvo_yoruichi_skill_5_off"):SetLevel(level3)
	caster:FindAbilityByName("bvo_yoruichi_skill_5"):SetHidden(true)

	caster:FindAbilityByName("bvo_yoruichi_skill_5_off"):StartCooldown(off_sync1)

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_yoruichi_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("agi_final", ability:GetLevel() - 1 )
	local tick = ability:GetLevelSpecialValueFor("agi_tick", ability:GetLevel() - 1 )

	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	caster:SetForwardVector(difference)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_Spectre.Attack")
	--damage
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetAgility() * 1.0,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)

	local strike = 0
	Timers:CreateTimer(0.05, function()
		if strike < 15 then
			strike = strike + 1
			if not caster:IsAlive() then return nil end
			if not target:IsAlive() or target:IsInvisible() then return nil end

			FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
			caster:SetForwardVector(difference)
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:EmitSound("Hero_Spectre.Attack")

			--damage
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = caster:GetAgility() * tick,
				damage_type = DAMAGE_TYPE_PURE,
			}
			ApplyDamage(damageTable)
			return 0.05
		else
			FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
			caster:SetForwardVector(difference)
			caster:StartGesture(ACT_DOTA_ATTACK2)

			--damage
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = caster:GetAgility() * multi,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)

			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, Vector(275, 0, 275))
			caster:EmitSound("Hero_Centaur.HoofStomp")
			return nil
		end
	end)
end