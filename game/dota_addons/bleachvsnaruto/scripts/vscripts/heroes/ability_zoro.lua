require('timers')

function bvo_zoro_skill_0(keys)
    local caster = keys.caster
    local target = keys.target

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
	ProjectileManager:ProjectileDodge(caster)
	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_Sven.Attack")
	caster:EmitSound("Hero_PhantomAssassin.Strike.Start")
	caster:EmitSound("Hero_PhantomAssassin.Strike.End")

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetStrength() * 4,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_zoro_skill_2(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector() 

	local v1 = 64
	local v2 = 72

	local positions = {}

	local rotation = QAngle( 0, 90, 0 )
	local rot_vector = RotatePosition(casterPos, rotation, casterPos + forward * 100)
 	local pos1 = casterPos + forward * v1 + ((rot_vector - casterPos):Normalized() * v2)
 	table.insert(positions, pos1)
 	local rotation2 = QAngle( 0, -90, 0 )
	local rot_vector2 = RotatePosition(casterPos, rotation2, casterPos + forward * 100)
 	local pos2 = casterPos + forward * v1 + ((rot_vector2 - casterPos):Normalized() * v2)
 	table.insert(positions, pos2)

	for _,pos in pairs(positions) do
		local info = 
		{
			Ability = keys.ability,
	    	EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
	    	vSpawnOrigin = pos,
	    	fDistance = 1000,
	    	fStartRadius = 100,
	    	fEndRadius = 250,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = forward:Normalized() * 1200,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(info)
	end

	local positions2 = {}

	local rotation3 = QAngle( 0, 90, 0 )
	local rot_vector3 = RotatePosition(casterPos, rotation3, casterPos + forward * 100)
 	local pos3 = casterPos + forward * -v1 + ((rot_vector3 - casterPos):Normalized() * v2)
 	table.insert(positions2, pos3)
 	local rotation4 = QAngle( 0, -90, 0 )
	local rot_vector4 = RotatePosition(casterPos, rotation4, casterPos + forward * 100)
 	local pos4 = casterPos + forward * -v1 + ((rot_vector4 - casterPos):Normalized() * v2)
 	table.insert(positions2, pos4)

	for _,pos in pairs(positions2) do
		local info = 
		{
			Ability = keys.ability,
	    	EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
	    	vSpawnOrigin = pos,
	    	fDistance = 1000,
	    	fStartRadius = 100,
	    	fEndRadius = 250,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = -forward:Normalized() * 1200,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end

function bvo_zoro_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multiplier = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetStrength() * multiplier,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_zoro_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("bvo_zoro_skill_3_channel")

	local stacks = 0
	while caster:HasModifier("bvo_zoro_skill_3_stacks") do
		stacks = stacks + 1
		caster:RemoveModifierByName("bvo_zoro_skill_3_stacks")
	end
	ability.stacks = stacks
	if caster:IsAlive() then
		caster:Stop()

		ability.leap_direction = caster:GetForwardVector()
		ability.leap_distance = 1000
		ability.leap_speed = 3000 * 1/30
		ability.leap_traveled = 0

		local info = 
		{
			Ability = ability,
	    	EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
	    	vSpawnOrigin = caster:GetAbsOrigin(),
	    	fDistance = 1000,
	    	fStartRadius = 250,
	    	fEndRadius = 250,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = caster:GetForwardVector():Normalized() * 3000,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		caster.zoro_skill_3_projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

function bvo_zoro_skill_3_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetStrength() * 5.5 * ability.stacks,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		local new_pos = caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
			ProjectileManager:DestroyLinearProjectile(caster.zoro_skill_3_projectile)
		else
			caster:SetAbsOrigin(new_pos)
			ability.leap_traveled = ability.leap_traveled + ability.leap_speed
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_zoro_skill_4(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	caster:EmitSound("Hero_Invoker.Tornado.Cast")
	for i = 0, 7 do
	    local rotation = QAngle( 0, 45 * i, 0 )
		local rot_vector = RotatePosition(casterPos, rotation, casterPos + Vector(0, 100, 0))

		local info = 
		{
			Ability = ability,
	    	EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
	    	vSpawnOrigin = casterPos,
	    	fDistance = 650,
	    	fStartRadius = 100,
	    	fEndRadius = 450,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_NONE,
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

function bvo_zoro_skill_4_damage(keys)
	local caster = keys.caster
	local target = keys.target

	local str = caster:GetStrength()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = str * 12,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_zero_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi
	caster:Stop()
	target:Stop()
	Timers:CreateTimer(1.6, function()
		caster:EmitSound("Hero_Riki.Blink_Strike")
		FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)
		ProjectileManager:ProjectileDodge(caster)
	
		caster:StartGesture(ACT_DOTA_ATTACK)
		caster:EmitSound("Hero_Sven.Attack")
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )

		caster:MoveToTargetToAttack(target)
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = 2000 + (caster:GetBaseStrength() * multi),
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end)
end