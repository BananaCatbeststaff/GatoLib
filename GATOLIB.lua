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
    local duracao = config.Duração or 5
    
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
        wait(0.3)
        notifyFrame:Destroy()
    end
    
    closeButton.MouseButton1Click:Connect(removeNotification)
    
    -- Auto-remover após duração
    if duracao > 0 then
        spawn(function()
            wait(duracao)
            if notifyFrame.Parent then
                removeNotification()
            end
        end)
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
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Parent = contentContainer
        tabContent.Visible = false
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.FillDirection = Enum.FillDirection.Vertical
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        -- Auto-resize canvas
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
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
