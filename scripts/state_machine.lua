logMessage("Initializing state_machine.lua ...")

-- Physics World
do
	local cinfo = WorldCInfo()
	cinfo.gravity = Vec3(0, 0, 0)
	cinfo.worldSize = 2000.0
	local world = PhysicsFactory:createWorld(cinfo)
	PhysicsSystem:setWorld(world)
end

-- Camera
cam = GameObjectManager:createGameObject("cam")
cam.cc = cam:createCameraComponent()
cam.cc:setPosition(Vec3(0.0, -300.0, 0.0))
cam.cc:lookAt(Vec3(0.0, 0.0, 0.0))
cam.cc:setState(ComponentState.Active)

-- // strip-start "StateMachineImpl"

-- The following state machine setup adds a state "A" and "B(fsm)" to the state machine "gameRunning"
-- The behavior is as follows:
--   When in state "A", press "B" to switch into the state machine "B(fsm)".
--   When in state "B(fsm)", press "A" to switch into the state machine "A".
--   When in state "B(fsm)", press "L" to exit "gameRunning".

local myGameState = State{
	name = "A",
	parent = "/game/gameRunning",
	eventListeners = {
		update = {
			--[[
			function(updateData)
				logMessage("A: Update listener 1. dt = " .. updateData:getElapsedTime())
				return EventResult.Handled
			end,
			function(updateData)
				logMessage("A: Update listener 2. dt = " .. updateData:getElapsedTime())
				return EventResult.Handled
			end,
			]]--
		}
	}
}

StateMachine{
	name = "B(fsm)",
	parent = "/game/gameRunning",
	states = {
		{
			name = "a",
			eventListeners = {
				update = {
					function(updateData)
						logMessage("a: Updating. dt = " .. updateData:getElapsedTime())
						return EventResult.Handled
					end,
				}
			},
		},
		{
			name = "b",
			eventListeners = {
				update = {
					function(updateData)
						logMessage("b: Updating. dt = " .. updateData:getElapsedTime())
						return EventResult.Handled
					end,
				}
			},
		},
		{
			name = "innerMost",
			eventListeners = {
				update = {
					function(updateData)
						logMessage("innerMost update.")
						return EventResult.Handled
					end,
				}
			},
			states = {
				{ name = "innerA" },
				{ name = "innerB" },
			},
			transitions = {
				{ from = "__enter", to = "innerA", },
				{ from = "innerA",  to = "innerB", },
				{ from = "innerB",  to = "__leave", },
			}
		},
	},
	transitions = {
		{ from = "__enter",   to = "a" },
		{ from = "a",         to = "innerMost" },
		{ from = "innerMost", to = "b" },
		{ from = "b",         to = "__leave", condition = function() return InputHandler:wasTriggered(Key.A) end },
		{ from = "b",         to = "__leave", condition = function() return InputHandler:wasTriggered(Key.L) end },
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "A" },
	{ from = "A", to = "B(fsm)", condition = function() return InputHandler:wasTriggered(Key.B) end },
	{ from = "B(fsm)", to = "A", condition = function() return InputHandler:wasTriggered(Key.A) end },
	{ from = "B(fsm)", to = "__leave", condition = function() return InputHandler:wasTriggered(Key.L) end },
}

-- // strip-replace "StateMachineImpl"

-- TODO insert state machine code here
-- You can find out how to create state machines in the lua documentation.

-- // strip-end "StateMachineImpl"

logMessage("Finished initializing state_machine.lua")
