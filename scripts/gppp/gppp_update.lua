print("running updates")


function nextGUID()
	local guid_string = tostring(guid)
	guid = guid + 1
	return guid_string
end


function defaultUpdate(updateData)

	local elapsedTime = updateData:getElapsedTime() / 1000.0

	return EventResult.Handled
end