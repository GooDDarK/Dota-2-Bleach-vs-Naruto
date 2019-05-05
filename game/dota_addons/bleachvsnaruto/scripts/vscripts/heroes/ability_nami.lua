require('timers')

function bvo_nami_skill_0(keys)
	local caster = keys.caster
	local ability = keys.ability
	--
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end

	ability.dummy0 = dummy

	--particle
	ability.particle0 = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_CUSTOMORIGIN, dummy)
	ParticleManager:SetParticleControlEnt(ability.particle0, 0, dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", dummy:GetAbsOrigin(), true)
	--trigger thundercloud
	local triggerSpecial = false
	local special = caster:FindAbilityByName("bvo_nami_skill_2")
	if special.mainDummy ~= nil and not special.mainDummy:IsNull() then
		local difference = caster:GetAbsOrigin() - special.mainDummy:GetAbsOrigin()
		if difference:Length2D() < 800 then
			triggerSpecial = true
		end
	end
	if triggerSpecial then
		--motion
		local leap_direction = Vector(0, 0, 1)
		local leap_distance = 1200
		local leap_speed = 2000 * 1/30
		local leap_traveled = 0
		Timers:CreateTimer(0.03, function()
			if leap_traveled < leap_distance then
				local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
				dummy:SetAbsOrigin(new_pos)
				leap_traveled = leap_traveled + leap_speed
				return 0.03
			else
				ParticleManager:DestroyParticle(ability.particle0, false)
				dummy:RemoveSelf()
				--
				special:ApplyDataDrivenModifier(caster, special.mainDummy, "bvo_nami_skill_2_damage_modifier", {duration=6.0} )
				return nil
			end
		end)
		return
	end
	--trigger normal
	local info = 
	{
		Ability = ability,
    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = 1200,
    	fStartRadius = 256,
    	fEndRadius = 256,
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector():Normalized() * 1200,
		bProvidesVision = false,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
	--motion
	local leap_direction = caster:GetForwardVector()
	local leap_distance = 1300
	local leap_speed = 2000 * 1/30
	local leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if leap_traveled < leap_distance then
			local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
			dummy:SetAbsOrigin(new_pos)
			leap_traveled = leap_traveled + leap_speed
			return 0.03
		else
			ParticleManager:DestroyParticle(ability.particle0, false)
			dummy:RemoveSelf()
		end
	end)
end

function bvo_nami_skill_0_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi = ability:GetLevelSpecialValueFor("int_multi", ability:GetLevel() - 1 )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetBaseIntellect() * multi,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damageTable)
end

function bvo_nami_skill_1(keys)
	local caster = keys.caster
	local point = keys.target_points[1]

	local special = caster:FindAbilityByName("bvo_nami_skill_5")
	if special.dummy5 ~= nil and not special.dummy5:IsNull() then
		caster:RemoveModifierByName("bvo_nami_skill_5_modifier")

		local distance = point - special.dummy5:GetAbsOrigin()
		local face = special.dummy5:GetAbsOrigin() - point
		local info = 
		{
			Ability = special,
	    	EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf",
	    	vSpawnOrigin = point,
	    	fDistance = distance:Length2D(),
	    	fStartRadius = 200,
	    	fEndRadius = 200,
	    	Source = caster,
	    	bHasFrontalCone = false,
	    	bReplaceExisting = false,
	    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	    	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = face:Normalized() * 10000,
			bProvidesVision = false,
			iVisionRadius = 1000,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		projectile = ProjectileManager:CreateLinearProjectile(info)
		--
		local dummy = CreateUnitByName("npc_dummy_unit", point, false, caster, caster, caster:GetTeam())
		dummy:AddAbility("custom_unit_particle")
		local abl = dummy:FindAbilityByName("custom_unit_particle")
		if abl ~= nil then abl:SetLevel(1) end
		--
		special.dummy5:EmitSound("Ability.LagunaBlade")
		dummy:EmitSound("Ability.LagunaBladeImpact")
		--
		special.dummy5:CastAbilityOnTarget(dummy, special.dummy5:FindAbilityByName("bvo_nami_skill_1_extra"), special.dummy5:GetTeamNumber())
		Timers:CreateTimer(0.25, function ()
			dummy:RemoveSelf()
			special.dummy5:RemoveSelf()
			special.dummy5 = nil
		end)
	end
end

function bvo_nami_skill_2(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability

	ability.dummyList = {}

	--main dummy
	local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	table.insert(ability.dummyList, dummy)

	ability.mainDummy = dummy

	local point_projectile = point + caster:GetForwardVector():Normalized() * 800
	local point_projectile2 = point + caster:GetForwardVector():Normalized() * 500
	local point_projectile3 = point + caster:GetForwardVector():Normalized() * 200
	--extra dummys
	for i = 1, 12 do
		local rotation = QAngle( 0, i * 30, 0 )
		local rot_vector = RotatePosition(point, rotation, point_projectile)
		--
		local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, nil, nil, caster:GetTeam())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		ability:ApplyDataDrivenModifier(caster, dummy, "bvo_nami_skill_2_smoke_modifier", {} )
		dummy:SetAbsOrigin(Vector(rot_vector.x, rot_vector.y, rot_vector.z + 400))
		table.insert(ability.dummyList, dummy)
	end
	for i = 1, 8 do
		local rotation = QAngle( 0, i * 45, 0 )
		local rot_vector = RotatePosition(point, rotation, point_projectile2)
		--
		local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, nil, nil, caster:GetTeam())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		ability:ApplyDataDrivenModifier(caster, dummy, "bvo_nami_skill_2_smoke_modifier", {} )
		dummy:SetAbsOrigin(Vector(rot_vector.x, rot_vector.y, rot_vector.z + 400))
		table.insert(ability.dummyList, dummy)
	end
	for i = 1, 4 do
		local rotation = QAngle( 0, i * 90, 0 )
		local rot_vector = RotatePosition(point, rotation, point_projectile3)
		--
		local dummy = CreateUnitByName("npc_dummy_unit", rot_vector, false, nil, nil, caster:GetTeam())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		ability:ApplyDataDrivenModifier(caster, dummy, "bvo_nami_skill_2_smoke_modifier", {} )
		dummy:SetAbsOrigin(Vector(rot_vector.x, rot_vector.y, rot_vector.z + 400))
		table.insert(ability.dummyList, dummy)
	end

	Timers:CreateTimer(10.0, function()
		for _,dummy in pairs(ability.dummyList) do
			dummy:RemoveSelf()
		end
		ability.dummyList = nil
		ability.mainDummy = nil
	end)
end

function bvo_nami_skill_2_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi
	local damage = keys.damage

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage + (caster:GetIntellect() * multi),
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
	--
	local particleName = "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf"
	ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, target)
end

--
function MirrorImage( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor("images_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor("illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor("outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor("incoming_damage", ability:GetLevel() - 1 )

	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()

	-- Stop any actions of the caster otherwise its obvious which unit is real
	caster:EmitSound("DOTA_Item.Manta.Activate")
	caster:Stop()

	-- Initialize the illusion table to keep track of the units created by the spell
	if not caster.mirror_image_illusions then
		caster.mirror_image_illusions = {}
	end

	-- Kill the old images
	for k,v in pairs(caster.mirror_image_illusions) do
		if v and IsValidEntity(v) then 
			v:ForceKill(false)
		end
	end

	-- Start a clean illusion table
	caster.mirror_image_illusions = {}

	-- Setup a table of potential spawn positions
	local vRandomSpawnPos = {
		Vector( 72, 0, 0 ),		-- North
		Vector( 0, 72, 0 ),		-- East
		Vector( -72, 0, 0 ),	-- South
		Vector( 0, -72, 0 ),	-- West
	}

	for i=#vRandomSpawnPos, 2, -1 do	-- Simply shuffle them
		local j = RandomInt( 1, i )
		vRandomSpawnPos[i], vRandomSpawnPos[j] = vRandomSpawnPos[j], vRandomSpawnPos[i]
	end

	-- Insert the center position and make sure that at least one of the units will be spawned on there.
	table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )

	-- At first, move the main hero to one of the random spawn positions.
	FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )

	-- Spawn illusions
	for i=1, images_count do

		local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )

		-- handle_UnitOwner needs to be nil, else it will crash the game.
		local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(caster:GetPlayerID(), true)

		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		
		-- Level Up the unit to the casters level
		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end

		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				if illusionAbility ~= nil then
					illusionAbility:SetLevel(abilityLevel)
				end
			end
		end

		-- Recreate the items of the caster
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end

		-- Set the unit as an illusion
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })

		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()
		-- Set the illusion hp to be the same as the caster
		illusion:SetHealth(caster:GetHealth())

		-- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
		table.insert(caster.mirror_image_illusions, illusion)

		Timers:CreateTimer(duration + 0.1, function ()
			if not illusion:IsNull() and illusion ~= nil then
				illusion:RemoveSelf()
			end
		end)
	end
end

--

function bvo_nami_skill_4(keys)
	local caster = keys.caster
	--
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:EmitSound("Hero_Invoker.Tornado")
	--motion
	local leap_direction = caster:GetForwardVector()
	local leap_distance = 1800
	local leap_speed = 2000 * 1/30
	local leap_traveled = 0
	Timers:CreateTimer(0.03, function()
		if leap_traveled < leap_distance then
			local new_pos = dummy:GetAbsOrigin() + leap_direction * leap_speed
			dummy:SetAbsOrigin(new_pos)
			leap_traveled = leap_traveled + leap_speed
			return 0.03
		else
			dummy:StopSound("Hero_Invoker.Tornado")
			dummy:RemoveSelf()
		end
	end)
end

function bvo_nami_skill_4_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetIntellect() * multi,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_nami_skill_5(keys)
	local caster = keys.caster
	local ability = keys.ability
	--
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeam())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	dummy:AddAbility("bvo_nami_skill_1_extra")
	dummy:FindAbilityByName("bvo_nami_skill_1_extra"):SetLevel(1)
	dummy:SetControllableByPlayer(caster:GetPlayerID(), false)
	ability.dummy5 = dummy
	dummy:FindAbilityByName("bvo_nami_skill_1_extra"):ApplyDataDrivenModifier(caster, dummy, "bvo_nami_skill_1_smoke_modifier", {} )

	Timers:CreateTimer(40.0, function()
		if ability.dummy5 ~= nil and not ability.dummy5:IsNull() then
			ability.dummy5:RemoveSelf()
			ability.dummy5 = nil
		end
	end)
end

function bvo_nami_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi
	local damage = keys.damage

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ( caster:GetIntellect() * multi ) + damage,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
end