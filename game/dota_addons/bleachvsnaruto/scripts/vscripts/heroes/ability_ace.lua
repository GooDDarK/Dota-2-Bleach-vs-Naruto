require('timers')

function bvo_ace_skill_0(keys)
	local caster = keys.caster
	local attacker = keys.attacker

	if not attacker:IsMagicImmune() then
		local damageTable = {
			victim = attacker,
			attacker = caster,
			damage = attacker:GetHealth() * 0.05,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end
end

function bvo_ace_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("lvl_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + (caster:GetLevel() * multi),
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

function bvo_ace_skill_3(keys)
	local caster = keys.caster

	local particleName = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle , 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle , 1, Vector(350, 0, 0) )
	ParticleManager:SetParticleControl(particle , 3, Vector(0, 0, 0) )
	caster:EmitSound("Ability.LightStrikeArray")
end

function bvo_ace_skill_3_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("lvl_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + (caster:GetLevel() * multi),
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

function bvo_ace_skill_4_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	if target:IsMagicImmune() then
		return
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetAgility() * multi,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_ace_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("lvl_multi", ability:GetLevel() - 1 )

	if not caster:IsAlive() then return end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = 3000 + (caster:GetLevel() * multi),
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

function bvo_ace_skill_5_dummy(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	local pos = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 320 )
	dummy:SetAbsOrigin(pos)
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	dummy:SetModel("models/heroes/phoenix/phoenix_egg.vmdl")
	dummy:SetOriginalModel("models/heroes/phoenix/phoenix_egg.vmdl")

	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_ace_skill_5_modifier_dummy", {} )

	ability.dummy = dummy
end

function bvo_ace_skill_5_dead(keys)
	local ability = keys.ability

	local dummy = CreateUnitByName("npc_dummy_unit", ability.dummy:GetAbsOrigin(), false, nil, nil, ability.dummy:GetTeam())
	dummy:SetAbsOrigin(ability.dummy:GetAbsOrigin())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	local particleName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
	ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, dummy)

	ability.dummy:RemoveSelf()

	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)
end

function bvo_ace_skill_5_grow(keys)
	local caster = keys.target

	caster:SetModelScale(caster:GetModelScale() + 0.1)
	local pos = Vector( caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z + 8 )
	caster:SetAbsOrigin(pos)
end