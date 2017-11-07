--[[
for every frame, build a taglist, which is a table, to lua
taglist
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

package.path = package.path ..';../lua/?.lua'		-- for opengl testbench
package.path = package.path ..';../../lua/?.lua'	-- for argos testbench
--package.path = package.path ..';loopFunction/?.lua'
require("calcTagPos")
Vec3 = require("Vector3")

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

	-- Calc boxes --------- ------------------------------------

	local boxcenters = {n = tagList.n}
	for i = 1, tagList.n do
		boxcenters[i] = pos[i].translation - halfBox * (pos[i].rotation:nor())
	end

	local boxes = {n = 0}
	--[[
		boxes = {	n
					1 = {	nTags = x
							average = <vector>
							rotation = <vector>
							quaternion = <quaternion>
							1 = tag No. x
							2 = tag No. x
						}
				}
	--]]
	local dis
	local flag
	for i = 1, tagList.n do
		-- go through all the tags, focal tag is boxcenters[i]
		j = 1; flag = 0 
		while j <= boxes.n do
			-- go through all the known boxes
			dis = boxes[j].average - boxcenters[i]
			if (dis:len() < halfBox) then
				-- it mean this tag belongs to a known box, boxes[j]
				boxes[j].average = 	(boxes[j].average * boxes[j].nTags + boxcenters[i]) / 
									(boxes[j].nTags + 1)
				boxes[j].nTags = boxes[j].nTags + 1
				boxes[j][boxes[j].nTags] = i 

				flag = 1
				break
			end
			j = j + 1
		end
		if flag == 0 then
			-- it mean this tag does not belong to any known boxes
			boxes.n = boxes.n + 1
			boxes[boxes.n] = {	nTags = 1, 
								average = boxcenters[i],
								rotation = pos[i].rotation,
								quaternion = pos[i].quaternion,
								translation = boxcenters[i] * 2 - pos[i].translation,
							 }
			boxes[boxes.n][1] = i
		end
	end

	---[[
	for i = 1, boxes.n do
		--boxes[i].translation = boxes[i].average
		--boxes[i].rotation = boxes[i].average
		--boxes[i].quaternion = boxes[i].average
		--print("translation",boxes[i].average)
		--print("rotation",boxes[i].rotation)
		--print("quaternion",boxes[i].quaternion)
	end
	--]]

	--[[ -- for testing pos(calTagPos returns)
	print(pos.n)
	if pos.n ~= 0 then
		print(pos[1].rotation.x)
		print(pos[1].quaternion.w)
	end
	--]]

	return {tags = pos,boxes = boxes}
	--return pos
	--[[
		-- pos have
		pos.n
		pos[1] = {rotation.x/y/z, translation.x/y/z, quaternion x,y,z,w}
	--]]
end
