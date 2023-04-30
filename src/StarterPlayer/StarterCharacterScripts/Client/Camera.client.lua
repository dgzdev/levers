local function clerp(p1,p2,percent)
    local p1x,p1y,p1z,p1R00,p1R01,p1R02,p1R10,p1R11,p1R12,p1R20,p1R21,p1R22 = p1:components()
    local p2x,p2y,p2z,p2R00,p2R01,p2R02,p2R10,p2R11,p2R12,p2R20,p2R21,p2R22 = p2:components()
    return 
        CFrame.new(p1x+percent*(p2x-p1x), p1y+percent*(p2y-p1y) ,p1z+percent*(p2z-p1z),
        (p1R00+percent*(p2R00-p1R00)), (p1R01+percent*(p2R01-p1R01)) ,(p1R02+percent*(p2R02-p1R02)),
        (p1R10+percent*(p2R10-p1R10)), (p1R11+percent*(p2R11-p1R11)) , (p1R12+percent*(p2R12-p1R12)),
        (p1R20+percent*(p2R20-p1R20)), (p1R21+percent*(p2R21-p1R21)) ,(p1R22+percent*(p2R22-p1R22)))
end

local cam = workspace.CurrentCamera
local LastCameraCFrame = cam.CFrame
local rs = game:GetService("RunService").RenderStepped

rs:Connect(function(deltaTime)
    cam.CFrame = clerp(LastCameraCFrame, cam.CFrame, .8)
    LastCameraCFrame = cam.CFrame
end)