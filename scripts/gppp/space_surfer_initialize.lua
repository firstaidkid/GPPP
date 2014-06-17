print("initializing gameworld")
do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = 2000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)

	--PhysicsDebugView
	PhysicsSystem:setDebugDrawingEnabled(true)

end

do -- debugCam
	debugCam = GameObjectManager:createGameObject("debugCam")
	debugCam.cc = debugCam:createCameraComponent()
	-- debugCam.eye = Vec3(100.0, -100.0, 100.0)  -- camera position
	debugCam.eye = Vec3(300, 0, 20)  -- camera position
	debugCam.aim = Vec3(0.0, 0.0, 0.0) -- camera target
	debugCam.rotSpeed = 20.0
	debugCam.zoomSpeed = 50.0
	debugCam.maxZoom = 1000.0
	debugCam.minZoom = 10.0
	debugCam.zoom = (debugCam.aim - debugCam.eye):length() -- initialer zoom, die länge des vektors: target-position
	debugCam.cc:setPosition(debugCam.eye)
	debugCam.cc:lookAt(debugCam.aim)
end

homeWorldSize = 50
do -- homeWorld
	homeWorld = {}
	homeWorld.go = GameObjectManager:createGameObject("homeWorld")
	homeWorld.pc = homeWorld.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(homeWorldSize)
	cinfo.motionType = MotionType.Keyframed
	cinfo.position = Vec3(0, 0, 0)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 10
	homeWorld.rb = homeWorld.pc:createRigidBody(cinfo)
	homeWorld.sc = homeWorld.go:createScriptComponent()
--	homeWorld.sc:setUpdateFunction(updateHomePlanet)
	homeWorld.go:setComponentStates(ComponentState.Active)
end
	
do	-- Character
	character = {}
	character.go = GameObjectManager:createGameObject("character")
	character.pc = character.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createBox(Vec3(5,5,5))
	cinfo.motionType = MotionType.Character
	cinfo.position = Vec3(0, 0, 70)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 10
	cinfo.maxLinearVelocity = 150
	character.rb = character.pc:createRigidBody(cinfo)
	character.sc = character.go:createScriptComponent()
	local renderComponent = character.go:createRenderComponent()
	renderComponent:setPath("data/models/mario/mario.thModel")
	--character.sc:setUpdateFunction(updateEnemy)
	character.go:setComponentStates(ComponentState.Active)
end

planetSize = 100
do	-- Planet
	planet = {}
	planet.go = GameObjectManager:createGameObject("planet")
	planet.pc = planet.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(planetSize)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = Vec3(-40, 200, 40)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 10
	planet.rb = planet.pc:createRigidBody(cinfo)
	planet.sc = planet.go:createScriptComponent()
	planet.go:setComponentStates(ComponentState.Active)
end

planetTwoSize = 100
do	-- planetTwo
	planetTwo = {}
	planetTwo.go = GameObjectManager:createGameObject("planetTwo")
	planetTwo.pc = planetTwo.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(planetSize)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = Vec3(-40, -200, 40)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 10
	planetTwo.rb = planetTwo.pc:createRigidBody(cinfo)
	planetTwo.sc = planetTwo.go:createScriptComponent()
	planetTwo.go:setComponentStates(ComponentState.Active)
end

function defaultEnter(enterData)
	return EventResult.Handled
end

function collisionCharacter( event )
	-- body
	DebugRenderer:printText(Vec2(-0.9, 0.7), "collisionCharacter ")

	if(character.rb.__ptr == event:getBody(event:getSource()).__ptr) then
		DebugRenderer:printText(Vec2(-0.9, 0.11), "jump ")
		character.grounded = true
	elseif(ground.rb.__ptr == event:getBody(event:getSource()).__ptr) then
		DebugRenderer:printText(Vec2(-0.9, 0.11), "enemy ")
		character.grounded = true
	end
end