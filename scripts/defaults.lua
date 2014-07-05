logMessage("Initializing defaults.lua ...")

do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = 2000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
end

do -- debugCam
	debugCam = GameObjectManager:createGameObject("debugCam")
	debugCam.cc = debugCam:createCameraComponent()
	debugCam.cc:setPosition(Vec3(0.0, 0.0, 0.0))
	debugCam.cc:setViewDirection(Vec3(1.0, 0.0, 0.0))
	debugCam.baseViewDir = Vec3(1.0, 0.0, 0.0)
	debugCam.cc:setBaseViewDirection(debugCam.baseViewDir)
end

function debugCamEnter(enterData)
	debugCam:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function debugCamUpdate(updateData)
	local deltaSeconds = updateData:getElapsedTime()
	local mouseDelta = InputHandler:getMouseDelta()
	local rotationSpeed = 200 * deltaSeconds
	local lookVec = mouseDelta:mulScalar(rotationSpeed)
	debugCam.cc:look(lookVec)

	local moveVec = Vec3(0.0, 0.0, 0.0)
	local moveSpeed = 500 * deltaSeconds
	if (InputHandler:isPressed(Key.Shift)) then
		moveSpeed = moveSpeed * 5
	end
	if (InputHandler:isPressed(Key.W)) then
		moveVec.y = moveSpeed
	elseif (InputHandler:isPressed(Key.S)) then
		moveVec.y = -moveSpeed
	end
	if (InputHandler:isPressed(Key.A)) then
		moveVec.x = -moveSpeed
	elseif (InputHandler:isPressed(Key.D)) then
		moveVec.x = moveSpeed
	end
	debugCam.cc:move(moveVec)

	return EventResult.Handled
end

State{
	name = "debugCam",
	parent = "/game/gameRunning",
	eventListeners = {
		update = { debugCamUpdate },
		enter = { debugCamEnter }
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "debugCam" },
}

logMessage("... finished initializing defaults.lua.")
