
function debugBreak(message)
	Scripting:_debugBreak(message or "")
end

function DebugRenderer:drawArrow(startPoint, endPoint, color)
	DebugRenderer:_drawArrow(startPoint, endPoint, color or Color(1,1,1,1))
end

function DebugRenderer:drawLine3D(startPoint, endPoint, color)
	DebugRenderer:_drawLine3D(startPoint, endPoint, color or Color(1,1,1,1))
end

function DebugRenderer:drawLine2D(startPoint, endPoint, color)
	DebugRenderer:_drawLine2D(startPoint, endPoint, color or Color(1,1,1,1))
end

function DebugRenderer:printText(position, text, color)
	DebugRenderer:_printText2D(position, text, color or Color(1,1,1,1))
end

function DebugRenderer:printText3D(position, text, color)
	DebugRenderer:_printText3D(position, text, color or Color(1,1,1,1))
end

function DebugRenderer:drawBox(min, max, color)
	DebugRenderer:_drawBox(min, max, color or Color(1,1,1,1))
end