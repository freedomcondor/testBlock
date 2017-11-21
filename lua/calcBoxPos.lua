--Vec3 = require("Vector3")

function calcBoxPos(pos)
	--[[
		calcBoxPos calculate the pos of the boxes from pos of tags

		pos has : {
						n
						halfBox = half the length of each side of the box
						1 = {	rotation = {x,y,z}	the direction vector
								translation			the location vector
								quaternion			the quaternion 
							}
						2
						3...
					}
		returns boxes
					{
						n
						1 = {rotation,translation,quaternion}
							-- currently average
						2
						3
					}
	--]]
	local halfBox = pos.halfBox
	local boxcenters = {n = pos.n}
	for i = 1, pos.n do
		boxcenters[i] = pos[i].translation - halfBox * (pos[i].rotation:nor())
	end

	local boxes = {n = 0}
	--[[
		boxes is supposed to have 
			= {	n
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
	for i = 1, pos.n do
		-- go through all the tags, focal tag is boxcenters[i]
		j = 1; flag = 0 
		while j <= boxes.n do
			-- go through all the known boxes
			dis = boxes[j].average - boxcenters[i]	
			if (dis:len() < halfBox) then								-- the threshold
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
			-- it mean this tag does not belong to any known boxes, create a new one
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

	return boxes
end
