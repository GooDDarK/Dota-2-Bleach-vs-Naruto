require('timers')

function bvo_sado_skill_2(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damage = keys.damage
	local ability = keys.ability
	local block = ability:GetLevelSpecialValueFor("damage_block", ability:GetLevel() - 1 )
	
	local true_damage = damage - block
	if true_damage > 0 then
		if true_damage > caster:GetHealth() then return end
		caster:Heal(block, caster)
	else
		caster:Heal(damage, caster)
	end
end

function bvo_sado_skill_3( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	if caster:HasModifier("bvo_sado_skill_4_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_sado_skill_3_modifier", {duration=0.2})
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 2.0)
		Timers:CreateTimer(0.2, function ()
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 1, Vector(1200, 0, 1200))
			caster:EmitSound("Hero_Brewmaster.ThunderClap")
			local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            800,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
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

				local damageTable2 = {
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE,
				}
				ApplyDamage(damageTable2)

				ability:ApplyDataDrivenModifier(caster, target, "bvo_sado_skill_3_stun_modifier", {duration=1.25})
			end
		end)
	end
end

function bvo_sado_skill_3_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
	ability:ApplyDataDrivenModifier(caster, target, "bvo_sado_skill_3_stun_modifier", {duration=1.25})

	if caster:HasModifier("bvo_sado_skill_4_modifier") then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end
end

function bvo_sado_skill_4(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_sado_skill_4_modifier") then return end
end

function bvo_sado_skill_4_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_sado_skill_5(keys)
	local caster = keys.caster
	local target = keys.target

	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
	target.leap_direction = -difference:Normalized()
	target.leap_speed = 1300 * 1/30

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_Slardar.Attack")
	caster:EmitSound("Hero_Slardar.Attack.Impact")
end

function KnockbackTarget( keys )
	local owner = keys.caster
	local caster = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("final_damage", ability:GetLevel() - 1 )

	local new_pos = caster:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	local new_pos2 = owner:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	if caster:HasModifier("bvo_sado_skill_5_stun_modifier") then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			owner:RemoveModifierByName("bvo_sado_skill_5_stun_self_modifier")
			caster:RemoveModifierByName("bvo_sado_skill_5_stun_modifier")

			local damageTable = {
				victim = caster,
				attacker = owner,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			ApplyDamage(damageTable)

			local particleName = "particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 1, Vector(1200, 0, 1200))
			caster:EmitSound("Hero_Brewmaster.ThunderClap")

			caster:InterruptMotionControllers(true)
		else
			FindClearSpaceForUnit(owner, new_pos2, false)
			caster:SetAbsOrigin(new_pos)
		end
	else
		owner:RemoveModifierByName("bvo_sado_skill_5_stun_self_modifier")

		local damageTable = {
			victim = caster,
			attacker = owner,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)

		local particleName = "particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 1, Vector(1200, 0, 1200))
		caster:EmitSound("Hero_Brewmaster.ThunderClap")

		caster:InterruptMotionControllers(true)
	end
end

function bvo_sado_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end