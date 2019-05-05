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

function bvo_lucci_skill_1(keys)
	local caster = keys.caster
	local ability = keys.ability

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/econ/items/death_prophet/death_prophet_acherontia/death_prophet_acher_swarm.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 900,
    	fStartRadius = 300,
    	fEndRadius = 300,
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
		iVisionRadius = 300,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

function bvo_lucci_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	if not caster:HasModifier("bvo_lucci_skill_4_modifier") then return end
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_lucci_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local targetPos = target:GetAbsOrigin()

	FindClearSpaceForUnit(caster, targetPos, false)
	ProjectileManager:ProjectileDodge(caster)
	caster:StartGesture(ACT_DOTA_ATTACK)

	caster:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")

	local extra_damage = 0
	if caster:HasModifier("bvo_lucci_skill_4_modifier") then extra_damage = damage end

	caster:MoveToTargetToAttack(target)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + extra_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
	--AoE damage in Beast Form
	if caster:HasModifier("bvo_lucci_skill_4_modifier") then
		local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		            caster:GetAbsOrigin(),
		            nil,
		            275,
		            DOTA_UNIT_TARGET_TEAM_ENEMY,
		            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		            FIND_ANY_ORDER,
		            false)

		for _,unit in pairs(localUnits) do
			if unit ~= target then
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
				}
				ApplyDamage(damageTable)
			end
		end

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, Vector(275, 0, 275))
		caster:EmitSound("Hero_Centaur.HoofStomp")
	end
end

function bvo_lucci_skill_3_damage(keys)
	local caster = keys.caster
	local attacker = keys.attacker

	local damage = RandomInt(150, 800)
	local damageTable = {
		victim = attacker,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_lucci_skill_4(keys)
	local caster = keys.caster

	caster:SetModel("models/hero_lucci/hero_lucci_leo_base.vmdl")
	caster:SetOriginalModel("models/hero_lucci/hero_lucci_leo_base.vmdl")
	caster:SetModelScale(1.6)
end

function bvo_lucci_skill_4_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel("models/hero_lucci/hero_lucci_base.vmdl")
	caster:SetOriginalModel("models/hero_lucci/hero_lucci_base.vmdl")
	caster:SetModelScale(1.2)

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_lucci_skill_5(keys)
	Timers:CreateTimer(1.6, function()
		
		local caster = keys.caster
		local target = keys.target
		local multi = keys.multi

		local targetPos = target:GetAbsOrigin()

		local multi2 = 1
		if caster:HasModifier("bvo_lucci_skill_4_modifier") then multi2 = 1.25 end

		FindClearSpaceForUnit(caster, targetPos, false)
		ProjectileManager:ProjectileDodge(caster)

		caster:EmitSound("Hero_Huskar.Life_Break")
		caster:StartGesture(ACT_DOTA_ATTACK)

		caster:MoveToTargetToAttack(target)
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = (2000 + (caster:GetLevel() * multi)) * multi2,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end)
end