function bvo_law_skill_0(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target == caster then
		ability:EndCooldown()
		ability:RefundManaCost();
		return
	end
	if not caster:HasModifier("bvo_law_skill_1_ally_modifier") or not ( target:HasModifier("bvo_law_skill_1_enemy_modifier") or target:HasModifier("bvo_law_skill_1_ally_modifier") ) then
		ability:EndCooldown()
		ability:RefundManaCost();
		return
	end

	local casterPos = caster:GetAbsOrigin()
	local targetPos = target:GetAbsOrigin()

	FindClearSpaceForUnit(caster, targetPos, false)
	FindClearSpaceForUnit(target, casterPos, false)

	caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
	target:EmitSound("Hero_VengefulSpirit.NetherSwap")

	target:Stop();
end