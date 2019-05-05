function GameMode:RescaleUnit( unit )
	if     unit:GetName() == "npc_dota_roshan" then 
		GameMode:kyuubi(unit)
    elseif  unit:GetName() == "npc_dota_courier" then 
    	GameMode:rescaleCourier(unit)
    elseif  unit:GetModelName() == "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl" then 
    	unit:SetModelScale(2.2)
    elseif  unit:GetModelName() == "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl" then 
        unit:SetModelScale(0.8)
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_worg_small/n_creep_worg_small.vmdl" then 
        unit:SetModelScale(3.0)
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl" then 
        unit:SetModelScale(5.0)    
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_vulture_a/n_creep_vulture_a.vmdl" then 
        unit:SetModelScale(0.85)
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_vulture_b/n_creep_vulture_b.vmdl" then 
        unit:SetModelScale(0.6)    
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl" then 
        unit:SetModelScale(0.5)    
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl" then 
        unit:SetModelScale(0.5)  
    elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_thunder_lizard/n_creep_thunder_lizard_small.vmdl" then 
        unit:SetModelScale(0.3)       
     elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_thunder_lizard/n_creep_thunder_lizard_big.vmdl" then 
        unit:SetModelScale(0.4) 
     elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl" then 
        unit:SetModelScale(0.6) 
     elseif  unit:GetModelName() == "models/creeps/neutral_creeps/n_creep_centaur_med/n_creep_centaur_med.vmdl" then 
        unit:SetModelScale(0.6)                  
    else                 
    	
    end
end

function GameMode:kyuubi( unit )
	unit:SetModelScale(0.7)
end


function GameMode:rescaleCourier( unit )
	if unit:GetModelName() == "models/props_gameplay/donkey.vmdl" then
		unit:SetModelScale(0.6)
	end
	if unit:GetModelName() == "models/props_gameplay/donkey_dire.vmdl" then
		unit:SetModelScale(0.6)
	end
end

function GameMode:ChangeDuelBuildings( keys )
     --alliance towers
    local allianceTower = Entities:FindByModel(nil, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local akatTower = Entities:FindByModel(nil, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
end

function GameMode:ChangeBuildings( keys)
    local hokageBuilding = Entities:FindByModel(nil, "models/props_structures/radiant_ancient001.vmdl")
    hokageBuilding:SetModelScale(0.55)
    local akatBase = Entities:FindByModel(nil, "models/props_structures/dire_ancient_base001.vmdl")
    akatBase:SetModelScale(0.55) 

    --alliance towers
    local allianceTower = Entities:FindByModel(nil, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)
    local allianceTower = Entities:FindByModel(allianceTower, "models/props_structures/radiant_tower002.vmdl")
    allianceTower:SetModelScale(3.5)

     --akatsuki towers
    local akatTower = Entities:FindByModel(nil, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)
    local akatTower = Entities:FindByModel(akatTower, "models/props_structures/dire_tower002.vmdl")
    akatTower:SetModelScale(6.0)

    --alliance melee rax
    local melee_raxs = Entities:FindByModel(nil, "models/props_structures/radiant_melee_barracks001.vmdl")
    melee_raxs:SetModelScale(1.4)
    local melee_raxs = Entities:FindByModel(melee_raxs, "models/props_structures/radiant_melee_barracks001.vmdl")
    melee_raxs:SetModelScale(1.4)
    local melee_raxs = Entities:FindByModel(melee_raxs, "models/props_structures/radiant_melee_barracks001.vmdl")
    melee_raxs:SetModelScale(1.4)

    --akat ranged rax
    local akat_melee_raxs = Entities:FindByModel(nil, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(1.4)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(1.4)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(1.4)

    --akat melee rax
    local akat_melee_raxs = Entities:FindByModel(nil, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(0.75)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(0.75)
    local akat_melee_raxs = Entities:FindByModel(akat_melee_raxs, "models/props_structures/dire_barracks_ranged001.vmdl")
    akat_melee_raxs:SetModelScale(0.75)

    --alliance ranged rax
    local range_raxs = Entities:FindByModel(nil, "models/props_structures/radiant_ranged_barracks001.vmdl")
    range_raxs:SetModelScale(0.8)
    local range_raxs = Entities:FindByModel(range_raxs, "models/props_structures/radiant_ranged_barracks001.vmdl")
    range_raxs:SetModelScale(0.8)
    local range_raxs = Entities:FindByModel(range_raxs, "models/props_structures/radiant_ranged_barracks001.vmdl")
    range_raxs:SetModelScale(0.8)


    --alliance statue 2 ramenshop
    local ramenshop = Entities:FindByModel(nil, "models/props_structures/radiant_statue002.vmdl")
    ramenshop:SetModelScale(1.5)
    local ramenshop = Entities:FindByModel(ramenshop, "models/props_structures/radiant_statue002.vmdl")
    ramenshop:SetModelScale(1.5)
     local ramenshop = Entities:FindByModel(ramenshop, "models/props_structures/radiant_statue002.vmdl")
    ramenshop:SetModelScale(1.5)


    --konoha secret shop
    local kono_sec_shop = Entities:FindByModel(nil, "models/props_gameplay/quirt/quirt.vmdl")
    kono_sec_shop:SetModelScale(3.0)

    --akat secret shop
    local akat_sec_shop = Entities:FindByModel(nil, "models/props_gameplay/sithil/sithil.vmdl")
    akat_sec_shop:SetModelScale(3.0)




end