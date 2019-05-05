function bvo_anzu_skill_3(keys)
	local caster = keys.caster

	caster:Heal(caster:GetMaxHealth() * (keys.RegenPercentPerSecond / 100) * keys.Interval, caster)
	caster:GiveMana(caster:GetMaxMana() * (keys.RegenPercentPerSecond / 100) * keys.Interval)
end