function update()
	DebugRenderer:drawLine3D(Vec3(0,0,0), Vec3(100, 100, 100), Color(1,0,0,1))
	DebugRenderer:drawLine3D(Vec3(0,0,0), Vec3(-100, 100, 100))

	DebugRenderer:drawLine2D(Vec2(0,0), Vec2(1,1))
	DebugRenderer:drawLine2D(Vec2(0,0), Vec2(0,1), Color(1,0,0,1))

	DebugRenderer:drawArrow(Vec3(0,0,0), Vec3(100, -100, 100), Color(1,1,0,1))
	DebugRenderer:drawArrow(Vec3(0,0,0), Vec3(-100, 100, -100))

	DebugRenderer:drawBox(Vec3(-10,-10,-10), Vec3(10, 10, 10), Color(0,1,0,1))
	DebugRenderer:drawBox(Vec3(-10,-10,-10), Vec3(20, 20, 20))

	DebugRenderer:printText(Vec2(0,0), 'Text2D colored!', Color(1,0,0,1))
	DebugRenderer:printText(Vec2(0,0.1), 'Text2D default(white)')

	DebugRenderer:printText3D(Vec3(0,0,100), "Text3D colored!", Color(0,0,1,1))
	DebugRenderer:printText3D(Vec3(0,0,150), "Text3D default(white)")
	return EventResult.Handled
end

Events.Update:registerListener(update)