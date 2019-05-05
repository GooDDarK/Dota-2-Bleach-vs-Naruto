function bvo_law_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("lvl_multi", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	ability:ApplyDataDrivenModifier(caster, target, "bvo_law_skill_5_modifier", {duration=duration})

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end