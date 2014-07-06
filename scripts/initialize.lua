print("initializing gameworld")

WORLD_SIZE = 3000.0
--WORLD_SIZE = 200000.0
-- Alle Planeten Radien
planetRadien = {}
-- Alle Collisons Planeten vom Homeplanet
collisionSpheres = {}
maxSize = 100
growAim = 5
currentGrow = 0
character_size = 20
numberOfPlanets = 50




-- Variablen 
planetAmount = 2
nearestPlanet = 1
planetArr = {}
gravityZone = {}
homeWorldSize = 200


local serpent = require("data/scripts/serpent")

do -- Physics world
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = WORLD_SIZE
	local world = PhysicsFactory:createWorld(cinfo)
	world = PhysicsFactory:createWorld(cinfo)
	world:setCollisionFilter(PhysicsFactory:createCollisionFilter_Simple())
	PhysicsSystem:setWorld(world)
	PhysicsSystem:setDebugDrawingEnabled(true)
end


function create_collisionSphere( size )
	-- body
	collisionSphere 				= 	{}
	collisionSphere.go 			= 	GameObjectManager:createGameObject(nextGUID())
	collisionSphere.pc 			= 	collisionSphere.go:createPhysicsComponent()

	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	Vec3(0,0,0)
	cinfo.shape 			= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 		= 	MotionType.Keyframed
	cinfo.restitution 		= 	0
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	10000
	cinfo.collisionFilterInfo = 0xff1f
	cinfo.isTriggerVolume = true
	collisionSphere.rb 			= 	collisionSphere.pc:createRigidBody(cinfo)
	
	-- stores the table inside the rigidbody
	collisionSphere.rb:setUserData(collisionSphere)

	collisionSphere.rb:getTriggerEvent():registerListener(function(args)
		local planet = args:getRigidBody():getUserData()
		print(planet.go:getName())

		if(growAim<maxSize)then
			growAim = growAim + 1
		end
			if args:getEventType() == TriggerEventType.Entered then

				planet.go.isGone = true

			elseif args:getEventType() == TriggerEventType.Left then

			end
		return EventResult.Handled
	end)
	collisionSphere.go:setParent(homeplanetBody.go)
	
	return collisionSphere
end

function create_GravitySphere(number, size)
	-- body
	gravityZone[number] 				= 	{}
	gravityZone[number].go 			= 	GameObjectManager:createGameObject("gravityZone[" .. number .."]")
	gravityZone[number].pc 			= 	gravityZone[number].go:createPhysicsComponent()
	gravityZone[number].go.isGone = false
	
	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 			= 	planetArr[number].go:getWorldPosition()
	cinfo.shape 			= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 		= 	MotionType.Dynamic
	cinfo.friction 			= 	0
	cinfo.gravityFactor 	= 	0
	cinfo.mass 				= 	900000
	cinfo.maxLinearVelocity = 	100000000
	cinfo.collisionFilterInfo = 0xff1f
	gravityZone[number].rb 			= 	gravityZone[number].pc:createRigidBody(cinfo)
	
	-- stores the table inside the rigidbody
	gravityZone[number].rb:setUserData(gravityZone[number])
	
	gravityZone[number].sc = gravityZone[number].go:createScriptComponent()
	gravityZone[number].go:setComponentStates(ComponentState.Active)
	
	-- gravityZone[number].go:setParent(motherPlanet.go)
	--gravityZone[number].go:setParent(planetArr[number].go)
end

guid = 0
function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

do -- homeWorld
	homeplanetBody 			= {}
	homeplanetBody.go 		= GameObjectManager:createGameObject("homeplanetBody")
	homeplanetBody.wasPreviouslyBehind = false
	homeplanetBody.pc 		= homeplanetBody.go:createPhysicsComponent()
	
	local cinfo 			= RigidBodyCInfo()
	cinfo.position 			= Vec3(0,0,0)
	cinfo.shape 			= PhysicsFactory:createSphere(20)
	cinfo.motionType 		= MotionType.Dynamic
	cinfo.restitution 		= 0
	cinfo.friction 			= 0
	cinfo.gravityFactor 	= 0
	cinfo.mass 				= 900000
	cinfo.maxLinearVelocity = 400


	homeplanetBody.rb = homeplanetBody.pc:createRigidBody(cinfo)
	homeplanetBody.sc = homeplanetBody.go:createScriptComponent()
	
	homeplanetBody.go:setComponentStates(ComponentState.Active)
end

do -- homeWorldModel
	homePlanetModel 			= {}
	homePlanetModel.go 		= GameObjectManager:createGameObject("homePlanetModel")
	homePlanetModel.pc 		= homePlanetModel.go:createPhysicsComponent()
	
	local cinfo 			= RigidBodyCInfo()
	cinfo.position 			= Vec3(0,0,0)
	cinfo.shape 			= PhysicsFactory:createSphere(20)
	cinfo.motionType 		= MotionType.Dynamic
	cinfo.restitution 		= 0
	cinfo.friction 			= 0
	cinfo.gravityFactor 	= 0
	cinfo.mass 				= 900000
	cinfo.maxLinearVelocity = 400


	homePlanetModel.rb = homePlanetModel.pc:createRigidBody(cinfo)
	homePlanetModel.sc = homePlanetModel.go:createScriptComponent()
	homePlanetModel.rc = homePlanetModel.go:createRenderComponent()
	homePlanetModel.rc:setPath("data/models/space/nibiru_50.thModel")
--	homePlanetModel.rc:setPath("data/models/home_planet/home_planet.thModel")

	homePlanetModel.go:setComponentStates(ComponentState.Active)
end

do	-- Character
	character = {}
	character.go = GameObjectManager:createGameObject("character")

	character.sc = character.go:createScriptComponent()
	local renderComponent = character.go:createRenderComponent()
	
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
	--character.ac:setPlaybackSpeed("Walk", 1)
	
	-- set Attack
	character.attacks = { "Attack", "Attack2" }
	character.ac:addAnimationFile(character.attacks[1], "data/models/roboter/robot_shot.hkt")
	character.activeAttack = 0 -- no attack
	
	character.go:setComponentStates(ComponentState.Active)
	
end

function createPlanet(number, size, position)
	planetArr[number] = {}
	planetArr[number].go = GameObjectManager:createGameObject("planetArr[" .. number .. "]")
	planetArr[number].pc = planetArr[number].go:createPhysicsComponent()
	planetArr[number].go.isGone = false
	planetArr[number].go.isGravity = false
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(size)
	cinfo.motionType = MotionType.Dynamic
	cinfo.position = position
	cinfo.mass = 2
	cinfo.gravityFactor = 0
	cinfo.maxLinearVelocity = 	100000000
	cinfo.collisionFilterInfo = 0xff1f
	planetArr[number].rb = planetArr[number].pc:createRigidBody(cinfo)
	-- stores the table inside the rigidbody
	planetArr[number].rb:setUserData(planetArr[number])
	
	planetArr[number].rc = planetArr[number].go:createRenderComponent()
	-- planetArr[number].rc:setPath("data/models/space/nibiru_" .. size .. ".thModel")
	planetArr[number].rc:setPath("data/models/planet_models/jupiter.thModel")
	

	planetArr[number].rc:setScale(Vec3(size/50 + .1, size/50 + .1, size/50 + .1))

	planetArr[number].sc = planetArr[number].go:createScriptComponent()
	planetArr[number].go:setComponentStates(ComponentState.Active)
	planetArr[number].size = size


	local planetVelocity = Vec3(math.random(-50, 50), 0, math.random(-50, 50))

	--planetArr[number].rb:setLinearVelocity(planetVelocity)
	planetArr[number].rb:applyForce(0.5, planetVelocity)
	
	--createGravityZone(number, size)
	
	--GravityZone
	--planetArr[number].gz = createGravityZone(size, planetArr[number])
	--planetArr[number].gz.go:setComponentStates(ComponentState.Inactive)
end

function createGravityZone(number, size)
	create_GravitySphere(number, size * 5)
end

for j=1 , numberOfPlanets do
    local position = Vec3(math.random(-WORLD_SIZE, WORLD_SIZE), 0, math.random(-WORLD_SIZE, WORLD_SIZE))
	
	local size = math.random(50, 500)
	createPlanet(j, size, position)

	-- planetArr[j].gz.go:setComponentStates(ComponentState.Aktive)
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


function grow( i )
	-- body

	local characterUpDirection 	= 	character.go:getUpDirection()
	local impulse = (homeplanetBody.go:getWorldPosition() + character.go:getWorldPosition()):mulScalar(20)


	--character.rc:setScale(Vec3(i,i,i))

	-- apply impulse
	--character.go:setPosition(characterUpDirection:mulScalar(i *20))
	homePlanetModel.rc:setScale(Vec3(i/4 ,i/4,i/4))
	print(homePlanetModel.rc)

	--targetObject:setScale(Vec3(2,2,2))
	for k,v in pairs(collisionSpheres) do
		
		collisionSpheres[k].go:setComponentStates(ComponentState.Inactive)
		if(k==i)then
			
			collisionSpheres[k].go:setComponentStates(ComponentState.Active)
		end

	end
	character.go:setPosition(Vec3(0, 0, planetRadien[i]))

	currentGrow = i

end

for i=1,maxSize do 
	planetRadien[i] = i* 10
	collisionSpheres[i] = create_collisionSphere(planetRadien[i])
	collisionSpheres[i].go:setComponentStates(ComponentState.Inactive)
end

character.go:setParent(homeplanetBody.go)
character.go:setPosition(Vec3(0, 0, 200))

-- BEGIN debris

function addDebris(i)
	local particle = {}
	particle.go = GameObjectManager:createGameObject("debris-particle-" .. i)
	particle.pc = particle.go:createPhysicsComponent()
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(3)
	cinfo.motionType = MotionType.Dynamic
	cinfo.position = Vec3(-1000, -1000 , -1000)
	cinfo.mass = 5
	cinfo.friction = 0.1
	cinfo.restitution = 0.8
	cinfo.gravityFactor = 1
	
	particle.rb = particle.pc:createRigidBody(cinfo)

	particle.go:setComponentStates(ComponentState.Inactive)

	return particle
end

function spawnDebris(position, normal) 
	for i = 1, #debris do
		debris[i].go:setPosition(position)
		debris[i].go:setComponentStates(ComponentState.Active)
		debris[i].rb:applyLinearImpulse(Vec3(normal.x * math.random(50), normal.y * math.random(200), normal.z * math.random(100)))
	end
	debris.timer = 0

	debris.visible = true
end

function resetDebris(speedFactor) 
	speedFactor = math.random(speedFactor, speedFactor * 2)
	local destroyUntil = debris.alreadyDestroyed + (#debris * (speedFactor / 10))
	destroyUntil = math.clamp(destroyUntil, 1, debris.maxAmount)
	for i = 1, destroyUntil do
		debris[i].go:setPosition(Vec3(-1000, -1000, -1000))
		debris[i].go:setComponentStates(ComponentState.Inactive)
	end
	debris.alreadyDestroyed = destroyUntil

	if(debris.alreadyDestroyed >= debris.maxAmount) then 
		debris.visible = false
	end

end

debris = {}
debris.maxAmount = 30
debris.timer = 0
debris.maxTime = 1.5 -- seconds
debris.visible = false
debris.alreadyDestroyed = 0


for i = 1, debris.maxAmount do
	debris[i] = addDebris(i)
end

-- END debris
