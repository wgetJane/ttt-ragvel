hook.Add("PlayerTraceAttack", "ttt_ragvel_DoPlayerDeath", function(ply, dmginfo, _, trace)
	if not (
		IsValid(ply)
		and dmginfo:IsBulletDamage()
		and bit.band(trace.Contents, CONTENTS_HITBOX) > 0
	) then
		return
	end

	ply._ttt_ragvel_data = ply._ttt_ragvel_data or {}

	local data = ply._ttt_ragvel_data

	local curtime = CurTime()

	if data.time == curtime then
		return
	end

	data.time = curtime
	data.vel = ply:GetVelocity()
	data.force = dmginfo:GetDamageForce()
	data.pos = trace.HitPos
	data.physbone = trace.PhysicsBone
	data.hitgroup = trace.HitGroup
end)

hook.Add("DoPlayerDeath", "ttt_ragvel_DoPlayerDeath", function(ply, _, dmginfo)
	if IsValid(ply) and ply._ttt_ragvel_data then
		ply._ttt_ragvel_data.dmg = dmginfo:GetDamage()
	end
end)

hook.Add("TTTOnCorpseCreated", "ttt_ragvel_TTTOnCorpseCreated", function(rag, ply)
	if not (
		IsValid(ply)
		and IsValid(rag)
	) then
		return
	end

	local data = ply._ttt_ragvel_data

	if not data
		or data.time ~= CurTime()
	then
		return
	end

	local vel = data.vel
	local physbone = data.physbone

	local i = rag:GetPhysicsObjectCount()

	::loop::

	i = i - 1

	if i < 0 then
		return
	end

	local bone = rag:GetPhysicsObjectNum(i)

	if not IsValid(bone) then
		goto loop
	end

	bone:SetVelocity(vel)

	if i ~= physbone then
		goto loop
	end

	data.force:Normalize()

	data.force:Mul(
		(math.Clamp(bone:GetMass(), 2, 10) + 5) * 0.1 *
		math.Remap(
			math.Clamp(data.dmg or 0, 20, 70),
			20, 70,
			4000, 6000
		)
	)

	bone:ApplyForceOffset(data.force, data.pos)

	goto loop
end)

ENT.Type = "point"
