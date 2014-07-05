logMessage("Initializing samples/character_component.lua ...")

--
-- physics world
--
local cinfo = WorldCInfo()
cinfo.gravity = Vec3(0, 0, -9.81)
cinfo.worldSize = 4000.0
local world = PhysicsFactory:createWorld(cinfo)
PhysicsSystem:setWorld(world)
PhysicsSystem:setDebugDrawingEnabled(true)

function createCollisionBox(guid, halfExtends, position)
	local box = GameObjectManager:createGameObject(guid)
	box.pc = box:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createBox(halfExtends)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = position
	box.pc.rb = box.pc:createRigidBody(cinfo)
	return box
end

--
-- scene
--
scene = {}
scene.sponza = GameObjectManager:createGameObject("sponza")
--scene.sponza.rc = scene.sponza:createRenderComponent()
--scene.sponza.rc:setPath("data/sponza/sponza.thModel")
scene.ground = createCollisionBox("ground", Vec3(1750.0, 1000.0, 10.0), Vec3(0.0, 0.0, -10.0))
scene.ground = createCollisionBox("wallRight", Vec3(1000.0, 40.0, 200.0), Vec3(-60.0, 280.0, 200.0))

function createDefaultCam(guid)
	local cam = GameObjectManager:createGameObject(guid)
	cam.cc = cam:createCameraComponent()
	cam:setPosition(Vec3(0.0, 0.0, 0.0))
	cam.cc:setViewDirection(Vec3(1.0, 0.0, 0.0))
	cam.baseViewDir = Vec3(1.0, 0.0, 0.0)
	cam.cc:setBaseViewDirection(cam.baseViewDir)
	return cam
end

--
-- debugCam
--
debugCam = createDefaultCam("debugCam")

function debugCamEnter(enterData)
	debugCam:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function debugCamUpdate(updateData)
	DebugRenderer:printText(Vec2(-0.9, 0.85), "debugCamUpdate")

	local mouseDelta = InputHandler:getMouseDelta()
	local rotationSpeed = 0.2 * updateData:getElapsedTime()
	local lookVec = mouseDelta:mulScalar(rotationSpeed)
	debugCam.cc:look(lookVec)
	
	local moveVec = Vec3(0.0, 0.0, 0.0)
	local moveSpeed = 0.5 * updateData:getElapsedTime()
	if (InputHandler:isPressed(Key.Shift)) then
		moveSpeed = moveSpeed * 5
	end
	if (InputHandler:isPressed(Key.Up)) then
		moveVec.y = moveSpeed
	elseif (InputHandler:isPressed(Key.Down)) then
		moveVec.y = -moveSpeed
	end
	if (InputHandler:isPressed(Key.Left)) then
		moveVec.x = -moveSpeed
	elseif (InputHandler:isPressed(Key.Right)) then
		moveVec.x = moveSpeed
	end
	debugCam.cc:move(moveVec)
	
	local pos = debugCam.cc:getWorldPosition()
	DebugRenderer:printText(Vec2(-0.9, 0.80), "  pos: " .. string.format("%5.2f", pos.x) .. ", " .. string.format("%5.2f", pos.y) .. ", " .. string.format("%5.2f", pos.z))
	local dir = debugCam:getViewDirection()
	DebugRenderer:printText(Vec2(-0.9, 0.75), "  dir: " .. string.format("%5.2f", dir.x) .. ", " .. string.format("%5.2f", dir.y) .. ", " .. string.format("%5.2f", dir.z))
	
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

--
-- normalCam
--
normalCam = {}

normalCam.firstPerson = createDefaultCam("firstPerson")

function normalCamFirstPersonEnter(enterData)
	normalCam.firstPerson:setComponentStates(ComponentState.Active)
	player.firstPersonMode = true
	return EventResult.Handled
end

function normalCamFirstPersonUpdate(updateData)
	DebugRenderer:printText(Vec2(-0.9, 0.85), "firstPerson")
	local camPos = player:getWorldPosition() + Vec3(0.0, 0.0, 10.0)
	normalCam.firstPerson:setPosition(camPos)
	normalCam.firstPerson.cc:lookAt(camPos + player:getViewDirection():mulScalar(100.0) + Vec3(0.0, 0.0, player.viewUpDown))
	return EventResult.Handled
end

function normalCamFirstPersonLeave(leaveData)
	player.firstPersonMode = false
	return EventResult.Handled
end

normalCam.thirdPerson = createDefaultCam("thirdPerson")
normalCam.thirdPerson.pc = normalCam.thirdPerson:createPhysicsComponent()
local cinfo = RigidBodyCInfo()
cinfo.shape = PhysicsFactory:createSphere(2.5)
cinfo.motionType = MotionType.Dynamic
cinfo.mass = 50.0
cinfo.restitution = 0.0
cinfo.friction = 0.0
cinfo.maxLinearVelocity = 3000
cinfo.linearDamping = 5.0
cinfo.gravityFactor = 0.0
normalCam.thirdPerson.pc.rb = normalCam.thirdPerson.pc:createRigidBody(cinfo)
normalCam.thirdPerson.pc:setState(ComponentState.Inactive)
normalCam.thirdPerson.calcPosTo = function()
	return player:getWorldPosition() + player:getViewDirection():mulScalar(-150.0) + Vec3(0.0, 0.0, 50.0)
end

function normalCamThirdPersonEnter(enterData)
	normalCam.thirdPerson:setPosition(normalCam.thirdPerson.calcPosTo())
	normalCam.thirdPerson:setComponentStates(ComponentState.Active)
	normalCam.thirdPerson.cc:setViewTarget(player)
	normalCam.thirdPerson.cc:setViewTargetPositionOffset(Vec3(0,0,30.0))
	return EventResult.Handled
end

function normalCamThirdPersonUpdate(updateData)
	DebugRenderer:printText(Vec2(-0.9, 0.85), "thirdPerson")
	local camPosTo = normalCam.thirdPerson.calcPosTo()
	local camPosIs = normalCam.thirdPerson:getWorldPosition()
	local camPosVel = camPosTo - camPosIs
	if (camPosVel:length() > 1.0 ) then
		normalCam.thirdPerson.pc.rb:setLinearVelocity(camPosVel:mulScalar(2.5))
	end
	--normalCam.thirdPerson.cc:lookAt(player:getWorldPosition() + Vec3(0.0, 0.0, 30.0))
	return EventResult.Handled
end

normalCam.isometric = createDefaultCam("isometric")
normalCam.isometric.cc:look(Vec2(0.0, 20.0))

function normalCamIsometricEnter(enterData)
	normalCam.isometric:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function normalCamIsometricUpdate(updateData)
	DebugRenderer:printText(Vec2(-0.9, 0.85), "isometric")
	local rotationSpeed = 0.05 * updateData:getElapsedTime()
	local mouseDelta = InputHandler:getMouseDelta()
	mouseDelta.x = mouseDelta.x * rotationSpeed
	mouseDelta.y = 0.0
	normalCam.isometric.cc:look(mouseDelta)
	local viewDir = normalCam.isometric.cc:getViewDirection()
	viewDir = viewDir:mulScalar(-250.0)
	viewDir.z = 125.0
	normalCam.isometric:setPosition(player:getWorldPosition() + viewDir)
	return EventResult.Handled
end

StateMachine{
	name = "normalCam(fsm)",
	parent = "/game/gameRunning",
	states = {
		{
			name = "firstPerson",
			eventListeners = {
				update = { normalCamFirstPersonUpdate },
				enter = { normalCamFirstPersonEnter },
				leave = { normalCamFirstPersonLeave }
			},
		},
		{
			name = "thirdPerson",
			eventListeners = {
				update = { normalCamThirdPersonUpdate },
				enter = { normalCamThirdPersonEnter }
			},
		},
		{
			name = "isometric",
			eventListeners = {
				update = { normalCamIsometricUpdate },
				enter = { normalCamIsometricEnter }
			},
		},
	},
	transitions = {
		{ from = "__enter", to = "isometric" },
		{ from = "firstPerson", to = "thirdPerson", condition = function() return InputHandler:wasTriggered(Key.V) end },
		{ from = "thirdPerson", to = "isometric", condition = function() return InputHandler:wasTriggered(Key.V) end },
		{ from = "isometric", to = "firstPerson", condition = function() return InputHandler:wasTriggered(Key.V) end }
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "normalCam(fsm)" },
	{ from = "debugCam", to = "normalCam(fsm)", condition = function() return InputHandler:wasTriggered(Key.C) end },
	{ from = "normalCam(fsm)", to = "debugCam", condition = function() return InputHandler:wasTriggered(Key.C) end }
}

StateTransitions{
	parent = "/game",
	{ from = "gameRunning", to = "__leave", condition = function() return InputHandler:wasTriggered(Key.Q) end }
}

--
-- player
--

function playerCharacterUdpate(characterInput)
	local eventResult = EventResult.Ignored
	for k,v in pairs(characterInput) do
		--print(k,v)
	end

	if InputHandler:isPressed(Key.W) then
		eventResult = EventResult.Handled
		characterInput:setInputUD(-1)
	elseif InputHandler:isPressed(Key.S) then
		eventResult = EventResult.Handled
		characterInput:setInputUD(1)
	end

	if InputHandler:isPressed(Key.Space) then
		characterInput:setWantJump(true)
	end

	return eventResult
end

player = GameObjectManager:createGameObject("player")
player.char = player:createCharacterComponent()
local cinfo = CharacterRigidBodyCInfo()
cinfo.shape = PhysicsFactory:createBox(Vec3(10.0, 10.0, 20.0))
cinfo.position = Vec3(0.0, 0.0, 20.5)
player.char.crb = player.char:createCharacterRigidBody(cinfo)
player.char.rb = player.char.crb:getRigidBody()
player.char:getInputUpdateEvent():registerListener(playerCharacterUdpate)
player:setBaseViewDirection(Vec3(1.0, 0.0, 0.0))
-- additional members
player.firstPersonMode = false
player.currentAngularVelocity = Vec3()
player.angularVelocitySwapped = false
player.viewUpDown = 0.0

logMessage("... finished initializing samples/character_component.lua.")
