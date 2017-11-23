Vec3 = require("Vector3")
Qua = require("Quaternion")

function calcBoxPos(pos)
	--[[
		calcBoxPos calculate the pos of the boxes from pos of tags

		pos contains tags information
			  has : {
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
		-- boxcenters is the boxcenter for every tag

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
			-- it means this tag does not belong to any known boxes, create a new one
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
		-- go through all the boxes, calc rotation and quaternion
		calcRotation(boxes[i],pos,halfBox)
	end
	--]]

	return boxes
end

function calcRotation(box,tags,halfBox)
	--[[ box mean the box to be calculated
		nTags = x
		average = <vector>
		rotation = <vector>
		quaternion = <quaternion>
		1 = tag No. x
		2 = tag No. x
	--]]
	--tags is all the tags
	if (box.nTags == 1) then
		box.rotation = tags[box[1]].rotation
		box.quaternion = tags[box[1]].quaternion
		box.translation = box.average
	elseif (box.nTags == 2) then
		local vec1 = halfBox * (tags[box[1]].rotation:nor())
		local vec2 = halfBox * (tags[box[2]].rotation:nor())
		local vec = vec1 + vec2
		local side = halfBox * (vec1 * vec2):nor()

		box.quaternion = Qua:createFrom4Vecs(Vec3:create(halfBox,0,halfBox),Vec3:create(0,1,0),
											 vec,				side)
		box.rotation = Vec3:create(0,0,1):rotatedby(box.quaternion)
	elseif (box.nTags == 3) then
		local vec1 = halfBox * (tags[box[1]].rotation:nor())
		local vec2 = halfBox * (tags[box[2]].rotation:nor())
		local vec3 = halfBox * (tags[box[3]].rotation:nor())
	else
		print("that is incredible! you can see more than 3 dimension!")
	end
end
