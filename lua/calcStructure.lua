Vec3 = require("Vector3")

function calcStructure(boxes)
	--[[
		boxes has
		{
			halfBox
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
	local halfBox = boxes.halfBox

	local structures = {n = 0}
	for i = 1,boxes.n do
		-- go through all known structures
		j = 1; flag = 0
		while j <= structures.n do
								--print("structure[",j,"]",".nBoxes",structures[j].nBoxes)
			for k = 1,structures[j].nBoxes do
			-- for box j of structure i, go through all its boxes
				disVec = structures[j][k].translation - boxes[i].translation
				dis = disVec:len()
				err = halfBox * 0.3
				if dis < halfBox * 2 + err and dis > halfBox * 2 - err then
					-- means this box (boxes[i]) belongs to this structure (structure[j])
					structures[j].nBoxes = structures[j].nBoxes + 1
					structures[j][structures[j].nBoxes] = boxes[i]

					flag = 1
					break
				end
				if flag == 1 then break end
			end
			j = j + 1
		end
		if flag == 0 then
			-- this box does not belong to any known structures
			structures.n = structures.n + 1
			structures[structures.n] = {nBoxes = 1}
			structures[structures.n][1] = boxes[i]
		end
	end
	return structures
end
