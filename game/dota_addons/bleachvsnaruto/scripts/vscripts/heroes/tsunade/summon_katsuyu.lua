function summon_katsuyu( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin() 
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local armor_gain = ability:GetLevelSpecialValueFor( "armor_gain", ability:GetLevel() - 1 )
	local hp_gain = ability:GetLevelSpecialValueFor( "hp_gain", ability:GetLevel() - 1 )
	-- Ability variables
	local duration = ability:GetSpecialValueFor("duration") 

	-- Clear any previous Karasu in case of WTF Mode
	if IsValidEntity(ability.karasu) then 
		ability.karasu:ForceKill(false)
	end

	--Creates the Puppet next to the Caster
	local katsuyu  = CreateUnitByName("npc_katsuyu", caster_location + RandomVector(150), true, caster, caster, caster:GetTeamNumber())
	--Stores the unit for tracking
	ability.karasu = katsuyu
	katsuyu:AddNewModifier(caster, ability, "modifier_phased", {duration = 0.03})


	local pid = ParticleManager:CreateParticle("particles/units/heroes/tsunade/summon_katsuyu.vpcf", PATTACH_ABSORIGIN_FOLLOW, katsuyu)
	ParticleManager:SetParticleControlEnt(pid, 0, katsuyu, PATTACH_POINT_FOLLOW, "attach_hitloc", katsuyu:GetAbsOrigin(), false)
	katsuyu:SetArmorGain(armor_gain)
	--Determine Karasu's Skills
	if (ability:GetLevel() == 1) then
		katsuyu:CreatureLevelUp(1)
		katsuyu:FindAbilityByName("katsuyu_tongue_tooth_sticky_acid"):SetLevel(1)
		katsuyu:FindAbilityByName("katsuyu_kuchiyose_no_jutsu"):SetLevel(1)
		katsuyu:FindAbilityByName("katsuyu_physical_composition"):SetLevel(1)
		katsuyu:FindAbilityByName("katsuyu_slug_great_division"):SetLevel(1)

	elseif (ability:GetLevel() == 2) then
		katsuyu:SetMaxHealth(katsuyu:GetMaxHealth()+hp_gain)
		katsuyu:SetHealth(katsuyu:GetMaxHealth()+hp_gain)
		katsuyu:CreatureLevelUp(2)
		katsuyu:FindAbilityByName("katsuyu_tongue_tooth_sticky_acid"):SetLevel(2)
		katsuyu:FindAbilityByName("katsuyu_kuchiyose_no_jutsu"):SetLevel(2)
		katsuyu:FindAbilityByName("katsuyu_physical_composition"):SetLevel(2)
		katsuyu:FindAbilityByName("katsuyu_slug_great_division"):SetLevel(2)
	elseif (ability:GetLevel() == 3) then
		katsuyu:SetMaxHealth(katsuyu:GetMaxHealth()+(hp_gain*2))
		katsuyu:SetHealth(katsuyu:GetMaxHealth()+(hp_gain*2))
		katsuyu:CreatureLevelUp(3)
		katsuyu:FindAbilityByName("katsuyu_tongue_tooth_sticky_acid"):SetLevel(3)
		katsuyu:FindAbilityByName("katsuyu_kuchiyose_no_jutsu"):SetLevel(3)
		katsuyu:FindAbilityByName("katsuyu_physical_composition"):SetLevel(3)
		katsuyu:FindAbilityByName("katsuyu_slug_great_division"):SetLevel(3)
	elseif (ability:GetLevel() == 4) then
		katsuyu:SetMaxHealth(katsuyu:GetMaxHealth()+(hp_gain*3))
		katsuyu:SetHealth(katsuyu:GetMaxHealth()+(hp_gain*3))
		katsuyu:CreatureLevelUp(4)
		katsuyu:FindAbilityByName("katsuyu_tongue_tooth_sticky_acid"):SetLevel(4)
		katsuyu:FindAbilityByName("katsuyu_kuchiyose_no_jutsu"):SetLevel(4)
		katsuyu:FindAbilityByName("katsuyu_physical_composition"):SetLevel(4)
		katsuyu:FindAbilityByName("katsuyu_slug_great_division"):SetLevel(4)
	end

	katsuyu:SetControllableByPlayer(player, true)

	--Kills Puppet after timer
	Timers:CreateTimer(duration,function()
		if katsuyu ~= nil and katsuyu:IsAlive() then
			katsuyu:ForceKill(false)
		end
	end)
end