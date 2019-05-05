function bvo_mihawk_skill_1_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "bvo_mihawk_skill_1_modifier"
	local duration = 5
	local max_stack = 3
	caster:EmitSound("DOTA_Item.Butterfly")
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { } )
	caster:SetModifierStackCount( modifierName, ability, max_stack )
end

function bvo_mihawk_skill_1_decrease_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )
	local modifierName = "bvo_mihawk_skill_1_modifier"
	local current_stack = caster:GetModifierStackCount( modifierName, ability )
	
	local str = caster:GetBaseStrength()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)

	if current_stack > 1 then
		caster:SetModifierStackCount( modifierName, ability, current_stack - 1 )
	else
		caster:RemoveModifierByName( modifierName )
	end
end

function bvo_mihawk_skill_3(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
	caster:EmitSound("Hero_Magnataur.ShockWave.Particle")
	for i = 0, 2 do
		local rotation = QAngle( 0, -25 + 25 * i, 0 )
		local rot_vector = RotatePosition(casterPos, rotation, point)

		local info = 
		{
			Ability = keys.ability,
	    	EffectName = "particles/custom/mihawk/mihawk_shockwave.vpcf",
	    	vSpawnOrigin = casterPos,
	    	fDistance = 1000,
	    	fStartRadius = 250,
	    	fEndRadius = 250,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = (rot_vector - casterPos):Normalized() * 1200,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

function bvo_mihawk_skill_4(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local ability = keys.ability
	local distance = ability:GetLevelSpecialValueFor("distance", ability:GetLevel() - 1 )
	caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
	caster:EmitSound("Hero_Magnataur.ShockWave.Particle")
	for i = 0, 11 do
	    local rotation = QAngle( 0, 30 * i, 0 )
		local rot_vector = RotatePosition(casterPos, rotation, casterPos + Vector(0, 100, 0))
		local info = 
		{
			Ability = ability,
	    	EffectName = "particles/custom/mihawk/mihawk_shockwave.vpcf",
	    	vSpawnOrigin = casterPos,
	    	fDistance = distance,
	    	fStartRadius = 10,
	    	fEndRadius = 450,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = (rot_vector - casterPos):Normalized() * 1200,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

function bvo_mihawk_skill_4_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local range = ability:GetLevelSpecialValueFor("distance", ability:GetLevel() - 1 )
	local difference = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local dif = difference:Length2D()
	if dif > range then dif = range end

	local multi = 1 - (dif / range)
	if multi < 0.25 then multi = 0.25 end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end