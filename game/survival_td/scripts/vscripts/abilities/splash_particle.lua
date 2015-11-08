function ParticleOnAttackLanded(event)
	local caster = event.attacker
	local target = event.target
	local particleName = event.ParticleName

	local targetPosition = target:GetAbsOrigin()

	local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl( particle, 0, targetPosition)
	ParticleManager:SetParticleControl( particle, 1, targetPosition)
	ParticleManager:SetParticleControl( particle, 2, targetPosition)
end