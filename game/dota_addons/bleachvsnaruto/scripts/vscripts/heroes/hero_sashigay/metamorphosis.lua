function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local ability = keys.ability
	local projectile_model = keys.projectile_model

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	-- caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new model and projectile
	caster:SetOriginalModel(model)
	-- caster:SetRangedProjectileName(projectile_model)

	-- Sets the new attack type
	-- caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	caster:SwapAbilities("Amaterasu", "sasuke_chidori_eiso", true, false) 
	caster:SwapAbilities("sasunoo_arrow", "sasuke_chidori_nagashi", true, false)
end

function ModelSwapEnd( keys )
	local caster = keys.caster

	caster:SwapAbilities("Amaterasu", "sasuke_chidori_eiso", false, true) 
	caster:SwapAbilities("sasunoo_arrow", "sasuke_chidori_nagashi", false, true)
	-- caster:SetAttackCapability(caster.caster_attack)
end

function HideWearables( event )
	local hero = event.caster
	local ability = event.ability

	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		if IsValidEntity(v) then 
            v:RemoveEffects(EF_NODRAW) 
        end
	end
end


function sasunochange( event )
	local caster = event.caster
	local ability = event.ability

	 if caster:HasModifier("modifier_sasuke_talent_3") then
	    local duration = ability:GetLevelSpecialValueFor("talent_duration", ability:GetLevel() -1)
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_metamorphosis", { duration = duration })
	   else
        local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_metamorphosis", { duration = duration })
	  end
end