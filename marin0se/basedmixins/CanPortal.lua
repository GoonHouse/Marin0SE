CanPortal = {
	-- whether or not we override the default portal method with a local one
	portaloverride = true,
	-- this has to do with being carried and portalability, I don't know, it's confusing
	portaledframe = false
}

function CanPortal:portaled()
	-- this is only triggered if we have portaloverride
	self.portaledframe = true
end