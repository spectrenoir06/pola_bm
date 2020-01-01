
local socket = require("socket")

local qrencode = dofile("lib/qrcode/qrencode.lua")

-- local GPIO = require('periphery').GPIO

-- local gpio_echo = GPIO(27, "in")
-- local gpio_trig = GPIO(17, "out")


function qr_code(x,y,lx,txt)
	local ok, tab_or_message = qrencode.qrcode(txt)
	if not ok then
		print(tab_or_message)
	else
		local s = lx / #tab_or_message
		-- print(#tab_or_message, #tab_or_message[1])
		for k,v in ipairs(tab_or_message) do
			for l,w in ipairs(v) do
				if w > 0 then
					love.graphics.setColor(0,0,0)
				else
					love.graphics.setColor(1,1,1)
				end
				love.graphics.rectangle("fill", x+k*s, y+l*s , s, s)
			end
		end
	end
end

function gen()
	love.graphics.rectangle("fill", 0, 0, 512, 384*1.5)
	print(photo:getDimensions())
	love.graphics.draw(photo, 0, 0)
	love.graphics.draw(dusty, 0, 384)
	qr_code(512/2+60, 390, 340/2, "dustyfrogz.fr/photo_2019/1234.jpeg")
end

function love.load(arg)
	print("start")

	love.filesystem.createDirectory("pola")
	love.filesystem.createDirectory("photo")
	love.filesystem.createDirectory("low")


	local list = love.filesystem.getDirectoryItems("photo")
	for k,v in ipairs(list) do
		print(k, v)
	end
	print("photo")
	os.execute("raspistill -n -t 1 -o "..love.filesystem.getSaveDirectory().."/photo/"..#list..".jpeg")
	os.execute("raspistill -n -t 1 -w 512 -h 384 -o "..love.filesystem.getSaveDirectory().."/low/"..#list..".jpeg")

	render = love.graphics.newCanvas(512, 384*1.5)

	photo = love.graphics.newImage("low/"..#list..".jpeg")
	dusty = love.graphics.newImage("dusty.png")

	print("render")
	love.graphics.setCanvas(render)
		gen()
	love.graphics.setCanvas()
	print("save")
	render:newImageData():encode("png", "pola/"..#list..".png")
	print("end")

end

function love.draw()
	love.graphics.draw(render,0,0)
end

function love.update(dt)

end


function love.keypressed( key, scancode, isrepeat )

end
