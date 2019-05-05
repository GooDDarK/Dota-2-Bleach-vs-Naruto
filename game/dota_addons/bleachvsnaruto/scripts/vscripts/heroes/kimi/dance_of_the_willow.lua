function appylDamage( keys )
	if not keys.target:IsBuilding() and keys.target:GetTeamNumber() ~= keys.caster:GetTeamNumber() then
		local agility_percent = keys.ability:GetLevelSpecialValueFor("agility_percent",keys.ability:GetLevel() - 1)
		local agility = keys.caster:GetAgility()
		local damage = agility / 100 * agility_percent
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
		PopupDamage(keys.target, math.floor(damage))
	end
end