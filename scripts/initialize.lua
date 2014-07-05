print("initializing gameworld")

WORLD_SIZE = 5000.0
--WORLD_SIZE = 200000.0
-- Alle Planeten Radien
planetRadien = {}
-- Alle Collisons Planeten vom Homeplanet
collisionSpheres = {}
maxSize = 100
growAim = 5
currentGrow = 0
character_size = 20

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

guid = 0
function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

-- do -- debugCam
	-- debugCam = GameObjectManager:createGameObject("debugCam")
	-- debugCam.cc = debugCam:createCameraComponent()
	-- debugCam.cc:setPosition(Vec3(-600.0, 0.0, 0.0))
	-- debugCam.cc:setViewDirection(Vec3(1.0, 0.0, 0.0))
	-- debugCam.baseViewDir = Vec3(1.0, 0.0, 0.0)
	-- debugCam.cc:setBaseViewDirection(debugCam.baseViewDir)
-- end

-- Variablen 
planetAmount = 2
nearestPlanet = 1
planetArr = {}
homeWorldSize = 200
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
	-- homeplanetBody.rc = homeplanetBody.go:createRenderComponent()
	-- homeplanetBody.rc:setPath("data/models/space/nibiru_50.thModel")
	
	-- ## Animation ##
	-- homeplanetBody.rc:setPath("data/models/home_planet/home_planet_bones.thModel")
	
	-- #Animations
	-- homeplanetBody.ac = homeplanetBody.go:createAnimationComponent()
	-- homeplanetBody.ac:setSkeletonFile("data/models/home_planet/hp_animated_bone.hkt")
	-- homeplanetBody.ac:setSkinFile("data/models/home_planet/hp_animated_bone.hkt")
	
	-- set Idles
	-- homeplanetBody.idles = { "Idle", "IdleFidget", "IdleFidget2", "IdleFidget3" }
	-- homeplanetBody.ac:addAnimationFile(homeplanetBody.idles[1], "data/models/home_planet/hp_bubble_bone.hkt")
	-- homeplanetBody.activeIdle = 1
	
	-- ## Animation ENDE ##
	
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
	
	-- set Attack
	character.attacks = { "Attack", "Attack2" }
	character.ac:addAnimationFile(character.attacks[1], "data/models/roboter/robot_shot.hkt")
	character.activeAttack = 0 -- no attack
	
	character.go:setComponentStates(ComponentState.Active)
	
	-- Additional for Camera
	character.go.firstPersonMode = false
	character.go.currentAngularVelocity = Vec3()
	character.go.angularVelocitySwapped = false
	character.go.viewUpDown = 0.0
end

function createPlanet(number, size, position)
	planetArr[number] = {}
	planetArr[number].go = GameObjectManager:createGameObject("planetArr[" .. number .. "]")
	planetArr[number].pc = planetArr[number].go:createPhysicsComponent()
	planetArr[number].go.isGone = false
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
	
	planetArr[number].sc = planetArr[number].go:createScriptComponent()
	planetArr[number].go:setComponentStates(ComponentState.Active)
	planetArr[number].size = size
end

createPlanet(1, 50, Vec3(-40, 400, 40))
createPlanet(2, 100, Vec3(-40, -400, 40))


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

-- Neu

function grow( i )
	-- body

	local characterUpDirection 	= 	character.go:getUpDirection()
	local impulse = (homeplanetBody.go:getWorldPosition() + character.go:getWorldPosition()):mulScalar(20)


	--character.rc:setScale(Vec3(i,i,i))

	-- apply impulse
	--character.go:setPosition(characterUpDirection:mulScalar(i *20))
	homePlanetModel.rc:setScale(Vec3(i/5,i/5,i/5))
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
		
		--print(go:getName())

		print("         " .. serpent.dump(planet))
		print("         ")
		print("     GameObject::     " .. serpent.dump(planetArr[1].planet))
		
		
		
		--otherPlanets[tonumber(go:getName())].go:setComponentStates(ComponentState.Inactive)
		

		if(growAim<maxSize)then
			growAim = growAim + 1
		end

		--print(GameObjectManager:getGameObject(go:getName()))
		
		--GameObjectManager:getGameObject(go:getName()):setComponentStates(ComponentState.Inactive)
		if args:getEventType() == TriggerEventType.Entered then
			-- local help = GameObjectManager:getGameObject(go.go:getName())
				--go.rb:setLinearVelocity(Vec3(200000,0,0))
				-- planet.rb:setLinearVelocity(Vec3(999999,0,0))
				planet.go.isGone = true

		elseif args:getEventType() == TriggerEventType.Left then

		end
		return EventResult.Handled
	end)
	collisionSphere.go:setParent(homeplanetBody.go)

	return collisionSphere
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
