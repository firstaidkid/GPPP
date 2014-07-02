print("initializing gameworld")

WORLD_SIZE = 2000.0

do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = WORLD_SIZE
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)

	--PhysicsDebugView
	PhysicsSystem:setDebugDrawingEnabled(true)
end

guid = 0
function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

do -- Camera
	camera = {}
	camera.go = GameObjectManager:createGameObject("camera")
	camera.pc = camera.go:createPhysicsComponent()
	camera.cc = camera.go:createCameraComponent()
	camera.eye = Vec3(100.0, -100.0, 100.0)  -- camera position
	camera.aim = Vec3(0.0, 0.0, 0.0) -- camera target
	camera.cc:setPosition(camera.eye)
	camera.cc:lookAt(camera.aim)

	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(2.5)
	cinfo.motionType = MotionType.Character
	cinfo.position = Vec3(0, 0, 0)
	cinfo.mass = 1.0
	cinfo.restitution = 0.0
	cinfo.friction = 0.0
	cinfo.maxLinearVelocity = 3000
	cinfo.linearDamping = 5.0
	cinfo.gravityFactor = 0.0

	camera.pc.rb = camera.pc:createRigidBody(cinfo)
end

-- do -- homeWorld
-- 	homeWorld = {}
-- 	homeWorld.go = GameObjectManager:createGameObject("homeWorld")
-- 	homeWorld.pc = homeWorld.go:createPhysicsComponent()
-- 	local cinfo = RigidBodyCInfo()
-- 	cinfo.shape = PhysicsFactory:createSphere(10)
-- 	cinfo.motionType = MotionType.Dynamic
-- 	cinfo.position = Vec3(0, 0, 0)
-- 	cinfo.mass = 2000
-- 	cinfo.friction = 0.4
-- 	cinfo.restitution = 0.8
-- 	cinfo.gravityFactor = 10
-- 	homeWorld.rb = homeWorld.pc:createRigidBody(cinfo)
-- 	homeWorld.sc = homeWorld.go:createScriptComponent()
-- 	homeWorld.go:setComponentStates(ComponentState.Active)
-- end

do -- character
	player = {}
	player.go = GameObjectManager:createGameObject("player")
	player.pc = player.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(5)
	cinfo.motionType = MotionType.Character
	cinfo.position = Vec3(0, 0, 0)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 10
	player.rb = player.pc:createRigidBody(cinfo)
	player.sc = player.go:createScriptComponent()
	player.go:setComponentStates(ComponentState.Active)
end

function defaultEnter(enterData)
	return EventResult.Handled
end