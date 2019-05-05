require('timers')

function bvo_brook_skill_1_end(keys)
	local caster = keys.attacker
	local target = keys.unit

	if caster:IsHero() then
		target:RemoveModifierByName("bvo_brook_skill_1_modifier")
	end
end

function bvo_brook_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = 250 + (target:GetHealth() * 0.12),
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

function bvo_brook_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = multi * caster:GetAgility() + 360,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_brook_skill_2_dash( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		local new_pos = caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
			ability.leap_traveled = ability.leap_traveled + ability.leap_speed
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_brook_skill_2(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = 800
	ability.leap_speed = 2000 * 1/30
	ability.leap_traveled = 0

	local info = 
	{
		Ability = keys.ability,
    	EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 800,
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
		vVelocity = ability.leap_direction:Normalized() * 2000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

function bvo_brook_skill_3( event )
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local casterHP = caster:GetHealth()
	local casterMana = caster:GetMana()
	local abilityManaCost = ability:GetManaCost( ability:GetLevel() - 1 )

	if not caster:IsRealHero() then return end

	local respawnTimeFormula = 3
	
	if casterHP == 0 and ability:IsCooldownReady() and casterMana >= abilityManaCost  then
		caster.ankh = true
		-- Variables for Reincarnation
		local reincarnate_time = ability:GetLevelSpecialValueFor( "reincarnate_time", ability:GetLevel() - 1 )
		local respawnPosition = caster:GetAbsOrigin()
		
		-- Start cooldown on the passive
		ability:StartCooldown(cooldown)

		-- Kill, counts as death for the player but doesn't count the kill for the killer unit
		caster:SetHealth(1)
		caster:Kill(caster, nil)

		-- Set the short respawn time and respawn position
		caster:SetTimeUntilRespawn(reincarnate_time) 
		caster:SetRespawnPosition(respawnPosition) 

		-- Particle
		local particleName = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
		caster.ReincarnateParticle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(caster.ReincarnateParticle, 0, respawnPosition)
		ParticleManager:SetParticleControl(caster.ReincarnateParticle, 1, Vector(slow_radius,0,0))

		-- End Particle after reincarnating
		Timers:CreateTimer(reincarnate_time, function() 
			ParticleManager:DestroyParticle(caster.ReincarnateParticle, false)
		end)

		-- Grave and rock particles
		-- The parent "particles/units/heroes/hero_skeletonking/skeleton_king_death.vpcf" misses the grave model
		local model = "models/props_gameplay/tombstoneb01.vmdl"
		local grave = Entities:CreateByClassname("prop_dynamic")
    	grave:SetModel(model)
    	grave:SetAbsOrigin(respawnPosition)

    	local particleName = "particles/units/heroes/hero_skeletonking/skeleton_king_death_bits.vpcf"
		local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControl(particle1, 0, respawnPosition)

		local particleName = "particles/units/heroes/hero_skeletonking/skeleton_king_death_dust.vpcf"
		local particle2 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(particle2, 0, respawnPosition)

		local particleName = "particles/units/heroes/hero_skeletonking/skeleton_king_death_dust_reincarnate.vpcf"
		local particle3 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(particle3 , 0, respawnPosition)

    	-- End grave after reincarnating
    	Timers:CreateTimer(reincarnate_time, function() grave:RemoveSelf() end)		

		-- Sounds
		caster:EmitSound("Hero_SkeletonKing.Reincarnate")
		caster:EmitSound("Hero_SkeletonKing.Death")
		Timers:CreateTimer(reincarnate_time, function()
			caster:EmitSound("Hero_SkeletonKing.Reincarnate.Stinger")
		end)
	elseif casterHP == 0 then
		-- On Death without reincarnation, set the respawn time to the respawn time formula
		caster:SetTimeUntilRespawn(respawnTimeFormula)
	end
end