function bvo_mayuri_skill_3_init(keys)
	keys.ability.target = keys.target
end

function bvo_mayuri_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.target
	local int_multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )
	local agi_multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )
	
	target:Heal(( caster:GetIntellect() * int_multi ) + ( caster:GetAgility() * agi_multi ), caster)
	target:EmitSound("Hero_Omniknight.Purification")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(125,125,125))
end