logMessage("Initializing character_initialize.lua ...")

do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = 2000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
end

PhysicsSystem:setDebugDrawingEnabled(true)

do -- debugCam
	debugCam = GameObjectManager:createGameObject("debugCam")
	debugCam.cc = debugCam:createCameraComponent()
	debugCam.cc:setPosition(Vec3(-300.0, 0.0, 0.0))
	debugCam.cc:setViewDirection(Vec3(1.0, 0.0, 0.0))
	debugCam.baseViewDir = Vec3(1.0, 0.0, 0.0)
	debugCam.cc:setBaseViewDirection(debugCam.baseViewDir)
end

do
	--Create Little Home Planet
	guid = 1;

	ground = {}
	ground.go = GameObjectManager:createGameObject("homeplanet")
	ground.pc = ground.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.position = Vec3(0,0,0)
	cinfo.shape = PhysicsFactory:createSphere(100)
	cinfo.motionType = MotionType.Character
	cinfo.restitution = 0
	cinfo.friction = 1
	cinfo.gravityFactor = 0
	cinfo.mass = 900000
	cinfo.maxLinearVelocity = 1000
	cinfo.linearDamping = 1
	ground.rb = ground.pc:createRigidBody(cinfo)


end
-- create ID


-- Create Character
do
	character = {}
	character.go = GameObjectManager:createGameObject("character")
	character.pc = character.go:createPhysicsComponent()

	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createBox(Vec3(10, 10, 10))
	cinfo.motionType = MotionType.Dynamic
	cinfo.restitution = 0
	cinfo.friction = 0
	cinfo.position = Vec3(0,0,200)
	cinfo.gravityFactor = 10
	cinfo.mass = 90
	cinfo.maxLinearVelocity = 1000
	cinfo.linearDamping = 1
	character.rb = character.pc:createRigidBody(cinfo)
	character.sc = character.go:createScriptComponent()
	local renderComponent = character.go:createRenderComponent()
	renderComponent:setPath("data/models/mario/mario.thModel")

	-- collision event
	--character.pc:getContactPointEvent():registerListener(collisionCharacter)
	character.sc:setUpdateFunction(updateCharacter)
	character.grounded = false



end











function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end






function debugCamEnter(enterData)
	debugCam:setComponentStates(ComponentState.Active)
	return EventResult.Handled
end

function debugCamUpdate(updateData)

	local mouseDelta = InputHandler:getMouseDelta()
	local rotationSpeed = 0.2 * updateData:getElapsedTime()
	local lookVec = mouseDelta:mulScalar(rotationSpeed)
	debugCam.cc:look(lookVec)


	local moveVec = Vec3(0.0, 0.0, 0.0)
	local moveSpeed = 0.5 * updateData:getElapsedTime()
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
		update = { 
			--debugCamUpdate 
		},
		enter = { debugCamEnter 
			}
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "debugCam" },
}

logMessage("... finished initializing defaults.lua.")
