require('timers')

function naruto_fox(keys)
	local caster = keys.caster
	
	caster:SetModel("models/kyuubi_new/kyuubi.vmdl")
	caster:SetOriginalModel("models/kyuubi_new/kyuubi.vmdl")
end

function naruto_fox_end(keys)
	local caster = keys.caster
	
	if caster:GetUnitName() == "npc_dota_hero_beastmaster" then
	caster:SetModel("models/kakashi/kaka.vmdl")
	caster:SetOriginalModel("models/kakashi/kaka.vmdl")
	caster:SetModelScale(0.82)
	else
	caster:SetModel("models/naruto_new/naruto.vmdl")
	caster:SetOriginalModel("models/naruto_new/naruto.vmdl")
	end
end