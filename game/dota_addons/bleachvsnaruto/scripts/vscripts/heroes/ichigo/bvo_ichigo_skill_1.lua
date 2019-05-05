bvo_ichigo_skill_1 = class ({})

function bvo_ichigo_skill_1:GetCastAnimation()
	return ACT_DOTA_ATTACK
end

function bvo_ichigo_skill_1:GetPlaybackRateOverride()
	return 3.0
end

function bvo_ichigo_skill_1:OnSpellStart()
	local caster = self:GetCaster()

	local particleName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"
	local dbl_chance = 6
	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then
		dbl_chance = 8
		particleName = "particles/custom/ichigo/ichigo_shockwave.vpcf"
	end

	caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
	caster:EmitSound("Hero_Magnataur.ShockWave.Particle")

	local info = 
	{
		Ability = self,
    	EffectName = particleName,
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 800,
    	fStartRadius = 300,
    	fEndRadius = 300,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1200,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)

	if caster:HasModifier("bvo_ichigo_skill_2_modifier") then
		local rnd_level = caster:FindAbilityByName("bvo_ichigo_skill_2"):GetLevel()
		local chance = rnd_level * dbl_chance
		local roll = RandomInt(1, 100)
		if roll <= chance then
			Timers:CreateTimer(0.1, function ()
				caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
				caster:EmitSound("Hero_Magnataur.ShockWave.Particle")
				ProjectileManager:CreateLinearProjectile(info)
			end)
		end
	end
end

function bvo_ichigo_skill_1:OnProjectileHit( hTarget, vLocation )
	if hTarget == nil then return end

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")

	if caster:HasModifier("bvo_ichigo_skill_3_modifier") then
		damage = self:GetSpecialValueFor("damage_bankai")
	end

	hTarget:EmitSound("Hero_Magnataur.ShockWave.Target")

	local damageTable = {
		victim = hTarget,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end