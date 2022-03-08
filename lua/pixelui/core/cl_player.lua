function PIXEL.GetRank(ply)
	return ply:GetUserGroup() or ply:GetSeccondaryUserGroup()
end