function applyDamage( keys )

    local radius = keys.ability:GetLevelSpecialValueFor("radius",keys.ability:GetLevel() - 1)
    local damage = keys.ability:GetLevelSpecialValueFor("damage",keys.ability:GetLevel() - 1)
    local life_percentage_damage = keys.ability:GetLevelSpecialValueFor("life_percentage_damage",keys.ability:GetLevel() - 1)
    local slow_duration = keys.ability:GetLevelSpecialValueFor("slow_duration",keys.ability:GetLevel() - 1)

    local caster = keys.caster

    local targetEntities = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    if targetEntities then
        for _,target in pairs(targetEntities) do
            local realdamage = (target:GetHealth() / 100 * life_percentage_damage) + damage
           ApplyDamage({victim = target, attacker = keys.caster, damage = realdamage, damage_type = DAMAGE_TYPE_MAGICAL})
           keys.ability:ApplyDataDrivenModifier(keys.caster,target,"modifier_kimi_sawarabi_slow",{duration = slow_duration})

           local particle = ParticleManager:CreateParticle("particles/units/heroes/hidan/hidan_passive_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) 
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()) 


        end
    end


    local pid = ParticleManager:CreateParticle("particles/units/heroes/kimimaro/ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:SetParticleControlEnt(pid, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_origin", keys.caster:GetAbsOrigin(), false)
    ParticleManager:SetParticleControlEnt(pid, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_origin", keys.caster:GetAbsOrigin(), false)
    ParticleManager:SetParticleControlEnt(pid, 3, keys.caster, PATTACH_POINT_FOLLOW, "attach_origin", keys.caster:GetAbsOrigin(), false)
    ParticleManager:SetParticleControlEnt(pid, 10, keys.caster, PATTACH_POINT_FOLLOW, "attach_origin", keys.caster:GetAbsOrigin(), false)
    Timers:CreateTimer(1.5, function()
        ParticleManager:DestroyParticle(pid, true)
    end)  




end