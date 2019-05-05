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

function bvo_renji_skill_1_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_renji_skill_2(keys)
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

function bvo_renji_skill_2_hit(keys)
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

function bvo_renji_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	if target == caster then

	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_renji_skill_2_damage_self(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	if target ~= caster then
		return
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_renji_skill_3(keys)
	local caster = keys.caster
	local target = keys.target
	local casterPos = caster:GetAbsOrigin()
	local ability = keys.ability

	caster.skill3state = 1

	ability.dummyList = {}
	ability.target = target

	local forward = caster:GetForwardVector()
	local point_projectile = casterPos + forward:Normalized() * 275
	caster:EmitSound("Hero_Bloodseeker.Attack")
	for i = 1, 8 do
		local rotation = QAngle( 0, i * 45, 0 )
		local rot_vector = RotatePosition(casterPos, rotation, point_projectile)

		local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, caster, caster, caster:GetTeamNumber())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end

		table.insert(ability.dummyList, dummy)
		if dummy ~= nil then
			local projTable = {
		        EffectName = "particles/custom/renji/renji_weapon_throw.vpcf",
		        Ability = ability,
		        Target = dummy,
		        Source = caster,
		        bDodgeable = false,
		        bProvidesVision = false,
		        vSpawnOrigin = caster:GetAbsOrigin(),
		        iMoveSpeed = 1000,
		        iVisionRadius = 0,
		        iVisionTeamNumber = caster:GetTeamNumber(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
		    }
		    ProjectileManager:CreateTrackingProjectile(projTable)
		end
	end
end

function bvo_renji_skill_3_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:HasAbility("custom_point_dummy") then
		local str_multi = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )
		local lvl_multi = ability:GetLevelSpecialValueFor("lvl_multi", ability:GetLevel() - 1 )
		local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(damageTable)
		--particle
		local particleName = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(particle , 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle , 1, Vector(75, 0, 0) )
		ParticleManager:SetParticleControl(particle , 3, Vector(0, 0, 0) )
		target:EmitSound("Ability.LightStrikeArray")
	else
		if caster.skill3state == 1 then
			caster.skill3state = 2
			
			for _,dummy in pairs(ability.dummyList) do
				--local difference = dummy:GetAbsOrigin() - ability.target:GetAbsOrigin()
				local projTable = {
			        EffectName = "particles/custom/renji/renji_weapon_throw.vpcf",
			        Ability = ability,
			        Target = ability.target,
			        Source = dummy,
			        bDodgeable = false,
			        bProvidesVision = false,
			        vSpawnOrigin = dummy:GetAbsOrigin(),
			        iMoveSpeed = 900,
			        iVisionRadius = 0,
			        iVisionTeamNumber = caster:GetTeamNumber(),
			        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
			    }
			    ProjectileManager:CreateTrackingProjectile(projTable)
			end
		end
	end
end

function bvo_renji_skill_3_end(keys)
	local caster = keys.caster
end

function bvo_renji_skill_4(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.dummyList4 = {}
	ability.hitList = {}
	ability.caster5 = caster
	caster.castABL5 = false
	--vector
	local forward = caster:GetForwardVector()
	--body
	for i = 1, 14 do
		local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		local distance = forward * i * 78
		dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x + distance.x, dummy:GetAbsOrigin().y + distance.y, dummy:GetAbsOrigin().z + 160 ) )
		dummy:SetOriginalModel("models/hero_renji/renji_bankai_part.vmdl")
		dummy:SetModel("models/hero_renji/renji_bankai_part.vmdl")
		dummy:SetForwardVector(forward)
		dummy.angle = 0
		dummy:SetParent(caster, "attach_root")
		--ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, dummy)
		table.insert(caster.dummyList4, dummy)
	end
	--head
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	local distance = forward * 15 * 78 - 16
	dummy:SetAbsOrigin( Vector( dummy:GetAbsOrigin().x + distance.x, dummy:GetAbsOrigin().y + distance.y, dummy:GetAbsOrigin().z + 160 ) )
	dummy:SetOriginalModel("models/hero_renji/renji_bankai_head.vmdl")
	dummy:SetModel("models/hero_renji/renji_bankai_head.vmdl")
	dummy:SetForwardVector(forward)
	dummy.angle = 0
	dummy:SetParent(caster, "attach_root")
	--ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, dummy)
	table.insert(caster.dummyList4, dummy)
	--rotate
	ability:ApplyDataDrivenModifier(caster, caster, "bvo_renji_skill_4_rotate", {duration=0.5} )
	--skill
end

function bvo_renji_skill_4_point_damage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local str_multi = ability:GetLevelSpecialValueFor("str_multi", ability:GetLevel() - 1 )
	local lvl_multi = ability:GetLevelSpecialValueFor("lvl_multi", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )

	local forward = caster:GetForwardVector()
	for i = 1, 15 do
		local distance = forward * i * 78

		local localUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	            caster:GetAbsOrigin() + distance,
	            nil,
	            200,
	            DOTA_UNIT_TARGET_TEAM_ENEMY,
	            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	            DOTA_UNIT_TARGET_FLAG_NONE,
	            FIND_ANY_ORDER,
	            false)

		for _,unit in pairs(localUnits) do
			local flag = false
			for _,hit in pairs(ability.hitList) do
				if hit == unit then
					flag = true
				end
			end
			if not flag then
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				}
				ApplyDamage(damageTable)
				table.insert(ability.hitList, unit)
			end
		end
	end
end

function bvo_renji_skill_4_end(keys)
	local caster = keys.caster
	local forward = caster:GetForwardVector()

	Timers:CreateTimer(0.1, function ()
		for _,dummy in pairs(caster.dummyList4) do
			dummy:SetParent(nil, "attach_root")
			
			local x = RandomFloat(-1, 1)
			local y = RandomFloat(-1, 1)
			local endPosition = dummy:GetAbsOrigin() + ( Vector( x, y, forward.z ):Normalized() * 800 )

			local z = GetGroundHeight( Vector( endPosition.x, endPosition.y, 128 ), nil)
			local o_vector = Vector( endPosition.x, endPosition.y, z )

			dummy.leap_direction = (o_vector - dummy:GetAbsOrigin()):Normalized()
			dummy.leap_distance = 800
			dummy.leap_speed = 800 * 1/30
			dummy.leap_traveled = 0

			Timers:CreateTimer(0.03, function()
				if dummy.leap_traveled < dummy.leap_distance then
					local new_pos = dummy:GetAbsOrigin() + dummy.leap_direction * dummy.leap_speed
					dummy:SetAbsOrigin(new_pos)
					dummy.leap_traveled = dummy.leap_traveled + dummy.leap_speed
					return 0.03
				end
			end)
		end
	end)

	local particleName = "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf"
	Timers:CreateTimer(6.0, function ()
		if not caster.castABL5 then
			bvo_renji_skill_4_skill( caster )
			--
			if caster.dummyList4 ~= nil then
				for _,dummy in pairs(caster.dummyList4) do
					--particle
					local pdummy = CreateUnitByName("npc_dummy_unit", dummy:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
					pdummy:AddAbility("custom_point_dummy")
					local abl = pdummy:FindAbilityByName("custom_point_dummy")
					if abl ~= nil then abl:SetLevel(1) end
					ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, pdummy)

					UTIL_Remove(dummy)
					Timers:CreateTimer(2.0, function ()
						UTIL_Remove(pdummy)
					end)
				end
				caster.dummyList4 = nil
			end
		end
	end)
	
end

function bvo_renji_skill_4_skill( caster )
	if not caster:FindAbilityByName("bvo_renji_skill_5"):IsHidden() then
	end
end

function bvo_renji_skill_5(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local forward = caster:GetForwardVector()

	bvo_renji_skill_4_skill( caster )

	caster.castABL5 = true
	local index = 0
	local angle = 0

	local prev = nil
	local nextD = nil

	if caster.dummyList4 == nil then return end

	for _,dummy in pairs(caster.dummyList4) do
		if prev ~= nil then
			dummy.prevD = prev
			prev.nextD = dummy
		end
		prev = dummy
		--
		dummy.settingUp5 = true
		local distance = forward * index * 46
		--rotate
		local rotation = QAngle( 0, caster:GetAngles().y + angle * 24, 0 )
		distance = RotatePosition(caster:GetAbsOrigin(), rotation, caster:GetAbsOrigin() + distance)
		--
		local dummyPos = Vector( dummy:GetAbsOrigin().x, dummy:GetAbsOrigin().y, caster:GetAbsOrigin().z )
		dummy.leap_direction = (  -dummyPos + distance ):Normalized()
		dummy.leap_distance = ( -dummyPos + distance ):Length2D()
		dummy.leap_speed = 1200 * 1/30
		dummy.leap_traveled = 0
		--set forward
		local distance2 = forward * index + 1 * 46
		local rotation2 = QAngle( 0, caster:GetAngles().y + angle + 1 * 24, 0 )
		distance2 = RotatePosition(caster:GetAbsOrigin(), rotation2, caster:GetAbsOrigin() + distance2)
		dummy:SetForwardVector( (dummy:GetAbsOrigin() - distance2):Normalized() )
		--move
		Timers:CreateTimer(0.03, function()
			if dummy.leap_traveled < dummy.leap_distance then
				local new_pos = dummy:GetAbsOrigin() + dummy.leap_direction * dummy.leap_speed
				dummy:SetAbsOrigin(new_pos)
				dummy.leap_traveled = dummy.leap_traveled + dummy.leap_speed
				return 0.03
			else
				dummy.settingUp5 = false
				local flag = false
				for _,dummy in pairs(caster.dummyList4) do
					if dummy.settingUp5 then flag = true end
				end
				if not flag then bvo_renji_skill_5_move( keys ) end
			end
		end)
		angle = angle + 1
		if index < 5 then
			index = index + 1
		end

		if angle == 15 then
			--dummy:SetForwardVector( ( target:GetAbsOrigin() - dummyPos ):Normalized() )
			dummy:SetForwardVector(forward)
		end
	end
end

function bvo_renji_skill_5_move(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local drag_str_multi = ability:GetLevelSpecialValueFor("drag_str_multi", ability:GetLevel() - 1 )
	local final_str_mutli = ability:GetLevelSpecialValueFor("final_str_mutli", ability:GetLevel() - 1 )
	local lastShot = false
	local particleName = "particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf"
	local mainHead = nil
	for _,dummy in pairs(caster.dummyList4) do
		if dummy.nextD == nil then mainHead = dummy end
	end
	--move
	local dummyPos = Vector( mainHead:GetAbsOrigin().x, mainHead:GetAbsOrigin().y, mainHead:GetAbsOrigin().z )
	mainHead.leap_direction = ( target:GetAbsOrigin() - dummyPos ):Normalized()
	mainHead.leap_distance = 64
	mainHead.leap_speed = 600 * 1/30
	mainHead.leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if mainHead ~= nil and not mainHead:IsNull() then
			if mainHead.leap_traveled < mainHead.leap_distance then
				local new_pos = mainHead:GetAbsOrigin() + mainHead.leap_direction * mainHead.leap_speed
				mainHead:SetAbsOrigin(new_pos)
				mainHead.leap_traveled = mainHead.leap_traveled + mainHead.leap_speed
				mainHead:SetForwardVector(mainHead.leap_direction)
				if ( target:GetAbsOrigin() - mainHead:GetAbsOrigin() ):Length2D() < 80 then
					local new_pos2 = target:GetAbsOrigin() + mainHead.leap_direction * mainHead.leap_speed
					if not GridNav:CanFindPath(target:GetAbsOrigin(), new_pos2) then
						if not lastShot then
							lastShot = true
							--shoot
							local info = 
							{
								Ability = ability,
						    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
						    	vSpawnOrigin = mainHead:GetAbsOrigin(),
						    	fDistance = 1000,
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
								vVelocity = (mainHead:GetForwardVector() ):Normalized() * 1200,
								bProvidesVision = true,
								iVisionRadius = 600,
								iVisionTeamNumber = caster:GetTeamNumber()
							}
							projectile = ProjectileManager:CreateLinearProjectile(info)
							target:EmitSound("Hero_DragonKnight.BreathFire")
							--clear
							for _,dummy in pairs(caster.dummyList4) do
								--particle
								local pdummy = CreateUnitByName("npc_dummy_unit", dummy:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
								pdummy:AddAbility("custom_point_dummy")
								local abl = pdummy:FindAbilityByName("custom_point_dummy")
								if abl ~= nil then abl:SetLevel(1) end
								ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, pdummy)

								UTIL_Remove(dummy)
								Timers:CreateTimer(2.0, function ()
									UTIL_Remove(pdummy)
								end)
							end
							caster.dummyList4 = nil
							caster.castABL5 = false
							--mod
							caster:RemoveModifierByName("bvo_renji_skill_5_self_modifier")
							target:RemoveModifierByName("bvo_renji_skill_5_enemy_modifier")
							FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
						end
					else
						target:SetAbsOrigin(new_pos2)
					end
					--damage
					local damage = caster:GetStrength() * drag_str_multi / 25
					local targetArmor = target:GetPhysicalArmorValue()
					local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
					local damagePostReduction = damage * (1 - damageReduction)

					local new_health = target:GetHealth() - damagePostReduction
					if new_health <= 1 then
						target:Kill(ability, caster)
						if not lastShot then
							lastShot = true
							--shoot
							local info = 
							{
								Ability = ability,
						    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
						    	vSpawnOrigin = mainHead:GetAbsOrigin(),
						    	fDistance = 1000,
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
								vVelocity = (mainHead:GetForwardVector() ):Normalized() * 1200,
								bProvidesVision = true,
								iVisionRadius = 600,
								iVisionTeamNumber = caster:GetTeamNumber()
							}
							projectile = ProjectileManager:CreateLinearProjectile(info)
							target:EmitSound("Hero_DragonKnight.BreathFire")
							--clear
							for _,dummy in pairs(caster.dummyList4) do
								--particle
								local pdummy = CreateUnitByName("npc_dummy_unit", dummy:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
								pdummy:AddAbility("custom_point_dummy")
								local abl = pdummy:FindAbilityByName("custom_point_dummy")
								if abl ~= nil then abl:SetLevel(1) end
								ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, pdummy)

								UTIL_Remove(dummy)
								Timers:CreateTimer(2.0, function ()
									UTIL_Remove(pdummy)
								end)
							end
							caster.dummyList4 = nil
							caster.castABL5 = false
							--mod
							caster:RemoveModifierByName("bvo_renji_skill_5_self_modifier")
							target:RemoveModifierByName("bvo_renji_skill_5_enemy_modifier")
							FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
						end
					else
						target:SetHealth(new_health)
					end
				end
				return 0.03
			else
				if ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D() < 1400 then
					bvo_renji_skill_5_move( keys )
				else
					if not lastShot then
						--shoot
						local info = 
						{
							Ability = ability,
					    	EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
					    	vSpawnOrigin = mainHead:GetAbsOrigin(),
					    	fDistance = 1000,
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
							vVelocity = (mainHead:GetForwardVector() ):Normalized() * 1200,
							bProvidesVision = true,
							iVisionRadius = 600,
							iVisionTeamNumber = caster:GetTeamNumber()
						}
						projectile = ProjectileManager:CreateLinearProjectile(info)
						target:EmitSound("Hero_DragonKnight.BreathFire")
						--clear
						for _,dummy in pairs(caster.dummyList4) do
							--particle
							local pdummy = CreateUnitByName("npc_dummy_unit", dummy:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
							pdummy:AddAbility("custom_point_dummy")
							local abl = pdummy:FindAbilityByName("custom_point_dummy")
							if abl ~= nil then abl:SetLevel(1) end
							ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, pdummy)

							UTIL_Remove(dummy)
							Timers:CreateTimer(2.0, function ()
								UTIL_Remove(pdummy)
							end)
						end
						caster.dummyList4 = nil
						caster.castABL5 = false
						--mod
						caster:RemoveModifierByName("bvo_renji_skill_5_self_modifier")
						target:RemoveModifierByName("bvo_renji_skill_5_enemy_modifier")
						FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
					end
				end
			end
		end
	end)
	--follow
	for _,dummy in pairs(caster.dummyList4) do
		if dummy.nextD ~= nil then
			dummy.leap_direction = ( dummy.nextD:GetAbsOrigin() - dummy:GetAbsOrigin() ):Normalized()
			dummy.leap_distance = ( dummy.nextD:GetAbsOrigin() - dummy:GetAbsOrigin() ):Length2D()
			dummy.leap_speed = 600 * 1/30
			dummy.leap_traveled = 0
			Timers:CreateTimer(0.03, function()
				if dummy ~= nil and not dummy:IsNull() then
					if dummy.leap_traveled < dummy.leap_distance then
						local new_pos = dummy:GetAbsOrigin() + dummy.leap_direction * dummy.leap_speed
						dummy:SetAbsOrigin(new_pos)
						dummy.leap_traveled = dummy.leap_traveled + dummy.leap_speed
						dummy:SetForwardVector(dummy.leap_direction)
						return 0.03
					end
				end
			end)
		end
	end
end

function bvo_renji_skill_5_prodmg(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("final_str_mutli", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end