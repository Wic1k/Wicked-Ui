local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}

local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(object, TweenInfo.new(0.15), {Position = pos})
		Tween:Play()
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

function Library:CreateWindow(HubName, IconAsset)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = HubName .. "UI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 240, 0, 300)
	MainFrame.Position = UDim2.new(0.5, -120, 0.5, -150)
	MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 15)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(40, 40, 80)
	MainStroke.Thickness = 2
	MainStroke.Parent = MainFrame

	local StarBackground = Instance.new("ImageLabel")
	StarBackground.Name = "Stars"
	StarBackground.Size = UDim2.new(1, 0, 1, 0)
	StarBackground.BackgroundTransparency = 1
	StarBackground.Image = "rbxassetid://252627854"
	StarBackground.ImageTransparency = 0.6
	StarBackground.ScaleType = Enum.ScaleType.Tile
	StarBackground.TileSize = UDim2.new(0, 100, 0, 100)
	StarBackground.Parent = MainFrame

	local StarCorner = Instance.new("UICorner")
	StarCorner.CornerRadius = UDim.new(0, 15)
	StarCorner.Parent = StarBackground

	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundTransparency = 1
	Header.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 40, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = HubName
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Header

	local IconImage = Instance.new("ImageLabel")
	IconImage.Name = "Icon"
	IconImage.Size = UDim2.new(0, 24, 0, 24)
	IconImage.Position = UDim2.new(0, 10, 0.5, -12)
	IconImage.BackgroundTransparency = 1
	IconImage.Image = IconAsset or "rbxassetid://0"
	IconImage.Parent = Header

	MakeDraggable(Header, MainFrame)

	local ScrollContainer = Instance.new("ScrollingFrame")
	ScrollContainer.Name = "Container"
	ScrollContainer.Size = UDim2.new(1, 0, 1, -45)
	ScrollContainer.Position = UDim2.new(0, 0, 0, 45)
	ScrollContainer.BackgroundTransparency = 1
	ScrollContainer.BorderSizePixel = 0
	ScrollContainer.ScrollBarThickness = 4
	ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 150)
	ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollContainer.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = ScrollContainer
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 6)
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 5)
	Padding.PaddingBottom = UDim.new(0, 5)
	Padding.Parent = ScrollContainer

	local ToggleIcon = Instance.new("ImageButton")
	ToggleIcon.Name = "OpenButton"
	ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
	ToggleIcon.Position = UDim2.new(0, 20, 0.5, 0)
	ToggleIcon.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
	ToggleIcon.Image = IconAsset or "rbxassetid://0"
	ToggleIcon.Parent = ScreenGui
	ToggleIcon.Active = true
	ToggleIcon.Draggable = true

	local OpenCorner = Instance.new("UICorner")
	OpenCorner.CornerRadius = UDim.new(0, 12)
	OpenCorner.Parent = ToggleIcon

	local OpenStroke = Instance.new("UIStroke")
	OpenStroke.Color = Color3.fromRGB(100, 100, 200)
	OpenStroke.Thickness = 2
	OpenStroke.Parent = ToggleIcon

	ToggleIcon.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
	end)

	local Window = {}

	function Window:CreateToggle(Text, Callback)
		Callback = Callback or function() end

		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(0, 200, 0, 38)
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleBtn.Text = ""
		ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		ToggleBtn.Font = Enum.Font.GothamSemibold
		ToggleBtn.TextSize = 14
		ToggleBtn.AutoButtonColor = false
		ToggleBtn.Parent = ScrollContainer

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 8)
		BtnCorner.Parent = ToggleBtn

		local BtnStroke = Instance.new("UIStroke")
		BtnStroke.Color = Color3.fromRGB(60, 60, 100)
		BtnStroke.Thickness = 1
		BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		BtnStroke.Parent = ToggleBtn

		local Label = Instance.new("TextLabel")
		Label.Text = Text
		Label.Font = Enum.Font.GothamMedium
		Label.TextSize = 14
		Label.TextColor3 = Color3.fromRGB(200, 200, 200)
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(1, -60, 1, 0)
		Label.Position = UDim2.new(0, 12, 0, 0)
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = ToggleBtn

		local SwitchBg = Instance.new("Frame")
		SwitchBg.Size = UDim2.new(0, 40, 0, 20)
		SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
		SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
		SwitchBg.BorderSizePixel = 0
		SwitchBg.Parent = ToggleBtn

		local SwitchCorner = Instance.new("UICorner")
		SwitchCorner.CornerRadius = UDim.new(1, 0)
		SwitchCorner.Parent = SwitchBg

		local SwitchDot = Instance.new("Frame")
		SwitchDot.Size = UDim2.new(0, 14, 0, 14)
		SwitchDot.Position = UDim2.new(0, 3, 0.5, -7)
		SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SwitchDot.BorderSizePixel = 0
		SwitchDot.Parent = SwitchBg

		local DotCorner = Instance.new("UICorner")
		DotCorner.CornerRadius = UDim.new(1, 0)
		DotCorner.Parent = SwitchDot

		local toggled = false

		ToggleBtn.MouseButton1Click:Connect(function()
			toggled = not toggled
			
			if toggled then
				TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 80)}):Play()
				TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(100, 255, 150)}):Play()
				TweenService:Create(SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(50, 255, 100)}):Play()
				TweenService:Create(SwitchDot, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			else
				TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 60)}):Play()
				TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 100)}):Play()
				TweenService:Create(SwitchBg, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
				TweenService:Create(SwitchDot, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0.5, -7)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
			end
			
			Callback(toggled)
		end)
	end

	return Window
end

return Library
