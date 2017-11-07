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

function func(tagList)
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

	--print("tagList got:",tagList.n,"tags")
	pos = {n = tagList.n}
	for i = 1, tagList.n do
		--print("\tfor the",i,"tag")

		tagList[i].halfL = 5
		pos[i] = calTagPos(tagList[i])
			-- calTagPos returns a table (for each tag)
				-- {rotation = {x=,y=,z=}  the direction vector of the tag
				--	translation = {x=,y=,z=} the position of the the tag
				--	quaternion = {x,y,z,w}  the quaternion rotation of the tag
				-- }
	end

	--[[ -- for testing pos(calTagPos returns)
	print(pos.n)
	if pos.n ~= 0 then
		print(pos[1].rotation.x)
		print(pos[1].quaternion.w)
	end
	--]]

	return pos
	--[[
		-- pos have
		pos.n
		pos[1] = {rotation.x/y/z, translation.x/y/z, quaternion x,y,z,w}
	--]]
end
