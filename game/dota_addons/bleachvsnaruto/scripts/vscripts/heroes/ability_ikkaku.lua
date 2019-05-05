require('timers')

function bvo_ikkaku_skill_1(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.damage

	local targetPos = target:GetAbsOrigin()

	FindClearSpaceForUnit(caster, targetPos, false)
	ProjectileManager:ProjectileDodge(caster)
	caster:StartGesture(ACT_DOTA_ATTACK2)

	caster:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")

	caster:MoveToTargetToAttack(target)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
	
	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		            caster:GetAbsOrigin(),
		            nil,
		            275,
		            DOTA_UNIT_TARGET_TEAM_ENEMY,
		            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		            DOTA_UNIT_TARGET_FLAG_NONE,
		            FIND_ANY_ORDER,
		            false)

	for _,unit in pairs(localUnits) do
		if unit ~= target then
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

			ApplyDamage(damageTable)
		end
	end

	Timers:CreateTimer(0.1, function ()
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, Vector(275, 0, 275))
		caster:EmitSound("Hero_Centaur.HoofStomp")
	end)
end

function bvo_ikkaku_skill_2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local helix_modifier = keys.helix_modifier

	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown
	if target == caster and not caster:HasModifier(helix_modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
	end
end

function bvo_ikkaku_skill_2_damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
	local radius = ability:GetLevelSpecialValueFor("radius1", (ability:GetLevel() - 1))

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		            caster:GetAbsOrigin(),
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
			damage_type = DAMAGE_TYPE_PURE,
		}

		ApplyDamage(damageTable)
	end
end

function bvo_ikkaku_skill_3(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_ikkaku_skill_3_modifier") then return end

	caster:SetModel("models/hero_ikkaku/hero_ikkaku_bankai_base.vmdl")
	caster:SetOriginalModel("models/hero_ikkaku/hero_ikkaku_bankai_base.vmdl")
	caster:SetModelScale(0.65)
end

function bvo_ikkaku_skill_3_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModel("models/hero_ikkaku/hero_ikkaku_base.vmdl")
	caster:SetOriginalModel("models/hero_ikkaku/hero_ikkaku_base.vmdl")
	caster:SetModelScale(0.47)

	if caster:IsAlive() then
		local temp_hp = caster:GetHealth()
		local temp_mp = caster:GetMana()
		local temp_pos = caster:GetAbsOrigin()
		caster:RespawnHero(false, false, false)
		FindClearSpaceForUnit(caster, temp_pos, false)
		caster:SetHealth(temp_hp)
		caster:SetMana(temp_mp)
	end

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_ikkaku_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:SetModifierStackCount("bvo_ikkaku_skill_4_modifier_boni", ability, 1 )
end

function bvo_ikkaku_skill_4_stack(keys)
	local caster = keys.caster
	local ability = keys.ability

	local current_stack = caster:GetModifierStackCount("bvo_ikkaku_skill_4_modifier_boni", ability )
	if current_stack < 7 then caster:SetModifierStackCount("bvo_ikkaku_skill_4_modifier_boni", ability, current_stack + 1 ) end
end


function bvo_ikkaku_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local charge_multi = keys.multi1
	local str_multi = keys.multi2

	local stack = caster:GetModifierStackCount("bvo_ikkaku_skill_4_modifier_boni", ability)
	if not stack then stack = 0 end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if caster:GetHealth() > (caster:GetMaxHealth() * 0.15) then
		local new_pos = caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed
		if not GridNav:CanFindPath(caster:GetAbsOrigin(), new_pos) then
			caster:InterruptMotionControllers(true)
			caster:RemoveModifierByName("bvo_ikkaku_skill_5_modifier")
			ProjectileManager:DestroyLinearProjectile(caster.projectile5)
		else
			caster:SetAbsOrigin(new_pos)
		end
	else
		caster:InterruptMotionControllers(true)
		caster:RemoveModifierByName("bvo_ikkaku_skill_5_modifier")
		ProjectileManager:DestroyLinearProjectile(caster.projectile5)
	end
end

function bvo_ikkaku_skill_5_hpcheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetHealthPercent() < 15 then
		caster:GiveMana(400)
		ability:EndCooldown()
		caster:InterruptMotionControllers(true)
		caster:RemoveModifierByName("bvo_ikkaku_skill_5_modifier")
		ProjectileManager:DestroyLinearProjectile(caster.projectile5)
	else
		caster:EmitSound("Hero_Centaur.Stampede.Movement")
	end
end

function bvo_ikkaku_skill_5(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability.leap_direction = caster:GetForwardVector()

	ability.leap_speed = 1600 * 1/30

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 30000,
    	fStartRadius = 250,
    	fEndRadius = 250,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector():Normalized() * 1600,
		bProvidesVision = false,
		iVisionRadius = 250,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	caster.projectile5 = ProjectileManager:CreateLinearProjectile(info)
end

function bvo_ikkaku_skill_5_tick(keys)
	local caster = keys.caster
	local ability = keys.ability

	if not caster:HasModifier("item_doom_1_modifier_buff") then
		local hp = caster:GetHealth()
		local new_hp = hp - (caster:GetMaxHealth() * 0.15)
		if new_hp > 1 then
			caster:SetHealth(new_hp)
		else
			caster:SetHealth(1)
		end
	end
end