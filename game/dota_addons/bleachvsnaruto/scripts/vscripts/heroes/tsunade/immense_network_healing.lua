function applyModifier( keys )
	keys.ability.katsuyu = false
	local katsuyu = Entities:FindByModel(nil, "models/tsunade/katsuyu.vmdl")
	if katsuyu ~= nil then
		keys.ability.katsuyu = true	
		keys.ability.katsuyuLvl = katsuyu:GetLevel()
		local summo_ability = keys.caster:FindAbilityByName("tsunade_summon_katsuyu")
		summo_ability:StartCooldown(summo_ability:GetCooldown(summo_ability:GetLevel()))
	end
	
	if katsuyu ~= nil then
		katsuyu:RemoveSelf()
	end


	for playerID=0,DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetAssignedHero():GetTeamNumber() == keys.caster:GetTeamNumber() and player:GetAssignedHero():IsAlive() and player:GetAssignedHero() ~= keys.caster then
				keys.ability:ApplyDataDrivenModifier(keys.caster,player:GetAssignedHero(),keys.modifier_name,{})
			end
		end
	end
end

function manaCosts( keys )
	-- Variables
	local ability_level = keys.ability:GetLevel()
	local caster = keys.caster
	local ability = keys.ability
	local manacost_per_second = keys.ability:GetLevelSpecialValueFor("manacost_per_second", keys.ability:GetLevel() - 1 )
	local manacost_per_second_after_percentage = caster:GetMaxMana() / 100 * manacost_per_second / 10
	local current_mana = caster:GetMana()
	local new_mana = current_mana - manacost_per_second_after_percentage
	if (current_mana - manacost_per_second_after_percentage) <= 0 then
		caster:SetMana(1)
		removeModifierFromMana(caster, "tsunade_immense_network_healing_buff")
	else
		caster:SetMana(new_mana)
	end
end

function removeModifierFromMana(caster, modifier_name )
	for playerID=0,DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetAssignedHero():GetTeamNumber() == caster:GetTeamNumber() and player:GetAssignedHero():IsAlive() and player:GetAssignedHero() ~= caster then
				if player:GetAssignedHero():HasModifier(modifier_name) then
					player:GetAssignedHero():RemoveModifierByName(modifier_name)
				end
			end
		end
	end
end

function removeModifier( keys )
	for playerID=0,DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetAssignedHero():GetTeamNumber() == keys.caster:GetTeamNumber() and player:GetAssignedHero():IsAlive() and player:GetAssignedHero() ~= keys.caster then
				if player:GetAssignedHero():HasModifier(keys.modifier_name) then
					player:GetAssignedHero():RemoveModifierByName(keys.modifier_name)
				end
			end
		end
	end
end

function healAllies( keys )

	local katsuyu = Entities:FindByModel(nil, "models/tsunade/katsuyu.vmdl")
	local unit = keys.unit
	local caster = keys.caster
	local damage = keys.damage
	local heal_from_damage_percentage = keys.ability:GetLevelSpecialValueFor("heal_from_damage_percentage", keys.ability:GetLevel() - 1 )
	local heal = 0
	if keys.ability.katsuyu then
		if  keys.ability.katsuyuLvl == 5 then
			 heal = damage / 100 * (heal_from_damage_percentage + 5.0)
		else
			 heal = damage / 100 * heal_from_damage_percentage
		end
	else
		 heal = damage / 100 * heal_from_damage_percentage
	end
	
	unit:Heal(heal,caster)
	PopupHealing(unit, math.floor(heal))
	
end


function restoreManaAllies(keys )
	local hero = keys.unit
	local manacost = keys.event_ability:GetManaCost(keys.event_ability:GetLevel() - 1)
	local mana_restore_percentage = keys.ability:GetLevelSpecialValueFor("mana_restore_percentage", keys.ability:GetLevel() - 1 )
	local bonus_mana = 0
	if keys.ability.katsuyu then
		if keys.ability.katsuyuLvl == 5 then
			 bonus_mana = manacost / 100 * (mana_restore_percentage + 5.0)
		else
			 bonus_mana = manacost / 100 * mana_restore_percentage
		end
	else
		 bonus_mana = manacost / 100 * mana_restore_percentage
	end
	if (hero:GetMana() + bonus_mana) > hero:GetMaxMana() then
		hero:SetMana(hero:GetMaxMana())
	else
		hero:SetMana(hero:GetMana() + bonus_mana)
	end
	PopupMana(hero, math.floor(bonus_mana))
end