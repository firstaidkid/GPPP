
settings = {
	video = {
		screenResolution = Vec2u(1280, 720),
		vsyncEnabled = true,
		clearColor = Color(0.0, 0.125, 0.3, 1.0) -- rgba
	},
	lua = {
		maxStackDumpLevel = 2,
		callstackTracebackEnabled = true,
		stackDumpEnabled = true,
	}
}

Settings:load(settings)
