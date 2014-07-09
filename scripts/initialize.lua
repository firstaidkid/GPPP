print("initializing gameworld")

WORLD_SIZE = 2500.0
REAL_WORLD_SIZE = 10000.0

MAX_IMPULSE = 200
--WORLD_SIZE = 200000.0
-- Alle Planeten Radien
planetRadien = {}
-- Alle Collisons Planeten vom Homeplanet
collisionSpheres = {}
NUM_COLLISIONSHERES = 200
MIN_COLLISIONSHERES = 1
growAim = 1
currentGrow = 0
character_size = 20
numberOfPlanets = 100
numberOfSmallPlanets = 15
numberOfMidPlanets = 20
numberOfBigPlanets = 10

massPerSize = 50

--the higher the gravity, the smaller the force
PLANET_GRAVITY = 200


-- size of CollisionCheckSphere
colSpSize = 500
checkArray = {}
nearestPlanet = nil
planetArr = {}
gameover = false





-- sound banks
SoundSystem:loadLibrary(".\\data\\sound\\Master Bank.bank")
SoundSystem:loadLibrary(".\\data\\sound\\Master Bank.bank.strings")
SoundSystem:loadLibrary(".\\data\\sound\\Weapons.bank")
SoundSystem:loadLibrary(".\\data\\sound\\UI_Menu.bank")
SoundSystem:loadLibrary(".\\data\\sound\\Surround_Ambience.bank")
SoundSystem:loadLibrary(".\\data\\sound\\Character.bank")



DIFFICULTY = {
	EASY = {
		velocity =1500
	}
	,
	EASYMEDIUM = {
		velocity = 2500
	}
	,
	MEDIUM = {
		velocity = 3500
	}
	,
	MEDIUMHARD = {
		velocity = 6500
	}
	,
	HARD = {
		velocity = 12000
	}
}

currentDiffulty = DIFFICULTY.EASY

score = 0



brokenPlanets = {}

textures = {
	"data/models/planet_models/avalon.thModel",
	"data/models/planet_models/jupiter.thModel",
	"data/models/planet_models/klendathu.thModel",
	"data/models/planet_models/planet.thModel"
}


currentCollider = nil

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
	cinfo.worldSize = REAL_WORLD_SIZE
	local world = PhysicsFactory:createWorld(cinfo)
	world = PhysicsFactory:createWorld(cinfo)
	world:setCollisionFilter(PhysicsFactory:createCollisionFilter_Simple())
	PhysicsSystem:setWorld(world)
	PhysicsSystem:setDebugDrawingEnabled(true)
end



function addPoint()
	score = score + 1

	if(growAim<NUM_COLLISIONSHERES)then
		growAim = growAim + 1
	end
end



function create_collisionSphere( size )
	-- body
	collisionSphere 			= 	{}
	collisionSphere.go 			= 	GameObjectManager:createGameObject(nextGUID())
	collisionSphere.go.size 	= 	size
	collisionSphere.pc 			= 	collisionSphere.go:createPhysicsComponent()

	collisionSphere.go.mass 	= 	size * massPerSize
	
	local cinfo 			= 	RigidBodyCInfo()
	cinfo.position 				= 	Vec3(0,0,0)
	cinfo.shape 				= 	PhysicsFactory:createSphere(size)
	--cinfo.shape 				= 	PhysicsFactory:createBox(Vec3(size, size, size))
	cinfo.motionType 			= 	MotionType.Keyframed
	cinfo.restitution 			= 	0
	cinfo.friction 				= 	0
	cinfo.gravityFactor 		= 	0
	cinfo.mass 					= 	size * massPerSize
	cinfo.maxLinearVelocity 	= 	10000
	cinfo.collisionFilterInfo 	= 	0xff1f
	cinfo.isTriggerVolume 		= 	true
	collisionSphere.rb 			= 	collisionSphere.pc:createRigidBody(cinfo)
	
	-- stores the table inside the rigidbody
	collisionSphere.rb:setUserData(collisionSphere)

	collisionSphere.rb:getTriggerEvent():registerListener(function(args)
		local planet = args:getRigidBody():getUserData()
			if args:getEventType() == TriggerEventType.Entered then
				planet.go.isGone = true
			elseif args:getEventType() == TriggerEventType.Left then
			end
		return EventResult.Handled
	end)
	collisionSphere.go:setParent(homeplanetBody.go)
	return collisionSphere
end

function create_CollisionCheckSphere(size)
	colCheckSphere 				= 	{}
	colCheckSphere.go 			= 	GameObjectManager:createGameObject(nextGUID())
	colCheckSphere.pc 			= 	colCheckSphere.go:createPhysicsComponent()
	local cinfo 				= 	RigidBodyCInfo()
	cinfo.position 				= 	Vec3(0,0,0)
	cinfo.shape 				= 	PhysicsFactory:createSphere(size)
	cinfo.motionType 			= 	MotionType.Keyframed
	cinfo.restitution 			= 	0
	cinfo.friction 				= 	0
	cinfo.gravityFactor 		= 	0
	cinfo.mass 					= 	size * massPerSize
	cinfo.maxLinearVelocity 	= 	10000
	cinfo.collisionFilterInfo 	= 	0xff1f
	cinfo.isTriggerVolume 		= 	true
	colCheckSphere.rb 			= 	colCheckSphere.pc:createRigidBody(cinfo)
	
	-- stores the table inside the rigidbody
	colCheckSphere.rb:setUserData(colCheckSphere)

	colCheckSphere.rb:getTriggerEvent():registerListener(function(args)
		local planet 	=	args:getRigidBody():getUserData()
		local name 		= 	planet.go:getName()
				
		if args:getEventType() == TriggerEventType.Entered then
			-- print("in : " .. name)
			checkArray[#checkArray+1] = tonumber(name:sub(11,#name))
			-- for i=1, #checkArray do
				-- print("Array : " .. #checkArray .. " :: " .. checkArray[i])
			-- end
		elseif args:getEventType() == TriggerEventType.Left then
			-- print("out : " .. name)
			-- aus Array rauslöschen
			for i=1, #checkArray do
				-- search Planet in Check Array and delete
				if(checkArray[i] == tonumber(name:sub(11,#name))) then
					table.remove(checkArray, i)
				end
			end
			-- for i=1, #checkArray do
				-- print("Array : " .. #checkArray .. " :: " .. checkArray[i])
			-- end
		end
		
		return EventResult.Handled
	end)
	colCheckSphere.go:setParent(homeplanetBody.go)
	
	-- colCheckSphere.go:setComponentStates(ComponentState.Inactive)
	
	return colCheckSphere

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
	--cinfo.shape 			= PhysicsFactory:createSphere(20)
	cinfo.shape 			= PhysicsFactory:createBox(Vec3(20,20,20))
	cinfo.motionType 		= MotionType.Dynamic
	cinfo.restitution 		= 0
	cinfo.friction 			= 0
	cinfo.gravityFactor 	= 0
	cinfo.mass 				= 3
	cinfo.linearDamping 	= .1
	cinfo.maxLinearVelocity = 400


	homeplanetBody.au = homeplanetBody.go:createAudioComponent()
	homeplanetBody.collisionSound = homeplanetBody.au:createSoundInstance("CollisionSound", "/UI/Cancel")
	homeplanetBody.explosionSound = homeplanetBody.au:createSoundInstance("ExplosionSound", "/UI/Cancel")

	homeplanetBody.ambience = homeplanetBody.au:createSoundInstance("Ambience", "/Ambience/Country")
	homeplanetBody.ambience:setVolume(0.5)
	homeplanetBody.ambience:play()

	homeplanetBody.rb = homeplanetBody.pc:createRigidBody(cinfo)
	homeplanetBody.sc = homeplanetBody.go:createScriptComponent()
	
	homeplanetBody.go:setComponentStates(ComponentState.Active)
end

do -- homeWorldModel
	homePlanetModel 		= 	{}
	homePlanetModel.go 		= 	GameObjectManager:createGameObject("homePlanetModel")
	homePlanetModel.sc 		= 	homePlanetModel.go:createScriptComponent()
	homePlanetModel.rc 		= 	homePlanetModel.go:createRenderComponent()
	homePlanetModel.rc:setPath("data/models/planet_models/earth.thModel")
	homePlanetModel.go:setComponentStates(ComponentState.Active)
end

do	-- Character
	character 		= 	{}
	character.go 	= 	GameObjectManager:createGameObject("character")

	character.sc 	= 	character.go:createScriptComponent()
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
	character.ac:addAnimationFile("Walk", "data/models/roboter/robot_walk3.hkt")
	--character.ac:setPlaybackSpeed("Walk", 1)
	
	-- set Attack
	character.attacks = { "Attack", "Attack2" }
	character.ac:addAnimationFile(character.attacks[1], "data/models/roboter/robot_shot2.hkt")
	character.activeAttack = 0 -- no attack
	
	character.go:setComponentStates(ComponentState.Active)
	
	--## create CollsionCheckSphere
	create_CollisionCheckSphere(colSpSize)
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end





function gameOver()

	--.go:setComponentStates(ComponentState.Inactive)
	--if(not gameover) then
		print("gameover")
		for k,v in pairs(brokenPlanets) do
			brokenPlanets[k].go:setComponentStates(ComponentState.Active)
			local planetVelocity = Vec3(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))

			brokenPlanets[k].go:setPosition(homeplanetBody.go:getWorldPosition())

			--brokenPlanets[k].rb:setLinearVelocity(planetVelocity)
			brokenPlanets[k].rb:applyForce(1, planetVelocity:mulScalar(10))
		end

		character.go:setComponentStates(ComponentState.Inactive)
		homePlanetModel.go:setComponentStates(ComponentState.Inactive)
		homeplanetBody.go:setComponentStates(ComponentState.Inactive)


		for k,v in pairs(collisionSpheres) do
			collisionSpheres[k].go:setComponentStates(ComponentState.Inactive)
		end

		
		gameover = true
	--end
end

--------------------------------------------------------------------- Restart the game ---------------------------------------
function Restart()

	-- body
	print("restart")
	for k,v in pairs(brokenPlanets) do
		brokenPlanets[k].go:setComponentStates(ComponentState.Inactive)
	end

	character.go:setComponentStates(ComponentState.Active)
	homePlanetModel.go:setComponentStates(ComponentState.Active)
	homeplanetBody.go:setComponentStates(ComponentState.Active)
	homeplanetBody.rb:setLinearVelocity(Vec3(0,0,0))

	--activate collisionSpheres
	growAim= 5
	grow(5)

	-- 
	for k,v in pairs(planetArr) do
		planetArr[k].go:setPosition(Vec3(math.random(-WORLD_SIZE, WORLD_SIZE), 0, math.random(-WORLD_SIZE, WORLD_SIZE)))
		local planetVelocity = Vec3(math.random(-50, 50), 0, math.random(-50, 50))
		planetArr[k].rb:applyForce(currentDiffulty.velocity, planetVelocity)
	end

	gameover = false
end
-----------------------------------------------------------------------------------------------------------------------------





function createBackgroundPlanet(number, size, position)
	
	backgroundPlanet 			= 	{}
	backgroundPlanet.go 		= 	GameObjectManager:createGameObject("backgroundPlanet[" .. number .. "]")
	backgroundPlanet.rc 		= 	backgroundPlanet.go:createRenderComponent()
	backgroundPlanet.rc:setPath("data/models/space/nibiru_50.thModel")
	backgroundPlanet.rc:setScale(Vec3(size/50, size/50, size/50))
	backgroundPlanet.go:setComponentStates(ComponentState.Active)
	backgroundPlanet.go:setPosition(position)

end

function createBackgroundStars(number, size, position)
	backgroundPlanet = {}
	backgroundPlanet.go = GameObjectManager:createGameObject("backgroundStars[" .. number .. "]")
	backgroundPlanet.rc = backgroundPlanet.go:createRenderComponent()
	backgroundPlanet.rc:setPath("data/models/planet_models/none.thModel")
	backgroundPlanet.rc:setScale(Vec3(size/50, size/50, size/50))
	backgroundPlanet.go:setComponentStates(ComponentState.Active)
	backgroundPlanet.go:setPosition(position)

end




function createPlanet(number, size, position)
	planetArr[number] = {}
	planetArr[number].go = GameObjectManager:createGameObject("planetArr_" .. number)
	planetArr[number].pc = planetArr[number].go:createPhysicsComponent()
	planetArr[number].go.isGone = false
	planetArr[number].go.isGravity = false
	planetArr[number].go.size = size
	planetArr[number].go.mass = size * massPerSize
	local cinfo = RigidBodyCInfo()
	cinfo.shape = PhysicsFactory:createSphere(size)
	cinfo.motionType = MotionType.Dynamic
	cinfo.position = position
	cinfo.mass = size * massPerSize
	cinfo.gravityFactor = 0
	cinfo.maxLinearVelocity = 	100000000
	cinfo.collisionFilterInfo = 0xff1f
	planetArr[number].rb = planetArr[number].pc:createRigidBody(cinfo)
	
	-- stores the table inside the rigidbody
	planetArr[number].rb:setUserData(planetArr[number])
	
	planetArr[number].rc = planetArr[number].go:createRenderComponent()
	planetArr[number].rc:setPath(textures[math.random(1,4)])
	planetArr[number].rc:setScale(Vec3(size/50, size/50, size/50))

	planetArr[number].sc = planetArr[number].go:createScriptComponent()
	planetArr[number].go:setComponentStates(ComponentState.Active)
	planetArr[number].size = size


	local planetVelocity = Vec3(math.random(-50, 50), 0, math.random(-50, 50))

	--planetArr[number].rb:setLinearVelocity(planetVelocity)
	planetArr[number].rb:applyForce(currentDiffulty.velocity, planetVelocity)
end





function createBrokenPlanet(number, size, position)
	brokenPlanet = {}
	
	brokenPlanet.go = GameObjectManager:createGameObject(nextGUID())
	brokenPlanet.pc = brokenPlanet.go:createPhysicsComponent()
	brokenPlanet.go.isGone = false
	brokenPlanet.go.isGravity = false
	brokenPlanet.go.size = size
	local cinfo = RigidBodyCInfo()
	--cinfo.shape = PhysicsFactory:createSphere(size)
	cinfo.shape = PhysicsFactory:createBox(Vec3(size/1.6,size/1.6, size/1.6))
	cinfo.motionType = MotionType.Dynamic
	cinfo.position = position
	cinfo.mass = 2
	cinfo.gravityFactor = 0
	cinfo.linearDamping = .3
	cinfo.maxLinearVelocity = 	100000000
	cinfo.collisionFilterInfo = 0xff1f
	brokenPlanet.rb = brokenPlanet.pc:createRigidBody(cinfo)
	-- stores the table inside the rigidbody
	brokenPlanet.rb:setUserData(brokenPlanet)
	
	brokenPlanet.rc = brokenPlanet.go:createRenderComponent()
	brokenPlanet.rc:setPath("data/models/planet_models/earth.thModel")
	

	brokenPlanet.rc:setScale(Vec3(size/200, size/200, size/200))

	brokenPlanet.sc = brokenPlanet.go:createScriptComponent()
	brokenPlanet.go:setComponentStates(ComponentState.Inactive)
	brokenPlanet.size = size



	--planetArr[number].rb:setLinearVelocity(planetVelocity)
	
	--createGravityZone(number, size)
	
	--GravityZone
	--planetArr[number].gz = createGravityZone(size, planetArr[number])
	--planetArr[number].gz.go:setComponentStates(ComponentState.Inactive)
	return brokenPlanet
end

for i=1,40 do
	brokenPlanets[i] = createBrokenPlanet(i, 5, Vec3(0,0,0))
end




--background
do
	bg={}
	bg.go = GameObjectManager:createGameObject("bg")
	bg.pc = bg.go:createPhysicsComponent()

	local cinfo = RigidBodyCInfo()
	cinfo.position = Vec3(0, 3000, -3000)
	cinfo.shape = PhysicsFactory:createBox(3000, 3000, 1)
	cinfo.motionType = MotionType.Fixed
	cinfo.mass = 1
	bg.rb = bg.pc:createRigidBody(cinfo)
	bg.rc = bg.go:createRenderComponent()

	bg.rc:setPath("data/models/planet_models/bg.thModel")
	bg.rc:setScale(Vec3(4,4,4))

	bg.go:setComponentStates(ComponentState.Active)
	
end


for j=1 , numberOfSmallPlanets do
    local position = Vec3(math.random(-WORLD_SIZE, WORLD_SIZE), 0, math.random(-WORLD_SIZE, WORLD_SIZE))
	
	local size = math.random(20, 50)
	createPlanet(j, size, position)
end
for j=#planetArr+1 , #planetArr + numberOfMidPlanets do
    local position = Vec3(math.random(-WORLD_SIZE, WORLD_SIZE), 0, math.random(-WORLD_SIZE, WORLD_SIZE))
	
	local size = math.random(51, 100)
	createPlanet(j, size, position)
end

for j=#planetArr+1 , #planetArr + numberOfBigPlanets do
    local position = Vec3(math.random(-WORLD_SIZE, WORLD_SIZE), 0, math.random(-WORLD_SIZE, WORLD_SIZE))
	
	local size = math.random(101, 200)
	createPlanet(j, size, position)
end

-- create Background Planets
for j=1 , 100 do
    local position = Vec3(math.random(-REAL_WORLD_SIZE/2, REAL_WORLD_SIZE/2), math.random(2000, 3000), math.random(-REAL_WORLD_SIZE/2, REAL_WORLD_SIZE/2))
	local size = math.random(20, 200)
	createBackgroundPlanet(j, size, position)
end

-- create Background Stars
for j=1 , 300 do
    local position = Vec3(math.random(-REAL_WORLD_SIZE, REAL_WORLD_SIZE), math.random(2000, 3000), math.random(-REAL_WORLD_SIZE, REAL_WORLD_SIZE))
	
	local size = math.random(100, 500)
	createBackgroundStars(j, size, position)
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
	homePlanetModel.rc:setScale(Vec3((50 + i)/500 ,(50 + i)/500,(50 + i)/500))
	print(homePlanetModel.rc)

	--targetObject:setScale(Vec3(2,2,2))
	for k,v in pairs(collisionSpheres) do
		
		collisionSpheres[k].go:setComponentStates(ComponentState.Inactive)
		if(k==i)then
			currentCollider = collisionSpheres[k]
			collisionSpheres[k].go:setComponentStates(ComponentState.Active)
		end

	end
	character.go:setPosition(Vec3(0, 0, planetRadien[i]))

	currentGrow = i

end

for i=1,NUM_COLLISIONSHERES do 
	planetRadien[i] = 50 + i
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

	particle.rc = particle.go:createRenderComponent()
	particle.rc:setPath("data/models/planet_models/none.thModel")

	particle.go:setComponentStates(ComponentState.Inactive)

	return particle
end

function spawnDebris(position, normal) 
	for i = 1, #debris do
		debris[i].go:setPosition(position)
		debris[i].go:setComponentStates(ComponentState.Active)
		debris[i].rb:applyLinearImpulse(normal:mulScalar(100))
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
