
-- GameScene (backgrounds, road, player)

Scene = Core.class(Sprite)

local rumble_length = 3
local segment_length = 200
local position = 0 -- Camera position
local draw_distance = 80
local road_width = 1200
local field_of_view = 100

local camera_height = 900
local camera_depth = 1 / math.tan((field_of_view/2) * math.pi/180);

-- player position (Y is constant)
local playerX = 0
local playerZ = (camera_height * camera_depth)

local fog_density = 5 --(1-50)
local speed = 150

-- Background, hills and trees
local texture_sky = Texture.new("images/background/sky.png")
local bg_sky = Bitmap.new(texture_sky)

local texture_hills = Texture.new("images/background/hills.png")
local bg_hills = Bitmap.new(texture_hills)

local texture_trees = Texture.new("images/background/trees.png")
local bg_trees = Bitmap.new(texture_trees)

-- Player and cars
local texture_player = Texture.new("images/player_straight.png")

local COLORS = {
  SKY = "0x72D7EE",
  TREE = "0x005108",
  FOG = "0x005108",
  LIGHT = { road = "0x6B6B6B", grass = "0x10AA10", rumble = "0x555555", lane = "0xCCCCCC" },
  DARK = { road = "0x696969", grass = "0x009A00", rumble = "0xBBBBBB" },
  START = { road = "0xffffff", grass = "0xffffff", rumble = "0xffffff" },
  FINISH = { road = "0x000000", grass = "0x000000", rumble = "0x000000" }
}

-- Constructor
function Scene:init()
	self.position = position
	self.road = Sprite.new()
	self:draw_backgrounds()
	self:reset_road()
	self:draw_player()
end

-- Draws backgrounds of the game scene
function Scene:draw_backgrounds()
	self:addChild(bg_sky)
	self:addChild(bg_hills)
	self:addChild(bg_trees)
end

-- Draws player car
function Scene:draw_player()
	
	local player = Bitmap.new(texture_player)
	player:setScale(2)
	local posX = (application:getContentWidth() - player:getWidth()) * 0.5
	local posY = application:getContentHeight() - player:getHeight() - 10
	player:setPosition(posX, posY)
	self.player = player
	self:addChild(player)
end

-- Update player in the scene
function Scene:update_player()

	local player = self.player
	
	if (player and self:contains(player)) then
		self:removeChild(player)
		self:addChild(player)
	end
end

-- Inits road segments
function Scene:reset_road() 
	
	local road_length = 1000 -- For the moment we use this value
	local segments = {}
		
	for n=1, road_length do
		local segment = {}
		segment.index = n
		
		--Create new segment
		local p1 = {}
		p1.world = { z = (n-1) * segment_length}
		p1.camera = {}
		p1.screen = {}
		segment.p1 = p1
		
		local p2 = {}
		p2.world = { z = (n) * segment_length}
		p2.camera = {}
		p2.screen = {}
		segment.p2 = p2
		
		local color = math.floor(n/rumble_length) % 2
		if (color == 0) then
			segment.color = COLORS.DARK
		else
			segment.color = COLORS.LIGHT
		end
		
		segments[n] = segment
	end
		
	self.track_length = segment_length * #segments;
	
	self.segments = segments
	print ("#segments", #segments)
 end

-- Find segment including Z coordinate
function Scene:find_segment(z) 
	
	local segments = self.segments
	local num_segments = #segments
	local index = math.floor(z/segment_length) % num_segments
	
	return segments[index + 1]
end

-- Calculate new position (z value). Speed is a constant
function Scene:increase()
	
	local max = self.track_length
	local new_position = self.position + speed
	
	while (new_position >= max) do
		new_position = new_position - max
	end
	
	while (new_position < 0) do
		new_position = new_position + max
	end
	
	self.position = new_position
end

-- Draws all segments of the road
function Scene:draw_road()
	
	local position = self.position
	local road_width = road_width
	local old_road = self.road
	
	-- Redraw a new road sprite
	local road = Sprite.new()
	
	local segments = self.segments
	local base_segment = self:find_segment(self.position)
	local maxy = application:getContentHeight()
	local num_segments = #segments
	
	--local t1= os.clock()
	
	local j = 1
	for i = 0, draw_distance -1 do
		local index = (base_segment.index + i) % num_segments
					
		local segment = segments[index + 1]
		local p1 = segment.p1
		local p2 = segment.p2
		
		-- Calculate project of p1 and p2 points that describes a segment
		Utils.project(p1, playerX * road_width, camera_height, position, camera_depth, road_width)
		Utils.project(p2, playerX * road_width, camera_height, position, camera_depth, road_width)
			
		--print ("camera_depth ", camera_depth)
				
		if not (segment.p1.camera.z <= camera_depth or -- behind us
			segment.p2.screen.y >= maxy) then       -- clip by (already rendered) segment
	
			--local t1= os.clock()
			--print (j)
			
			local sprite_segment = Segment.new(
							p1.screen.x,
							p1.screen.y,
							p1.screen.w, 
							p2.screen.x,
							p2.screen.y,
							p2.screen.w,
							segment.fog,
							segment.color)
			road:addChild(sprite_segment)
			j = j + 1
			
			maxy = segment.p2.screen.y
			
			--local t2 = os.clock() - t1
			--print (t2)
		end
		
		--print ("i ", i)
		
	end
	
	self:addChild(road)
	
	-- Remove old road
	if (old_road and self:contains(old_road)) then
		self:removeChild(old_road)
	end
	
	self.road = road
	
	--print ("road children ", self.road:getNumChildren()) -- segments
	
	--local t2 = os.clock() - t1
	--print (t2)
end