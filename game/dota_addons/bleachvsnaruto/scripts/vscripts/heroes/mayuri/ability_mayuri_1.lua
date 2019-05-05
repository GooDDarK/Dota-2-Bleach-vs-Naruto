require('timers')

function bvo_mayuri_skill_1(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local ability = keys.ability
    local autocast = ability:GetLevelSpecialValueFor("autocast", ability:GetLevel() - 1 )

    caster.bvo_mayuri_skill_1_point = point

	local timer_info = {
        endTime = autocast,
        callback = function()
        	bvo_mayuri_skill_1_explode(keys)
            return nil
        end
    }
	Timers:CreateTimer("MAYURI_CAST_SKILL_1", timer_info)

	caster.bvo_mayuri_skill_1_particle = ParticleManager:CreateParticleForTeam("particles/newplayer_fx/npx_moveto_arrow.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(caster.bvo_mayuri_skill_1_particle, 0, point)
end

function bvo_mayuri_skill_1_explode(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
    local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )
    local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
    local point = caster.bvo_mayuri_skill_1_point

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            point,
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end
	--particle
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_POINT, dummy)
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
	dummy:EmitSound("Hero_Gyrocopter.CallDown.Damage")
	ParticleManager:DestroyParticle(caster.bvo_mayuri_skill_1_particle, true)
end

function bvo_mayuri_skill_1_cast(keys)
    Timers:RemoveTimer("MAYURI_CAST_SKILL_1")
    keys.ability = keys.caster:FindAbilityByName("bvo_mayuri_skill_1")
    bvo_mayuri_skill_1_explode(keys)
end