

Utils = {}

local width = application:getContentWidth()
local height = application:getContentHeight()

function Utils.project(p, cameraX, cameraY, cameraZ, camera_depth, road_width)

	local ceil = math.ceil
	
	p.camera.x = (p.world.x or 0) - cameraX
	p.camera.y = (p.world.y or 0) - cameraY
	p.camera.z = (p.world.z or 0) - cameraZ
	
	local scale = camera_depth / p.camera.z
	p.screen.scale = scale
	p.screen.x = ceil((width / 2) + (scale * p.camera.x * width / 2))
	p.screen.y = ceil((height / 2) - (scale * p.camera.y * height / 2))
	p.screen.w = ceil(p.screen.scale * road_width * width/2)
	
end

function Utils.easeIn(a, b, percent)
	local result = a + (b - a) * math.pow(percent, 2)
	
	return result
end

function Utils.easeOut(a, b, percent)

	local result = a + (b - a) * (1- math.pow(1-percent, 2))
	
	return result
end

function Utils.easeInOut(a, b, percent)
	local result = a + (b - a) * ((-math.cos(percent*math.pi)/2) + 0.5)
	
	return result
end

function Utils.percentRemaining(n, total) 
	return (n % total) / total
end

function Utils.interpolate(a, b, percent)
	return a + (b-a)*percent 
end
