-- GatoLIB - Modern GUI Library for Roblox
-- Biblioteca GUI moderna com design limpo e funcionalidades completas

local GatoLIB = {}
GatoLIB.__index = GatoLIB

-- Serviços do Roblox
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configurações de cores e estilo
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(240, 71, 71),
    Border = Color3.fromRGB(40, 40, 45)
}

-- Funções utilitárias
local function CreateTween(object, properties, duration, easingStyle)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    
    local tween = TweenService:Create(object, TweenInfo.new(duration, easingStyle), properties)
    tween:Play()
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Sistema de Notificações
function GatoLIB:Notify(config)
    local titulo = config.Titulo or "Notificação"
    local conteudo = config.Conteudo or "Conteúdo da notificação"
    local subConteudo = config.SubConteudo
    local duracao = config.Duracao or 5
    -- Container principal das notificações
    local notifyContainer = PlayerGui:FindFirstChild("GatoLIB_Notifications")
    if not notifyContainer then
        notifyContainer = Instance.new("ScreenGui")
        notifyContainer.Name = "GatoLIB_Notifications"
        notifyContainer.Parent = PlayerGui
        notifyContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        listLayout.Padding = UDim.new(0, 10)
        listLayout.Parent = notifyContainer
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 20)
        padding.PaddingRight = UDim.new(0, 20)
        padding.Parent = notifyContainer
    end
    
    -- Frame da notificação
    local notifyFrame = Instance.new("Frame")
    notifyFrame.Size = UDim2.new(0, 300, 0, subConteudo and 80 or 60)
    notifyFrame.BackgroundColor3 = Theme.Secondary
    notifyFrame.BorderSizePixel = 0
    notifyFrame.Parent = notifyContainer
    notifyFrame.AnchorPoint = Vector2.new(1, 0)
    notifyFrame.Position = UDim2.new(1, 350, 0, 0)
    
    CreateCorner(notifyFrame, 10)
    CreateStroke(notifyFrame, Theme.Border)
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titulo
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifyFrame
    
    -- Conteúdo
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -40, 0, 16)
    contentLabel.Position = UDim2.new(0, 15, 0, 28)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = conteudo
    contentLabel.TextColor3 = Theme.TextSecondary
    contentLabel.TextScaled = true
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.Parent = notifyFrame
    
    -- SubConteúdo (opcional)
    if subConteudo then
        local subLabel = Instance.new("TextLabel")
        subLabel.Size = UDim2.new(1, -40, 0, 14)
        subLabel.Position = UDim2.new(0, 15, 0, 50)
        subLabel.BackgroundTransparency = 1
        subLabel.Text = subConteudo
        subLabel.TextColor3 = Theme.TextSecondary
        subLabel.TextScaled = true
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.TextTransparency = 0.5
        subLabel.Parent = notifyFrame
    end
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 8)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Theme.TextSecondary
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = notifyFrame
    
    -- Animação de entrada
    CreateTween(notifyFrame, {Position = UDim2.new(1, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
    
    -- Função para remover notificação
    local function removeNotification()
        CreateTween(notifyFrame, {Position = UDim2.new(1, 350, 0, 0)}, 0.3)
        game:GetService("Debris"):AddItem(notifyFrame, 0.5)
    end
    
    closeButton.MouseButton1Click:Connect(removeNotification)
    
    -- Auto-remover após duração
    if duracao > 0 then
        game:GetService("Debris"):AddItem(notifyFrame, duracao)
    end
end

-- Sistema de Janelas
function GatoLIB:CreateWindow(config)
    local window = {}
    window.Tabs = {}
    
    local windowTitle = config.Title or "GatoLIB Window"
    local windowSize = config.Size or UDim2.new(0, 600, 0, 400)
    
    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GatoLIB_" .. windowTitle
    screenGui.Parent = PlayerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    CreateCorner(mainFrame, 12)
    CreateStroke(mainFrame, Theme.Border)
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    CreateCorner(titleBar, 12)
    
    -- Máscara para o título
    local titleMask = Instance.new("Frame")
    titleMask.Size = UDim2.new(1, 0, 0, 20)
    titleMask.Position = UDim2.new(0, 0, 1, -20)
    titleMask.BackgroundColor3 = Theme.Secondary
    titleMask.BorderSizePixel = 0
    titleMask.Parent = titleBar
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Theme.Error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    CreateCorner(closeButton, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Container de abas
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 150, 1, -50)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    -- Container de conteúdo
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -170, 1, -50)
    contentContainer.Position = UDim2.new(0, 160, 0, 45)
    contentContainer.BackgroundColor3 = Theme.Secondary
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    CreateCorner(contentContainer, 8)
    CreateStroke(contentContainer, Theme.Border)
    
    -- Função para criar abas
    function window:CreateTab(config)
        local tab = {}
        local tabName = config.Title or "Nova Aba"
        local tabIcon = config.Icon or "📄"
        
        -- Botão da aba
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = Theme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabIcon .. " " .. tabName
        tabButton.TextColor3 = Theme.TextSecondary
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = tabContainer
        
        CreateCorner(tabButton, 6)
        
        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingLeft = UDim.new(0, 10)
        tabPadding.Parent = tabButton
        
        -- Conteúdo da aba
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Theme.Accent
        tabContent.Parent = contentContainer
        tabContent.Visible = false
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.FillDirection = Enum.FillDirection.Vertical
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        -- Ativar aba
        tabButton.MouseButton1Click:Connect(function()
            -- Desativar outras abas
            for _, otherTab in pairs(window.Tabs) do
                otherTab.Button.BackgroundColor3 = Theme.Secondary
                otherTab.Button.TextColor3 = Theme.TextSecondary
                otherTab.Content.Visible = false
            end
            
            -- Ativar esta aba
            tabButton.BackgroundColor3 = Theme.Accent
            tabButton.TextColor3 = Theme.Text
            tabContent.Visible = true
        end)
        
        tab.Button = tabButton
        tab.Content = tabContent
        tab.Layout = contentLayout
        
        -- Função para adicionar parágrafo
        function tab:AddParagraph(config)
            local title = config.Title or "Parágrafo"
            local content = config.Content or "Conteúdo do parágrafo"
            
            local paragraphFrame = Instance.new("Frame")
            paragraphFrame.Size = UDim2.new(1, 0, 0, 60)
            paragraphFrame.BackgroundColor3 = Theme.Background
            paragraphFrame.BorderSizePixel = 0
            paragraphFrame.Parent = tabContent
            
            CreateCorner(paragraphFrame, 8)
            CreateStroke(paragraphFrame, Theme.Border)
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -20, 0, 20)
            titleLabel.Position = UDim2.new(0, 10, 0, 8)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = Theme.Text
            titleLabel.TextScaled = true
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = paragraphFrame
            
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, -20, 0, 25)
            contentLabel.Position = UDim2.new(0, 10, 0, 28)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = content
            contentLabel.TextColor3 = Theme.TextSecondary
            contentLabel.TextScaled = true
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.Parent = paragraphFrame
        end
        
        -- Função para adicionar slider
        function tab:AddSlider(name, config)
            local title = config.Title or "Slider"
            local description = config.Description or ""
            local default = config.Default or 0
            local min = config.Min or 0
            local max = config.Max or 100
            local rounding = config.Rounding or 1
            local callback = config.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, description ~= "" and 80 or 60)
            sliderFrame.BackgroundColor3 = Theme.Background
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            
            CreateCorner(sliderFrame, 8)
            CreateStroke(sliderFrame, Theme.Border)
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(0.7, 0, 0, 20)
            titleLabel.Position = UDim2.new(0, 10, 0, 8)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = Theme.Text
            titleLabel.TextScaled = true
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.3, -10, 0, 20)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 8)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Theme.Accent
            valueLabel.TextScaled = true
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            if description ~= "" then
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, -20, 0, 15)
                descLabel.Position = UDim2.new(0, 10, 0, 28)
                descLabel.BackgroundTransparency = 1
                descLabel.Text = description
                descLabel.TextColor3 = Theme.TextSecondary
                descLabel.TextScaled = true
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.Parent = sliderFrame
            end
            
            local sliderBack = Instance.new("Frame")
            sliderBack.Size = UDim2.new(1, -20, 0, 6)
            sliderBack.Position = UDim2.new(0, 10, 1, -16)
            sliderBack.BackgroundColor3 = Theme.Secondary
            sliderBack.BorderSizePixel = 0
            sliderBack.Parent = sliderFrame
            
            CreateCorner(sliderBack, 3)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.Position = UDim2.new(0, 0, 0, 0)
            sliderFill.BackgroundColor3 = Theme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBack
            
            CreateCorner(sliderFill, 3)
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(1, 0, 1, 0)
            sliderButton.Position = UDim2.new(0, 0, 0, 0)
            sliderButton.BackgroundTransparency = 1
            sliderButton.Text = ""
            sliderButton.Parent = sliderBack
            
            local dragging = false
            
            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            sliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = UserInputService:GetMouseLocation()
                    local relativePos = math.clamp((mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * relativePos
                    value = math.floor(value * (10 ^ rounding)) / (10 ^ rounding)
                    
                    sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                    valueLabel.Text = tostring(value)
                    callback(value)
                end
            end)
        end
        
        -- Função para adicionar botão
        function tab:AddButton(config)
            local title = config.Title or "Botão"
            local description = config.Description or ""
            local callback = config.Callback or function() end
            
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Size = UDim2.new(1, 0, 0, description ~= "" and 65 or 45)
            buttonFrame.BackgroundColor3 = Theme.Background
            buttonFrame.BorderSizePixel = 0
            buttonFrame.Parent = tabContent
            
            CreateCorner(buttonFrame, 8)
            CreateStroke(buttonFrame, Theme.Border)
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -20, 0, 30)
            button.Position = UDim2.new(0, 10, 0, description ~= "" and 25 or 8)
            button.BackgroundColor3 = Theme.Accent
            button.BorderSizePixel = 0
            button.Text = title
            button.TextColor3 = Theme.Text
            button.TextScaled = true
            button.Font = Enum.Font.GothamBold
            button.Parent = buttonFrame
            
            CreateCorner(button, 6)
            
            if description ~= "" then
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, -20, 0, 15)
                descLabel.Position = UDim2.new(0, 10, 0, 5)
                descLabel.BackgroundTransparency = 1
                descLabel.Text = description
                descLabel.TextColor3 = Theme.TextSecondary
                descLabel.TextScaled = true
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.Parent = buttonFrame
            end
            
            button.MouseButton1Click:Connect(callback)
            
            -- Efeito hover
            button.MouseEnter:Connect(function()
                CreateTween(button, {BackgroundColor3 = Color3.fromRGB(98, 111, 252)}, 0.2)
            end)
            
            button.MouseLeave:Connect(function()
                CreateTween(button, {BackgroundColor3 = Theme.Accent}, 0.2)
            end)
        end
        
        -- Função para adicionar dropdown
        function tab:AddDropdown(name, config)
            local dropdown = {}
            local title = config.Title or "Dropdown"
            local description = config.Description or ""
            local values = config.Values or {}
            local multi = config.Multi or false
            local default = config.Default or (multi and {} or nil)
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, description ~= "" and 80 or 60)
            dropdownFrame.BackgroundColor3 = Theme.Background
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = tabContent
            
            CreateCorner(dropdownFrame, 8)
            CreateStroke(dropdownFrame, Theme.Border)
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -20, 0, 20)
            titleLabel.Position = UDim2.new(0, 10, 0, 8)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = Theme.Text
            titleLabel.TextScaled = true
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = dropdownFrame
            
            if description ~= "" then
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, -20, 0, 15)
                descLabel.Position = UDim2.new(0, 10, 0, 28)
                descLabel.BackgroundTransparency = 1
                descLabel.Text = description
                descLabel.TextColor3 = Theme.TextSecondary
                descLabel.TextScaled = true
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.Parent = dropdownFrame
            end
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, -20, 0, 25)
            dropdownButton.Position = UDim2.new(0, 10, 1, -33)
            dropdownButton.BackgroundColor3 = Theme.Secondary
            dropdownButton.BorderSizePixel = 0
            dropdownButton.Text = multi and "Selecione..." or (default and values[default] or "Selecione...")
            dropdownButton.TextColor3 = Theme.Text
            dropdownButton.TextScaled = true
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
            dropdownButton.Parent = dropdownFrame
            
            CreateCorner(dropdownButton, 6)
            CreateStroke(dropdownButton, Theme.Border)
            
            local dropdownPadding = Instance.new("UIPadding")
            dropdownPadding.PaddingLeft = UDim.new(0, 10)
            dropdownPadding.PaddingRight = UDim.new(0, 10)
            dropdownPadding.Parent = dropdownButton
            
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -25, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Theme.TextSecondary
            arrow.TextScaled = true
            arrow.Font = Enum.Font.Gotham
            arrow.Parent = dropdownButton
            
            -- Lista de opções
            local optionsList = Instance.new("Frame")
            optionsList.Size = UDim2.new(1, -20, 0, math.min(#values * 30, 150))
            optionsList.Position = UDim2.new(0, 10, 1, -8)
            optionsList.BackgroundColor3 = Theme.Secondary
            optionsList.BorderSizePixel = 0
            optionsList.Parent = dropdownFrame
            optionsList.Visible = false
            optionsList.ZIndex = 10
            
            CreateCorner(optionsList, 6)
            CreateStroke(optionsList, Theme.Border)
            
            local optionsScroll = Instance.new("ScrollingFrame")
            optionsScroll.Size = UDim2.new(1, 0, 1, 0)
            optionsScroll.Position = UDim2.new(0, 0, 0, 0)
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 4
            optionsScroll.ScrollBarImageColor3 = Theme.Accent
            optionsScroll.Parent = optionsList
            
            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.FillDirection = Enum.FillDirection.Vertical
            optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            optionsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            optionsLayout.Parent = optionsScroll
            
            local selectedValues = {}
            if multi and type(default) == "table" then
                for _, v in pairs(default) do
                    selectedValues[v] = true
                end
            end
            
            for i, value in pairs(values) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.BackgroundColor3 = Theme.Secondary
                optionButton.BorderSizePixel = 0
                optionButton.Text = value
                optionButton.TextColor3 = Theme.Text
                optionButton.TextScaled = true
                optionButton.Font = Enum.Font.Gotham
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.Parent = optionsScroll
                
                local optionPadding = Instance.new("UIPadding")
                optionPadding.PaddingLeft = UDim.new(0, 10)
                optionPadding.Parent = optionButton
                
                if multi then
                    local checkbox = Instance.new("Frame")
                    checkbox.Size = UDim2.new(0, 16, 0, 16)
                    checkbox.Position = UDim2.new(1, -26, 0.5, -8)
                    checkbox.BackgroundColor3 = selectedValues[value] and Theme.Accent or Theme.Background
                    checkbox.BorderSizePixel = 0
                    checkbox.Parent = optionButton
                    
                    CreateCorner(checkbox, 3)
                    CreateStroke(checkbox, Theme.Border)
                    
                    if selectedValues[value] then
                        local checkmark = Instance.new("TextLabel")
                        checkmark.Size = UDim2.new(1, 0, 1, 0)
                        checkmark.BackgroundTransparency = 1
                        checkmark.Text = "✓"
                        checkmark.TextColor3 = Theme.Text
                        checkmark.TextScaled = true
                        checkmark.Font = Enum.Font.GothamBold
                        checkmark.Parent = checkbox
                    end
                end
                
                optionButton.MouseButton1Click:Connect(function()
                    if multi then
                        selectedValues[value] = not selectedValues[value]
                        checkbox.BackgroundColor3 = selectedValues[value] and Theme.Accent or Theme.Background
                        
                        if selectedValues[value] then
                            local checkmark = Instance.new("TextLabel")
                            checkmark.Size = UDim2.new(1, 0, 1, 0)
                            checkmark.BackgroundTransparency = 1
                            checkmark.Text = "✓"
                            checkmark.TextColor3 = Theme.Text
                            checkmark.TextScaled = true
                            checkmark.Font = Enum.Font.GothamBold
                            checkmark.Parent = checkbox
                        else
                            for _, child in pairs(checkbox:GetChildren()) do
                                if child:IsA("TextLabel") then
                                    child:Destroy()
                                end
                            end
                        end
                        
                        local selectedCount = 0
                        for _ in pairs(selectedValues) do
                            if selectedValues[_] then
                                selectedCount = selectedCount + 1
                            end
                        end
                        
                        dropdownButton.Text = selectedCount > 0 and selectedCount .. " selecionado(s)" or "Selecione..."
                    else
                        dropdownButton.Text = value
                        optionsList.Visible = false
                        CreateTween(arrow, {Rotation = 0}, 0.2)
                        
                        if config.Callback then
                            config.Callback(value)
                        end
                    end
                end)
                
                optionButton.MouseEnter:Connect(function()
                    CreateTween(optionButton, {BackgroundColor3 = Theme.Background}, 0.2)
                end)
                
                optionButton.MouseLeave:Connect(function()
                    CreateTween(optionButton, {BackgroundColor3 = Theme.Secondary}, 0.2)
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(function()
                optionsList.Visible = not optionsList.Visible
                CreateTween(arrow, {Rotation = optionsList.Visible and 180 or 0}, 0.2)
                
                if optionsList.Visible then
                    dropdownFrame.Size = UDim2.new(1, 0, 0, (description ~= "" and 80 or 60) + math.min(#values * 30, 150) + 8)
                else
                    dropdownFrame.Size = UDim2.new(1, 0, 0, description ~= "" and 80 or 60)
                end
            end)
            
            -- Função SetValue para multi dropdown
            function dropdown:SetValue(newValues)
                if multi then
                    selectedValues = newValues or {}
                    
                    for _, optionButton in pairs(optionsScroll:GetChildren()) do
                        if optionButton:IsA("TextButton") then
                            local value = optionButton.Text
                            local checkbox = optionButton:FindFirstChild("Frame")
                            if checkbox then
                                checkbox.BackgroundColor3 = selectedValues[value] and Theme.Accent or Theme.Background
                                
                                -- Remove checkmarks
                                for _, child in pairs(checkbox:GetChildren()) do
                                    if child:IsA("TextLabel") then
                                        child:Destroy()
                                    end
                                end
                                
                                -- Add checkmark if selected
                                if selectedValues[value] then
                                    local checkmark = Instance.new("TextLabel")
                                    checkmark.Size = UDim2.new(1, 0, 1, 0)
                                    checkmark.BackgroundTransparency = 1
                                    checkmark.Text = "✓"
                                    checkmark.TextColor3 = Theme.Text
                                    checkmark.TextScaled = true
                                    checkmark.Font = Enum.Font.GothamBold
                                    checkmark.Parent = checkbox
                                end
                            end
                        end
                    end
                    
                    local selectedCount = 0
                    for _ in pairs(selectedValues) do
                        if selectedValues[_] then
                            selectedCount = selectedCount + 1
                        end
                    end
                    
                    dropdownButton.Text = selectedCount > 0 and selectedCount .. " selecionado(s)" or "Selecione..."
                end
            end
            
            return dropdown
        end
        
        window.Tabs[tabName] = tab
        
        -- Ativar primeira aba por padrão
        if #window.Tabs == 1 then
            tabButton.BackgroundColor3 = Theme.Accent
            tabButton.TextColor3 = Theme.Text
            tabContent.Visible = true
        end
        
        return tab
    end
    
    -- Função Dialog
    function window:Dialog(config)
        local title = config.Title or "Dialog"
        local content = config.Content or "Conteúdo do dialog"
        local buttons = config.Buttons or {{Title = "OK", Callback = function() end}}
        
        -- Overlay
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.Position = UDim2.new(0, 0, 0, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BorderSizePixel = 0
        overlay.Parent = screenGui
        overlay.ZIndex = 100
        
        -- Dialog frame
        local dialogFrame = Instance.new("Frame")
        dialogFrame.Size = UDim2.new(0, 400, 0, 200)
        dialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        dialogFrame.BackgroundColor3 = Theme.Background
        dialogFrame.BorderSizePixel = 0
        dialogFrame.Parent = overlay
        dialogFrame.ZIndex = 101
        
        CreateCorner(dialogFrame, 12)
        CreateStroke(dialogFrame, Theme.Border)
        
        -- Título do dialog
        local dialogTitle = Instance.new("TextLabel")
        dialogTitle.Size = UDim2.new(1, -20, 0, 30)
        dialogTitle.Position = UDim2.new(0, 10, 0, 10)
        dialogTitle.BackgroundTransparency = 1
        dialogTitle.Text = title
        dialogTitle.TextColor3 = Theme.Text
        dialogTitle.TextScaled = true
        dialogTitle.Font = Enum.Font.GothamBold
        dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
        dialogTitle.Parent = dialogFrame
        dialogTitle.ZIndex = 102
        
        -- Conteúdo do dialog
        local dialogContent = Instance.new("TextLabel")
        dialogContent.Size = UDim2.new(1, -20, 0, 80)
        dialogContent.Position = UDim2.new(0, 10, 0, 50)
        dialogContent.BackgroundTransparency = 1
        dialogContent.Text = content
        dialogContent.TextColor3 = Theme.TextSecondary
        dialogContent.TextScaled = true
        dialogContent.Font = Enum.Font.Gotham
        dialogContent.TextXAlignment = Enum.TextXAlignment.Left
        dialogContent.TextWrapped = true
        dialogContent.Parent = dialogFrame
        dialogContent.ZIndex = 102
        
        -- Container de botões
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -20, 0, 40)
        buttonContainer.Position = UDim2.new(0, 10, 1, -50)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = dialogFrame
        buttonContainer.ZIndex = 102
        
        local buttonLayout = Instance.new("UIListLayout")
        buttonLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        buttonLayout.Padding = UDim.new(0, 10)
        buttonLayout.Parent = buttonContainer
        
        for _, buttonConfig in pairs(buttons) do
            local dialogButton = Instance.new("TextButton")
            dialogButton.Size = UDim2.new(0, 80, 0, 30)
            dialogButton.BackgroundColor3 = buttonConfig.Title == "Confirm" and Theme.Accent or Theme.Secondary
            dialogButton.BorderSizePixel = 0
            dialogButton.Text = buttonConfig.Title
            dialogButton.TextColor3 = Theme.Text
            dialogButton.TextScaled = true
            dialogButton.Font = Enum.Font.GothamBold
            dialogButton.Parent = buttonContainer
            dialogButton.ZIndex = 102
            
            CreateCorner(dialogButton, 6)
            
            dialogButton.MouseButton1Click:Connect(function()
                if buttonConfig.Callback then
                    buttonConfig.Callback()
                end
                overlay:Destroy()
            end)
            
            -- Efeito hover
            dialogButton.MouseEnter:Connect(function()
                local newColor = buttonConfig.Title == "Confirm" and Color3.fromRGB(98, 111, 252) or Theme.Background
                CreateTween(dialogButton, {BackgroundColor3 = newColor}, 0.2)
            end)
            
            dialogButton.MouseLeave:Connect(function()
                local originalColor = buttonConfig.Title == "Confirm" and Theme.Accent or Theme.Secondary
                CreateTween(dialogButton, {BackgroundColor3 = originalColor}, 0.2)
            end)
        end
        
        -- Animação de entrada
        dialogFrame.Size = UDim2.new(0, 0, 0, 0)
        CreateTween(dialogFrame, {Size = UDim2.new(0, 400, 0, 200)}, 0.3, Enum.EasingStyle.Back)
    end
    
    -- Animação de entrada da janela
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    CreateTween(mainFrame, {Size = windowSize}, 0.5, Enum.EasingStyle.Back)
    
    -- Sistema de arrastar janela
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return window
end
