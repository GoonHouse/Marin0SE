CanFunnel = {
	-- can the object be funneled?
	can_funnel = false,
	-- true when this is being handled by a funnel
	funnel = false,
	-- this is an edge-switch against funnel so that we can detect entry/exit
	infunnel = false,
}

function CanFunnel:funnelcallback(entering)
	-- if we go into a funnel, this is what we do
	if entering then
		self.infunnel = true
	else
		self.infunnel = false
		self.gravity = nil
	end
end