function bvo_ulquiorra_skill_4(keys)
    local caster = keys.caster
    local ability = keys.ability
    local length = ability:GetLevelSpecialValueFor("length", (ability:GetLevel() - 1))

    local casterOrigin = caster:GetAbsOrigin()
    local casterForward = caster:GetForwardVector()

    local particleName = "particles/custom/ulquiorra/ulquiorra_skill_4.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true )

	local endcapPos = casterOrigin + casterForward * length
	caster.skill4Endpoint = endcapPos

	endcapPos = GetGroundPosition( endcapPos, nil )
	endcapPos.z = endcapPos.z + 92
	ParticleManager:SetParticleControl( pfx, 1, endcapPos )

	caster.skill4Particle = pfx
end

function bvo_ulquiorra_skill_4_tick( keys )
	local caster = keys.caster
	local ability = keys.ability
    local damage = ability:GetLevelSpecialValueFor("damage_tick", (ability:GetLevel() - 1))
    local width = ability:GetLevelSpecialValueFor("width", (ability:GetLevel() - 1))

	local units = FindUnitsInLine(caster:GetTeamNumber(),
								caster:GetAbsOrigin(),
								caster.skill4Endpoint,
								nil,
								width,
								DOTA_UNIT_TARGET_TEAM_ENEMY,
								DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
								DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)

	for _,unit in pairs(units) do
	   local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)

		ability:ApplyDataDrivenModifier(caster, unit, "bvo_ulquiorra_skill_4_slow_modifier", {duration=0.25})
	end
end

function bvo_ulquiorra_skill_4_end(keys)
    local caster = keys.caster

    StopSoundEvent("Hero_Phoenix.SunRay.Loop", caster)
    ParticleManager:DestroyParticle(caster.skill4Particle, true)
end