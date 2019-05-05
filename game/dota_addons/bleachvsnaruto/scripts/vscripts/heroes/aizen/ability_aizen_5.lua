function bvo_aizen_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local skillDuration = 1.5
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 1.0)

	ability:ApplyDataDrivenModifier(caster, target, "bvo_aizen_skill_5_modifier_enemy", {duration=skillDuration})
	ability:ApplyDataDrivenModifier(caster, caster, "bvo_aizen_skill_5_modifier", {duration=skillDuration})

	local particle = ParticleManager:CreateParticle( "particles/custom/aizen/aizen_skill_5.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl(particle, 1, Vector(30, 30, 40) )

	local particle_name = "particles/units/heroes/hero_death_prophet/death_prophet_death.vpcf"
	local _repeat = 5
	for i = 0, _repeat - 1 do
		Timers:CreateTimer( (skillDuration / _repeat) * i, function ()
			target:EmitSound("Hero_DeathProphet.Exorcism.Cast")
			local _particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN, target )
			ParticleManager:SetParticleControl(_particle, 0, target:GetAbsOrigin() )
		end)
	end

	caster:Stop()
	target:Stop()

	Timers:CreateTimer(skillDuration, function()
		caster:RemoveModifierByName("bvo_aizen_skill_5_modifier")
		target:RemoveModifierByName("bvo_aizen_skill_5_modifier_enemy")

		target:EmitSound("Hero_Bloodseeker.Rupture.Cast")

		local damageTable = {
			victim = target,
			attacker = caster,
			damage =  damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end)
end