function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end

	if caster:HasModifier("modifier_kimi_clematis_dance") then
		caster:SetModel("models/kimi/kimi_model.vmdl")
		caster:SetOriginalModel("models/kimi/kimi_model.vmdl")
	else
		caster:SetModel("models/kimi/kimi_cs_no_clemantis.vmdl")
		caster:SetOriginalModel("models/kimi/kimi_cs_no_clemantis.vmdl")
	end

end

function ModelSwapEnd( keys )
	local caster = keys.caster
	if caster:HasModifier("modifier_kimi_clematis_dance") then
		caster:SetModel("models/kimi/kimi_dance.vmdl")
		caster:SetOriginalModel("models/kimi/kimi_dance.vmdl")
	else
		caster:SetModel("models/kimi/kimi_no_cs.vmdl")
		caster:SetOriginalModel("models/kimi/kimi_no_cs.vmdl")
	end
	keys.ability.agilityGain = 0
end

function agility_gain( keys )
	if not keys.target:IsBuilding() and keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() then
		local agility_gain = keys.ability:GetLevelSpecialValueFor("agility_gain",keys.ability:GetLevel() - 1)

		if not keys.ability.agilityGain then
			keys.ability.agilityGain = 0
		end
		keys.ability.agilityGain = keys.ability.agilityGain + agility_gain
		keys.caster:SetModifierStackCount("modifier_kimi_cursed_seal_agi_bonus", keys.ability, keys.ability.agilityGain)
	end
end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("kimi_e",keys.caster)
	elseif random == 2 then
		EmitSoundOn("kimi_e_2",keys.caster)
	end
end