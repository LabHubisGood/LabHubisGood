local InputService = game:GetService('UserInputService')
local httpService = game:GetService('HttpService')
local TextService = game:GetService('TextService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local LocalPlayer = game:GetService('Players').LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")

local Library = {}

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

local rannun = Random.new():NextNumber(1000000,9999999)
local oldScreenGui = CoreGui:FindFirstChild(rannun)
if oldScreenGui then
	oldScreenGui:Destroy()
end
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = tostring(rannun)
ProtectGui(ScreenGui)

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

local Toggles = {}
local Options = {}

getgenv().Toggles = Toggles
getgenv().Options = Options

local Library = {
	Registry = {},
	RegistryMap = {},
	OpenedFrames = {},
	HudRegistry = {},
	FontColor = Color3.fromRGB(255, 255, 255),
	MainColor = Color3.fromRGB(28, 28, 28),
	BackgroundColor = Color3.fromRGB(20, 20, 20),
	AccentColor = Color3.fromRGB(64, 188, 243),
	OutlineColor = Color3.fromRGB(50, 50, 50),
	Black = Color3.new(0, 0, 0),
	ThemeManager = {},
	Icon = nil
}

function Library:AttemptSave()
	if Library.SaveManager then
		Library.SaveManager:Save();
	end;
end;

function Library:Create(Class, Properties)
	local _Instance = Class;

	if type(Class) == 'string' then
		_Instance = Instance.new(Class);
	end;

	for Property, Value in next, Properties do
		_Instance[Property] = Value;
	end;

	return _Instance;
end;

function Library:CreateLabel(Properties, IsHud)
	local _Instance = Library:Create('TextLabel', {
		BackgroundTransparency = 1;
		Font = Enum.Font.Code;
		TextColor3 = Library.FontColor;
		TextSize = 16;
		TextStrokeTransparency = 0;
	});

	Library:AddToRegistry(_Instance, {
		TextColor3 = 'FontColor';
	}, IsHud);

	return Library:Create(_Instance, Properties);
end;

function Library:GetTextBounds(Text, Font, Size)
	return TextService:GetTextSize(Text, Size, Font, Vector2.new(1920, 1080))
end

function Library:MakeDraggable(Instance, Cutoff)
	Instance.Active = true;

	Instance.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			local ObjPos = Vector2.new(
				Mouse.X - Instance.AbsolutePosition.X,
				Mouse.Y - Instance.AbsolutePosition.Y
			);

			if ObjPos.Y > (Cutoff or 40) then
				return;
			end;

			while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				Instance.Position = UDim2.new(
					0,
					Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
					0,
					Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
				);

				RunService.RenderStepped:Wait();
			end;
		end;
	end);
end;

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
	HighlightInstance.MouseEnter:Connect(function()
		local Reg = Library.RegistryMap[Instance];

		for Property, ColorIdx in next, Properties do
			Instance[Property] = Library[ColorIdx] or ColorIdx;

			if Reg and Reg.Properties[Property] then
				Reg.Properties[Property] = ColorIdx;
			end;
		end;
	end);

	HighlightInstance.MouseLeave:Connect(function()
		local Reg = Library.RegistryMap[Instance];

		for Property, ColorIdx in next, PropertiesDefault do
			Instance[Property] = Library[ColorIdx] or ColorIdx;

			if Reg and Reg.Properties[Property] then
				Reg.Properties[Property] = ColorIdx;
			end;
		end;
	end);
end;

function Library:Notify(Text, Time)
	local XSize, YSize = Library:GetTextBounds(Text, Enum.Font.Code, 14).x,Library:GetTextBounds(Text, Enum.Font.Code, 14).y;

	YSize = YSize + 7

	local NotifyOuter = Library:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 100, 0, 10);
		Size = UDim2.new(0, 0, 0, YSize);
		ClipsDescendants = true;
		ZIndex = 100;
		Parent = Library.NotificationArea;
	});

	local NotifyInner = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor;
		BorderColor3 = Library.OutlineColor;
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 101;
		Parent = NotifyOuter;
	});

	Library:AddToRegistry(NotifyInner, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	}, true);

	local InnerFrame = Library:Create('Frame', {
		BackgroundColor3 = Color3.new(1, 1, 1);
		BorderSizePixel = 0;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		ZIndex = 102;
		Parent = NotifyInner;
	});

	local Gradient = Library:Create('UIGradient', {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
			ColorSequenceKeypoint.new(1, Library.MainColor),
		});
		Rotation = -90;
		Parent = InnerFrame;
	});

	Library:AddToRegistry(Gradient, {
		Color = function()
			return ColorSequence.new({
				ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
				ColorSequenceKeypoint.new(1, Library.MainColor),
			});
		end
	});

	local NotifyLabel = Library:CreateLabel({
		Position = UDim2.new(0, 4, 0, 0);
		Size = UDim2.new(1, -4, 1, 0);
		Text = Text;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextSize = 14;
		ZIndex = 103;
		Parent = InnerFrame;
	});

	local LeftColor = Library:Create('Frame', {
		BackgroundColor3 = Library.AccentColor;
		BorderSizePixel = 0;
		Position = UDim2.new(0, -1, 0, -1);
		Size = UDim2.new(0, 3, 1, 2);
		ZIndex = 104;
		Parent = NotifyOuter;
	});

	Library:AddToRegistry(LeftColor, {
		BackgroundColor3 = 'AccentColor';
	}, true);

	pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);

	task.spawn(function()
		wait(Time or 5);

		pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

		wait(0.4);

		NotifyOuter:Destroy();
	end);
end;

function Library:MouseIsOverOpenedFrame()
	for Frame, _ in next, Library.OpenedFrames do
		local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

		if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
			and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

			return true;
		end;
	end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
	return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetDarkerColor(Color)
	local H, S, V = Color3.toHSV(Color);
	return Color3.fromHSV(H, S, V / 1.5);
end; Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
	local Idx = #Library.Registry + 1;
	local Data = {
		Instance = Instance;
		Properties = Properties;
		Idx = Idx;
	};

	table.insert(Library.Registry, Data);
	Library.RegistryMap[Instance] = Data;

	if IsHud then
		table.insert(Library.HudRegistry, Data);
	end;
end;

function Library:RemoveFromRegistry(Instance)
	local Data = Library.RegistryMap[Instance];

	if Data then
		for Idx = #Library.Registry, 1, -1 do
			if Library.Registry[Idx] == Data then
				table.remove(Library.Registry, Idx);
			end;
		end;

		for Idx = #Library.HudRegistry, 1, -1 do
			if Library.HudRegistry[Idx] == Data then
				table.remove(Library.HudRegistry, Idx);
			end;
		end;

		Library.RegistryMap[Instance] = nil;
	end;
end;

ScreenGui.DescendantRemoving:Connect(function(Instance)
	if Library.RegistryMap[Instance] then
		Library:RemoveFromRegistry(Instance);
	end;
end);

function Library:UpdateColorsUsingRegistry()
	for Idx, Object in next, Library.Registry do
		for Property, ColorIdx in next, Object.Properties do
			if type(ColorIdx) == 'string' then
				Object.Instance[Property] = Library[ColorIdx];
			elseif type(ColorIdx) == 'function' then
				Object.Instance[Property] = ColorIdx()
			end
		end;
	end;
end;

function Library:Unload()
	for Idx,values in pairs(Toggles) do
		print(Toggles,values.Value)
		if typeof(values.Value) == "boolean" then
			values:SetValue(false)
		end
	end

	if Library.OnUnload then
		Library.OnUnload()
	end

	ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
	Library.OnUnload = Callback
end

local BaseAddons = {};

do
	local Funcs = {};

	function Funcs:AddColorPicker(Idx, Info)
		local ToggleLabel = self.TextLabel;
		local Container = self.Container;

		local ColorPicker = {
			Value = Info.Default;
			Type = 'ColorPicker';
		};

		function ColorPicker:SetHSVFromRGB(Color)
			local H, S, V = Color3.toHSV(Color);

			ColorPicker.Hue = H;
			ColorPicker.Sat = S;
			ColorPicker.Vib = V;
		end;

		ColorPicker:SetHSVFromRGB(ColorPicker.Value);

		local DisplayFrame = Library:Create('Frame', {
			BackgroundColor3 = ColorPicker.Value;
			BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(0, 28, 0, 14);
			ZIndex = 6;
			Parent = ToggleLabel;
		});

		local RelativeOffset = 0;

		for _, Element in next, Container:GetChildren() do
			if not Element:IsA('UIListLayout') then
				RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
			end;
		end;

		local PickerFrameOuter = Library:Create('Frame', {
			Name = 'Color';
			BackgroundColor3 = Color3.new(1, 1, 1);
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(0, 4, 0, 20 + RelativeOffset + 1);
			Size = UDim2.new(1, -4, 0, 234);
			Visible = false;
			ZIndex = 15;
			Parent = Container.Parent;
		});

		local PickerFrameInner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.InlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 16;
			Parent = PickerFrameOuter;
		});

		Library:AddToRegistry(PickerFrameInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local Highlight = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 0, 2);
			ZIndex = 17;
			Parent = PickerFrameInner;
		});

		Library:AddToRegistry(Highlight, {
			BackgroundColor3 = 'AccentColor';
		});

		local SatVibMapOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(0, 4, 0, 6);
			Size = UDim2.new(0, 200, 0, 200);
			ZIndex = 17;
			Parent = PickerFrameInner;
		});

		local SatVibMapInner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18;
			Parent = SatVibMapOuter;
		});

		Library:AddToRegistry(SatVibMapInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local SatVibMap = Library:Create('ImageLabel', {
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18;
			Image = 'rbxassetid://4155801252';
			Parent = SatVibMapInner;
		});

		local HueSelectorOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(0, 211, 0, 7);
			Size = UDim2.new(0, 15, 0, 198);
			ZIndex = 17;
			Parent = PickerFrameInner;
		});

		local HueSelectorInner = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(1, 1, 1);
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18;
			Parent = HueSelectorOuter;
		});

		local HueTextSize = Library:GetTextBounds('Hex color', Enum.Font.Code, 16).x + 3
		local RgbTextSize = Library:GetTextBounds('255, 255, 255', Enum.Font.Code, 16).x + 3

		local HueBoxOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(4, 209),
			Size = UDim2.new(0.5, -6, 0, 20),
			ZIndex = 18,
			Parent = PickerFrameInner;
		});

		local HueBoxInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 18,
			Parent = HueBoxOuter;
		});

		Library:AddToRegistry(HueBoxInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		Library:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = HueBoxInner;
		});

		local HueBox = Library:Create('TextBox', {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -5, 1, 0);
			Font = Enum.Font.Code;
			PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
			PlaceholderText = 'Hex color',
			Text = '#FFFFFF',
			TextColor3 = Library.FontColor;
			TextSize = 14;
			TextStrokeTransparency = 0;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 20,
			Parent = HueBoxInner;
		});

		local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
			Position = UDim2.new(0.5, 2, 0, 209),
			Size = UDim2.new(0.5, -6, 0, 20),
			Parent = PickerFrameInner
		})  

		Library:AddToRegistry(RgbBoxBase.Frame, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
			Text = '255, 255, 255',
			PlaceholderText = 'RGB color',
		})

		local SequenceTable = {};

		for Hue = 0, 1, 0.1 do
			table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
		end;

		local HueSelectorGradient = Library:Create('UIGradient', {
			Color = ColorSequence.new(SequenceTable);
			Rotation = 90;
			Parent = HueSelectorInner;
		});

		HueBox.FocusLost:Connect(function(enter)
			if enter then
				local success, result = pcall(Color3.fromHex, HueBox.Text)
				if success and typeof(result) == 'Color3' then
					ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
				end
			end

			ColorPicker:Display()
		end)

		RgbBox.FocusLost:Connect(function(enter)
			if enter then
				local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
				if r and g and b then
					ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
				end
			end

			ColorPicker:Display()
		end)

		function ColorPicker:Display()
			ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
			SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

			Library:Create(DisplayFrame, {
				BackgroundColor3 = ColorPicker.Value;
				BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
			});

			HueBox.Text = '#' .. ColorPicker.Value:ToHex()
			RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

			if ColorPicker.Changed then
				ColorPicker.Changed();
			end;
		end;

		function ColorPicker:OnChanged(Func)
			ColorPicker.Changed = Func;
			Func();
		end;

		function ColorPicker:Show()
			for Frame, Val in next, Library.OpenedFrames do
				if Frame.Name == 'Color' then
					Frame.Visible = false;
					Library.OpenedFrames[Frame] = nil;
				end;
			end;

			PickerFrameOuter.Visible = true;
			Library.OpenedFrames[PickerFrameOuter] = true;
		end;

		function ColorPicker:Hide()
			PickerFrameOuter.Visible = false;
			Library.OpenedFrames[PickerFrameOuter] = nil;
		end;

		function ColorPicker:SetValue(HSV)
			local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

			ColorPicker:SetHSVFromRGB(Color);
			ColorPicker:Display();
		end;

		function ColorPicker:SetValueRGB(Color)
			ColorPicker:SetHSVFromRGB(Color);
			ColorPicker:Display();
		end;

		SatVibMap.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinX = SatVibMap.AbsolutePosition.X;
					local MaxX = MinX + SatVibMap.AbsoluteSize.X;
					local MouseX = math.clamp(Mouse.X, MinX, MaxX);

					local MinY = SatVibMap.AbsolutePosition.Y;
					local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

					ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
					ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
					ColorPicker:Display();

					RunService.RenderStepped:Wait();
				end;

				Library:AttemptSave();
			end;
		end);

		HueSelectorInner.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinY = HueSelectorInner.AbsolutePosition.Y;
					local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

					ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
					ColorPicker:Display();

					RunService.RenderStepped:Wait();
				end;

				Library:AttemptSave();
			end;
		end);

		DisplayFrame.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				if PickerFrameOuter.Visible then
					ColorPicker:Hide();
				else
					ColorPicker:Show();
				end;
			end;
		end);

		InputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

					ColorPicker:Hide();
				end;
			end;
		end);

		ColorPicker:Display();

		Options[Idx] = ColorPicker;

		return self;
	end;

	function Funcs:AddKeyPicker(Idx, Info)
		local ToggleLabel = self.TextLabel;
		local Container = self.Container;

		local KeyPicker = {
			Value = Info.Default;
			Toggled = false;
			Mode = Info.Mode or 'Toggle';
			Type = 'KeyPicker';
		};

		local RelativeOffset = 0;

		for _, Element in next, Container:GetChildren() do
			if not Element:IsA('UIListLayout') then
				RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
			end;
		end;

		local PickOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(0, 28, 0, 15);
			ZIndex = 6;
			Parent = ToggleLabel;
		});

		local PickInner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 7;
			Parent = PickOuter;
		});

		Library:AddToRegistry(PickInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local DisplayLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 13;
			Text = Info.Default;
			TextWrapped = true;
			ZIndex = 8;
			Parent = PickInner;
		});

		local ModeSelectOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(1, 0, 0, RelativeOffset + 1);
			Size = UDim2.new(0, 60, 0, 45 + 2);
			Visible = false;
			ZIndex = 14;
			Parent = Container.Parent;
		});

		local ModeSelectInner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 15;
			Parent = ModeSelectOuter;
		});

		Library:AddToRegistry(ModeSelectInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		Library:Create('UIListLayout', {
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = ModeSelectInner;
		});

		local ContainerLabel = Library:CreateLabel({
			TextXAlignment = Enum.TextXAlignment.Left;
			Size = UDim2.new(1, 0, 0, 18);
			TextSize = 13;
			Visible = false;
			ZIndex = 110;
			Parent = Library.KeybindContainer;
		},  true);

		local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
		local ModeButtons = {};

		for Idx, Mode in next, Modes do
			local ModeButton = {};

			local Label = Library:CreateLabel({
				Size = UDim2.new(1, 0, 0, 15);
				TextSize = 13;
				Text = Mode;
				ZIndex = 16;
				Parent = ModeSelectInner;
			});

			function ModeButton:Select()
				for _, Button in next, ModeButtons do
					Button:Deselect();
				end;

				KeyPicker.Mode = Mode;

				Label.TextColor3 = Library.AccentColor;
				Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

				ModeSelectOuter.Visible = false;
			end;

			function ModeButton:Deselect()
				KeyPicker.Mode = nil;

				Label.TextColor3 = Library.FontColor;
				Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
			end;

			Label.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					ModeButton:Select();
					Library:AttemptSave();
				end;
			end);

			if Mode == KeyPicker.Mode then
				ModeButton:Select();
			end;

			ModeButtons[Mode] = ModeButton;
		end;

		function KeyPicker:Update()
			if Info.NoUI then
				return;
			end;

			local State = KeyPicker:GetState();

			ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);
			ContainerLabel.Visible = true;
			ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

			Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

			local YSize = 0;

			for _, Label in next, Library.KeybindContainer:GetChildren() do
				if not Label:IsA('UIListLayout') then
					if Label.Visible then
						YSize = YSize + 18;
					end;
				end;
			end;

			Library.KeybindFrame.Size = UDim2.new(0, 210, 0, 20 + YSize);
		end;

		function KeyPicker:GetState()
			if KeyPicker.Mode == 'Always' then
				return true;
			elseif KeyPicker.Mode == 'Hold' then
				local Key = KeyPicker.Value;

				if Key == 'MB1' or Key == 'MB2' then
					return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
						or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
				else
					return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
				end;
			else
				return KeyPicker.Toggled;
			end;
		end;

		function KeyPicker:SetValue(Data)
			local Key, Mode = Data[1], Data[2];
			DisplayLabel.Text = Key;
			KeyPicker.Value = Key;
			ModeButtons[Mode]:Select();
			KeyPicker:Update();
		end;

		function KeyPicker:OnClick(Callback)
			KeyPicker.Clicked = Callback
		end

		function KeyPicker:DoClick()
			if KeyPicker.Clicked then
				KeyPicker.Clicked()
			end
		end

		local Picking = false;

		PickOuter.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				Picking = true;

				DisplayLabel.Text = '';

				local Break;
				local Text = '';

				task.spawn(function()
					while (not Break) do
						if Text == '...' then
							Text = '';
						end;

						Text = Text .. '.';
						DisplayLabel.Text = Text;

						wait(0.4);
					end;
				end);

				wait(0.2);

				local Event;
				Event = InputService.InputBegan:Connect(function(Input)
					local Key;

					if Input.UserInputType == Enum.UserInputType.Keyboard then
						Key = Input.KeyCode.Name;
					elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Key = 'MB1';
					elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
						Key = 'MB2';
					end;

					Break = true;
					Picking = false;

					DisplayLabel.Text = Key;
					KeyPicker.Value = Key;

					Library:AttemptSave();

					Event:Disconnect();
				end);
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
				ModeSelectOuter.Visible = true;
			end;
		end);

		InputService.InputBegan:Connect(function(Input)
			if (not Picking) then
				if KeyPicker.Mode == 'Toggle' then
					local Key = KeyPicker.Value;

					if Key == 'MB1' or Key == 'MB2' then
						if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
							or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
							KeyPicker.Toggled = not KeyPicker.Toggled
							KeyPicker:DoClick()
						end;
					elseif Input.UserInputType == Enum.UserInputType.Keyboard then
						if Input.KeyCode.Name == Key then
							KeyPicker.Toggled = not KeyPicker.Toggled;
							KeyPicker:DoClick()
						end;
					end;
				end;

				KeyPicker:Update();
			end;

			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

					ModeSelectOuter.Visible = false;
				end;
			end;
		end);

		InputService.InputEnded:Connect(function(Input)
			if (not Picking) then
				KeyPicker:Update();
			end;
		end);

		KeyPicker:Update();

		Options[Idx] = KeyPicker;

		return self;
	end;

	BaseAddons.__index = Funcs;
	BaseAddons.__namecall = function(Table, Key, ...)
		return Funcs[Key](...);
	end;
end;

local BaseGroupbox = {};

do
	local Funcs = {};

	function Funcs:AddBlank(Size)
		local Groupbox = self;
		local Container = Groupbox.Container;

		Library:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(1, 0, 0, Size);
			ZIndex = 1;
			Parent = Container;
		});
	end;

	function Funcs:AddLabel(Text)
		local Label = {};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local TextLabel = Library:CreateLabel({
			Size = UDim2.new(1, -4, 0, 15);
			TextSize = 14;
			Text = Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 5;
			Parent = Container;
		});

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 4);
			FillDirection = Enum.FillDirection.Horizontal;
			HorizontalAlignment = Enum.HorizontalAlignment.Right;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = TextLabel;
		});

		Label.TextLabel = TextLabel;
		Label.Container = Container;
		setmetatable(Label, BaseAddons);

		function Label:NewText(Text)
			TextLabel.Text = Text
		end

		Groupbox:AddBlank(5);
		Groupbox:Resize();

		return Label;
	end;

	function Funcs:AddButton(Text, Func)
		local Button = {};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local ButtonOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
			Parent = Container;
		});

		Library:AddToRegistry(ButtonOuter, {
			BorderColor3 = 'Black';
		});

		local ButtonInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = ButtonOuter;
		});

		Library:AddToRegistry(ButtonInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		Library:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = ButtonInner;
		});

		local ButtonLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = Text;
			ZIndex = 6;
			Parent = ButtonInner;
		});

		Library:OnHighlight(ButtonOuter, ButtonOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		);

		ButtonOuter.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				Func();
			end;
		end);

		function Button:AddButton(Text, Func)
			local SubButton = {}

			ButtonOuter.Size = UDim2.new(0.5, -2, 0, 20)

			local Outer = ButtonOuter:Clone()
			local Inner = Outer.Frame;
			local Label = Inner:FindFirstChildWhichIsA('TextLabel')

			Outer.Position = UDim2.new(1, 2, 0, 0)
			Outer.Size = UDim2.fromOffset(ButtonOuter.AbsoluteSize.X - 2, ButtonOuter.AbsoluteSize.Y)
			Outer.Parent = ButtonOuter

			Label.Text = Text;

			Library:AddToRegistry(Inner, {
				BackgroundColor3 = 'MainColor';
				BorderColor3 = 'OutlineColor';
			});

			Library:OnHighlight(Outer, Outer,
				{ BorderColor3 = 'AccentColor' },
				{ BorderColor3 = 'Black' }
			)

			Library:Create('UIGradient', {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
				});

				Rotation = 90;
				Parent = Inner;
			});

			Outer.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
					Func();
				end;
			end);

			return SubButton
		end 

		Groupbox:AddBlank(5);
		Groupbox:Resize();

		return Button;
	end;

	function Funcs:AddDivider()
		local Groupbox = self;
		local Container = self.Container

		local Divider = {
			Type = 'Divider',
		}

		Groupbox:AddBlank(2);
		local DividerOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 5);
			ZIndex = 5;
			Parent = Container;
		});

		local DividerInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = DividerOuter;
		});

		Library:AddToRegistry(DividerOuter, {
			BorderColor3 = 'Black';
		});

		Library:AddToRegistry(DividerInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		Groupbox:AddBlank(9);
		Groupbox:Resize();
	end

	function Funcs:AddInput(Idx, Info)
		local Textbox = {
			Value = Info.Default or '';
			Type = 'Input';
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local InputLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 0, 15);
			TextSize = 14;
			Text = Info.Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 5;
			Parent = Container;
		});

		Groupbox:AddBlank(1);

		local TextBoxOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1, -4, 0, 20),
			ZIndex = 5,
			Parent = Container
		})

		local TextBoxInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor,
			BorderColor3 = Library.OutlineColor,
			BorderMode = Enum.BorderMode.Inset,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6,
			Parent = TextBoxOuter
		})

		Library:AddToRegistry(TextBoxInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		Library:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = TextBoxInner;
		});

		local Box = Library:Create('TextBox', {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -5, 1, 0);
			Font = Enum.Font.Code;
			PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
			PlaceholderText = Info.Placeholder or '';
			Text = Info.Default or '';
			TextColor3 = Library.FontColor;
			TextSize = 14;
			TextStrokeTransparency = 0;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 7;
			Parent = TextBoxInner;
		});

		function Textbox:SetValue(Text)
			if Info.MaxLength and #Text > Info.MaxLength then
				Text = Text:sub(1, Info.MaxLength);
			end;

			if Textbox.Changed then
				Textbox.Changed();
			end;

			Textbox.Value = Text;
			Box.Text = Text;
		end;

		Box:GetPropertyChangedSignal('Text'):Connect(function()
			Textbox:SetValue(Box.Text);
			Library:AttemptSave();
		end);

		Library:AddToRegistry(Box, {
			TextColor3 = 'FontColor';
		});

		function Textbox:OnChanged(Func)
			Textbox.Changed = Func;
			Func();
		end;

		Groupbox:AddBlank(5);
		Groupbox:Resize();

		Options[Idx] = Textbox;

		return Textbox;
	end;

	function Funcs:AddToggle(Idx, Info)
		local Toggle = {
			Value = Info.Default or false;
			Type = 'Toggle';
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local ToggleOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(0, 13, 0, 13);
			ZIndex = 5;
			Parent = Container;
		});

		Library:AddToRegistry(ToggleOuter, {
			BorderColor3 = 'Black';
		});

		local ToggleInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = ToggleOuter;
		});

		Library:AddToRegistry(ToggleInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local ToggleLabel = Library:CreateLabel({
			Size = UDim2.new(0, 216, 1, 0);
			Position = UDim2.new(1, 6, 0, 0);
			TextSize = 14;
			Text = Info.Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 6;
			Parent = ToggleInner;
		});

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 4);
			FillDirection = Enum.FillDirection.Horizontal;
			HorizontalAlignment = Enum.HorizontalAlignment.Right;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = ToggleLabel;
		});

		local ToggleRegion = Library:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(0, 170, 1, 0);
			ZIndex = 8;
			Parent = ToggleOuter;
		});

		Library:OnHighlight(ToggleRegion, ToggleOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		);

		function Toggle:UpdateColors()
			Toggle:Display();
		end;

		function Toggle:Display()
			ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
			ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

			Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
			Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
		end;

		function Toggle:OnChanged(Func)
			Toggle.Changed = Func;
			Func();
		end;

		function Toggle:SetValue(Bool)
			Toggle.Value = Bool;
			Toggle:Display();

			if Toggle.Changed then
				Toggle.Changed();
			end;
		end;

		ToggleRegion.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				Toggle.Value = not Toggle.Value;
				Toggle:Display();

				if Toggle.Changed then
					Toggle.Changed();
				end;

				Library:AttemptSave();
			end;
		end);

		Toggle:Display();
		Groupbox:AddBlank(Info.BlankSize or 5 + 2);
		Groupbox:Resize();

		Toggle.TextLabel = ToggleLabel;
		Toggle.Container = Container;
		setmetatable(Toggle, BaseAddons);

		Toggles[Idx] = Toggle;

		return Toggle;
	end;

	function Funcs:AddSlider(Idx, Info)
		assert(Info.Default and Info.Text and Info.Min and Info.Max and Info.Rounding, 'Bad Slider Data');

		local Slider = {
			Value = Info.Default;
			Min = Info.Min;
			Max = Info.Max;
			Rounding = Info.Rounding;
			MaxSize = 232;
			Type = 'Slider';
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local SlidersetMain = Library:Create('Frame', {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Visible = Info and not Info.Compact or Info.SetSlider or false,
			ZIndex = 1,
			Parent = Container
		})

		if not Info.Compact then
			Library:CreateLabel({
				AnchorPoint = Vector2.new(0,.5),
				Position = UDim2.fromScale(0,.5),
				Size = UDim2.new(1, 0, 1, 0);
				TextSize = 14;
				Text = Info.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				ZIndex = 5;
				Parent = SlidersetMain
			})

			Groupbox:AddBlank(3)
		end

		local SliderOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 13);
			ZIndex = 5;
			Parent = Container;
		});

		Library:AddToRegistry(SliderOuter, {
			BorderColor3 = 'Black';
		});

		local SliderInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = SliderOuter;
		});

		Library:AddToRegistry(SliderInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local Fill = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderColor3 = Library.AccentColorDark;
			Size = UDim2.new(0, 0, 1, 0);
			ZIndex = 7;
			Parent = SliderInner;
		});

		Library:AddToRegistry(Fill, {
			BackgroundColor3 = 'AccentColor';
			BorderColor3 = 'AccentColorDark';
		});

		local HideBorderRight = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderSizePixel = 0;
			Position = UDim2.new(1, 0, 0, 0);
			Size = UDim2.new(0, 1, 1, 0);
			ZIndex = 8;
			Parent = Fill;
		});

		Library:AddToRegistry(HideBorderRight, {
			BackgroundColor3 = 'AccentColor';
		});

		local DisplayLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = 'Infinite';
			ZIndex = 9;
			Parent = SliderInner;
		});

		Library:OnHighlight(SliderOuter, SliderOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		);

		function Slider:UpdateColors()
			Fill.BackgroundColor3 = Library.AccentColor;
			Fill.BorderColor3 = Library.AccentColorDark;
		end;

		function Slider:Display()
			local Suffix = Info.Suffix or '';
			DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);

			local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
			Fill.Size = UDim2.new(0, X, 1, 0);

			HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0);
		end;

		function Slider:OnChanged(Func)
			Slider.Changed = Func;
			Func();
		end;

		local function Round(Value)
			if Slider.Rounding == 0 then
				return math.floor(Value);
			end;

			local Str = Value .. '';
			local Dot = Str:find('%.');

			return Dot and tonumber(Str:sub(1, Dot + Slider.Rounding)) or Value;
		end;

		function Slider:GetValueFromXOffset(X)
			return Round(Library:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
		end;

		function Slider:SetValue(Str)
			local Num = tonumber(Str);

			if (not Num) then
				return;
			end;

			Num = math.clamp(Num, Slider.Min, Slider.Max);

			Slider.Value = Num;
			Slider:Display();

			if Slider.Changed then
				Slider.Changed();
			end;
		end;

		if Info.SetSlider then
			local SetSliderFrame = Library:Create('Frame', {
				AnchorPoint = Vector2.new(0,.5),
				Position = UDim2.fromScale(.7,.45),
				BackgroundColor3 = Library.MainColor,
				BorderColor3 = Color3.new(0,0,0),
				Size = UDim2.new(.3, -4, 1, -1),
				ZIndex = 5,
				Parent = SlidersetMain
			})
			local Sliderset = Library:Create('TextBox', {
				BackgroundColor3 = Library.MainColor,
				BorderColor3 = Library.OutlineColor,
				BorderMode = Enum.BorderMode.Inset,
				TextColor3 = Color3.new(1,1,1),
				Size = UDim2.new(1, 0, 1, 0),
				TextScaled = true,
				ZIndex = 5,
				Parent = SetSliderFrame
			})
			Sliderset.FocusLost:Connect(function(enter)
				if enter and tonumber(Sliderset.Text) then
					local nValue = math.clamp(tonumber(Sliderset.Text),Slider.Min,Slider.Max)
					local OldValue = Slider.Value
					Slider.Value = nValue

					Sliderset.Text = nValue
					Slider:Display()

					if nValue ~= OldValue and Slider.Changed then
						Slider.Changed()
					end
				end
			end)
		end

		SliderInner.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				local mPos = Mouse.X;
				local gPos = Fill.Size.X.Offset;
				local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local nMPos = Mouse.X;
					local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

					local nValue = Slider:GetValueFromXOffset(nX);
					local OldValue = Slider.Value;
					Slider.Value = nValue;

					Slider:Display();

					if nValue ~= OldValue and Slider.Changed then
						Slider.Changed();
					end;

					RunService.RenderStepped:Wait();
				end;

				Library:AttemptSave();
			end;
		end);

		Slider:Display();
		Groupbox:AddBlank(Info.BlankSize or 6);
		Groupbox:Resize();

		Options[Idx] = Slider;

		return Slider;
	end;

	function Funcs:AddDropdown(Idx, Info)
		assert(Info.Text and Info.Values, 'Bad Dropdown Data');

		local Dropdown = {
			Values = Info.Values;
			Value = Info.Multi and {};
			Multi = Info.Multi;
			Type = 'Dropdown';
		};

		local Groupbox = self;
		local Container = Groupbox.Container;

		local RelativeOffset = 0;

		local DropdownLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 0, 10);
			TextSize = 14;
			Text = Info.Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Bottom;
			ZIndex = 5;
			Parent = Container;
		});

		Groupbox:AddBlank(3);

		for _, Element in next, Container:GetChildren() do
			if not Element:IsA('UIListLayout') then
				RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
			end;
		end;

		local DropdownOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
			Parent = Container;
		});

		Library:AddToRegistry(DropdownOuter, {
			BorderColor3 = 'Black';
		});

		local DropdownInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = DropdownOuter;
		});

		Library:AddToRegistry(DropdownInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		Library:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			});
			Rotation = 90;
			Parent = DropdownInner;
		});

		local DropdownArrow = Library:Create('ImageLabel', {
			AnchorPoint = Vector2.new(0, 0.5);
			BackgroundTransparency = 1;
			Position = UDim2.new(1, -16, 0.5, 0);
			Size = UDim2.new(0, 12, 0, 12);
			Image = 'http://www.roblox.com/asset/?id=6282522798';
			ZIndex = 7;
			Parent = DropdownInner;
		});

		local ItemList = Library:CreateLabel({
			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -5, 1, 0);
			TextSize = 14;
			Text = '--';
			TextXAlignment = Enum.TextXAlignment.Left;
			TextWrapped = true;
			ZIndex = 7;
			Parent = DropdownInner;
		});

		Library:OnHighlight(DropdownOuter, DropdownOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		);

		local MAX_DROPDOWN_ITEMS = 8;

		local ListOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.new(0, 4, 0, 20 + RelativeOffset + 1 + 20);
			Size = UDim2.new(1, -8, 0, MAX_DROPDOWN_ITEMS * 20 + 2);
			ZIndex = 20;
			Visible = false;
			Parent = Container.Parent;
		});

		local ListInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 21;
			Parent = ListOuter;
		});

		Library:AddToRegistry(ListInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		});

		local Scrolling = Library:Create('ScrollingFrame', {
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 21,
			Parent = ListInner
		})

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 0);
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = Scrolling;
		});

		function Dropdown:Display()
			local Values = Dropdown.Values;
			local Str = '';

			if Info.Multi then
				for Idx, Value in next, Values do
					if Dropdown.Value[Value] then
						Str = Str .. Value .. ', ';
					end;
				end;

				Str = Str:sub(1, #Str - 2);
			else
				Str = Dropdown.Value or '';
			end;

			ItemList.Text = (Str == '' and '--' or Str);
		end;

		function Dropdown:GetActiveValues()
			if Info.Multi then
				local T = {};

				for Value, Bool in next, Dropdown.Value do
					table.insert(T, Value);
				end;

				return T;
			else
				return Dropdown.Value and 1 or 0;
			end;
		end;

		function Dropdown:SetValues()
			local Values = Dropdown.Values;
			local Buttons = {};

			for _, Element in next, Scrolling:GetChildren() do
				if not Element:IsA('UIListLayout') then
					Element:Destroy();
				end;
			end;

			local Count = 0;

			for Idx, Value in next, Values do
				local Table = {};

				Count = Count + 1;

				local Button = Library:Create('Frame', {
					BackgroundColor3 = Library.MainColor;
					BorderColor3 = Library.OutlineColor;
					BorderMode = Enum.BorderMode.Middle;
					Size = UDim2.new(1, -1, 0, 20);
					ZIndex = 23;
					Parent = Scrolling;
				});

				Library:AddToRegistry(Button, {
					BackgroundColor3 = 'MainColor';
					BorderColor3 = 'OutlineColor';
				});

				local ButtonLabel = Library:CreateLabel({
					Size = UDim2.new(1, -6, 1, 0);
					Position = UDim2.new(0, 6, 0, 0);
					TextSize = 14;
					Text = Value;
					TextXAlignment = Enum.TextXAlignment.Left;
					ZIndex = 25;
					Parent = Button;
				});

				Library:OnHighlight(Button, Button,
					{ BorderColor3 = 'AccentColor', ZIndex = 24 },
					{ BorderColor3 = 'OutlineColor', ZIndex = 23 }
				);

				local Selected;

				if Info.Multi then
					Selected = Dropdown.Value[Value];
				else
					Selected = Dropdown.Value == Value;
				end;

				function Table:UpdateButton()
					if Info.Multi then
						Selected = Dropdown.Value[Value];
					else
						Selected = Dropdown.Value == Value;
					end;

					ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
					Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
				end;

				ButtonLabel.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						local Try = not Selected;

						if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
						else
							if Info.Multi then
								Selected = Try;

								if Selected then
									Dropdown.Value[Value] = true;
								else
									Dropdown.Value[Value] = nil;
								end;
							else
								Selected = Try;

								if Selected then
									Dropdown.Value = Value;
								else
									Dropdown.Value = nil;
								end;

								for _, OtherButton in next, Buttons do
									OtherButton:UpdateButton();
								end;
							end;

							Table:UpdateButton();
							Dropdown:Display();

							if Dropdown.Changed then
								Dropdown.Changed();
							end;

							Library:AttemptSave();
						end;
					end;
				end);

				Table:UpdateButton();
				Dropdown:Display();

				Buttons[Button] = Table;
			end;

			local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
			ListOuter.Size = UDim2.new(1, -8, 0, Y);
			Scrolling.CanvasSize = UDim2.new(0, 0, 0, Count * 20);

			ListOuter.Size = UDim2.new(1, -8, 0, (#Values * 20) + 2);
		end;

		function Dropdown:OpenDropdown()
			ListOuter.Visible = true;
			Library.OpenedFrames[ListOuter] = true;
			DropdownArrow.Rotation = 180;
		end;

		function Dropdown:CloseDropdown()
			ListOuter.Visible = false;
			Library.OpenedFrames[ListOuter] = nil;
			DropdownArrow.Rotation = 0;
		end;

		function Dropdown:OnChanged(Func)
			Dropdown.Changed = Func;
			Func();
		end;

		function Dropdown:SetValue(Val)
			if Dropdown.Multi then
				local nTable = {};

				for Value, Bool in next, Val do
					if table.find(Dropdown.Values, Value) then
						nTable[Value] = true
					end;
				end;

				Dropdown.Value = nTable;
			else
				if (not Val) then
					Dropdown.Value = nil;
				elseif table.find(Dropdown.Values, Val) then
					Dropdown.Value = Val;
				end;
			end;

			Dropdown:SetValues();
			Dropdown:Display();
		end;

		DropdownOuter.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				if ListOuter.Visible then
					Dropdown:CloseDropdown();
				else
					Dropdown:OpenDropdown();
				end;
			end;
		end);

		InputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

					Dropdown:CloseDropdown();
				end;
			end;
		end);

		Dropdown:SetValues();
		Dropdown:Display();

		if type(Info.Default) == 'string' then
			Info.Default = table.find(Dropdown.Values, Info.Default)
		end

		if Info.Default then
			if Info.Multi then
				Dropdown.Value[Dropdown.Values[Info.Default]] = true;
			else
				Dropdown.Value = Dropdown.Values[Info.Default];
			end;

			Dropdown:SetValues();
			Dropdown:Display();
		end;

		Groupbox:AddBlank(Info.BlankSize or 5);
		Groupbox:Resize();

		Options[Idx] = Dropdown;

		return Dropdown;
	end;

	BaseGroupbox.__index = Funcs;
	BaseGroupbox.__namecall = function(Table, Key, ...)
		return Funcs[Key](...);
	end;
end;

do
	Library.NotificationArea = Library:Create('Frame', {
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 40);
		Size = UDim2.new(0, 300, 0, 200);
		ZIndex = 100;
		Parent = ScreenGui;
	});

	Library:Create('UIListLayout', {
		Padding = UDim.new(0, 4);
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = Library.NotificationArea;
	});

	local WatermarkOuter = Library:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 100, 0, -25);
		Size = UDim2.new(0, 213, 0, 20);
		ZIndex = 200;
		Visible = false;
		Parent = ScreenGui;
	});

	local WatermarkInner = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor;
		BorderColor3 = Library.AccentColor;
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 201;
		Parent = WatermarkOuter;
	});

	Library:AddToRegistry(WatermarkInner, {
		BorderColor3 = 'AccentColor';
	});

	local InnerFrame = Library:Create('Frame', {
		BackgroundColor3 = Color3.new(1, 1, 1);
		BorderSizePixel = 0;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		ZIndex = 202;
		Parent = WatermarkInner;
	});

	local Gradient = Library:Create('UIGradient', {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
			ColorSequenceKeypoint.new(1, Library.MainColor),
		});
		Rotation = -90;
		Parent = InnerFrame;
	});

	Library:AddToRegistry(Gradient, {
		Color = function()
			return ColorSequence.new({
				ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
				ColorSequenceKeypoint.new(1, Library.MainColor),
			});
		end
	});

	local WatermarkLabel = Library:CreateLabel({
		Position = UDim2.new(0, 5, 0, 0);
		Size = UDim2.new(1, -4, 1, 0);
		TextSize = 14;
		TextXAlignment = Enum.TextXAlignment.Left;
		ZIndex = 203;
		Parent = InnerFrame;
	});

	Library.Watermark = WatermarkOuter;
	Library.WatermarkText = WatermarkLabel;
	Library:MakeDraggable(Library.Watermark);



	local KeybindOuter = Library:Create('Frame', {
		AnchorPoint = Vector2.new(0, 0.5);
		BorderColor3 = Color3.new(0, 0, 0);
		Position = UDim2.new(0, 10, 0.5, 0);
		Size = UDim2.new(0, 210, 0, 20);
		Visible = false;
		ZIndex = 100;
		Parent = ScreenGui;
	});

	local KeybindInner = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor;
		BorderColor3 = Library.OutlineColor;
		BorderMode = Enum.BorderMode.Inset;
		Size = UDim2.new(1, 0, 1, 0);
		ZIndex = 101;
		Parent = KeybindOuter;
	});

	Library:AddToRegistry(KeybindInner, {
		BackgroundColor3 = 'MainColor';
		BorderColor3 = 'OutlineColor';
	}, true);

	local ColorFrame = Library:Create('Frame', {
		BackgroundColor3 = Library.AccentColor;
		BorderSizePixel = 0;
		Size = UDim2.new(1, 0, 0, 2);
		ZIndex = 102;
		Parent = KeybindInner;
	});

	Library:AddToRegistry(ColorFrame, {
		BackgroundColor3 = 'AccentColor';
	}, true);

	local KeybindLabel = Library:CreateLabel({
		Size = UDim2.new(1, 0, 0, 20);
		Position = UDim2.fromOffset(5, 2),
		TextXAlignment = Enum.TextXAlignment.Left,

		Text = 'Keybinds';
		ZIndex = 104;
		Parent = KeybindInner;
	});

	local KeybindContainer = Library:Create('Frame', {
		BackgroundTransparency = 1;
		Size = UDim2.new(1, 0, 1, -20);
		Position = UDim2.new(0, 0, 0, 20);
		ZIndex = 1;
		Parent = KeybindInner;
	});

	Library:Create('UIListLayout', {
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = KeybindContainer;
	});

	Library:Create('UIPadding', {
		PaddingLeft = UDim.new(0, 5),
		Parent = KeybindContainer,
	})

	Library.KeybindFrame = KeybindOuter;
	Library.KeybindContainer = KeybindContainer;
	Library:MakeDraggable(KeybindOuter);
end;

function Library.CreateWindow(info)
	local Window = {
		Tabs = {}
	}

	local Outer = Library:Create('Frame', {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(.5,.5),
		Position = UDim2.new(.5, 0, .5, 0),
		Size = UDim2.new(0, 550, 0, 600),
		Visible = info and info.Show or false,
		ZIndex = 1,
		Parent = ScreenGui
	})

	Library:MakeDraggable(Outer, 50)

	local Inner = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor,
		BorderColor3 = Library.AccentColor,
		BorderMode = Enum.BorderMode.Inset,
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		ZIndex = 1,
		Parent = Outer
	})
	Library:AddToRegistry(Inner, {
		BackgroundColor3 = 'MainColor',
		BorderColor3 = 'AccentColor'
	})
	if info and info.Title and info.Title.Icon then
		local IconOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0),
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(0, 28, 0, 28),
			ZIndex = 1,
			Parent = Inner
		})
		local IconFrame = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor,
			BorderColor3 = Library.OutlineColor,
			BorderMode = Enum.BorderMode.Inset,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 1,
			Parent = IconOuter
		})
		Library:AddToRegistry(IconFrame, {
			BackgroundColor3 = 'MainColor',
			BorderColor3 = 'OutlineColor'
		})
		local IconLabel = Library:Create('ImageLabel', {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 1,
			Image = "rbxassetid://"..info.Title.Icon,
			Parent = IconFrame
		})
		Library:Create('UIGradient', {
			Rotation = 90,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))
			},
			Parent = IconFrame
		})
		Library.Icon = IconLabel
	end
	local TitleOuter = Library:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0),
		Position = info and info.Title and info.Title.Icon and UDim2.new(0, 43, 0, 10) or UDim2.new(0, 8, 0, 10),
		Size = UDim2.new(0, 110, 0, 28),
		ZIndex = 1,
		Parent = Inner
	})
	local TitleFrame = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor,
		BorderColor3 = Library.OutlineColor,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		Parent = TitleOuter
	})
	Library:AddToRegistry(TitleFrame, {
		BackgroundColor3 = 'MainColor',
		BorderColor3 = 'OutlineColor'
	})
	local TitleLabel = Library:CreateLabel({
		Size = UDim2.new(1, 0, 1, 0),
		TextColor3 = Library.AccentColor,
		Text = info and info.Title and info.Title.Name or 'hub',
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 1,
		Parent = TitleFrame
	})
	Library:Create('UIGradient', {
		Rotation = 90,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))
		},
		Parent = TitleFrame
	})
	Library:AddToRegistry(TitleLabel, {
		TextColor3 = 'AccentColor'
	})
	if info and info.Title and info.Title.Category then
		local CategoryOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0),
			Position = info and info.Title and info.Title.Icon and UDim2.new(0, 161, 0, 10) or UDim2.new(0, 125, 0, 10),
			Size = info and info.Title and info.Title.Icon and UDim2.new(0, 378, 0, 28) or UDim2.new(0, 411, 0, 28),
			ZIndex = 1,
			Parent = Inner
		})
		local CategoryFrame = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor,
			BorderColor3 = Library.OutlineColor,
			BorderMode = Enum.BorderMode.Inset,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 1,
			Parent = CategoryOuter
		})
		Library:AddToRegistry(CategoryFrame, {
			BackgroundColor3 = 'MainColor',
			BorderColor3 = 'OutlineColor'
		})
		local CategoryLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0),
			Text = info.Title.Category or '',
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 1,
			Parent = CategoryFrame
		})
		Library:Create('UIGradient', {
			Rotation = 90,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1,Color3.fromRGB(212,212,212))
			},
			Parent = CategoryFrame
		})
	end

	local MainSectionOuter = Library:Create('Frame', {
		BackgroundColor3 = Library.BackgroundColor,
		BorderColor3 = Color3.new(0, 0, 0),
		Position = UDim2.new(0, 8, 0, 48),
		Size = UDim2.new(1, -16, 0.96, -33),
		ZIndex = 1,
		Parent = Inner
	})

	Library:AddToRegistry(MainSectionOuter, {
		BackgroundColor3 = 'BackgroundColor',
		BorderColor3 = 'OutlineColor'
	})

	local MainSectionInner = Library:Create('Frame', {
		BackgroundColor3 = Library.BackgroundColor,
		BorderColor3 = Library.OutlineColor,
		BorderMode = Enum.BorderMode.Inset,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		Parent = MainSectionOuter
	})

	Library:AddToRegistry(MainSectionInner, {
		BackgroundColor3 = 'BackgroundColor'
	})
	local ButtonLeftOuter = Library:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0),
		Position = UDim2.new(0, 9, 0, 5),
		Size = UDim2.new(0, 28, 0, 28),
		ZIndex = 1,
		Parent = MainSectionInner
	})
	local ButtonLeft = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor,
		BorderColor3 = Library.OutlineColor,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		Parent = ButtonLeftOuter
	})
	Library:AddToRegistry(ButtonLeft, {
		BackgroundColor3 = 'MainColor',
		BorderColor3 = 'OutlineColor'
	})
	local LeftLabel = Library:CreateLabel({
		Size = UDim2.new(1, 0, 1, 0),
		Text = '<',
		ZIndex = 1,
		Parent = ButtonLeft
	})

	local ButtonRightOuter = Library:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0),
		Position = UDim2.new(0, 491, 0, 5),
		Size = UDim2.new(0, 28, 0, 28),
		ZIndex = 1,
		Parent = MainSectionInner
	})
	local ButtonRight = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor,
		BorderColor3 = Library.OutlineColor,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		Parent = ButtonRightOuter
	})
	Library:AddToRegistry(ButtonRight, {
		BackgroundColor3 = 'MainColor',
		BorderColor3 = 'OutlineColor'
	})
	local RightLabel = Library:CreateLabel({
		Size = UDim2.new(1, 0, 1, 0),
		Text = '>',
		ZIndex = 1,
		Parent = ButtonRight
	})
	local TabArea = Library:Create('Frame', {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 44, 0, 3),
		Size = UDim2.new(0, 440, 0, 32),
		ZIndex = 1,
		Parent = MainSectionInner
	})

	local TabScrolling = Library:Create('ScrollingFrame', {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		ClipsDescendants = true,
		ScrollingEnabled = false,
		Parent = TabArea
	})

	Library:Create('UIPadding', {
		PaddingLeft = UDim.new(0,2),
		Parent = TabScrolling
	})

	Library:Create('UIListLayout', {
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = TabScrolling
	})

	local TabContainerOuter = Library:Create('Frame', {
		BorderColor3 = Color3.new(0, 0, 0),
		Position = UDim2.new(0, 8, 0, 42),
		Size = UDim2.new(1, -16, .98, -38),
		ZIndex = 1,
		Parent = MainSectionInner
	})
	local TabContainer = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor,
		BorderColor3 = Library.OutlineColor,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 1,
		Parent = TabContainerOuter
	})

	Library:AddToRegistry(TabContainer, {
		BackgroundColor3 = 'MainColor',
		BorderColor3 = 'OutlineColor'
	})

	local tabside = 0
	LeftLabel.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and tabside-110 >= 0 and not Library:MouseIsOverOpenedFrame() then
			tabside -= 110
			TweenService:Create(TabScrolling,TweenInfo.new(.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(tabside,0)}):Play()
		end
	end)
	RightLabel.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and tabside+110 <= (TabScrolling.CanvasSize.X.Offset-TabArea.Size.X.Offset) and not Library:MouseIsOverOpenedFrame() then
			tabside += 110
			TweenService:Create(TabScrolling,TweenInfo.new(.1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CanvasPosition = Vector2.new(tabside,0)}):Play()
		end
	end)

	function Window:AddTab(Name,Info)
		TabScrolling.CanvasSize += UDim2.new(0, 110, 0, 0)
		local Tab = {
			Groupboxes = {},
			Tabboxes = {}
		}

		local TabButtonOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(0, 105, 0, 28),
			ZIndex = 1,
			Parent = TabScrolling
		})
		local TabButton = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor,
			BorderColor3 = Library.OutlineColor,
			Size = UDim2.new(1, 0, 1, 0),
			BorderMode = Enum.BorderMode.Inset,
			ZIndex = 1,
			Parent = TabButtonOuter
		})

		Library:Create('UIGradient', {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
			}),
			Rotation = 90,
			Parent = TabButton
		})

		Library:AddToRegistry(TabButton, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local TabButtonLabel = Library:CreateLabel({
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 1, 0);
			Text = Name;
			ZIndex = 1;
			Parent = TabButton;
		});

		local TabFrame = Library:Create('Frame', {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			ZIndex = 2,
			Parent = TabContainer
		})

		local LeftSide = Library:Create('ScrollingFrame', {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0, 8),
			Size = UDim2.new(0.5, -12, 0, 470),
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			ScrollBarThickness = 0,
			ClipsDescendants = true,
			ZIndex = 2,
			Parent = TabFrame
		})

		local RightSide = Library:Create('ScrollingFrame', {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 4, 0, 8),
			Size = UDim2.new(0.5, -12, 0, 470),
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			ScrollBarThickness = 0,
			ClipsDescendants = true,
			ZIndex = 2,
			Parent = TabFrame
		})

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 8),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = LeftSide
		})

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 8),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = RightSide
		})

		local function chargesizescrolling(scrolling)
			local nun = 0
			local SizeY = 0
			for i,v in pairs(scrolling:GetChildren()) do
				if v:IsA("Frame") then
					nun += 1
					SizeY += v.Size.Y.Offset
				end
			end
			return SizeY+(nun*8)
		end
		RightSide.CanvasSize = UDim2.new(0, 0, 0, chargesizescrolling(RightSide))
		LeftSide.CanvasSize = UDim2.new(0, 0, 0, chargesizescrolling(LeftSide))
		RightSide.ChildAdded:Connect(function(obj)
			RightSide.CanvasSize = UDim2.new(0, 0, 0, chargesizescrolling(RightSide))
			if typeof(obj) == "Frame" then
				obj:GetPropertyChangedSignal("Size"):Connect(function()
					RightSide.CanvasSize = UDim2.new(0, 0, 0, chargesizescrolling(RightSide))
				end)
			end
		end)
		LeftSide.ChildAdded:Connect(function(obj)
			LeftSide.CanvasSize = UDim2.new(0, 0, 0, chargesizescrolling(LeftSide))
			if typeof(obj) == "Frame" then
				obj:GetPropertyChangedSignal("Size"):Connect(function()
					LeftSide.CanvasSize = UDim2.new(0, 0, 0, chargesizescrolling(RightSide))
				end)
			end
		end)

		function Tab:ShowTab()
			for _, Tab in next, Window.Tabs do
				Tab:HideTab()
			end

			TabButton.BackgroundColor3 = Library.MainColor
			TabFrame.Visible = true
		end

		function Tab:HideTab()
			TabButton.BackgroundColor3 = Library.BackgroundColor
			TabFrame.Visible = false
		end

		function Tab:AddGroupbox(Info)
			local Groupbox = {}

			local block = Library:Create('Frame', {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 507),
				ZIndex = 2,
				Parent = Info.Side == 1 and LeftSide or RightSide
			})

			local BoxOuter = Library:Create('Frame', {
				AnchorPoint = Vector2.new(.5,.5),
				Position = UDim2.new(.5, 0, .5, 0),
				BackgroundColor3 = Library.BackgroundColor,
				BorderColor3 = Library.OutlineColor,
				Size = UDim2.new(.99, 0, .99, 0),
				ZIndex = 2,
				Parent = block
			})

			Library:AddToRegistry(BoxOuter, {
				BackgroundColor3 = 'BackgroundColor';
				BorderColor3 = 'OutlineColor';
			});

			local BoxInner = Library:Create('Frame', {
				BackgroundColor3 = Library.BackgroundColor,
				BorderColor3 = Color3.new(0, 0, 0),
				BorderMode = Enum.BorderMode.Inset,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 4,
				Parent = BoxOuter
			})

			Library:AddToRegistry(BoxInner, {
				BackgroundColor3 = 'BackgroundColor'
			})

			local Highlight = Library:Create('Frame', {
				BackgroundColor3 = Library.AccentColor;
				BorderSizePixel = 0;
				Size = UDim2.new(1, 0, 0, 2);
				ZIndex = 5;
				Parent = BoxInner;
			});

			Library:AddToRegistry(Highlight, {
				BackgroundColor3 = 'AccentColor';
			});

			local GroupboxLabel = Library:CreateLabel({
				Size = UDim2.new(1, 0, 0, 18);
				Position = UDim2.new(0, 4, 0, 2);
				TextSize = 14;
				Text = Info.Name;
				TextXAlignment = Enum.TextXAlignment.Left;
				ZIndex = 5;
				Parent = BoxInner;
			});

			local Container = Library:Create('Frame', {
				BackgroundTransparency = 1;
				Position = UDim2.new(0, 4, 0, 20);
				Size = UDim2.new(1, -4, 1, -20);
				ZIndex = 1;
				Parent = BoxInner;
			});

			Library:Create('UIListLayout', {
				FillDirection = Enum.FillDirection.Vertical;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = Container;
			});

			function Groupbox:Resize()
				local Size = 0;

				for _, Element in next, Groupbox.Container:GetChildren() do
					if not Element:IsA('UIListLayout') then
						Size = Size + Element.Size.Y.Offset;
					end;
				end;

				block.Size = UDim2.new(1, 0, 0, 20 + Size + 2);
			end;

			Groupbox.Container = Container;
			setmetatable(Groupbox, BaseGroupbox);

			Groupbox:AddBlank(3);
			Groupbox:Resize();

			Tab.Groupboxes[Info.Name] = Groupbox;

			return Groupbox;
		end;

		function Tab:AddLeftGroupbox(Name)
			return Tab:AddGroupbox({ Side = 1; Name = Name; });
		end;

		function Tab:AddRightGroupbox(Name)
			return Tab:AddGroupbox({ Side = 2; Name = Name; });
		end;

		function Tab:AddTabbox(Info)
			local Tabbox = {
				Tabs = {}
			}

			local block = Library:Create('Frame', {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0);
				ZIndex = 2,
				Parent = Info.Side == 1 and LeftSide or RightSide
			})

			local BoxOuter = Library:Create('Frame', {
				AnchorPoint = Vector2.new(.5,.5),
				Position = UDim2.new(.5, 0, .5, 0),
				BackgroundColor3 = Library.BackgroundColor;
				BorderColor3 = Library.OutlineColor;
				Size = UDim2.new(.99, 0, 0, 0);
				ZIndex = 2;
				Parent = block
			});

			Library:AddToRegistry(BoxOuter, {
				BackgroundColor3 = 'BackgroundColor';
				BorderColor3 = 'OutlineColor';
			});

			local BoxInner = Library:Create('Frame', {
				BackgroundColor3 = Library.BackgroundColor;
				BorderColor3 = Color3.new(0, 0, 0);
				BorderMode = Enum.BorderMode.Inset;
				Size = UDim2.new(1, 0, 1, 0);
				ZIndex = 4;
				Parent = BoxOuter;
			});

			Library:AddToRegistry(BoxInner, {
				BackgroundColor3 = 'BackgroundColor';
			});

			local Highlight = Library:Create('Frame', {
				BackgroundColor3 = Library.AccentColor;
				BorderSizePixel = 0;
				Size = UDim2.new(1, 0, 0, 2);
				ZIndex = 10;
				Parent = BoxInner;
			});

			Library:AddToRegistry(Highlight, {
				BackgroundColor3 = 'AccentColor';
			});

			local TabboxButtons = Library:Create('Frame', {
				BackgroundTransparency = 1;
				Position = UDim2.new(0, 0, 0, 1);
				Size = UDim2.new(1, 0, 0, 18);
				ZIndex = 5;
				Parent = BoxInner;
			});

			Library:Create('UIListLayout', {
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = TabboxButtons;
			});

			function Tabbox:AddTab(Name)
				local Tab = {};

				local Button = Library:Create('Frame', {
					BackgroundColor3 = Library.MainColor;
					BorderColor3 = Color3.new(0, 0, 0);
					Size = UDim2.new(0.5, 0, 1, 0);
					ZIndex = 6;
					Parent = TabboxButtons;
				});

				Library:AddToRegistry(Button, {
					BackgroundColor3 = 'MainColor'
				})

				local ButtonLabel = Library:CreateLabel({
					Size = UDim2.new(1, 0, 1, 0);
					TextSize = 14;
					Text = Name;
					TextXAlignment = Enum.TextXAlignment.Center;
					ZIndex = 7;
					Parent = Button;
				});

				local Block = Library:Create('Frame', {
					BackgroundColor3 = Library.BackgroundColor;
					BorderSizePixel = 0;
					Position = UDim2.new(0, 0, 1, 0);
					Size = UDim2.new(1, 0, 0, 1);
					Visible = false;
					ZIndex = 9;
					Parent = Button;
				});

				Library:AddToRegistry(Block, {
					BackgroundColor3 = 'BackgroundColor';
				});

				local Container = Library:Create('Frame', {
					Position = UDim2.new(0, 4, 0, 20);
					Size = UDim2.new(1, -4, 1, -20);
					ZIndex = 1;
					Visible = false;
					Parent = BoxInner;
				});

				Library:Create('UIListLayout', {
					FillDirection = Enum.FillDirection.Vertical;
					SortOrder = Enum.SortOrder.LayoutOrder;
					Parent = Container;
				});

				function Tab:Show()
					for _, Tab in next, Tabbox.Tabs do
						Tab:Hide();
					end;

					Container.Visible = true;
					Block.Visible = true;

					Button.BackgroundColor3 = Library.BackgroundColor;
					Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
				end;

				function Tab:Hide()
					Container.Visible = false;
					Block.Visible = false;

					Button.BackgroundColor3 = Library.MainColor;
					Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
				end;

				function Tab:Resize()
					local TabCount = 0;

					for _, Tab in next, Tabbox.Tabs do
						TabCount = TabCount +  1;
					end;

					for _, Button in next, TabboxButtons:GetChildren() do
						if not Button:IsA('UIListLayout') then
							Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
						end;
					end;

					local Size = 0;

					for _, Element in next, Tab.Container:GetChildren() do
						if not Element:IsA('UIListLayout') then
							Size = Size + Element.Size.Y.Offset;
						end;
					end;

					if block.Size.Y.Offset < 20 + Size + 2 then
						block.Size = UDim2.new(1, 0, 0, 20 + Size + 2);
					end;
				end;

				Button.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
						Tab:Show();
					end;
				end);

				Tab.Container = Container;
				Tabbox.Tabs[Name] = Tab;

				setmetatable(Tab, BaseGroupbox);

				Tab:AddBlank(3);
				Tab:Resize();

				if #TabboxButtons:GetChildren() == 2 then
					Tab:Show();
				end;

				return Tab;
			end;

			Tab.Tabboxes[Info.Name or ''] = Tabbox;

			return Tabbox;
		end;

		function Tab:AddLeftTabbox(Name)
			return Tab:AddTabbox({ Name = Name, Side = 1; });
		end;

		function Tab:AddRightTabbox(Name)
			return Tab:AddTabbox({ Name = Name, Side = 2; })
		end

		TabButton.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Tab:ShowTab()
			end
		end)

		if #TabContainer:GetChildren() == 1 then
			Tab:ShowTab()
		end

		Window.Tabs[Name] = Tab
		return Tab
	end

	InputService.InputBegan:Connect(function(Input, Processed)
		if Input.KeyCode == Enum.KeyCode[Options.MenuKeybind and Options.MenuKeybind.Value or "RightControl"] and not Processed then
			Outer.Visible = not Outer.Visible
		end
	end)

	Window.Holder = Outer

	return Window
end

Library.ThemeManager = {} do
	Library.ThemeManager.Folder = 'LinoriaLibSettings'

	Library.ThemeManager.Library = nil
	Library.ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"40bcf3","BackgroundColor":"141414","OutlineColor":"323232"}') },
		['Jester'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint'] 			= { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night'] 	= { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
	}

	function Library.ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end
		
		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)

			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
				if idx == "AccentColor" then
					if Library.Icon then
						local ID = 11411584338
						if col == "40bcf3" then
						elseif col == "db4467" then
							ID = 11465780134
						elseif col == "3db488" then
							ID = 11465860189
						elseif col == "6759b3" then
							ID = 11465872108
						end
						Library.Icon.Image = "rbxassetid://"..ID

					end
				end
			end
		end

		self:ThemeUpdate()
	end

	function Library.ThemeManager:ThemeUpdate()
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function Library.ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
			theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function Library.ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function Library.ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })

		groupbox:AddButton('Load custom theme', function() 
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
		end)

		groupbox:AddButton('Save custom theme', function() 
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)

			Options.ThemeManager_CustomThemeList.Values = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList.Values = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		Library.ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
	end

	function Library.ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)

		if not success then
			return nil
		end

		return decoded
	end

	function Library.ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function Library.ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function Library.ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function Library.ThemeManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function Library.ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function Library.ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function Library.ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function Library.ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	Library.ThemeManager:BuildFolderTree()
end

Library.SaveManager = {} do
	Library.SaveManager.Folder = 'LinoriaLibSettings'
	Library.SaveManager.Ignore = {}
	Library.SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex() }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value))
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if Options[idx] and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function Library.SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function Library.SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function Library.SaveManager:Save(name)
		local fullPath = self.Folder .. '/settings/' .. name .. '.json'

		local data = {
			objects = {}
		}

		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function Library.SaveManager:Load(name)
		local file = self.Folder .. '/settings/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				self.Parser[option.type].Load(option.idx, option)
			end
		end

		return true
	end

	function Library.SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName',
		})
	end

	function Library.SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function Library.SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end

		return out
	end

	function Library.SaveManager:SetLibrary(library)
		self.Library = library
	end

	function Library.SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end

	function Library.SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')

		local section = tab:AddRightGroupbox('Configuration')

		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })
		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })

		section:AddDivider()

		section:AddButton('Create config', function()
			local name = Options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('Created config %q', name))

			Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
			Options.SaveManager_ConfigList:SetValues()
			Options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:Notify(string.format('Loaded config %q', name))
		end)

		section:AddButton('Overwrite config', function()
			local name = Options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to overwrite config: ' .. err)
			end

			self.Library:Notify(string.format('Overwrote config %q', name))
		end)

		section:AddButton('Autoload config', function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			Library.SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)

		section:AddButton('Refresh config list', function()
			Options.SaveManager_ConfigList.Values = self:RefreshConfigList()
			Options.SaveManager_ConfigList:SetValues()
			Options.SaveManager_ConfigList:SetValue(nil)
		end)

		Library.SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			Library.SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		Library.SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end

	Library.SaveManager:BuildFolderTree()
end


return Library
