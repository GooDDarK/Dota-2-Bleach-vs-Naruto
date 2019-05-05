require('timers')

function enel_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.Bonus

	if target:IsMagicImmune() then
		return
	end

	local c_int = caster:GetIntellect()

	local p_dmg = c_int * multi

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = p_dmg,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function enel_skill_3(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.Bonus

	local c_int = caster:GetIntellect()

	local p_dmg = c_int * multi

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = p_dmg,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)

	local particleName = "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf"
	ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, target)
end