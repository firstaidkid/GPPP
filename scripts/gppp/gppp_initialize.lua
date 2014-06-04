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
	debugCam.eye = Vec3(100.0, -100.0, 100.0)  -- camera position
	debugCam.aim = Vec3(0.0, 0.0, 0.0) -- camera target
	debugCam.rotSpeed = 20.0
	debugCam.zoomSpeed = 50.0
	debugCam.maxZoom = 1000.0
	debugCam.minZoom = 10.0
	debugCam.zoom = (debugCam.aim - debugCam.eye):length() -- initialer zoom, die länge des vektors: target-position
	debugCam.cc:setPosition(debugCam.eye)
	debugCam.cc:lookAt(debugCam.aim)
end

do -- homeWorld
	homeWorld = {}
	homeWorld.go = GameObjectManager:createGameObject("homeWorld")
	homeWorld.pc = homeWorld.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(10)
	cinfo.motionType = MotionType.Dynamic
	cinfo.position = Vec3(0, 0, 0)
	cinfo.mass = 2
	cinfo.friction = 0.4
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 10
	homeWorld.rb = homeWorld.pc:createRigidBody(cinfo)
	homeWorld.sc = homeWorld.go:createScriptComponent()
--	homeWorld.sc:setUpdateFunction(updateEnemy)
	homeWorld.go:setComponentStates(ComponentState.Active)
end

function defaultEnter(enterData)
	return EventResult.Handled
end