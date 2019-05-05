bvo_ichigo_skill_5_sonido = class ({})

function bvo_ichigo_skill_5_sonido:CastFilterResultLocation( vLocation )
	if IsServer() then
		local caster = self:GetCaster()
		local range = self:GetSpecialValueFor("blink_range")
		local casterPos = caster:GetAbsOrigin()
		local point = vLocation
		local difference = point - casterPos

		if difference:Length2D() > range then
			point = casterPos + (point - casterPos):Normalized() * range
		end

		if not GridNav:CanFindPath(casterPos, point) then
			return UF_FAIL_CUSTOM
		end

		return UF_SUCCESS
	end
end

function bvo_ichigo_skill_5_sonido:GetCustomCastErrorLocation( vLocation )
	return "#dota_hud_error_teleport_outofbounds"
end

function bvo_ichigo_skill_5_sonido:GetCastAnimation()
	return ACT_DOTA_ATTACK
end

function bvo_ichigo_skill_5_sonido:OnSpellStart()
	local caster = self:GetCaster()
	local range = self:GetSpecialValueFor("blink_range")
	local casterPos = caster:GetAbsOrigin()
	local point = self:GetCursorPosition()
	local difference = point - casterPos
	
	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	caster:EmitSound("Hero_Antimage.Blink_out")
	ParticleManager:CreateParticle("particles/custom/misc/general_blink_start.vpcf", PATTACH_POINT, caster)

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	caster:EmitSound("Hero_Antimage.Blink_in")
	ParticleManager:CreateParticle("particles/custom/misc/general_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
end