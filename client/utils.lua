function dxDrawTextOnPosition(x, y, z, text,height,distance,R,G,B,alpha,size,font,...)
	local x2, y2, z2 = getCameraMatrix()
	distance = distance or 9999
	height = height or 1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawText(
					text,
					sx+2, 
					sy+2, 
					sx,
					sy, 
					tocolor(R or 255, G or 255, B or 255, alpha or 255), 
					(size or 1)-(distanceBetweenPoints / distance), 
					font or "arial", 
					"center", 
					"center",
					false,
					false,
					false,
					true		-- color coded
				)
			end
		end
	end
end

