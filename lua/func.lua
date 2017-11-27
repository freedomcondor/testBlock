luaPath_gl = ';../lua/'
luaPath_ar = ';../../lua/'

luaPath = '?.lua'
solvepnpPath = 'solvepnp/build/?.so'
solveSquPath = 'solveSqu/?.lua'
mathPath = 'math/?.lua'

package.path = package.path .. luaPath_gl .. luaPath
package.cpath = package.cpath .. luaPath_gl .. solvepnpPath
package.path = package.path .. luaPath_gl .. solveSquPath
package.path = package.path .. luaPath_gl .. mathPath

package.path = package.path .. luaPath_ar .. luaPath
package.cpath = package.cpath .. luaPath_ar .. solvepnpPath
package.path = package.path .. luaPath_ar .. solveSquPath
package.path = package.path .. luaPath_ar .. mathPath

require("calcTagPos")
require("calcBoxPos")
require("calcStructure")
Vec3 = require("Vector3")

--[[
for every frame, build a taglist, which is a table, to lua
taglist, as the para of func
{
	timestamp = xxx
	n = <a number> the number of tags
	1 = <a table> which is a tag
	    {
   			center = {x = **, y = **}
			corner = <a table>
					{
						1 = {x = **, y = **}
						2
						3
						4
					}
		}
	2
	3
	4
	...
}
--]]

function func(tagList)
	--[[
	-- tagList has:
		{
			n
			1 = {center = {x,y}
				 corners = {1 = {x,y}
							2 = {x,y}
							3 = {x,y}
							4 = {x,y}
							}
				}
			2 = {}
			3 = {}
		}
	--]]

									--[[ -- for testing tagList
										print(a.timestamp)
										print(a.n)
										for i = 1, a.n do
											print("\ttag ",i,":")
											print("\tcenter.x",a[i].center.x)
											print("\tcenter.y",a[i].center.y)
											for j = 1,4 do
												print("\t\tcorner ",j,":")
												print("\t\tx",a[i].corners[j].x)
												print("\t\ty",a[i].corners[j].y)
											end
										end
									--]]

	local halfTag = 0.012
	local halfBox = 0.0275
		-- expected unit is meter

	-- Calc position of tags ------------------------------------
	--print("tagList got:",tagList.n,"tags")

	local pos = {n = tagList.n}
	for i = 1, tagList.n do
									--print("\tfor the",i,"tag")

		tagList[i].halfL = halfTag
		pos[i] = calTagPos(tagList[i])
			-- calTagPos returns a table (for each tag)
				-- {rotation = {x=,y=,z=}  <a vector> the direction vector of the tag, 
					-- seems to point outside the box
				--	translation = {x=,y=,z=} <a vector> the position of the the tag
				--	quaternion = {x,y,z,w} <a quaternion> the quaternion rotation of the tag
				-- }
									--print("length",pos[i].translation:len())
									--print("translation:",pos[i].translation)
									--print("rotation:",pos[i].rotation)
	end
	--[[
		-- pos have
		pos.n
		pos[1] = {rotation.x/y/z, translation.x/y/z, quaternion x,y,z,w}
	--]]

	-- Calc postion of boxes ----------------------------------
	pos.halfBox = halfBox
	boxes = calcBoxPos(pos)
									--print("boxes n : ",boxes.n)
	--[[
		boxes has
		{
			n
			1 = {
					translation
					rotation
					quaternion
					average

					nTags
					1 = <atag> {translation, rotation, quaternion}
					2
				}
		}
	--]]

	-- Calc structure ?
	boxes.halfBox = halfBox
	structures = calcStructure(boxes)

									print("structures n : ",structures.n)

	return {tags = pos,boxes = boxes}
end
