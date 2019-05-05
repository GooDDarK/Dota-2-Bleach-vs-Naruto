require('timers')

function bvo_ulquiorra_skill_5( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	local dummy = CreateUnitByName("npc_dummy_unit", point, false, caster, caster, caster:GetTeamNumber())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	
	if dummy ~= nil then
		local projTable = {
	        EffectName = "particles/custom/ulquiorra_skill_5.vpcf",
	        Ability = ability,
	        Target = dummy,
	        Source = caster,
	        bDodgeable = false,
	        bProvidesVision = false,
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        iMoveSpeed = 2400,
	        iVisionRadius = 0,
	        iVisionTeamNumber = caster:GetTeamNumber(),
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	    }
	    ProjectileManager:CreateTrackingProjectile(projTable)
	end
end

function bvo_ulquiorra_skill_5_hit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
    local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
    local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

    local particleName = "particles/custom/ulquiorra/ulquiorra_skill_5.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, Vector(radius*2, radius*2, radius*2) )

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end

	Timers:CreateTimer(3.0, function ()
		target:RemoveSelf()
	end)
end