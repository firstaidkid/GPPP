
print("Initializing render component test...")

-- Physics World
do
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, -9.81)
	cinfo.worldSize = 2000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
end

PhysicsSystem:setDebugDrawingEnabled(true)

do -- set up state machine
	State{
		name = "default",
		parent = "/game/gameRunning"
	}

	StateTransitions{
		parent = "/game/gameRunning",
		{ from = "__enter", to = "default" },
	}
end

-- Camera
cameraObject = GameObjectManager:createGameObject("cameraObject")
cameraObject.cc = cameraObject:createCameraComponent()
cameraObject.cc:setState(ComponentState.Active)
cameraObject.cc:setPosition(Vec3(200.0, 30.0, 50.0))
cameraObject.cc:lookAt(Vec3(0.0, 0.0, 0.0))

distanceFromCamera = 300.0

-- PhysicsDebugView
PhysicsSystem:setDebugDrawingEnabled(true)

do
	theObject = GameObjectManager:createGameObject("theObject")

	-- render component
	theObject.rc = theObject:createRenderComponent()
	theObject.rc:setPath("data/models/barbarian/barbarian_axe.thModel")

	-- physics component
	theObject.pc = theObject:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	local box = PhysicsFactory:createBox(Vec3(5, 30, 50))
	cinfo.shape = PhysicsFactory:createConvexTranslateShape(box, Vec3(0, 50, -10))
	cinfo.motionType = MotionType.Fixed
	theObject.pc.rb = theObject.pc:createRigidBody(cinfo)

end

function update(elapsedTime)
	local speed = 1.0
	local rotationSpeed = 1.0
	local movement = Vec3()
	local mouseDelta = InputHandler:getMouseDelta()

	if InputHandler:isPressed(Key.Up)       then movement.z =  speed * elapsedTime end
	if InputHandler:isPressed(Key.Down)     then movement.z = -speed * elapsedTime end
	if InputHandler:isPressed(Key.Left)     then movement.x = -speed * elapsedTime end
	if InputHandler:isPressed(Key.Right)    then movement.x =  speed * elapsedTime end
	if InputHandler:isPressed(Key.Add)      then distanceFromCamera = distanceFromCamera - speed * elapsedTime end
	if InputHandler:isPressed(Key.Subtract) then distanceFromCamera = distanceFromCamera + speed * elapsedTime end
	distanceFromCamera = distanceFromCamera + speed * elapsedTime * -mouseDelta.z

	cameraObject.cc:move(movement)
	local pos = cameraObject.cc:getPosition()
	pos = pos:normalized()
	--logMessage("pos: " .. tostring(pos, "vec3"))
	pos = pos:mulScalar(distanceFromCamera)
	cameraObject.cc:setPosition(pos)
	cameraObject.cc:lookAt(Vec3(0.0, 0.0, 0.0))

	if mouseDelta.x then
		-- rotate theObject
		local rotation = theObject:getRotation()
		rotation = rotation * Quaternion(Vec3(1, 0, 0), mouseDelta.x * rotationSpeed)
		theObject:setRotation(rotation)
	end

	return EventResult.Handled
end

Events.Update:registerListener(update)

print("Finished render component test initialization.")
