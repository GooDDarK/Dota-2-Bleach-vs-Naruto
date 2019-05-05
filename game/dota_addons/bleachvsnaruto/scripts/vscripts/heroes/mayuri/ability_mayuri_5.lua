require('timers')

function bvo_mayuri_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local forward = caster:GetForwardVector()

	ability:ApplyDataDrivenModifier(caster, target, "bvo_mayuri_skill_5_modifier", {duration=1.5})
	ability:ApplyDataDrivenModifier(caster, caster, "bvo_mayuri_skill_5_modifier", {duration=1.5})
	caster:Stop()
	target:Stop()

	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	local diff = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local distance = forward * (diff + 500)
	dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x + distance.x, dummy:GetAbsOrigin().y + distance.y, dummy:GetAbsOrigin().z - 512 ) )
	dummy:SetOriginalModel("models/hero_mayuri/unit_mayuri_bankai_base.vmdl")
	dummy:SetModel("models/hero_mayuri/unit_mayuri_bankai_base.vmdl")
	dummy:SetModelScale(4.0)
	dummy:SetForwardVector(-forward)
	dummy:SetAngles( dummy:GetAnglesAsVector().x - 45, dummy:GetAnglesAsVector().y, dummy:GetAnglesAsVector().z )
	dummy:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.5)
	
	local tick = 0
	Timers:CreateTimer(0.0, function ()
		if tick < 30 then
			tick = tick + 1
			dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z ) + dummy:GetForwardVector() * 10 )
			return 0.05
		else
			return nil
		end
	end)

	Timers:CreateTimer(1.5, function ()
		ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, target)
		target:EmitSound("Hero_LifeStealer.consume")

		local pdummy = CreateUnitByName("npc_dummy_unit", dummy:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		pdummy:AddAbility("custom_point_dummy")
		local abl = pdummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		ParticleManager:CreateParticle("particles/custom/mayuri/mayuri_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, pdummy)
		Timers:CreateTimer(3.0, function ()
			pdummy:RemoveSelf()
		end)
		dummy:RemoveSelf()

		caster:RemoveModifierByName("bvo_mayuri_skill_5_modifier")
		target:RemoveModifierByName("bvo_mayuri_skill_5_modifier")
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end)
end