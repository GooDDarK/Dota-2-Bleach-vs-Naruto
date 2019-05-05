function bvo_law_skill_2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not caster:HasModifier("bvo_law_skill_1_ally_modifier") then return end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin(),
	            nil,
	            FIND_UNITS_EVERYWHERE,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		if unit ~= target and unit:HasModifier("bvo_law_skill_1_enemy_modifier") then
			local projTable = {
		        EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf",
		        Ability = ability,
		        Target = unit,
		        Source = caster,
		        bDodgeable = true,
		        bProvidesVision = false,
		        vSpawnOrigin = caster:GetAbsOrigin(),
		        iMoveSpeed = 2000,
		        iVisionRadius = 0,
		        iVisionTeamNumber = caster:GetTeamNumber(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		    }
		    ProjectileManager:CreateTrackingProjectile(projTable)
		end
	end
end

function bvo_law_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )
	local room_multi = ability:GetLevelSpecialValueFor("room_multi", ability:GetLevel() - 1 )

	if not caster:HasModifier("bvo_law_skill_1_ally_modifier") or not target:HasModifier("bvo_law_skill_1_enemy_modifier") then
		room_multi = 0
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end