logMessage("Initializing camera tests ...")

--
-- physics world
--
local cinfo = WorldCInfo()
cinfo.gravity = Vec3(0, 0, 0)
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

function createCollisionSphere(guid, radius, position)
	local sphere = GameObjectManager:createGameObject(guid)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = position
	sphere.pc.rb = sphere.pc:createRigidBody(cinfo)
	sphere.pc = sphere:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(radius)
return sphere
end

-- #gppp generate next guid
guid = 1
function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

-- #gppp Planet Factory
function createPlanet(position, size)
	-- checking if size is valid, setting to default if not
	if(size ~= 50 and size ~= 100 and size ~= 150 and size ~= 200 and size ~= 150) then
		size = 50
	end	

	local planet = {}
	planet.go = GameObjectManager:createGameObject(nextGUID())
	planet.pc = planet.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(size)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = position
	planet.pc.rb = planet.pc:createRigidBody(cinfo)
	planet.rc = planet.go:createRenderComponent()
	planet.rc:setPath("data/models/space/nibiru_" .. size .. ".thModel")
	planet.size = size

	return planet
end	

--
-- space
--
space = {}
space.go = GameObjectManager:createGameObject("space")
space.pc = space.go:createPhysicsComponent()
local cinfo = RigidBodyCInfo()
cinfo.shape = PhysicsFactory:createSphere(2048)
cinfo.motionType = MotionType.Fixed
cinfo.position = Vec3(0.0, 0.0, 0.0)
space.pc.rb = space.pc:createRigidBody(cinfo)

--planets
-- #gppp
planets = {}
planets.nibiru = createPlanet(Vec3(0,0,0), 200)


function createDefaultCam(guid)
	local cam = GameObjectManager:createGameObject(guid)
	cam.cc = cam:createCameraComponent()
	cam.cc:setPosition(Vec3(0.0, 0.0, 0.0))
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
	if (InputHandler:isPressed(Key.P)) then
		sleep(2)
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
	
	local pos = debugCam.cc:getPosition()
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
	-- #gppp setting camera position to 150 units above planet-player-vector
	local camPos = player:getPosition() - player.vecToHome:mulScalar(150)
	normalCam.firstPerson.cc:setPosition(camPos)

	-- #gppp setting camera lookat to planet center
	local vecToPlanet = (player.homePlanet.go:getPosition() - normalCam.firstPerson:getPosition()):normalized()
	normalCam.firstPerson.cc:lookAt(camPos + vecToPlanet:mulScalar(1000.0) + player:getViewDirection():mulScalar(300.0) + Vec3(0.0, 0.0, player.viewUpDown))
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
normalCam.thirdPerson.calcPosTo = function() -- #gppp
	return player:getPosition() + player.vecToHome:mulScalar(-(100 + player.homePlanet.size)) + Vec3(0.0, 0.0, 50)
end

function normalCamThirdPersonEnter(enterData)
	normalCam.thirdPerson:setPosition(normalCam.thirdPerson.calcPosTo())
	normalCam.thirdPerson:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function normalCamThirdPersonUpdate(updateData)
	DebugRenderer:printText(Vec2(-0.9, 0.85), "thirdPerson")
	local camPosTo = normalCam.thirdPerson.calcPosTo()
	local camPosIs = normalCam.thirdPerson:getPosition()
	local camPosVel = camPosTo - camPosIs
	if (camPosVel:length() > 1.0 ) then
		normalCam.thirdPerson.pc.rb:setLinearVelocity(camPosVel:mulScalar(2.5))
	end
	normalCam.thirdPerson.cc:lookAt(player:getPosition() + Vec3(0.0, 0.0, 30.0))
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
	},
	transitions = {
		{ from = "__enter", to = "firstPerson" },
		{ from = "firstPerson", to = "thirdPerson", condition = function() return InputHandler:wasTriggered(Key.V) end },
		{ from = "thirdPerson", to = "firstPerson", condition = function() return InputHandler:wasTriggered(Key.V) end },
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "debugCam" },
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
function playerUpdate(guid, elapsedTime)
	local position = player:getPosition()
	local viewDir = player:getViewDirection()
	local moveSpeed = 1200.0
	if (InputHandler:isPressed(Key.Shift)) then
		moveSpeed = moveSpeed * 2.5
	end
	if (InputHandler:isPressed(Key.W)) then
		player.pc.rb:applyLinearImpulse(viewDir:mulScalar(moveSpeed))
	elseif (InputHandler:isPressed(Key.S)) then
		player.pc.rb:applyLinearImpulse(viewDir:mulScalar(-0.5 * moveSpeed))
	end
		if (InputHandler:isPressed(Key.P)) then
		sleep(2)
	end
	if (player.firstPersonMode) then
		DebugRenderer:printText(Vec2(-0.01, 0.05), "X")
		local rightDir = viewDir:cross(Vec3(0.0, 0.0, 1.0))
		if (InputHandler:isPressed(Key.A) and InputHandler:isPressed(Key.D)) then
			-- no sideways walking
		elseif (InputHandler:isPressed(Key.A)) then
			player.pc.rb:applyLinearImpulse(rightDir:mulScalar(-moveSpeed))
		elseif (InputHandler:isPressed(Key.D)) then
			player.pc.rb:applyLinearImpulse(rightDir:mulScalar(moveSpeed))
		end
		local mouseDelta = InputHandler:getMouseDelta()
		local angularVelocity = Vec3(0.0, 0.0, mouseDelta.x * -0.05 * elapsedTime)
		player.pc.rb:setAngularVelocity(angularVelocity)
		player.viewUpDown = player.viewUpDown + mouseDelta.y * -0.05 * elapsedTime
		local viewUpDownMax = 100
		if (player.viewUpDown > viewUpDownMax) then
			player.viewUpDown = viewUpDownMax
		end
		if (player.viewUpDown < -viewUpDownMax) then
			player.viewUpDown = -viewUpDownMax
		end
	else
		if (InputHandler:isPressed(Key.A) and InputHandler:isPressed(Key.D)) then
			if (not player.angularVelocitySwapped) then
				player.currentAngularVelocity = player.currentAngularVelocity:mulScalar(-1.0)
				player.angularVelocitySwapped = true
			end
			player.pc.rb:setAngularVelocity(player.currentAngularVelocity)
		elseif (InputHandler:isPressed(Key.A)) then
			player.currentAngularVelocity = Vec3(0.0, 0.0, 2.5)
			player.angularVelocitySwapped = false
			player.pc.rb:setAngularVelocity(player.currentAngularVelocity)
		elseif (InputHandler:isPressed(Key.D)) then
			player.currentAngularVelocity = Vec3(0.0, 0.0, -2.5)
			player.angularVelocitySwapped = false
			player.pc.rb:setAngularVelocity(player.currentAngularVelocity)
		else
			player.angularVelocitySwapped = false
		end
	end
	-- #gppp calculating a vector that looks from the player to his current home
	local vecToHome = (player.homePlanet.go:getPosition() - position)
	local distance = vecToHome:length()
	player.vecToHome = vecToHome:normalized()

	logMessage("PrevD=" .. player.previousDistance .. "threshold=" .. player.homePlanet.size)
	-- #gppp preventing player from getting into the planet...
	if(player.previousDistance < player.homePlanet.size) then
		player.pc.rb:applyLinearImpulse(player.vecToHome:mulScalar(500))
	else
		-- #gppp apply impulse to player, so that he stays on the planet
		player.pc.rb:applyLinearImpulse(player.vecToHome:mulScalar(1500))
	end	

	local pos = player:getPosition()
	local currentViewDir = player:getViewDirection()
	local targetViewDir = (player.homePlanet.go:getPosition() - position)

	local a = currentViewDir:cross(targetViewDir):normalized()
	local w = math.sqrt((currentViewDir:squaredLength())) * (targetViewDir:squaredLength()) + currentViewDir:dot(targetViewDir)
 	-- ??
	--player:setRotation(Quaternion(a, math.deg(w)/100))

	-- #gppp saving distance
	player.previousDistance = distance
end


-- sleep #gppp
function sleep(n)
  if n > 0 then os.execute("ping -n " .. tonumber(n+1) .. " localhost > NUL") end
end

player = GameObjectManager:createGameObject("player")
player.pc = player:createPhysicsComponent()
local cinfo = RigidBodyCInfo()
cinfo.shape = PhysicsFactory:createSphere(5.0)
cinfo.motionType = MotionType.Dynamic
cinfo.mass = 100.0
cinfo.restitution = 1
cinfo.friction = 20.0
cinfo.maxLinearVelocity = 5000.0
cinfo.maxAngularVelocity = 250.0
cinfo.linearDamping = 1.0
cinfo.angularDamping = 10.0
cinfo.position = Vec3(130, 130, 130) -- #gppp max planet + buffer
player.pc.rb = player.pc:createRigidBody(cinfo)
player.sc = player:createScriptComponent()
player.sc:setUpdateFunction(playerUpdate)
player:setBaseViewDirection(Vec3(1.0, 0.0, 0.0))
-- additional members
player.firstPersonMode = false
player.currentAngularVelocity = Vec3()
player.angularVelocitySwapped = false
player.viewUpDown = 0.0

-- #gppp variables for camera
player.vecToHome = Vec3(1.0, 1.0, 1.0)
player.homePlanet = planets.nibiru
player.previousDistance = 255

logMessage("... finished initializing camera tests")
