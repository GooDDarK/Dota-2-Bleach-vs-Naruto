function applyBonusDmg( keys )
	local bonus_dmg_percentage = keys.ability:GetLevelSpecialValueFor("bonus_dmg_percentage",keys.ability:GetLevel() - 1)

	local current_dmg = keys.caster:GetAverageTrueAttackDamage(nil)

	local bonus_dmg = current_dmg / 100 * bonus_dmg_percentage
	if keys.caster:GetModifierStackCount("modifier_kimi_clematis_dance_dmg",keys.ability) == 0 then
		keys.caster:SetModifierStackCount("modifier_kimi_clematis_dance_dmg",keys.ability,bonus_dmg)
	end
end

function countStun( keys )


	local stun_duration = keys.ability:GetLevelSpecialValueFor("stun_duration",keys.ability:GetLevel() - 1)

	 if not keys.ability.stunCount then
	 	keys.ability.stunCount = 0
	 end

	 keys.ability.stunCount = keys.ability.stunCount + 1

	 if keys.ability.stunCount == 3 then

		if not keys.target:IsBuilding() and keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() then
	 			keys.target:AddNewModifier(keys.caster,keys.ability,"modifier_stunned",{duration = stun_duration})
		end
	 	keys.caster:RemoveModifierByName("modifier_kimi_clematis_dance")
	 	keys.caster:RemoveModifierByName("modifier_kimi_clematis_dance_dmg")

	 	keys.ability.stunCount = 0
	 end

end

 
function applyModel( keys )
	local caster = keys.caster
	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	if caster:GetModelName() == 'models/kimi/kimi_no_cs.vmdl' then
		keys.caster:SetModel(keys.modelname)
		keys.caster:SetOriginalModel(keys.modelname)
	else
		keys.caster:SetModel(keys.modelnamecs)
		keys.caster:SetOriginalModel(keys.modelnamecs)
	end

	local pid = ParticleManager:CreateParticle("particles/units/heroes/kimimaro/clemantis.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(pid, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_left_hand", keys.caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(pid, 9, keys.caster, PATTACH_POINT_FOLLOW, "attach_left_hand", keys.caster:GetAbsOrigin(), false)

	local pid = ParticleManager:CreateParticle("particles/units/heroes/kimimaro/clemantis.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(pid, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_right_hand", keys.caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(pid, 9, keys.caster, PATTACH_POINT_FOLLOW, "attach_right_hand", keys.caster:GetAbsOrigin(), false)
end

function ModelSwapEnd(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_kimi_cursed_seal_agi_bonus") then
		caster:SetModel("models/kimi/kimi_cs_no_clemantis.vmdl")
		caster:SetOriginalModel("models/kimi/kimi_cs_no_clemantis.vmdl")
	else
		caster:SetModel("models/kimi/kimi_no_cs.vmdl")
		caster:SetOriginalModel("models/kimi/kimi_no_cs.vmdl")
	end
end

function playSound( keys )
	local random = math.random(1, 2)
	if random == 1 then
		EmitSoundOn("kimi_q",keys.caster)
	elseif random == 2 then
		EmitSoundOn("kimi_q_2",keys.caster)
	end
end