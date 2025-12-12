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

function Library:CreateWindow(Config)
	local HubName = Config.Name or "Hub"
	local IconAsset = Config.Icon or "rbxassetid://0"
	local MinimizeIcon = Config.MinimizeIcon or IconAsset

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = HubName .. "UI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 240, 0, 300)
	MainFrame.Position = UDim2.new(0.5, -120, 0.5, -150)
	MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	MainFrame.BorderSizePixel = 0
	MainFrame.Active = true
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(255, 70, 130)
	MainStroke.Thickness = 2
	MainStroke.Transparency = 0.3
	MainStroke.Parent = MainFrame

	local GradientOverlay = Instance.new("Frame")
	GradientOverlay.Name = "GradientOverlay"
	GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
	GradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GradientOverlay.BackgroundTransparency = 0.95
	GradientOverlay.BorderSizePixel = 0
	GradientOverlay.Parent = MainFrame

	local GradientColor = Instance.new("UIGradient")
	GradientColor.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 150)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
	}
	GradientColor.Rotation = 45
	GradientColor.Parent = GradientOverlay

	local OverlayCorner = Instance.new("UICorner")
	OverlayCorner.CornerRadius = UDim.new(0, 12)
	OverlayCorner.Parent = GradientOverlay

	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Header.BorderSizePixel = 0
	Header.Parent = MainFrame

	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 12)
	HeaderCorner.Parent = Header

	local HeaderDivider = Instance.new("Frame")
	HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
	HeaderDivider.Position = UDim2.new(0, 0, 1, 0)
	HeaderDivider.BackgroundColor3 = Color3.fromRGB(255, 70, 130)
	HeaderDivider.BackgroundTransparency = 0.5
	HeaderDivider.BorderSizePixel = 0
	HeaderDivider.Parent = Header

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 40, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = HubName
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Header

	local IconImage = Instance.new("ImageLabel")
	IconImage.Name = "Icon"
	IconImage.Size = UDim2.new(0, 24, 0, 24)
	IconImage.Position = UDim2.new(0, 10, 0.5, -12)
	IconImage.BackgroundTransparency = 1
	IconImage.Image = IconAsset
	IconImage.ImageColor3 = Color3.fromRGB(255, 70, 130)
	IconImage.Parent = Header

	MakeDraggable(Header, MainFrame)

	local ScrollContainer = Instance.new("ScrollingFrame")
	ScrollContainer.Name = "Container"
	ScrollContainer.Size = UDim2.new(1, 0, 1, -45)
	ScrollContainer.Position = UDim2.new(0, 0, 0, 45)
	ScrollContainer.BackgroundTransparency = 1
	ScrollContainer.BorderSizePixel = 0
	ScrollContainer.ScrollBarThickness = 3
	ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 130)
	ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollContainer.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = ScrollContainer
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 8)
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 5)
	Padding.PaddingBottom = UDim.new(0, 5)
	Padding.Parent = ScrollContainer

	local ToggleIcon = Instance.new("ImageButton")
	ToggleIcon.Name = "OpenButton"
	ToggleIcon.Size = UDim2.new(0, 50, 0, 50)
	ToggleIcon.Position = UDim2.new(0, 20, 0.5, 0)
	ToggleIcon.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	ToggleIcon.Image = MinimizeIcon
	ToggleIcon.ImageColor3 = Color3.fromRGB(255, 70, 130)
	ToggleIcon.Parent = ScreenGui
	ToggleIcon.Active = true
	ToggleIcon.Draggable = true

	local OpenCorner = Instance.new("UICorner")
	OpenCorner.CornerRadius = UDim.new(0, 12)
	OpenCorner.Parent = ToggleIcon

	local OpenStroke = Instance.new("UIStroke")
	OpenStroke.Color = Color3.fromRGB(255, 70, 130)
	OpenStroke.Thickness = 2
	OpenStroke.Transparency = 0.3
	OpenStroke.Parent = ToggleIcon

	ToggleIcon.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
	end)

	local Window = {}

	function Window:CreateToggle(Text, Callback)
		Callback = Callback or function() end

		local ToggleBtn = Instance.new("TextButton")
		ToggleBtn.Size = UDim2.new(0, 200, 0, 38)
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		ToggleBtn.Text = ""
		ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		ToggleBtn.Font = Enum.Font.GothamSemibold
		ToggleBtn.TextSize = 14
		ToggleBtn.AutoButtonColor = false
		ToggleBtn.Parent = ScrollContainer

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 10)
		BtnCorner.Parent = ToggleBtn

		local BtnStroke = Instance.new("UIStroke")
		BtnStroke.Color = Color3.fromRGB(40, 40, 40)
		BtnStroke.Thickness = 1
		BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		BtnStroke.Parent = ToggleBtn

		local Label = Instance.new("TextLabel")
		Label.Text = Text
		Label.Font = Enum.Font.GothamMedium
		Label.TextSize = 13
		Label.TextColor3 = Color3.fromRGB(180, 180, 180)
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(1, -60, 1, 0)
		Label.Position = UDim2.new(0, 12, 0, 0)
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = ToggleBtn

		local CheckBox = Instance.new("Frame")
		CheckBox.Size = UDim2.new(0, 20, 0, 20)
		CheckBox.Position = UDim2.new(1, -32, 0.5, -10)
		CheckBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		CheckBox.BorderSizePixel = 0
		CheckBox.Parent = ToggleBtn

		local CheckBoxCorner = Instance.new("UICorner")
		CheckBoxCorner.CornerRadius = UDim.new(0, 5)
		CheckBoxCorner.Parent = CheckBox

		local CheckBoxStroke = Instance.new("UIStroke")
		CheckBoxStroke.Color = Color3.fromRGB(60, 60, 60)
		CheckBoxStroke.Thickness = 1.5
		CheckBoxStroke.Parent = CheckBox

		local CheckMark = Instance.new("ImageLabel")
		CheckMark.Size = UDim2.new(0, 14, 0, 14)
		CheckMark.Position = UDim2.new(0.5, -7, 0.5, -7)
		CheckMark.BackgroundTransparency = 1
		CheckMark.Image = "rbxassetid://3926305904"
		CheckMark.ImageRectOffset = Vector2.new(312, 4)
		CheckMark.ImageRectSize = Vector2.new(24, 24)
		CheckMark.ImageColor3 = Color3.fromRGB(255, 255, 255)
		CheckMark.ImageTransparency = 1
		CheckMark.Parent = CheckBox

		local toggled = false

		ToggleBtn.MouseButton1Click:Connect(function()
			toggled = not toggled
			
			if toggled then
				TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
				TweenService:Create(BtnStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(255, 70, 130)}):Play()
				TweenService:Create(CheckBox, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 70, 130)}):Play()
				TweenService:Create(CheckBoxStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(255, 100, 150)}):Play()
				TweenService:Create(CheckMark, TweenInfo.new(0.25), {ImageTransparency = 0}):Play()
				TweenService:Create(Label, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			else
				TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
				TweenService:Create(BtnStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(40, 40, 40)}):Play()
				TweenService:Create(CheckBox, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
				TweenService:Create(CheckBoxStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(60, 60, 60)}):Play()
				TweenService:Create(CheckMark, TweenInfo.new(0.25), {ImageTransparency = 1}):Play()
				TweenService:Create(Label, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			end
			
			Callback(toggled)
		end)
	end

	return Window
end

return Library
