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

	if caster:HasModifier("bvo_ishida_skill_5_modifier") then
		ability:EndCooldown()
		ability:StartCooldown(3.0)
	end
end

function bvo_ishida_skill_1_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "bvo_ishida_skill_1_modifier"
	local duration = 6
	local max_stack = 6
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { } )
	caster:SetModifierStackCount( modifierName, ability, max_stack )
end

function bvo_ishida_skill_1_decrease_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifierName = "bvo_ishida_skill_1_modifier"
	local current_stack = caster:GetModifierStackCount( modifierName, ability )

	if current_stack > 1 then
		caster:SetModifierStackCount( modifierName, ability, current_stack - 1 )
	else
		caster:RemoveModifierByName( modifierName )
	end
end

function bvo_ishida_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target

	local agi = caster:GetBaseAgility()

	local multi = 1;
	if caster:HasModifier("bvo_ishida_skill_5_modifier") then multi = 1.2 end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = agi * 1.75 * multi,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_ishida_skill_1(keys)
	local caster = keys.attacker
	local target = keys.target
	local ability = keys.ability

	local manacost = 70;
	if caster:HasModifier("bvo_ishida_skill_5_modifier") then manacost = 140 end
	if caster:GetMana() < manacost then return end

	caster:SpendMana(manacost, ability)
	caster:EmitSound("Hero_Puck.Waning_Rift")
	local info = {
		Ability = ability,
    	EffectName = "particles/econ/items/puck/puck_merry_wanderer/puck_illusory_orb_merry_wanderer.vpcf",
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
		vVelocity = caster:GetForwardVector() * 1200,
		bProvidesVision = true,
		iVisionRadius = 250,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function bvo_ishida_skill_2(keys)
	local point = keys.target_points[1]
	local arrows = keys.arrows
	local ability = keys.ability

	Timers:CreateTimer(3.0, function()
		bvo_ishida_skill_2_rain(keys.caster, arrows, point, ability)
	end)
end

function bvo_ishida_skill_2_rain(caster, arrows, origin, abl)
	arrows = arrows - 1

	local offset = Vector(RandomInt(-150, 150), RandomInt(-150, 150), 0)
	local impact = origin + offset

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            impact,
	            nil,
	            250,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_ANY_ORDER,
	            false)

	local dummy = CreateUnitByName( "npc_dummy_unit", impact, false, caster, caster, caster:GetTeamNumber() )
	abl:ApplyDataDrivenModifier(caster, dummy, "bvo_ishida_skill_2_dummy", nil)
	dummy:EmitSound("Hero_Zuus.ArcLightning.Cast")
	local particleName = "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf"
	ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, dummy)


	local speed = 0.1
	local multi = 1
	if caster:HasModifier("bvo_ishida_skill_5_modifier") then
		multi = 1.2
		speed = 0.05
	end

	Timers:CreateTimer(speed, function()
		dummy:RemoveSelf()
	end)

	local agi = caster:GetBaseAgility()

	

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = agi * 1.5 * multi,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}

		ApplyDamage(damageTable)

		abl:ApplyDataDrivenModifier(caster, unit, "bvo_ishida_skill_2_stun", nil)
	end

	if arrows > 0 then
		Timers:CreateTimer(speed, function()
			bvo_ishida_skill_2_rain(caster, arrows, origin, abl)
		end)
	end
end

function bvo_ishida_skill_3(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("bvo_ishida_skill_5_modifier") then
		Timers:CreateTimer(0.0, function ()
			if ability:IsChanneling() then
				ability:EndChannel(false)
				caster:InterruptChannel()
				return nil
			end
			return 0
		end)
	end
end

function bvo_ishida_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.damage

	local dummy = CreateUnitByName( "npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_ishida_skill_4_dummy", nil)

	Timers:CreateTimer(2.5, function()

		local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            dummy:GetAbsOrigin(),
	            nil,
	            750,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
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

			local particleName = "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, unit)
			ParticleManager:SetParticleControl(particle, 2, unit:GetAbsOrigin())
		end
		dummy:EmitSound("Hero_Disruptor.ThunderStrike.Cast")
		dummy:RemoveSelf()

	end)
end

function bvo_ishida_skill_5(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveModifierByName("bvo_ishida_skill_5_aura")

	Timers:CreateTimer(0.0, function()
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, caster, "bvo_ishida_skill_5_lost_modifier", {})
			return nil
		else
			return 1.0
		end
	end)

	caster:FindAbilityByName("bvo_ishida_skill_5"):SetHidden(true)
	caster:FindAbilityByName("bvo_ishida_skill_3"):SetHidden(true)
	caster:FindAbilityByName("bvo_ishida_skill_2"):SetHidden(true)
	caster:FindAbilityByName("bvo_ishida_skill_1"):SetHidden(true)

	local str = caster:GetBaseStrength()
	local agi = caster:GetBaseAgility()
	local int = caster:GetBaseIntellect()

	caster:ModifyStrength(-str * 0.8)
	caster:ModifyAgility(-agi * 0.8)
	caster:ModifyIntellect(-int * 0.8)

	Timers:CreateTimer(30.0, function()
		caster:ModifyStrength(str * 0.8)
		caster:ModifyAgility(agi * 0.8)
		caster:ModifyIntellect(int * 0.8)

		caster:FindAbilityByName("bvo_ishida_skill_1"):SetHidden(false)
		caster:FindAbilityByName("bvo_ishida_skill_2"):SetHidden(false)
		caster:FindAbilityByName("bvo_ishida_skill_3"):SetHidden(false)

		caster:FindAbilityByName("bvo_ishida_skill_5"):SetHidden(false)

		caster:RemoveModifierByName("bvo_ishida_skill_5_lost_modifier")
	end)
end

function bvo_ishida_skill_5_aura(keys)
	local caster = keys.caster
	local target = keys.target

	local current = target:GetMana()
	local burned = current - 60
	if burned < 0 then burned = 0 end

	target:SetMana(burned)
	caster:GiveMana(60)
end