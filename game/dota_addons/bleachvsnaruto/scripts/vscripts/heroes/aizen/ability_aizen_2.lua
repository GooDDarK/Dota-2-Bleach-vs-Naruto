function bvo_aizen_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	ProjectileManager:ProjectileDodge(caster)

	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 2.0)
	caster:EmitSound("Hero_Antimage.Attack")
	caster:EmitSound("Hero_PhantomAssassin.Strike.Start")
	caster:EmitSound("Hero_PhantomAssassin.Strike.End")
	target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")

	caster:MoveToTargetToAttack(target)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end