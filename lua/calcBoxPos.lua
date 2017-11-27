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
					1 = {	average = <vector>
							rotation = <vector>
							quaternion = <quaternion>

							nTags = x
							1 = tag = {translation, rotation, qua}
							2 = tag
						}
				}
	--]]
	local dis
	local flag
	for i = 1, pos.n do
		-- go through all the tags, focal tag is boxcenters[i]
		-- j should have a local?
		j = 1; flag = 0 
		while j <= boxes.n do
			-- go through all the known boxes
			dis = boxes[j].average - boxcenters[i]	
			if (dis:len() < halfBox) then								-- the threshold
				-- it mean this tag belongs to a known box, boxes[j]
				boxes[j].average = 	(boxes[j].average * boxes[j].nTags + boxcenters[i]) / 
									(boxes[j].nTags + 1)
				boxes[j].nTags = boxes[j].nTags + 1
				boxes[j][boxes[j].nTags] = pos[i]

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
								--rotation = pos[i].rotation,
								--quaternion = pos[i].quaternion,
								--translation = boxcenters[i] * 2 - pos[i].translation,
							 }
			boxes[boxes.n][1] = pos[i]
		end
	end

	---[[
	for i = 1, boxes.n do
		-- go through all the boxes, calc rotation and quaternion
		calcRotation(boxes[i],pos,halfBox)
		--print("rotation, = ",boxes[i].rotation)
		--print("quaternion = ",boxes[i].quaternion)
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
	box.translation = box.average

	--if (box.nTags == 1) then
	if (box.nTags == 1) or (box.nTags == 2) or (box.nTags == 3)then
													--print("tags = 1")
		box.rotation = box[1].rotation
		box.quaternion = box[1].quaternion
	elseif (box.nTags == 2) then
													--print("tags = 2")
		local vec1 = box[1].rotation:nor()
		local vec2 = box[2].rotation:nor()
		local vec = (vec1 + vec2):nor()
		local side = (vec1 * vec2):nor()

										--print("middle, check",vec ^ side)
		voc_o = Vec3:create(1,1,0)
		side_o = Vec3:create(0,0,1)
		box.quaternion = Qua:createFrom4Vecs(voc_o,side_o,vec,side)
										--print("quaternion",box.quaternion)
		box.rotation = Vec3:create(0,0,1):rotatedby(box.quaternion)
													--print("tags = 2 end")
	elseif (box.nTags == 3) then
		local vec1 = box[1].rotation:nor()
		local vec2 = box[2].rotation:nor()
		local vec3 = box[3].rotation:nor()
		local vec = (vec1 + vec2 + vec3):nor()
		local side = (vec1 * vec2):nor()
		box.quaternion = Qua:createFrom4Vecs(Vec3:create(1,1,1),Vec3:create(0,0,1),
											 vec,				side)
		box.rotation = Vec3:create(0,0,1):rotatedby(box.quaternion)
	else
		print("that is incredible! you can see more than 3 dimension!")
	end
end
