package.cpath = package.cpath .. ';../lua/solvepnp/build/?.so'		-- for opengl testbench
package.cpath = package.cpath .. ';../../lua/solvepnp/build/?.so'	-- for argos testbench
require("libsolvepnp")
require("solveSquare")

package.path = package.path .. ';../lua/?.lua'		-- for opengl testbench
package.path = package.path .. ';../../lua/?.lua'	-- for argos testbench
local Vec3 = require("Vector3")
local Qua = require("Quaternion")

function calTagPos(tag)
	-- tag is the information for a single tag, has:
		-- halfL = <a number>, the halfL of the box
		-- center = {x = xx, y = xx}
		-- corners = {
		--				1 = {x = xx, y = xx}
		--				2 = {x = xx, y = xx}
		--			}

	--for i = 1,4 do
	--	print("\t\ttagcorner",i,"x = ",tag.corners[i].x,"y = ",tag.corners[i].y) end

	tag.corners.halfL = tag.halfL;
	res = libsolvepnp.solvepnp(tag.corners)
	resSqu = solveSquare(	tag.corners,
							tag.halfL * 2,
							{883.9614,883.9614,319.5000,179.5000},
							{0.018433,0.16727,0,0,-1.548088})

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

	---[[
	print("solvepnp res loc:",res.translation)
	print("solveSqu res loc:",resSqu.translation)
	--res.translation = resSqu.translation
	--]]

	scale = 1
	res.translation = res.translation * scale

	local dir = Vec3:create(0,0,1)

	x = res.rotation.x
	y = res.rotation.y
	z = res.rotation.z
	th = math.sqrt(x * x + y * y + z * z)
	rotqq = Qua:createFromRotation(x,y,z,th)

	res.quaternion = {}
	res.quaternion.x = rotqq.v.x
	res.quaternion.y = rotqq.v.y
	res.quaternion.z = rotqq.v.z
	res.quaternion.w = rotqq.w

	dir = dir:rotatedby(rotqq)
		-- dir is a vector

	res.rotation = dir

	--------------------------
	res.rotation = resSqu.translation

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
