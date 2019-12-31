
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
		print(#tab_or_message, #tab_or_message[1])
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
	love.graphics.draw(photo, 0, 0)
	love.graphics.draw(dusty, 0, 384)
	qr_code(512/2+60, 390, 340/2, "dustyfrogz.fr/photo_2019/1234.jpeg")
end

function love.load(arg)
	render = love.graphics.newCanvas(512, 384*1.5)

	photo = love.graphics.newImage("printer.jpeg")
	dusty = love.graphics.newImage("dusty.png")

	love.graphics.setCanvas(render)
		gen()
	love.graphics.setCanvas()
	render:newImageData():encode("png", "photo_".."0"..".png")
end

function love.draw()
	love.graphics.draw(render,0,0)
end

function love.update(dt)

end


function love.keypressed( key, scancode, isrepeat )

end
