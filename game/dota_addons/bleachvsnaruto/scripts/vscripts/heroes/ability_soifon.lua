function Blink(keys)
    local ability = keys.ability
	local caster = keys.caster
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local casterPosB = caster:GetAbsOrigin()
	if not GridNav:CanFindPath(casterPos, casterPosB) then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1))
		FindClearSpaceForUnit(caster, casterPos, false)
    	return
	end
end

function bvo_soifon_skill_2(keys)
	local caster = keys.caster
	if caster.santa_hat ~= nil and not caster.santa_hat:IsNull() then
		caster:FindAbilityByName("bvo_mana_on_hit"):ApplyDataDrivenModifier(caster, caster.santa_hat, "bvo_extra_invis_modifier", {duration=4.0} )
	end
end

function bvo_soifon_skill_3(keys)
	local caster = keys.caster
	local target = keys.target
	local multi = keys.multi

	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)

	local c_agi = caster:GetAgility()
	local t_agi
	if target:IsHero() then t_agi = target:GetAgility()
	else t_agi = 0 end

	local diff = c_agi - t_agi
	if diff < 0 then diff = 0 end

	local multi = 1
	if caster:HasModifier("bvo_soifon_skill_4_modifier") or caster:HasModifier("bvo_soifon_skill_4_perma_modifier") then multi = 1.75 end

	caster:MoveToTargetToAttack(target)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = (400 + (diff * multi)) * multi,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
	
	caster:StartGesture(ACT_DOTA_ATTACK)
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_blood.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
end

function bvo_soifon_skill_4_end(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsSilenced() and not caster:IsStunned() and caster:IsAlive() and caster:IsRealHero() and caster:GetMana() > ability:GetManaCost(ability:GetManaCost(ability:GetLevel() - 1)) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerID())
	end
end

function bvo_soifon_skill_5_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local max_miss = keys.miss
	local ability = keys.ability

	local cooldown = ability:GetCooldown( ability:GetLevel() - 1 )
	local cd_reduction_items = {
		"item_doom_4",
		"item_doom_5",
	}
	for _,cdItem in pairs(cd_reduction_items) do
	    if caster:HasItemInInventory(cdItem) then
	    	local item = CreateItem(cdItem, caster, caster)
			local reduction = item:GetLevelSpecialValueFor("cd_reduction", 0 )
		    item:RemoveSelf()
		    local reduction = reduction / 100
		    cooldown = cooldown * ( 1.0 - reduction )
		end
	end
	ability:StartCooldown(cooldown)

	target:EmitSound("Hero_TemplarAssassin.Trap.Trigger")
	if not target:HasModifier("bvo_soifon_skill_5_modifier") then
		ability:ApplyDataDrivenModifier(caster, target, "bvo_soifon_skill_5_modifier", {} )
		local agi = caster:GetAgility()
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = agi * 3,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(damageTable)
	elseif target:GetLevel() < caster:GetLevel() or target:GetMaxHealth() * 0.25 > target:GetHealth() then
		target:RemoveModifierByName("bvo_soifon_skill_5_modifier")

		local c_agi = caster:GetAgility()
		local t_agi
		if target:IsHero() then t_agi = target:GetAgility()
		else t_agi = 0 end

		local miss = t_agi / c_agi
		miss = miss * 100
		if miss > max_miss then miss = max_miss end

		if target:IsStunned() then miss = miss - 20 end

		local roll = RandomInt(1, 100)
		if roll > miss then
			target:Kill(ability, caster)
		end
	else
		target:RemoveModifierByName("bvo_soifon_skill_5_modifier")

		local agi = caster:GetAgility()
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = agi * 20,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		ApplyDamage(damageTable)
	end
end

function bvo_soifon_skill_5_autodamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local manaCost = ability:GetManaCost( ability:GetLevel() - 1 )
	if target:IsHero() and caster:IsRealHero() then
		if ability:IsCooldownReady() and ability:GetAutoCastState() and caster:GetMana() > manaCost then
			caster:SpendMana(manaCost, ability)
			bvo_soifon_skill_5_damage( keys )
		end
	end
end