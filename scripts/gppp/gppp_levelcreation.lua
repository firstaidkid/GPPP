require "math"

gv_planets = {} 	-- array for planet-accessing

-- CONSTANTS
MAX_PLANET_SIZE		= 15 	-- maximum diameter of planets
MAX_PLANET_IMPULSE	= 15 	-- random impulse upon spawn
DEPTH_OF_FIELD		= WORLD_SIZE / 2 - 100	-- visible planet distance from center

NOISE_MAP_SIZE		= 32 	-- pixel-size of noise-map (size x size x size)
PLANET_SPACING		= 40 	-- distance between planets when spacing

THRESHOLD_PLANET = 0.5 		-- noise-threshold for planets (high value = high density = more planets)
THRESHOLD_BLACKHOLE = -0.9

RANDOM_SEED			= os.time()

lc_p = {}
lc_permutation = {151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
	190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
	88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
	102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
	135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
	5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
	223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
	129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
	49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}

for i=0,255 do
	lc_p[i] = lc_permutation[i+1]
	lc_p[256+i] = lc_permutation[i+1]
end


-- from http://gamedev.stackexchange.com/questions/58664/2d-and-3d-perlin-noise-terrain-generation
-- and http://mrl.nyu.edu/~perlin/noise/
function noise(x, y, z) 
	local X = math.floor(x % 255)
	local Y = math.floor(y % 255)
	local Z = math.floor(z % 255)
	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)
	local u = fade(x)
	local v = fade(y)
	local w = fade(z)

	A   = lc_p[X  ]+Y
	AA  = lc_p[A]+Z
	AB  = lc_p[A+1]+Z
	B   = lc_p[X+1]+Y
	BA  = lc_p[B]+Z
	BB  = lc_p[B+1]+Z

	return lerp(w, lerp(v, lerp(u, grad(lc_p[AA  ], x  , y  , z   ), 
	                             grad(lc_p[BA  ], x-1, y  , z   )), 
	                     lerp(u, grad(lc_p[AB  ], x  , y-1, z   ), 
	                             grad(lc_p[BB  ], x-1, y-1, z   ))),
	             lerp(v, lerp(u, grad(lc_p[AA+1], x  , y  , z-1 ),  
	                             grad(lc_p[BA+1], x-1, y  , z-1 )),
	                     lerp(u, grad(lc_p[AB+1], x  , y-1, z-1 ),
	                             grad(lc_p[BB+1], x-1, y-1, z-1 )))
	)
end

function fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end


function lerp(t,a,b)
	return a + t * (b - a)
end


function grad(hash,x,y,z)
	local h = hash % 16
	local u 
	local v 

	if (h<8) then u = x else u = y end
	if (h<4) then v = y elseif (h==12 or h==14) then v=x else v=z end
	local r

	if ((h%2) == 0) then r=u else r=-u end
	if ((h%4) == 0) then r=r+v else r=r-v end
	return r
end

function fBm(x, y, z, octaves, lacunarity, gain)
	local octaves = octaves or 8
	local lacunarity = lacunarity or 2.0
	local gain = gain or 0.5
    local amplitude = 1.0;
    local frequency = 3.0;
    local sum = 0.0;
    for i = 0, octaves do
        --sum = sum + amplitude * (1-math.abs(noise(x * frequency, y * frequency, z * frequency)))
        sum = sum + amplitude * noise(x * frequency, y * frequency, z * frequency)
        amplitude = amplitude * gain
        frequency = frequency * lacunarity
    end

    return sum
end

local cp = 0
local cb = 0
local max = 0
local min = 0


function initLevelCreation()
	print("Init Level with RANDOM_SEED: " .. tostring(RANDOM_SEED))
	math.randomseed(RANDOM_SEED)
	local map_offset = (NOISE_MAP_SIZE * PLANET_SPACING)/2

	-- get x/y/z value of 3D noise-map
    for x = 1, NOISE_MAP_SIZE do
        for y = 1, NOISE_MAP_SIZE do 
            for z = 1, NOISE_MAP_SIZE do

            	-- noise density at that point
                local density = fBm(x/PLANET_SPACING, y/PLANET_SPACING, z/PLANET_SPACING) --Find out the density

                -- cap density
                if density > max then
                	max = density
                end

                if density < min then
                	min = density
                end

                -- calulate planet-size
                local m_size = (math.abs(density) * 50 * MAX_PLANET_SIZE) / 50

                --print("x: " .. x .. ", y: " .. z .. ", z: " .. z .. ", d: " .. density)
                -- create planet
                if(density > THRESHOLD_PLANET) then
                	cp = cp + 1
                	local p = {}
                	local pPos = Vec3(x*PLANET_SPACING - map_offset, y*PLANET_SPACING - map_offset, z*PLANET_SPACING - map_offset)

					p.go = GameObjectManager:createGameObject(nextGUID())
					p.pc = p.go:createPhysicsComponent()
					
					local cinfo = RigidBodyCInfo()
					cinfo.shape = PhysicsFactory:createSphere(m_size)
					cinfo.motionType = MotionType.Dynamic
					cinfo.position = pPos
					cinfo.mass = 1
					p.rb = p.pc:createRigidBody(cinfo)

					p.rb:setLinearVelocity(Vec3(math.random() * MAX_PLANET_IMPULSE, math.random() * MAX_PLANET_IMPULSE, math.random() * MAX_PLANET_IMPULSE))

					gv_planets[cp] = p;
                end

                -- create black hole
	            if(density < THRESHOLD_BLACKHOLE) then
	            	cb = cb + 1
	            	local p = {}
					p.go = GameObjectManager:createGameObject(nextGUID())
					p.pc = p.go:createPhysicsComponent()
					local cinfo = RigidBodyCInfo()
					cinfo.shape = PhysicsFactory:createBox(Vec3(m_size, m_size, m_size))
					cinfo.motionType = MotionType.Dynamic
					cinfo.position = Vec3(x*PLANET_SPACING - map_offset, y*PLANET_SPACING - map_offset, z*PLANET_SPACING - map_offset)
					cinfo.mass = 1
					p.rb = p.pc:createRigidBody(cinfo)
	            end
            end
        end
    end

    print("planets: " .. cp .. " | blackholes: " .. cb)
	print("max: " .. max .. " | min: " .. min)
	
end

do
	initLevelCreation()
end

function updateLevel(elapsedTime)
	-- check bounds for each planet
	for i = 1, cp do
		local pos = gv_planets[i].go:getWorldPosition()
		local newPos = pos
		local hit = false

		if(pos.x > DEPTH_OF_FIELD) then
			newPos.x = - DEPTH_OF_FIELD
			hit = true
		end
		if (pos.x < -DEPTH_OF_FIELD) then
			newPos.x = DEPTH_OF_FIELD
			hit = true
		end

		if(pos.y > DEPTH_OF_FIELD) then
			newPos.y = - DEPTH_OF_FIELD
			hit = true
		end
		if (pos.y < -DEPTH_OF_FIELD) then
			newPos.y = DEPTH_OF_FIELD
			hit = true
		end

		if(pos.z > DEPTH_OF_FIELD) then
			newPos.z = - DEPTH_OF_FIELD
			hit = true
		end
		if (pos.z < -DEPTH_OF_FIELD) then
			newPos.z = DEPTH_OF_FIELD
			hit = true
		end

		-- if bounds were hit, reset position
		if(hit) then
			gv_planets[i].go:setPosition(newPos)
		end
	end

	DebugRenderer:printText(Vec2(-0.99, 0.75), "planets: " .. cp .. " | blackholes: " .. cb)
	DebugRenderer:printText(Vec2(-0.99, 0.8), "max: " .. max .. " | min: " .. min)
end
