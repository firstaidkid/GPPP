print("running updates")


function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end

function defaultUpdate(updateData)
	local elapsedTime = updateData:getElapsedTime() / 1000.0

	updateLevelCreation(elapsedTime)

	return EventResult.Handled
end

State{
	name = "default",
	parent = "/game/gameRunning",
	eventListeners = {
		enter = { defaultEnter },
		update = { defaultUpdate }
	}
}

StateTransitions{
	parent = "/game/gameRunning",
	{ from = "__enter", to = "default" }
}

StateTransitions{
	parent = "/game",
	{ from = "gameRunning", to = "__leave", condition = function() return bit32.btest(InputHandler:gamepad(0):buttonsPressed(), bit32.bor(Button.Start, Button.Back)) end }
}