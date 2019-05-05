require("timers")

function bvo_law_skill_4(keys)
	local caster = keys.caster
	local target = keys.target
	local playerID = target:GetPlayerID()
	local ability = keys.ability
	local parts = ability:GetLevelSpecialValueFor("parts", ability:GetLevel() - 1 )
	local dur = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )

	local model = target:GetModelName()
	local modelScale = target:GetModelScale()
	local health = target:GetHealth()
	target.law_skill_4_health = health
	target:AddNoDraw()

	local dummy = CreateUnitByName("npc_dummy_unit", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:AddAbility("custom_point_dummy")
	local abl = dummy:FindAbilityByName("custom_point_dummy")
	if abl ~= nil then abl:SetLevel(1) end
	ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
	Timers:CreateTimer(3.0, function ()
		dummy:RemoveSelf()
	end)

	local model_size = 1.5
	local part_size = 1 - ( parts / 10 )
	if part_size < 0.1 then part_size = 0.1 end
	--Split into parts
	target.all_law_parts = {}	
	for i = 1, parts do
		local offset = Vector( RandomFloat(-1, 1), RandomFloat(-1, 1), 0 ) * 100
		if not GridNav:CanFindPath(target:GetAbsOrigin(), target:GetAbsOrigin() + offset) then
			offset = Vector(0,0,0)
		end
		local part = CreateUnitByName("npc_dota_bvo_law_skill_4_split", target:GetAbsOrigin() + offset, true, target, nil, target:GetTeamNumber())
		FindClearSpaceForUnit(part, part:GetAbsOrigin(), false)
		part:SetControllableByPlayer(playerID, true)
		ability:ApplyDataDrivenModifier(caster, part, "bvo_law_skill_4_part_modifier", {})
		ability:ApplyDataDrivenModifier(caster, part, "bvo_law_skill_4_tip_modifier", {duration=dur})
		part:SetBaseMaxHealth(health * part_size)
		part:SetMaxHealth(health * part_size)
		part:SetHealth(part:GetMaxHealth())
		part:SetOriginalModel(model)
		part:SetModel(model)
		part:SetModelScale(modelScale / model_size)
		FindClearSpaceForUnit(part, part:GetAbsOrigin(), false)
		part:StartGesture(ACT_DOTA_RUN)
		part.pparent = target
		
		--motion
		local leap_direction = ( part:GetAbsOrigin() - target:GetAbsOrigin() ):Normalized()
		leap_direction = Vector(leap_direction.x, leap_direction.y, 0)
		local leap_distance = 300
		local leap_speed = 800
		local leap_traveled = 0
		Timers:CreateTimer(0.03, function()
			leap_speed = leap_speed - 10
			if leap_traveled < leap_distance then
				local new_pos = part:GetAbsOrigin() + leap_direction * (leap_speed * 1/30)
				if GridNav:CanFindPath(part:GetAbsOrigin(), new_pos) then
					part:SetAbsOrigin(new_pos)
					leap_traveled = leap_traveled + (leap_speed * 1/30)
					return 0.03
				else
					return nil
				end
			else
				return nil
			end
		end)

		table.insert(target.all_law_parts, part)
		model_size = model_size + 0.5
		part_size = part_size - 0.1
		if part_size < 0.1 then part_size = 0.1 end
		if model_size > 4 then model_size = 4 end
	end
	target.part_hits = 0
	target.part_dead = 0
	target.part_count = #target.all_law_parts
	
	--target:SetAbsOrigin(Vector(-14000, 12000, 256))
end

function bvo_law_skill_4_end( keys )
	local caster = keys.caster
	local target = keys.target
	if target:IsAlive() then
		local ability = keys.ability
		local biggest_part = nil
		for _,part in pairs(target.all_law_parts) do
			if not part:IsNull() and part:IsAlive() then
				if biggest_part == nil then biggest_part = part end
				if part:GetMaxHealth() > biggest_part:GetMaxHealth() then biggest_part = part end
			end
		end
		if GridNav:CanFindPath(target:GetAbsOrigin(), biggest_part:GetAbsOrigin()) then
			FindClearSpaceForUnit(target, biggest_part:GetAbsOrigin(), false)
		end
		ability:ApplyDataDrivenModifier(caster, target, "bvo_law_skill_4_wait_modifier", {})
		for _,part in pairs(target.all_law_parts) do
			if not part:IsNull() and part:IsAlive() then
				if part ~= biggest_part then
					local projTable = {
				        EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
				        Ability = ability,
				        Target = target,
				        Source = part,
				        bDodgeable = false,
				        bProvidesVision = false,
				        vSpawnOrigin = part:GetAbsOrigin(),
				        iMoveSpeed = 3000,
				        iVisionRadius = 0,
				        iVisionTeamNumber = part:GetTeamNumber(),
				        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK
				    }
				    ProjectileManager:CreateTrackingProjectile(projTable)
				else
					target.part_hits = target.part_hits + 1
					local alive_parts = target.part_count - target.part_dead
					if target.part_hits == alive_parts then
						target:RemoveModifierByName("bvo_law_skill_4_wait_modifier")
						target:RemoveNoDraw()
						target:SetHealth(target.law_skill_4_health)
					end
				end
			    part:RemoveSelf()
			end
		end
	end
end

function bvo_law_skill_4_hit( keys )
	local target = keys.target
	target.part_hits = target.part_hits + 1
	local alive_parts = target.part_count - target.part_dead
	if target.part_hits == alive_parts then
		target:RemoveModifierByName("bvo_law_skill_4_wait_modifier")
		target:RemoveNoDraw()
		target:SetHealth(target.law_skill_4_health)
	end
end

function bvo_law_skill_4_part_die( keys )
	local target = keys.unit.pparent
	local caster = keys.caster
	local ability = keys.ability
	target.part_dead = target.part_dead + 1
	if target.part_dead == target.part_count then
		target:RemoveModifierByName("bvo_law_skill_4_wait_modifier")
		FindClearSpaceForUnit(target, keys.unit:GetAbsOrigin(), false)
		target:RemoveNoDraw()
		target:Kill(ability, caster)
	end
end