require('timers')

function Blink(keys)
    local ability = keys.ability
	local caster = keys.caster
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
		FindClearSpaceForUnit(caster, casterPos, false)
    	return
	end
end

function bvo_rukia_skill_2(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	local dummy = CreateUnitByName("npc_dummy_unit", point, false, caster, caster, caster:GetTeamNumber())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	ability.dummy = dummy
	ability.point = point
	
	if dummy ~= nil then
		local projTable = {
	        EffectName = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf",
	        Ability = ability,
	        Target = ability.dummy,
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

function bvo_rukia_skill_2_hit(keys)
	local ability = keys.ability
	local target = keys.target

	ability.dummy:EmitSound("Hero_ObsidianDestroyer.SanityEclipse")
	ability.dummy:RemoveSelf()
	ability.dummy = nil

	local particleName = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( particle, 0, ability.point )
	ParticleManager:SetParticleControl( particle, 1, Vector(300, 0, 0) )
	ParticleManager:SetParticleControl( particle, 2, Vector(300, 0, 0) )
	ParticleManager:SetParticleControl( particle, 3, Vector(300, 0, 0) )
end

function bvo_rukia_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local level = caster:GetLevel()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_rukia_skill_3_reset( keys )
	keys.ability.rukia_skill_3_stack = 0
end

function bvo_rukia_skill_3_stack( keys )
	keys.ability.rukia_skill_3_stack = keys.ability.rukia_skill_3_stack + 1
end

function bvo_rukia_skill_3(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	while caster:HasModifier("bvo_rukia_skill_3_stack") do
		caster:RemoveModifierByName("bvo_rukia_skill_3_stack")
	end

	local forward = caster:GetForwardVector()
	local casterPos = caster:GetAbsOrigin()
	local stacks = ability.rukia_skill_3_stack
	local max = 3-- +2 = projectile amount
	if stacks == 0 then
		max = -2
	elseif stacks == 1 then
		max = -1
	elseif stacks == 2 then
		max = 1
	elseif stacks == 3 then
		max = 3
	end

	if ability.rukia_skill_3_stack > 0 then
		caster:EmitSound("Hero_Tusk.IceShards.Cast")
		caster:EmitSound("Hero_Tusk.IceShards")
	end

	local rotation = QAngle( 0, 90, 0 )
	for i = 0, ( max + 1 ) do
		local rot_vector = RotatePosition(casterPos, rotation, casterPos + forward)
	 	local pos1 = casterPos + ( (rot_vector - casterPos):Normalized() * ( 200 * i - max * 100 - 100 ) )
		local info = 
		{
			Ability = ability,
	    	EffectName = "particles/units/heroes/hero_tusk/tusk_ice_shards_projectile.vpcf",
	    	vSpawnOrigin = pos1,
	    	fDistance = 1000 + stacks * 200,
	    	fStartRadius = 200,
	    	fEndRadius = 200,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = caster:GetForwardVector() * 1800,
			bProvidesVision = true,
			iVisionRadius = 200,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end

function bvo_rukia_skill_4(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_rukia_skill_4_modifier") then return end
end

function bvo_rukia_skill_4_end(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function bvo_rukia_skill_5(keys)
	local caster = keys.caster
	local target = keys.target

	target:SetModifierStackCount("bvo_rukia_skill_5", caster, 10)
end

function bvo_rukia_skill_5_hit(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage
	local multi = keys.multi
	local attacker = keys.attacker

	if attacker ~= caster then return end

	if target:HasModifier("bvo_rukia_skill_5") then
		local stacks = target:GetModifierStackCount("bvo_rukia_skill_5", caster)
		target:SetModifierStackCount("bvo_rukia_skill_5", caster, stacks - 1)
		--extra damage
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(damageTable)
		local particleName = "particles/units/heroes/hero_lich/lich_frost_nova.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
		target:EmitSound("Hero_Lich.ChainFrostImpact.Hero")
		--end
		if stacks == 1 then
			target:RemoveModifierByName("bvo_rukia_skill_5")
		end
	end
end