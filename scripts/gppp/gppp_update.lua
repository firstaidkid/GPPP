print("running updates")

function cameraUpdate(elapsedTime)

	local mouseDelta = InputHandler:getMouseDelta()

	-- rotation
	local invDir = debugCam.cc:getViewDirection():mulScalar(-1.0) -- vektor from target to cam-position (inverse of view-direction)
	local rotQuat = Quaternion(Vec3(0.0, 0.0, 1.0), mouseDelta.x * debugCam.rotSpeed * elapsedTime)	-- rotations-quaternion, w/ rotating z-axis
	local rotMat = rotQuat:toMat3() -- 3x3 rot-matrix from quaternion
	local rotInvDir = rotMat:mulVec3(invDir) -- richtungsvektor mit rot-matrix multiplizieren, also vektor rotieren

	-- zoom
	debugCam.zoom = debugCam.zoom + mouseDelta.y * debugCam.zoomSpeed * elapsedTime  -- zoom abhängig von der mouse y-position 
	if (debugCam.zoom > debugCam.maxZoom ) then debugCam.zoom = debugCam.maxZoom end  -- bounds
	if (debugCam.zoom < debugCam.minZoom ) then debugCam.zoom = debugCam.minZoom end
	
	-- set new values
	debugCam.eye = debugCam.aim + rotInvDir:mulScalar(debugCam.zoom)
	debugCam.cc:setPosition(debugCam.eye)
	debugCam.cc:lookAt(debugCam.aim)
end


function defaultUpdate(updateData)
	local elapsedTime = updateData:getElapsedTime() / 1000.0

	updateLevelCreation(elapsedTime)
	cameraUpdate(elapsedTime)

	return EventResult.Handled
end

State{
	name = "default",
	parent = "/game/gameRunning",
	eventListeners = {
		enter = { defaultEnter },
		update = { defaultUpdate }
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "default" }
}

StateTransitions{
	parent = "/game",
	{ from = "gameRunning", to = "__leave", condition = function() return bit32.btest(InputHandler:gamepad(0):buttonsPressed(), bit32.bor(Button.Start, Button.Back)) end }
}