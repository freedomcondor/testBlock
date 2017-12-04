Mat = require("Matrix")
Hungarian = require("hungarian")
function trackingTags(tags,tags_seeing,_threshold)
	local threshold = _threshold or 100 -- the unit should be pixel
	local inf = 999999999
	--[[
		{n, 1 2 3 4}
	--]]

	local maxN
	if tags.n > tags_seeing.n then
		maxN = tags.n
	else
		maxN = tags_seeing.n
	end

	--if maxN == 0 then return nil end

	--local C = Mat:create(tags.n,tags_seeing.n)
	local C = Mat:create(maxN,maxN)
	--[[
					tags_seeing.n
		 		* * * * * * * * * * * 
		tags.n 	*					*
			 	*					*
		 		* * * * * * * * * * * 
	--]]

	-- set penalty matrix
	local dis,x1,y1,x2,y2
	for i = 1,tags.n do
		for j = 1,tags_seeing.n do
			dis = 0
			x1 = tags[i].center.x
			y1 = tags[i].center.y
			x2 = tags_seeing[j].center.x
			y2 = tags_seeing[j].center.y
			dis = dis + math.sqrt( (x1-x2)^2 + (y1-y2)^2 ) * 0.2

			for k = 1,4 do
				x1 = tags[i].corners[k].x
				y1 = tags[i].corners[k].y
				x2 = tags_seeing[j].corners[k].x
				y2 = tags_seeing[j].corners[k].y
				dis = dis + math.sqrt( (x1-x2)^2 + (y1-y2)^2 ) * 0.2
					-- 0.25 is weight, center is considered more important than corners
			end
			if dis > threshold then
				C[i][j] = inf
			else
				C[i][j] = dis + 0.1 -- make sure it is not 0
			end
		end
	end

												print("before set hung")
	local hun = Hungarian:create{costMat = C,MAXorMIN = "MIN"}
	hun:aug()
												print("after calc hung")
												print(C)

												--[[
														print("match table X")
														for x = 1,hun.N do
															print("\t",hun.match_of_X[x])
														end
												--]]

	local i = 1
	while i <= tags.n do
	--for i = 1, tags.n do
		-- match existing tags
		-- may have a match
		-- may lost it
		if C[i][hun.match_of_X[i]] > threshold or
		   C[i][hun.match_of_X[i]] == 0 then
			-- lost
			if tags[i].tracking == "lost" then
				tags[i].lostcount = tags[i].lostcount + 1
				if tags[i].lostcount >= 5 then
					-- abandon this
					tags.label[tags[i].label] = nil
					tags[i] = nil
					tags[i] = tags[tags.n]
					--tags[tags.n] = nil
					tags.n = tags.n - 1
					i = i - 1
				end
			else
				tags[i].tracking = "lost"
				tags[i].lostcount = 0
			end
		else
			-- tracking
			tags[i].center.x = tags_seeing[hun.match_of_X[i]].center.x
			tags[i].center.y = tags_seeing[hun.match_of_X[i]].center.y
			for j = 1,4 do
				tags[i].corners[j].x = tags_seeing[hun.match_of_X[i]].corners[j].x
				tags[i].corners[j].y = tags_seeing[hun.match_of_X[i]].corners[j].y
			end
			tags[i].trackcount = tags[i].trackcount + 1
			if tags[i].tracking == "lost" then
				tags[i].tracking = "found"
			else
				tags[i].tracking = "tracking"
			end
		end
		i = i + 1
	end

	for j = 1, tags_seeing.n do
		if C[hun.match_of_Y[j]][j] > threshold or
		   C[hun.match_of_Y[j]][j] == 0 then
			-- new tags
			local i = tags.n + 1
			tags.n = tags.n + 1
			tags[i] = {	center = {x = 0, y = 0}, 
						corners = {{x = 0, y = 0},{x = 0, y = 0},{x = 0, y = 0},{x = 0, y = 0}}
			 		  }
			tags[i].center.x = tags_seeing[j].center.x
			tags[i].center.y = tags_seeing[j].center.y
			for k = 1,4 do
				tags[i].corners[k].x = tags_seeing[j].corners[k].x
				tags[i].corners[k].y = tags_seeing[j].corners[k].y
			end
			tags[i].tracking = "new"
			tags[i].trackcount = 0
	
			local k = 1; while tags.label[k] ~= nil do k = k + 1 end
			tags[i].label = k
			tags.label[k] = true
		end
	end

													---[[
														print("tags.n",tags.n)
														i = 1; local count = 1
														while count <= tags.n do
															for j = 1, tags.n do
																if tags[j].label == i then
														  print("tag:",tags[j].label,tags[j].tracking,tags[j].trackcount)
														  		count = count + 1
														  		end
														    end
															i = i + 1
														end
													--]]

end
