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

function yamamoto_skill_2(keys)
	local caster = keys.caster

	local particleName = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle , 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle , 1, Vector(350, 0, 0) )
	ParticleManager:SetParticleControl(particle , 3, Vector(0, 0, 0) )
	caster:EmitSound("Ability.LightStrikeArray")
end

function yamamoto_skill_3 (keys)
	local caster = keys.caster
	local target = keys.target

	local point = keys.target_points[1]

	FindClearSpaceForUnit(caster, point, false)

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            350,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	            FIND_ANY_ORDER,
	            false)

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = 75,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
	end

	caster:StartGesture(ACT_DOTA_ATTACK)
	caster:EmitSound("Hero_DoomBringer.Attack")

	local particleName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle , 0, caster:GetAbsOrigin())
	caster:EmitSound("Hero_Phoenix.SuperNova.Explode")

	Timers:CreateTimer(0.35, function()
		yamamoto_skill_3_jump(caster, keys.jumps - 1, target)
	end)
end

function yamamoto_skill_3_jump (caster, jumps, target)
	jumps = jumps - 1

	if not caster:IsAlive() or caster:IsStunned() then return end

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            500,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
	            FIND_ANY_ORDER,
	            false)

	if #localUnits > 0 then
		for _,unit in pairs(localUnits) do
			FindClearSpaceForUnit(caster, unit:GetAbsOrigin(), false)

			local damageUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			            unit:GetAbsOrigin(),
			            nil,
			            250,
			            DOTA_UNIT_TARGET_TEAM_ENEMY,
			            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			            FIND_ANY_ORDER,
			            false)

			for _,tar in pairs(damageUnits) do
				local damageTable = {
					victim = tar,
					attacker = caster,
					damage = 225,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				}
				ApplyDamage(damageTable)
			end

			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:EmitSound("Hero_DoomBringer.Attack")

			local particleName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(particle , 0, caster:GetAbsOrigin())
			caster:EmitSound("Hero_Phoenix.SuperNova.Explode")

			target = unit
			break
		end
	else
		jumps = 0
		caster:RemoveModifierByName("bvo_yamamoto_skill_3_modifier")
	end

	if jumps > 0 then
		Timers:CreateTimer(0.35, function()
			yamamoto_skill_3_jump(caster, jumps, target)
		end)
	end
end

function yamamoto_skill_4_dummy(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	ability.ringDummys = {}
	local forward = caster:GetForwardVector()
	local point_projectile = casterPos + forward:Normalized() * 600

	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
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
	--ring dummys
	Timers:CreateTimer(1.6, function ()
		
		if caster:IsAlive() then
			--lenght mod
			ability:ApplyDataDrivenModifier(caster, caster, "bvo_yamamoto_skill_4_modifier", {duration=duration} )
			--create ring points
			for i = 1, 36 do
				local rotation = QAngle( 0, i * 10, 0 )
				local rot_vector = RotatePosition(casterPos, rotation, point_projectile)

				local b_burn_dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, caster, caster, caster:GetTeamNumber())
				b_burn_dummy:AddAbility("bvo_yamamoto_skill_4_big_burn")
				local abl = b_burn_dummy:FindAbilityByName("bvo_yamamoto_skill_4_big_burn")
				if abl ~= nil then abl:SetLevel(1) end

				b_burn_dummy.hero_str = caster:GetStrength()
				table.insert(ability.ringDummys, b_burn_dummy)

				Timers:CreateTimer(duration, function ()
					if not b_burn_dummy:IsNull() then
						b_burn_dummy:RemoveSelf()
					end
				end)
			end

			--small burn aura dummy
			local burn_dummy = CreateUnitByName("npc_dummy_unit", casterPos, false, caster, caster, caster:GetTeamNumber())
			burn_dummy:AddAbility("bvo_yamamoto_skill_4_small_burn")
			local abl = burn_dummy:FindAbilityByName("bvo_yamamoto_skill_4_small_burn")
			if abl ~= nil then abl:SetLevel(1) end

			burn_dummy.hero_str = caster:GetStrength()
			table.insert(ability.ringDummys, burn_dummy)

			--particle
			local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_ABSORIGIN_FOLLOW, burn_dummy )
			ParticleManager:SetParticleControl( particle, 0, burn_dummy:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, Vector(600, 600, 600) )

			Timers:CreateTimer(duration, function ()
				if not burn_dummy:IsNull() then
					burn_dummy:RemoveSelf()
				end
			end)

		end

	end)
end

function yamamoto_skill_4_dead(keys)
	local ability = keys.ability

	if ability.ringDummys ~= nil then
		for _,dummy in pairs(ability.ringDummys) do
			if dummy ~= nil and not dummy:IsNull() then
				dummy:RemoveSelf()
			end
		end
	end
end

function yamamoto_skill_4_burn_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if ability ~= nil then
		local damage = ability:GetLevelSpecialValueFor("burn", ability:GetLevel() - 1 )
		local multi = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
	end
end

function yamamoto_skill_4_pro_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage ,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function yamamoto_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi
	local targetPos = target:GetAbsOrigin()
	caster:Stop()
	target:Stop()
	caster:EmitSound("Hero_Riki.Blink_Strike")
	FindClearSpaceForUnit(caster, targetPos, false)
	local dif = caster:GetAbsOrigin() - target:GetAbsOrigin()
	caster:SetForwardVector(-dif:Normalized())
	Timers:CreateTimer(1.6, function()
		caster:MoveToTargetToAttack(target)
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		ApplyDamage(damageTable)
		
		caster:StartGesture(ACT_DOTA_ATTACK)
		caster:EmitSound("Hero_DoomBringer.Attack")
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
	end)
end