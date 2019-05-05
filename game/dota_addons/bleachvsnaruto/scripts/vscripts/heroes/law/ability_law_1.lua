require("timers")

function bvo_law_skill_1(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local radius_extra = ability:GetLevelSpecialValueFor("radius_extra", ability:GetLevel() - 1 )

	caster:EmitSound("BleachVsOnePieceReborn.LawSkill0")
	local particleName = "particles/custom/law/law_skill_0_room.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle , 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle , 1, Vector(radius, 0, 50))
	ParticleManager:SetParticleControl(particle , 2, Vector(radius_extra, 0, 0))

	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_law_skill_1_aura_ally_modifier", {})
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_law_skill_1_aura_enemy_modifier", {})

	Timers:CreateTimer(duration, function ()
		dummy:RemoveSelf()
	end)
end