print("initializing gameworld")
do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = 200000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
end

PhysicsSystem:setDebugDrawingEnabled(true)

-- do -- debugCam
	-- debugCam = GameObjectManager:createGameObject("debugCam")
	-- debugCam.cc = debugCam:createCameraComponent()
	-- debugCam.cc:setPosition(Vec3(-600.0, 0.0, 0.0))
	-- debugCam.cc:setViewDirection(Vec3(1.0, 0.0, 0.0))
	-- debugCam.baseViewDir = Vec3(1.0, 0.0, 0.0)
	-- debugCam.cc:setBaseViewDirection(debugCam.baseViewDir)
-- end

planetAmount = 2
nearestPlanet = 1
planetArr = {}
homeWorldSize = 200
do -- homeWorld
	homeWorld = {}
	homeWorld.go = GameObjectManager:createGameObject("homeWorld")
	homeWorld.pc = homeWorld.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.position = Vec3(0,0,0)
	cinfo.shape = PhysicsFactory:createSphere(200)
	cinfo.motionType = MotionType.Keyframed
	cinfo.restitution = 0
	cinfo.friction = 0
	cinfo.gravityFactor = 0
	cinfo.mass = 900000
	cinfo.maxLinearVelocity =400


	homeWorld.rb = homeWorld.pc:createRigidBody(cinfo)
	homeWorld.sc = homeWorld.go:createScriptComponent()
--	homeWorld.sc:setUpdateFunction(updateHomePlanet)
	local renderComponent = homeWorld.go:createRenderComponent()
	--renderComponent:setPath("data/models/proto_home.thModel")
	renderComponent:setPath("data/models/home_planet/home_planet_bones.thModel")
	
	-- #Animations
	-- homeWorld.ac = homeWorld.go:createAnimationComponent()
	-- homeWorld.ac:setSkeletonFile("data/models/home_planet/hp_animated_bone.hkt")
	-- homeWorld.ac:setSkinFile("data/models/home_planet/hp_animated_bone.hkt")
	
	-- set Idles
	-- homeWorld.idles = { "Idle", "IdleFidget", "IdleFidget2", "IdleFidget3" }
	-- homeWorld.ac:addAnimationFile(homeWorld.idles[1], "data/models/home_planet/hp_bubble_bone.hkt")
	-- homeWorld.activeIdle = 1
	
	homeWorld.go:setComponentStates(ComponentState.Active)
end

do	-- Character
	character = {}
	character.go = GameObjectManager:createGameObject("character")
	character.pc = character.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createBox(Vec3(20, 20, 20))
	cinfo.motionType = MotionType.Character
	cinfo.restitution = 0
	cinfo.friction = 0
	cinfo.position = Vec3(0,0,500)
	cinfo.gravityFactor = 10
	cinfo.mass = 90
	cinfo.maxLinearVelocity = 1000

	cinfo.linearDamping = 1
	cinfo.angularDamping = 1
	character.rb = character.pc:createRigidBody(cinfo)
	character.sc = character.go:createScriptComponent()
	local renderComponent = character.go:createRenderComponent()
	--renderComponent:setPath("data/models/mario/mario.thModel")
	--renderComponent:setPath("data/models/robot.thModel")
	renderComponent:setPath("data/models/roboter/robot2.thModel")
	
	-- #Animations
	character.ac = character.go:createAnimationComponent()
	character.ac:setSkeletonFile("data/models/roboter/robot_animated.hkt")
	character.ac:setSkinFile("data/models/roboter/robot_animated.hkt")
	
	-- set Idles
	character.idles = { "Idle", "IdleFidget" }
	character.ac:addAnimationFile(character.idles[1], "data/models/roboter/robot_idle.hkt")
	character.activeIdle = 0 -- no Idle
	
	-- set Walk
	character.ac:addAnimationFile("Walk", "data/models/roboter/robot_walk.hkt")
	
	-- set Attack
	character.attacks = { "Attack", "Attack2" }
	character.ac:addAnimationFile(character.attacks[1], "data/models/roboter/robot_shot.hkt")
	character.activeAttack = 0 -- no attack
	
	character.go:setComponentStates(ComponentState.Active)
	-- collision event
	--character.pc:getContactPointEvent():registerListener(collisionCharacter)
	character.grounded = false
	
	-- Additional
	character.go.firstPersonMode = false
	character.go.currentAngularVelocity = Vec3()
	character.go.angularVelocitySwapped = false
	character.go.viewUpDown = 0.0
end

planetSize = 50
do	-- Planet
	planetArr[1] = {}
	planetArr[1].go = GameObjectManager:createGameObject("planetArr[1]")
	planetArr[1].pc = planetArr[1].go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(planetSize)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = Vec3(-40, 400, 40)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 0
	planetArr[1].rb = planetArr[1].pc:createRigidBody(cinfo)
	planetArr[1].sc = planetArr[1].go:createScriptComponent()
	planetArr[1].go:setComponentStates(ComponentState.Active)
	planetArr[1].size = planetSize
end

planetSize = 100
do	-- planet2
	planetArr[2] = {}
	planetArr[2].go = GameObjectManager:createGameObject("planetArr[2]")
	planetArr[2].pc = planetArr[2].go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(planetSize)
	cinfo.motionType = MotionType.Fixed
	cinfo.position = Vec3(-40, -400, 40)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 0
	planetArr[2].rb = planetArr[2].pc:createRigidBody(cinfo)
	planetArr[2].sc = planetArr[2].go:createScriptComponent()
	planetArr[2].go:setComponentStates(ComponentState.Active)
	planetArr[2].size = planetSize
end

-- neu

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

--
-- normalCam
--
normalCam = {}

normalCam.firstPerson = createDefaultCam("firstPerson")

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
	return character.go:getWorldPosition() + character.go:getViewDirection():mulScalar(-150.0) + Vec3(0.0, 0.0, 50.0)
end

normalCam.isometric = createDefaultCam("isometric")
normalCam.isometric.cc:look(Vec2(0.0, 20.0))


