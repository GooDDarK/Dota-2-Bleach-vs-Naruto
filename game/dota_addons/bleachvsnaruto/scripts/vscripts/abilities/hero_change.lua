
function GiveNewHero(keys) 
	local caster = keys.caster 
	local playerID = caster:GetPlayerID()
	local oldHero = caster--PlayerResource:GetSelectedHeroEntity(playerID)	
	local newHeroName = keys.hero_name
	local gold = oldHero:GetGold()
	local experience = oldHero:GetCurrentXP() 
	print("gold = "..gold.." exp = "..experience)
	
	if playerID ~= nil and playerID ~= -1 then 
		items_table = {} 
		for i = 0, 14 do 
			local item = oldHero:GetItemInSlot( i ) 
			if item ~= nil then 
				items_table[item:GetName()] = item:GetCurrentCharges() 
				item:RemoveSelf() 
			end 
		end 
		local newHero = PlayerResource:ReplaceHeroWith(playerID, newHeroName, 0, 0) 
		newHero:RespawnHero(false, false) 
		
		newHero:SetGold(gold, false)
		newHero:AddExperience(experience, 0, false, true)
		for item,stacks in pairs(items_table) do 
			newHero:AddItemByName(item):SetCurrentCharges(stacks) 
		end 
	end 
end