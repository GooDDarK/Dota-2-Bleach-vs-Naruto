require('timers')

function bvo_megumin_skill_0( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )

	if not caster:IsRealHero() then return end

	if ability:IsCooldownReady() then
		ability:StartCooldown(ability:GetCooldown(0))

		local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			            target:GetAbsOrigin(),
			            nil,
			            radius,
			            DOTA_UNIT_TARGET_TEAM_ENEMY,
			            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			            DOTA_UNIT_TARGET_FLAG_NONE,
			            FIND_ANY_ORDER,
			            false)

		ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		target:EmitSound("Ability.LightStrikeArray")

		for _,unit in pairs(localUnits) do
			local damageTable = {
				victim = unit,
				attacker = caster,
				damage = damage + caster:GetIntellect() * multi,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			ApplyDamage(damageTable)
		end

	end
end

function bvo_megumin_skill_1( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            point,
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
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
		ability:ApplyDataDrivenModifier(caster, unit, "bvo_megumin_skill_1_modifier", {duration=0.1})
	end

	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:EmitSound("Hero_Gyrocopter.CallDown.Damage")
	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)

	bvo_megumin_skill_4_refresh( ability, caster )
end

function bvo_megumin_skill_3( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	caster:EmitSound("Hero_ObsidianDestroyer.ArcaneOrb")
	local projTable = {
        EffectName = "particles/custom/megumin/skill_3_projectile/megumin_skill_3_projectile.vpcf",
        Ability = ability,
        Target = target,
        Source = caster,
        bDodgeable = true,
        bProvidesVision = false,
        vSpawnOrigin = caster:GetAbsOrigin(),
        iMoveSpeed = 1000,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
    }
    ProjectileManager:CreateTrackingProjectile(projTable)

    bvo_megumin_skill_4_refresh(ability, caster)
end

function bvo_megumin_skill_3_hit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	local int_multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            target:GetAbsOrigin(),
	            nil,
	            radius,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_ANY_ORDER,
	            false)

	target:EmitSound("Hero_ObsidianDestroyer.ArcaneOrb.Impact")
	local particleName = "particles/custom/megumin/skill_4/megumin_skill_4_area.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, Vector(radius, radius, 2) )
	ParticleManager:SetParticleControl( particle, 2, Vector(radius, radius, radius) )
	target:EmitSound("Hero_Invoker.SunStrike.Ignite")
	target:EmitSound("Hero_EmberSpirit.FireRemnant.Explode")

	for _,unit in pairs(localUnits) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			damage = damage + ( caster:GetIntellect() * int_multi ),
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)
		ability:ApplyDataDrivenModifier(caster, unit, "bvo_megumin_skill_3_stun_modifier", {duration=1.5})
	end
end

function bvo_megumin_skill_4_refresh( ability, caster )
	if caster:HasModifier("bvo_megumin_skill_4_modifier") then
		caster:RemoveModifierByName("bvo_megumin_skill_4_modifier")
		ability:EndCooldown()
	end
end

function bvo_megumin_skill_5_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local point = keys.target_points[1]

	local particleName = "particles/custom/megumin/skill_5/megumin_skill_5_a.vpcf"
	caster.particle_megumin_5 = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.particle_megumin_5, 0, point )

	caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_5)

	bvo_megumin_skill_4_refresh(ability, caster)
end

function bvo_megumin_skill_5_stop( keys )
	local caster = keys.caster
	Timers:RemoveTimer("MEGUMIN_CAST_SKILL_5")
	ParticleManager:DestroyParticle(caster.particle_megumin_5, false)
	caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_5)
end

function bvo_megumin_skill_5_order( keys )
	local caster = keys.caster
	caster:RemoveModifierByName("bvo_megumin_skill_5_modifier")
	Timers:RemoveTimer("MEGUMIN_CAST_SKILL_5")
	ParticleManager:DestroyParticle(caster.particle_megumin_5, false)
	caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_5)
end

function bvo_megumin_skill_5( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1 )
	local channel_time = ability:GetLevelSpecialValueFor("channel_time", ability:GetLevel() - 1 )
	local mana_multi = ability:GetLevelSpecialValueFor("mana_multi", ability:GetLevel() - 1 )

	local timer_info = {
        endTime = channel_time,
        callback = function()
            
        	if not caster:IsAlive() then return end
			caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_5)
			ParticleManager:DestroyParticle(caster.particle_megumin_5, false)

			local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
			dummy:AddAbility("custom_point_dummy")
			local abl = dummy:FindAbilityByName("custom_point_dummy")
			if abl ~= nil then abl:SetLevel(1) end
			Timers:CreateTimer(3.0, function ()
				dummy:RemoveSelf()
			end)

			local extra_radius = 400
			local particleName = "particles/custom/megumin/skill_4/megumin_skill_4_area.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, dummy)
			ParticleManager:SetParticleControl( particle, 0, dummy:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, Vector(radius + extra_radius, radius + extra_radius, extra_radius / 10) )
			ParticleManager:SetParticleControl( particle, 2, Vector(radius + extra_radius, radius + extra_radius, radius + extra_radius) )
			ParticleManager:SetParticleControl( particle, 3, Vector(radius + extra_radius, radius + extra_radius, radius + extra_radius) )
			dummy:EmitSound("Hero_Invoker.SunStrike.Ignite")
			dummy:EmitSound("Hero_EmberSpirit.FireRemnant.Explode")
			dummy:EmitSound("Hero_ObsidianDestroyer.SanityEclipse")

			local mana = caster:GetMana()
			caster:SpendMana(mana, ability)
			local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			            point,
			            nil,
			            radius,
			            DOTA_UNIT_TARGET_TEAM_ENEMY,
			            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			            FIND_ANY_ORDER,
			            false)

			for _,unit in pairs(localUnits) do
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = mana * mana_multi,
					damage_type = DAMAGE_TYPE_PURE,
				}
				ApplyDamage(damageTable)
				ability:ApplyDataDrivenModifier(caster, unit, "bvo_megumin_skill_5_stun_modifier", {duration=1.5})
			end

            return nil
        end
    }
	Timers:CreateTimer("MEGUMIN_CAST_SKILL_5", timer_info)
end