package.cpath = package.cpath .. ';../lua/solvepnp/build/?.so'
package.cpath = package.cpath .. ';../../lua/solvepnp/build/?.so'
require("libsolvepnp")

package.path = package.path .. ';../lua/?.lua'
package.path = package.path .. ';../../lua/?.lua'
local Vec3 = require("Vector3")
local Qua = require("Quaternion")

function calTagPos(tag)
	--for i = 1,4 do
	--	print("\t\ttagcorner",i,"x = ",tag.corners[i].x,"y = ",tag.corners[i].y) end

	res = libsolvepnp.solvepnp(tag.corners)
		--[[
			res has: 	translation x,y,z
						rotation x,y,z which is solvepnp returns

						rotation x,y,z means: x^2 + y^2 + z^2 = th
						and the (x,y,z)/th is the normalization axis

			-- expecting right hand (from z look down, x to y is counter-clock)
				-- but opencv is left hand, left to right should be converted in lua libsolvepnp
		--]]

	x = res.translation.x
	y = res.translation.y
	z = res.translation.z
	res.translation = Vec3:create(x,y,z)

	local dir = Vec3:create(0,0,1)

	x = res.rotation.x
	y = res.rotation.y
	z = res.rotation.z
	th = math.sqrt(x * x + y * y + z * z)
	rotqq = Qua:createFromRotation(x,y,z,th)

	--[[
	res.quaternion = {}
	res.quaternion.x = x/th
	res.quaternion.y = y/th
	res.quaternion.z = z/th
	res.quaternion.th = th
	--]]

	---[[
	res.quaternion = {}
	res.quaternion.x = rotqq.v.x
	res.quaternion.y = rotqq.v.y
	res.quaternion.z = rotqq.v.z
	res.quaternion.w = rotqq.w
	--]]

	--[[
	--print(math.sin(0.5 * math.pi))
	a = x / th
	b = y / th
	c = z / th
	d = math.cos(th/2)
	-- print(a * a + b * b + c * c)  -- should be 1
 	a = a * math.sin(th/2)
 	b = b * math.sin(th/2)
 	c = c * math.sin(th/2)
	rotq = Qua:create(a,b,c,d)
	--]]

	--dir = dir:rotate(rotq)
	dir = dir:rotatedby(rotqq)
		-- dir is a vector

	res.rotation = dir
	--[[
	res.rotation.x = 2 * (a * c + b * d)
	res.rotation.y = 2 * (b * c - a * d)
	res.rotation.z = 1 - 2 * (a * a + b * b)
	--]]

	--[[
	print("\t\tin lua result: ",res.rotation.x)
	print("\t\tin lua result: ",res.rotation.y)
	print("\t\tin lua result: ",res.rotation.z)
	print("\t\tin lua result: ",res.translation.x)
	print("\t\tin lua result: ",res.translation.y)
	print("\t\tin lua result: ",res.translation.z)
	--]]
	return res
end
