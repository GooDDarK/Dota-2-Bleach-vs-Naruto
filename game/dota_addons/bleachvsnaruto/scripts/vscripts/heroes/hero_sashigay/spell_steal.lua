--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Get's the target's most recently cast spell]]
function GetLastSpell(keys)
	local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
    print("targetl =",target:GetName())
	-- Loops throught the target's abilities
	for i=0, 15 do
		local current_ability = target:GetAbilityByIndex(i)
		print("current_ability =",current_ability)
		if current_ability ~= nil then
			-- If the ability is toggleable, checks if it was turned on
			if current_ability:IsToggle() then
				if current_ability:GetToggleState() == true then
					-- Set this as the target's most recently cast ability
					target.last_ability = current_ability
				end
			else
				-- Finds the ability that caused the event trigger by checking if the cooldown is equal to the full cooldown
				local cd = current_ability:GetCooldownTimeRemaining()
				local full_cd = current_ability:GetCooldown(current_ability:GetLevel()-1)
				print("cd =",cd)
				print("full_cd =",full_cd)
				-- There is a delay after the ability cast event and before the ability goes on cooldown
				-- If the ability is on cooldown and the cooldown is within a small buffer of the full cooldown
				-- Set this as the target's most recently cast ability
				if cd > 0 and full_cd - cd < 0.04 then
					target.last_ability = current_ability
				end

			end
			
		end
	end
	if target.last_ability ~= nil then
		ability.new_steal = target.last_ability
		

	local new_ability_name = ability.new_steal:GetAbilityName()
	local new_ability_level = ability.new_steal:GetLevel()
	print("new_ability_level =",new_ability_level)
	if caster:HasModifier("modifier_spell_steal_datadriven") == false then
		caster:AddAbility(new_ability_name)
		caster:SwapAbilities("empty1_sasugay", new_ability_name, false, true)
		caster:FindAbilityByName(new_ability_name):SetLevel(new_ability_level)
	-- If the new stolen ability is not the same as the previous one, swap them
	elseif new_ability_name ~= ability.current_steal:GetAbilityName() then
		caster:AddAbility(new_ability_name)
		caster:SwapAbilities(ability.current_steal:GetAbilityName(), new_ability_name, false, true)
		caster:FindAbilityByName(new_ability_name):SetLevel(new_ability_level)
	end
	
	ability.current_steal = ability.new_steal
	print("ability.current_steal =",ability.current_steal)
	print("ability.new_steal =",ability.new_steal)
	 if caster:HasModifier("modifier_sasuke_talent_2") then
	    local duration = ability:GetLevelSpecialValueFor("addduration", ability:GetLevel() -1)
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_spell_steal_datadriven", { duration = duration })
	   else
        local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_spell_steal_datadriven", { duration = duration })
	  end

	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Ensures the target has cast a spell]]
function SpellCheck(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", (ability:GetLevel() -1))
	
	if target.last_ability ~= nil then
		ability.new_steal = target.last_ability
		-- Create the projectile
		local info = {
		Target = caster,
		Source = target,
		Ability = ability,
		EffectName = keys.particle,
		bDodgeable = false,
		bProvidesVision = false,
		iMoveSpeed = projectile_speed,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		}
		ProjectileManager:CreateTrackingProjectile( info )
	else
		-- Resets the cooldown
		ability:EndCooldown()
		-- Regains lost mana
		ability:RefundManaCost()
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Swaps rubick's spells]]
function SpellSteal(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local new_ability_name = ability.new_steal:GetAbilityName()
	local new_ability_level = ability.new_steal:GetLevel() - 1
	
	-- If the caster has no stolen spell, swap the new one with the empty spell
	if caster:HasModifier("modifier_spell_steal_datadriven") == false then
		caster:AddAbility(new_ability_name)
		caster:SwapAbilities("empty1_datadriven", new_ability_name, false, true)
		caster:FindAbilityByName(new_ability_name):SetLevel(new_ability_level)
	-- If the new stolen ability is not the same as the previous one, swap them
	elseif new_ability_name ~= ability.current_steal:GetAbilityName() then
		caster:AddAbility(new_ability_name)
		caster:SwapAbilities(ability.current_steal:GetAbilityName(), new_ability_name, false, true)
		caster:FindAbilityByName(new_ability_name):SetLevel(new_ability_level)
	end
	
	ability.current_steal = ability.new_steal
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_spell_steal_datadriven", {})
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Swaps the stolen spell with the empty spell]]
function RemoveSpell(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability.current_steal ~= nil then
	local new_ability_name = ability.current_steal:GetAbilityName()
	 
	caster:SwapAbilities(new_ability_name, "empty1_sasugay", false, true)
	--caster:RemoveAbility(new_ability_name)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Since you can still level up stolen spells, they automatically readjust to the level when stolen]]
function FixLevels(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local current_ability = caster:FindAbilityByName(ability.current_steal:GetAbilityName())
	local correct_ability_level = ability.current_steal:GetLevel()
	local current_ability_points = caster:GetAbilityPoints()
	
	-- Checks if the current stolen ability's level is higher than it should be
	if current_ability:GetLevel() > correct_ability_level then
		-- Counts how many levels have been added
		local levels_higher = current_ability:GetLevel() - correct_ability_level
		-- Sets the ability to the correct level
		current_ability:SetLevel(correct_ability_level)
		-- Gives the caster back the unused ability points
		caster:SetAbilityPoints(levels_higher + current_ability_points)
	end
end

function modifier_write_eye_cost(keys)
local  caster = keys.caster
local  ability = keys.ability
local mana_cost = keys.ManaCost
-- local modifier_flamewing = keys.modifier_flamewing
	if caster:GetMana() >= mana_cost then
	caster:SpendMana(mana_cost, ability)
	else
	ability:ToggleAbility()
end

end
