function bvo_zaraki_skill_0_death( event )
	local caster = event.caster
	local ability = event.ability
	local modifier = event.modifier
	local attacker = event.attacker

	if caster:GetHealth() == 0 and attacker:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS then
		local current_stack = caster:GetModifierStackCount( modifier, ability )
		local new_stack = current_stack - 1
		if new_stack < 0 then new_stack = 0 end

		if new_stack == 0 then
			caster:RemoveModifierByName(modifier)
		else
			caster:SetModifierStackCount( modifier, ability, new_stack )
		end
	end
end

function bvo_zaraki_skill_0_stack( event )
	local caster = event.caster
	local target = event.target -- unit? The killed thing
	local modifier = event.modifier
	local ability = event.ability

	-- Check if the hero already has the modifier
	local current_stack = caster:GetModifierStackCount( modifier, ability )
	if not caster:HasModifier( modifier ) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	end

	-- Set the stack up to max_souls
	caster:SetModifierStackCount( modifier, ability, current_stack + 1 )
end

function bvo_zaraki_skill_1(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damage = keys.damage
	local block = keys.block
	
	local true_damage = damage - block
	if true_damage > 0 then
		if true_damage > caster:GetHealth() then return end
		caster:Heal(block, caster)
	else
		caster:Heal(damage, caster)
	end
end

function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()

	local difference = target:GetAbsOrigin() - caster:GetAbsOrigin()

	ability.leap_distance = difference:Length2D()

	local speed = 1000
	local roll = RandomInt(1, 100)
	if roll < 21 then
		speed = speed + 1000
	end

	ability.leap_speed = speed * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0

	--charge logic
	ability:EndCooldown()
	local current_stack = caster:GetModifierStackCount( "bvo_zaraki_skill_3_modifier", ability )
	local new_stack = current_stack - 1
	if new_stack == 0 then
		caster:RemoveModifierByName("bvo_zaraki_skill_3_modifier")
		--set remaining cd to next charge
		local mods = caster:FindAllModifiers()
		local charge = 30
		for _,mod in pairs(mods) do
			if mod:GetName() == "bvo_zaraki_skill_3_load_modifier" then
				local time = 30 - mod:GetElapsedTime()
				if time < charge then charge = time end
			end
		end
		ability:StartCooldown(charge)
	else
		caster:SetModifierStackCount("bvo_zaraki_skill_3_modifier", ability, new_stack )
		ability:StartCooldown(1.5)
	end
	ability.zaraki_skill_3_stacks = ability.zaraki_skill_3_stacks - 1
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
		local cast = caster:FindAbilityByName("bvo_zaraki_skill_3_extra")
		cast:SetLevel(caster:FindAbilityByName("bvo_zaraki_skill_3_extra"):GetLevel())
		caster:CastAbilityNoTarget(cast, caster:GetPlayerID())
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end

function bvo_zaraki_skill_3_init(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability.zaraki_skill_3_init == nil then
		ability.zaraki_skill_3_init = true
		ability.zaraki_skill_3_stacks = 2
		caster:SetModifierStackCount( "bvo_zaraki_skill_3_modifier", ability, 2 )
	else
		if ability.zaraki_skill_3_stacks > 0 then
			caster:SetModifierStackCount( "bvo_zaraki_skill_3_modifier", ability, ability.zaraki_skill_3_stacks )
		else
			caster:RemoveModifierByName("bvo_zaraki_skill_3_modifier")
		end
	end
end

function bvo_zaraki_skill_3_charge(keys)
	local caster = keys.caster
	local ability = keys.ability
	local current_stack = caster:GetModifierStackCount( "bvo_zaraki_skill_3_modifier", ability )
	ability.zaraki_skill_3_stacks = ability.zaraki_skill_3_stacks + 1
	if not caster:HasModifier("bvo_zaraki_skill_3_modifier") then
		ability:ApplyDataDrivenModifier(caster, caster, "bvo_zaraki_skill_3_modifier", {} )
	end
	caster:SetModifierStackCount( "bvo_zaraki_skill_3_modifier", ability, current_stack + 1 )
	
end

function bvo_zaraki_skill_3_extra_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi

	local str = caster:GetStrength()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end

function bvo_zaraki_skill_4(keys)
	local caster = keys.caster

	if caster:HasModifier("bvo_zaraki_skill_4_modifier") then return end
end

function bvo_zaraki_skill_4_dead(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_zaraki_skill_5(keys)
	local caster = keys.caster

	local forward = caster:GetForwardVector()

	for i = 1, 4 do
		local point = caster:GetAbsOrigin() + forward * i * 200
		local dummy = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, caster:GetTeam())
		dummy:AddAbility("custom_point_dummy")
		local abl = dummy:FindAbilityByName("custom_point_dummy")
		if abl ~= nil then abl:SetLevel(1) end
		local particleName = "particles/units/heroes/hero_earthshaker/earthshaker_fissure_small_rocks.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, dummy)
		ParticleManager:SetParticleControl(particle, 0, dummy:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())

		Timers:CreateTimer(0.3, function()
			UTIL_Remove(dummy)
		end)
	end
end

function bvo_zaraki_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multi1 = keys.multi1
	local multi2 = keys.multi2

	local str = caster:GetStrength()

	local ability = caster:FindAbilityByName("bvo_zaraki_skill_0")
	local modifier = "bvo_zaraki_skill_0_modifier_bonus"
	local plus
	if modifier == nil then
		plus = 0
	else
		plus = caster:GetModifierStackCount( modifier, ability )
		plus = plus * 10
	end

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}

	ApplyDamage(damageTable)
end