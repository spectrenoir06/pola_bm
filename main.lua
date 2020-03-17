-- local socket = require("socket")
local qrencode = require("lib/qrcode/qrencode")
local GPIO = require('periphery').GPIO

local photo_pin = 24
local print_pin = 23

function setGpio()
	button_photo = GPIO(photo_pin, "in")
	GPIO(photo_pin, "out"):write(true)

	button_print = GPIO(print_pin, "in")
	GPIO(print_pin, "out"):write(true)
end

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

function takephoto(nb)
	print("take photo", nb)
	os.execute("raspistill -vf -hf -n -t 1 -o "..love.filesystem.getSaveDirectory().."/photo/"..nb..".jpeg")
	os.execute("raspistill -vf -hf -n -t 1 -w 512 -h 384 -o "..love.filesystem.getSaveDirectory().."/low/"..nb..".jpeg")
	print("end")
	setGpio()
end

function printphoto(nb)
	print("render")
	local photo = love.graphics.newImage("low/"..nb..".jpeg")
	--render = love.graphics.newCanvas(512, 384*1.5)
	love.graphics.setCanvas(render)
		love.graphics.clear(1,1,1,1)
		love.graphics.setColor(1,1,1,1)
		--love.graphics.rectangle("fill", 0, 0, 512, 384*1.5)
		print(photo:getDimensions())
		love.graphics.draw(photo, 0, 0)
		love.graphics.draw(dusty, 0, 384)
		qr_code(512/2+60, 390, 340/2, "dustyfrogz.fr/photo_2020/"..nb..".jpeg")
	love.graphics.setCanvas()
	print("save")
	render:newImageData():encode("png", "pola/"..nb..".png")
	print("print")
	os.execute("cat "..love.filesystem.getSaveDirectory().."/pola/"..nb..".png | lp")
	print("end")
	setGpio()
end

function love.load(arg)
	love.filesystem.createDirectory("pola")
	love.filesystem.createDirectory("photo")
	love.filesystem.createDirectory("low")

	local nb = #love.filesystem.getDirectoryItems("photo")
	print("photo", nb)

	render = love.graphics.newCanvas(512, 384*1.5)
	dusty = love.graphics.newImage("dusty.png")

	setGpio()
end

function love.draw()
	-- love.graphics.draw(render,0,0)
end

function love.update(dt)
	-- print(button_photo)
	-- print(button_photo:read())
	if not button_photo:read() then
		local nb = #love.filesystem.getDirectoryItems("photo")
		takephoto(nb)
		printphoto(nb)
	elseif not button_print:read() then
		local nb = #love.filesystem.getDirectoryItems("photo")
		printphoto(nb)
	end
end

function love.keypressed( key, scancode, isrepeat )
	print(key)
	if key == "space" then
		local nb = #love.filesystem.getDirectoryItems("photo")
		takephoto(nb)
	end
	if key == "p" then
		local nb = #love.filesystem.getDirectoryItems("photo")
		takephoto(nb)
		printphoto(nb)
	end
end
