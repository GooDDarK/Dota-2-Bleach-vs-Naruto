require('timers')

function bvo_shinobu_skill_0(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local range = ability:GetLevelSpecialValueFor("blink_range", 0)

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

	FindClearSpaceForUnit(caster, casterPos, false)
	ability:ApplyDataDrivenModifier(caster, caster, "bvo_shinobu_skill_0_modifier", {} )

	local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_shinobu_skill_0_effect_modifier", {duration=0.2} )

	caster:EmitSound("Hero_QueenOfPain.Blink_out")
	caster:AddNoDraw()
	FindClearSpaceForUnit(caster, point, false)
	local sink = 0
	Timers:CreateTimer(0.03, function()
		if sink < 3 then
			sink = sink + 1
			casterPos = caster:GetAbsOrigin()
			--caster:SetAbsOrigin( Vector(casterPos.x, casterPos.y, casterPos.z - 50) )
			return 0.03
		else
			local dummy2 = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
			dummy2:AddAbility("custom_point_dummy")
			local abl2 = dummy2:FindAbilityByName("custom_point_dummy")
			if abl2 ~= nil then abl2:SetLevel(1) end
			ability:ApplyDataDrivenModifier(caster, dummy2, "bvo_shinobu_skill_0_effect_modifier", {duration=0.2} )

			caster:EmitSound("Hero_QueenOfPain.Blink_in")
			local rise = 0
			Timers:CreateTimer(0.03, function()
				if rise < 3 then
					rise = rise + 1
					casterPos = caster:GetAbsOrigin()
					--caster:SetAbsOrigin( Vector(point.x, point.y, casterPos.z + 50) )
					return 0.03
				else
					caster:RemoveNoDraw()
					caster:RemoveModifierByName("bvo_shinobu_skill_0_modifier")
					--caster:MoveToPosition(caster:GetAbsOrigin())
					Timers:CreateTimer(3.0, function ()
						instant_anti_stuck( caster )
					end)
					return nil
				end
			end)
			return nil
		end
	end)
end

function bvo_shinobu_skill_0_end(keys)
	local target = keys.target
	target:RemoveSelf()
end

function bvo_shinobu_skill_2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	ApplyDamage(damageTable)

	ability:ApplyDataDrivenModifier(caster, target, "bvo_shinobu_skill_2_modifier", {duration=0.1} )
end

function bvo_shinobu_skill_2_throw(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	--_G:PlaySoundFile("BleachVsOnePieceReborn.ShinobuSkill2", caster)
	caster:EmitSound("BleachVsOnePieceReborn.ShinobuSkill2")

	caster.skill_state_2 = 0
	caster.endpoint2 = caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * 1100

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/custom/shinobu/shinobu_weapon_throw.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 1500,
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
		vVelocity = caster:GetForwardVector():Normalized() * 1800,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function bvo_shinobu_skill_2_throw_back(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if caster.skill_state_2 > 0 then return end
	caster.skill_state_2 = 1

	local direction = caster:GetAbsOrigin() - caster.endpoint2	
	local info = 
	{
		Ability = ability,
    	EffectName = "particles/custom/shinobu/shinobu_weapon_throw.vpcf",
    	vSpawnOrigin = caster.endpoint2,
    	fDistance = direction:Length2D(),
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
		vVelocity = direction:Normalized() * 1800,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function bvo_shinobu_skill_3(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dur = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )
	local percent = ability:GetLevelSpecialValueFor("percent_swap", ability:GetLevel() - 1 ) / 100

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		--ally
		target.shinobu_skill_3_str = caster:GetBaseStrength() * percent
		target.shinobu_skill_3_agi = caster:GetBaseAgility() * percent
		target.shinobu_skill_3_int = caster:GetBaseIntellect() * percent
		caster.shinobu_skill_3_str = caster:GetBaseStrength() * percent
		caster.shinobu_skill_3_agi = caster:GetBaseAgility() * percent
		caster.shinobu_skill_3_int = caster:GetBaseIntellect() * percent
		ability:ApplyDataDrivenModifier(target, caster, "bvo_shinobu_skill_3_debuff_modifier", {duration=dur})
		ability:ApplyDataDrivenModifier(caster, target, "bvo_shinobu_skill_3_buff_modifier", {duration=dur})
	else
		--enemy
		target.shinobu_skill_3_str = target:GetBaseStrength() * percent
		target.shinobu_skill_3_agi = target:GetBaseAgility() * percent
		target.shinobu_skill_3_int = target:GetBaseIntellect() * percent
		caster.shinobu_skill_3_str = target:GetBaseStrength() * percent
		caster.shinobu_skill_3_agi = target:GetBaseAgility() * percent
		caster.shinobu_skill_3_int = target:GetBaseIntellect() * percent
		ability:ApplyDataDrivenModifier(caster, target, "bvo_shinobu_skill_3_debuff_modifier", {duration=dur})
		ability:ApplyDataDrivenModifier(target, caster, "bvo_shinobu_skill_3_buff_modifier", {duration=dur})
	end
end

function bvo_shinobu_skill_3_lose(keys)
	local target = keys.target

	target:ModifyStrength(-target.shinobu_skill_3_str)
	target:ModifyAgility(-target.shinobu_skill_3_agi)
	target:ModifyIntellect(-target.shinobu_skill_3_int)
end

function bvo_shinobu_skill_3_gain(keys)
	local target = keys.target

	target:ModifyStrength(target.shinobu_skill_3_str)
	target:ModifyAgility(target.shinobu_skill_3_agi)
	target:ModifyIntellect(target.shinobu_skill_3_int)
end

function bvo_shinobu_skill_4_sound( keys )
	--_G:PlaySoundFile("BleachVsOnePieceReborn.ShinobuSkill4", keys.caster)
	keys.caster:EmitSound("BleachVsOnePieceReborn.ShinobuSkill4")
end

function bvo_shinobu_skill_4_stop( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		caster:StopSound("BleachVsOnePieceReborn.ShinobuSkill4")
	end
end

function bvo_shinobu_skill_4_stop_force( keys )
	local caster = keys.caster
	caster:StopSound("BleachVsOnePieceReborn.ShinobuSkill4")
	caster:RemoveModifierByName("bvo_shinobu_skill_4_modifier")
	if caster.shinobu_skill_4_particle ~= nil then
		ParticleManager:DestroyParticle(caster.shinobu_skill_4_particle, false)
	end
end

function bvo_shinobu_skill_4_stop_sfx( keys )
	local caster = keys.caster

	if caster.shinobu_skill_4_particle ~= nil then
		ParticleManager:DestroyParticle(caster.shinobu_skill_4_particle, false)
	end
end

function bvo_shinobu_skill_4( keys )
	local caster = keys.caster

	caster.shinobu_skill_4_particle = ParticleManager:CreateParticle("particles/custom/shinobu/shinobu_scream_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
end

function bvo_shinobu_skill_4_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

function bvo_shinobu_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = target:GetAbsOrigin()
	local casterPos = caster:GetAbsOrigin()
	local difference = casterPos - point

	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("agi_multi", ability:GetLevel() - 1 )
	local stack_creep = ability:GetLevelSpecialValueFor("stack_creep", ability:GetLevel() - 1 )
	local stack_hero = ability:GetLevelSpecialValueFor("stack_hero", ability:GetLevel() - 1 )

	ability:ApplyDataDrivenModifier(caster, caster, "bvo_shinobu_skill_5_modifier", {} )
	ProjectileManager:ProjectileDodge(caster)

	local dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	ability:ApplyDataDrivenModifier(caster, dummy, "bvo_shinobu_skill_5_effect_modifier", {duration=0.2} )

	caster:EmitSound("Hero_QueenOfPain.Blink_out")
	caster:AddNoDraw()
	FindClearSpaceForUnit(caster, point, false)
	local sink = 0
	Timers:CreateTimer(0.03, function()
		if sink < 3 then
			sink = sink + 1
			casterPos = caster:GetAbsOrigin()
			--caster:SetAbsOrigin( Vector(casterPos.x, casterPos.y, casterPos.z - 50) )
			return 0.03
		else
			local dummy2 = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
			dummy2:AddAbility("custom_point_dummy")
			local abl2 = dummy2:FindAbilityByName("custom_point_dummy")
			if abl2 ~= nil then abl2:SetLevel(1) end
			ability:ApplyDataDrivenModifier(caster, dummy2, "bvo_shinobu_skill_5_effect_modifier", {duration=0.2} )

			caster:EmitSound("Hero_QueenOfPain.Blink_in")
			local rise = 0
			Timers:CreateTimer(0.03, function()
				if rise < 3 then
					rise = rise + 1
					casterPos = caster:GetAbsOrigin()
					--caster:SetAbsOrigin( Vector(point.x, point.y, casterPos.z + 50) )
					return 0.03
				else
					caster:RemoveNoDraw()
					caster:RemoveModifierByName("bvo_shinobu_skill_5_modifier")

					caster:SetForwardVector(-difference:Normalized())
					caster:StartGesture(ACT_DOTA_ATTACK)
					caster:EmitSound("Hero_Juggernaut.Attack")

					local damageTable = {
						victim = target,
						attacker = caster,
						damage = damage,
						damage_type = DAMAGE_TYPE_PURE,
					}
					ApplyDamage(damageTable)

					Timers:CreateTimer(0.1, function ()
						if target ~= nil and not target:IsNull() and not target:IsAlive() then
							local plus = stack_creep
							if target:IsRealHero() then plus = stack_hero end
							local current_stack = caster:GetModifierStackCount( "bvo_shinobu_skill_5_bonus_modifier", ability )
							if not caster:HasModifier( "bvo_shinobu_skill_5_bonus_modifier" ) then
								ability:ApplyDataDrivenModifier(caster, caster, "bvo_shinobu_skill_5_bonus_modifier", {})
							end
							caster:SetModifierStackCount( "bvo_shinobu_skill_5_bonus_modifier", ability, current_stack + plus )
						end
					end)
					return nil
				end
			end)
			return nil
		end
	end)
end

function bvo_shinobu_skill_5_end(keys)
	local target = keys.target
	target:RemoveSelf()
end

function instant_anti_stuck(stuckUnit)
    local hero = stuckUnit
    local base_point = Vector( 0, 0, 0 )
    if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        base_point = Entities:FindByName( nil, "RADIANT_BASE"):GetAbsOrigin()
    else
        base_point = Entities:FindByName( nil, "DIRE_BASE"):GetAbsOrigin()
    end
    
    --anti abuse
    local IsHeroStuck = false
    local stuckPoint = hero:GetAbsOrigin()
    if not GridNav:CanFindPath(base_point, stuckPoint) then
        IsHeroStuck = true
    end

    --except areas with teleporter
    local forgotten_point = Entities:FindByName( nil, "TELE_POINT_8"):GetAbsOrigin()
    local infernal_point = Entities:FindByName( nil, "POINT_INFERNAL_CENTER"):GetAbsOrigin()
    local rapier_point = Entities:FindByName( nil, "TELE_POINT_9"):GetAbsOrigin()
    local duel_point = Entities:FindByName( nil, "DUEL_POINT_RADIANT_IN"):GetAbsOrigin()
    local skeleton_point = Entities:FindByName( nil, "POINT_SKELETON_CENTER"):GetAbsOrigin()

	if GridNav:CanFindPath(forgotten_point, stuckPoint) or GridNav:CanFindPath(infernal_point, stuckPoint) or GridNav:CanFindPath(rapier_point, stuckPoint) or GridNav:CanFindPath(skeleton_point, stuckPoint) then
		IsHeroStuck = false
	end

    if GridNav:CanFindPath(duel_point, stuckPoint) then
        IsHeroStuck = false
    end

    if IsHeroStuck then
        FindClearSpaceForUnit(hero, base_point, false)
    end
end