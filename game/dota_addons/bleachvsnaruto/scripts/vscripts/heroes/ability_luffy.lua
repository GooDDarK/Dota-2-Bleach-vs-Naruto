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

function bvo_luffy_skill_0(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damage = keys.damage
	
	local true_damage = damage * 0.85
	local blocked = damage * 0.15
	if true_damage > 0 then
		if true_damage > caster:GetHealth() then return end
		caster:Heal(blocked, caster)
	else
		caster:Heal(damage, caster)
	end
end

function bvo_luffy_skill_1(keys)
    local caster = keys.caster
    local point = keys.target_points[1]
    local casterPos = caster:GetAbsOrigin()
    local ability = keys.ability

    ability.wrongMove = false

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
		FindClearSpaceForUnit(caster, casterPos, false)
		ability.wrongMove = true
    	return
	end
end

function bvo_luffy_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local damage_2nd = ability:GetLevelSpecialValueFor("damage_2nd", ability:GetLevel() - 1 )
	local multi_2nd = ability:GetLevelSpecialValueFor("multi_2nd", ability:GetLevel() - 1 )

	if ability.wrongMove then return end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
	ability:ApplyDataDrivenModifier(caster, target, "bvo_luffy_skill_1_stun_modifier", {} )

	if not caster:HasModifier("bvo_luffy_skill_4_modifier") and not caster:HasModifier("bvo_luffy_skill_4_perma_modifier") then return end

	local abiliy = caster:FindAbilityByName("bvo_luffy_skill_4")
	if ability ~= nil then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage_2nd + ( multi_2nd * ability:GetLevel() ),
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end
end

function bvo_luffy_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	
	local difference = caster:GetAbsOrigin() - target:GetAbsOrigin()
	target.leap_direction = -difference:Normalized()
	target.leap_speed = 150 * 1/30

	if not caster:HasModifier("bvo_luffy_skill_4_modifier") and not caster:HasModifier("bvo_luffy_skill_4_perma_modifier") then return end

	local abiliy = caster:FindAbilityByName("bvo_luffy_skill_4")
	if ability ~= nil then
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = 125 + 75 * ability:GetLevel(),
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end
end

function KnockbackTarget( keys )
	local owner = keys.caster
	local caster = keys.target

	local new_pos = caster:GetAbsOrigin() + caster.leap_direction * caster.leap_speed
	if caster:HasModifier("bvo_luffy_skill_2_stun_modifier") then
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
	end
end

function bvo_luffy_skill_3_cast(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterPos = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()

    local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 600,
    	fStartRadius = 150,
    	fEndRadius = 250,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function bvo_luffy_skill_3_cast2(keys)
    local caster = keys.caster
    local ability = keys.ability
    local casterPos = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()

    caster:EmitSound("Hero_Lycan.PreAttack")

	local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 92 ) )
	local rotation = QAngle( 0, 90, 0 )
	local rot_vector = RotatePosition(casterPos, rotation, casterPos + forward * 100)
	dummy:SetAbsOrigin( dummy:GetAbsOrigin() + forward * 48)
	dummy:SetAbsOrigin( dummy:GetAbsOrigin() + (rot_vector - casterPos):Normalized() * RandomInt(-60, 60))
	dummy:SetForwardVector(forward)
	dummy:SetOriginalModel("models/hero_luffy2/luffy_punch_base.vmdl")
	dummy:SetModel("models/hero_luffy2/luffy_punch_base.vmdl")
	dummy:SetModelScale(4.0)
	--motion
	local leap_direction = forward:Normalized()
	local leap_distance = 600
	local leap_speed = 1200 * 1/30
	local leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if leap_traveled < leap_distance then
			local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
			dummy:SetAbsOrigin(new_pos)
			leap_traveled = leap_traveled + leap_speed
			return 0.03
		else
			dummy:EmitSound("Hero_Lycan.PreAttack")
			dummy:RemoveSelf()
		end
	end)
end

function bvo_luffy_skill_3_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if target ~= ability.dummy then
		ability:ApplyDataDrivenModifier(caster, target, "bvo_luffy_skill_3_stun_modifier", {duration=0.1} )
	end

	if not caster:HasModifier("bvo_luffy_skill_4_modifier") and not caster:HasModifier("bvo_luffy_skill_4_perma_modifier") then return end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = 2 * caster:GetLevel() * ability:GetLevel(),
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_luffy_skill_4(keys)
	local caster = keys.caster

	caster:FindAbilityByName("bvo_luffy_skill_4_soru"):SetHidden(false)
	caster:FindAbilityByName("bvo_luffy_skill_0"):SetHidden(true)
end

function bvo_luffy_skill_4_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:FindAbilityByName("bvo_luffy_skill_4_soru"):SetHidden(true)
	caster:FindAbilityByName("bvo_luffy_skill_0"):SetHidden(false)

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_luffy_skill_5(keys)
    local caster = keys.caster
	local ability = keys.ability
    local casterPos = caster:GetAbsOrigin()
    local forward = caster:GetForwardVector()

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
    	vSpawnOrigin = casterPos,
    	fDistance = 600,
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
		vVelocity = forward * 1000,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)

	local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, dummy:GetAbsOrigin().z + 92 ) )
	dummy:SetForwardVector(forward)
	dummy:SetOriginalModel("models/hero_luffy2/luffy_punch_base.vmdl")
	dummy:SetModel("models/hero_luffy2/luffy_punch_base.vmdl")
	dummy:SetModelScale(10.0)
	--motion
	local leap_direction = forward:Normalized()
	local leap_distance = 600
	local leap_speed = 1200 * 1/30
	local leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if leap_traveled < leap_distance then
			local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
			dummy:SetAbsOrigin(new_pos)
			leap_traveled = leap_traveled + leap_speed
			return 0.03
		else
			dummy:RemoveSelf()
		end
	end)
end

function bvo_luffy_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local min = keys.min
	local max = keys.max

	local multi = RandomInt(min, max)

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetLevel() * multi,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_luffy_skill_5_mini(keys)
    local caster = keys.caster
    local current = caster:GetModelScale()
    caster:SetModelScale(current / 2)
    Timers:CreateTimer(3.5, function ()
    	caster:SetModelScale(current)
    end)
end