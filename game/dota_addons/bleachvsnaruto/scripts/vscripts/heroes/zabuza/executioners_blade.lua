function execute( keys )
	local target = keys.target
	local caster = keys.caster
	local target_hp_percent = caster:GetHealth() / (caster:GetMaxHealth() / 100) 
	if target_hp_percent <= 30 or caster:HasModifier("modifier_demon_mark") then
		if not target:IsBuilding() and keys.caster:GetTeamNumber() ~= keys.target:GetTeamNumber() then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_executioners_blade_crit", {duration = 0.3})
		end
	end
end