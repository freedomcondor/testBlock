package.cpath = package.cpath .. ';../lua/solvepnp/build/?.so'		-- for opengl testbench
package.cpath = package.cpath .. ';../../lua/solvepnp/build/?.so'	-- for argos testbench
require("libsolvepnp")
require("solveSquare2")

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
	res_cv = libsolvepnp.solvepnp(tag.corners)
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

	--  transform res_cv.xyz into resCV.translation<a vector>
	local x = res_cv.translation.x
	local y = res_cv.translation.y
	local z = res_cv.translation.z
	local resCV = {}
	resCV.translation = Vec3:create(x,y,z)


	-- scale
	scale = 1
	resCV.translation = resCV.translation * scale
	resSqu.translation = resSqu.translation * scale


	--  transform res_cv.rotation.xyz into resCV.rotation and quaternion <a vector><a quaternion>
	x = res_cv.rotation.x
	y = res_cv.rotation.y
	z = res_cv.rotation.z
	local th = math.sqrt(x * x + y * y + z * z)
	local rotqq = Qua:createFromRotation(x,y,z,th)

	--print("CV's rotation axis",x/th,y/th,z/th)
	--print("Squ's rotation axis",resSqu.rotation)

	resCV.quaternion = rotqq
	-- because quaternion has q.v.x q.v.y q.v.z and q.w, need to generate q.x q.y q.z
	resCV.quaternion.x = rotqq.v.x
	resCV.quaternion.y = rotqq.v.y
	resCV.quaternion.z = rotqq.v.z

	resSqu.quaternion.x = resSqu.quaternion.v.x
	resSqu.quaternion.y = resSqu.quaternion.v.y
	resSqu.quaternion.z = resSqu.quaternion.v.z

	-- generate rotation direct
	local dir = Vec3:create(0,0,1)
	local dirCV = dir:rotatedby(resCV.quaternion)
	--local dirSqu = dir:rotatedby(resSqu.quaternion)
		-- dir is a vector

	resCV.rotation = dirCV
	--resSqu.rotation = dirSqu

	---[[ print check the location
	print("solvepnp res loc:",resCV.translation)
	print("solveSqu res loc:",resSqu.translation)
	print("ss")
	--]]

	--[[ print check the quaternion
	print("solvepnp res qua:",resCV.quaternion)
	print("solveSqu res qua:",resSqu.quaternion)

	print("solvepnp res dire:",resCV.rotation)
	print("solveSqu res dire:",resSqu.rotation)
	--]]

	--[[
	print("\t\tin lua result: ",res.rotation.x)
	print("\t\tin lua result: ",res.rotation.y)
	print("\t\tin lua result: ",res.rotation.z)
	print("\t\tin lua result: ",res.translation.x)
	print("\t\tin lua result: ",res.translation.y)
	print("\t\tin lua result: ",res.translation.z)
	--]]
	--return resCV
	resSqu.quaternion = resCV.quaternion
	return resSqu

	--return resCV
end
