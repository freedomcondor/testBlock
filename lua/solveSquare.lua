Vec = require("Vector")
Vec3 = require("Vector3")
Mat = require("Matrix")

function solveSquare(uv,_L,camera,distort)
	--[[
		uv[1] = {x = **, y = **}
		uv[2] = {x = **, y = **}
		uv[3] = {x = **, y = **}
		uv[4] = {x = **, y = **}

		L is a number to the side

		camera is a Matrix3/Matrix, or a {ku,kv,u0,v0}
	--]]

	---------------------- undistort -----------------------------
	-- undistort
		-- to be filled
	if distort ~= nil then
		-- undistort get new uv, new camera
		-- solveSquare(newuv,L,newcamera)
	end

	---------------------- prepare -----------------------------
	local ku,kv,u0,v0
	local u1,v1,u2,v2,u3,v3,u4,v4
	local L = _L 
	local hL = _L / 2

	-- get ku,kv,u0,v0
	if type(camera) == "table" then
		if type(camera[1]) == "table" then
			ku = camera[1][1]
			kv = camera[2][2]
			u0 = camera[1][3]
			v0 = camera[2][3]
		else
			ku = camera[1]
			kv = camera[2]
			u0 = camera[3]
			u0 = camera[4]
		end
	else
		print("camera parameter wrong")
		return nil
	end

	-- get u1v1 to u4v4
	-- assert
	if type(uv) == "table" then
		if type(uv[1]) == "table" then
			u1 = uv[1].x;   v1 = uv[1].y;
			u2 = uv[2].x;   v2 = uv[2].y;
			u3 = uv[3].x;   v3 = uv[3].y;
			u4 = uv[4].x;   v4 = uv[4].y;
		else
			u1 = uv[1];   v1 = uv[2];
			u2 = uv[3];   v2 = uv[4];
			u3 = uv[5];   v3 = uv[6];
			u4 = uv[7];   v4 = uv[8];
		end
	else
		print("camera parameter wrong")
		return nil
	end

	-- assert in case someone is nil
	ku = ku or 1; kv = kv or 1; u0 = u0 or 1; v0 = v0 or 1;
	u1 = u1 or 1; v1 = v1 or 1; u2 = u2 or 1; v2 = v2 or 1;
	u3 = u3 or 1; v3 = v3 or 1; u4 = u4 or 1; v4 = v4 or 1;

	--[[ print check
	print("ku = ",ku); print("kv = ",kv); print("u0 = ",u0); print("v0 = ",v0);
	print("u1 = ",u1); print("v1 = ",v1); print("u2 = ",u2); print("v2 = ",v2);
	print("u3 = ",u3); print("v3 = ",v3); print("u4 = ",u4); print("v4 = ",v4);
	--]]

	----------------------------------------------------------
	-- trick starts
	-- now we have ku kv u0 v0, and u* v*, and L 
	local A = Mat:create(8,8,
		-- 	x		y (z)	a		b		c		p		q		r
		{ {	-ku,	0,		-ku,	0,		u1-u0,	-ku,	0,		u1-u0	},
		  {	0,		-kv,	0,		-kv,	v1-v0,	0,		-kv,	v1-v0	},

		  {	-ku,	0,		-ku,	0,		u2-u0,	ku,		0,	  -(u2-u0)	},
		  {	0,		-kv,	0,		-kv,	v2-v0,	0,		kv,	  -(v2-v0)	},

		  {	-ku,	0,		ku,		0,	  -(u3-u0),	ku,		0,	  -(u3-u0)	},
		  {	0,		-kv,	0,		kv,	  -(v3-v0),	0,		kv,	  -(v3-v0)	},

		  {	-ku,	0,		ku,		0,	  -(u4-u0),	-ku,	0,		u4-u0	},
		  {	0,		-kv,	0,		kv,	  -(v4-v0),	0,		-kv,	v4-v0	},
		})

	A = A:exc(5,8,"col")

	local B = Vec:create(8,{ 
		--	z
			u1-u0,
			v1-v0,
			u2-u0,
			v2-v0,
			u3-u0,
			v3-v0,
			u4-u0,
			v4-v0,
			})
	B = -B
	local AB = A:link(B,"col")
	print("AB=",AB)
	local res1,exc,success = AB:tri()
	local res,exc,success = AB:dia()
	local Ks = res:takeDia()
	local Zs = res:takeVec(9,"col")
	
	---[[ print check A and B
	print("A=",A)
	print("B=",B)
	print("AB=",AB)
	print("res1=",res1)
	print("res=",res)
	print("exc=",exc)
	print("success=",success)
	print("Ks = ",Ks)
	print("Zs = ",Zs)
	--]]

	------------ no solution --------------------
	if success == false then
		-- to be filled
		return nil -- ?
	end
	---------------------------------------------
	local a,b,c,p,q,r,x,y,z

	x = Zs[1] / Ks[1]
	y = Zs[2] / Ks[2]
	a = Zs[3] / Ks[3]
	b = Zs[4] / Ks[4]
	q = Zs[5] / Ks[5]	--c = Zs[5] / Ks[5]
	p = Zs[6] / Ks[6]
	c = Zs[7] / Ks[7]	--q = Zs[7] / Ks[7]
	r = Zs[8] / Ks[8]

	---- 3 constraints ----
	-- a^2 + b^2 + c^2 = hL^2
	local z1 = math.sqrt(hL^2 / (a^2 + b^2 + c^2))
	-- p^2 + q^2 + r^2 = hL^2
	local z2 = math.sqrt(hL^2 / (p^2 + q^2 + r^2))
	-- ap + bq + cr = 0
	local constrain = a*p + b*q + c*r

	-- strict should be 0, maybe better have a check
	z = (z1 + z2) / 2  
		-- or better be sqrt(z1 * z2)? 
		-- need to think of geometric significance
	x = x * z
	y = y * z
	a = a * z
	b = b * z
	c = c * z
	p = p * z
	q = q * z
	r = r * z

	local loc = Vec3:create(-x,y,z)
	local abc = Vec3:create(-a,b,c)
	local pqr = Vec3:create(-p,q,r)

	---[[ print check
	print("z1 = ",z1)
	print("z2 = ",z2)
	print("constrain = ",constrain)

	print("loc = ",loc)
	print("abc = ",abc,"len = ",abc:len())
	print("pqr = ",pqr,"len = ",pqr:len())
	--]]
	local dir = abc * pqr

	return {translation = loc, rotation = dir, quaternion = dir}
end
