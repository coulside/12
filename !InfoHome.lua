script_name("InfoHome")
script_author("Trinity Coders")
script_version("0.1")

local var_0_0 = require("lib.samp.events")
local imgui = require("imgui")
imgui.ToggleButton = require('imgui_addons').ToggleButton
local fa = require("fAwesome5")
local effil = require("effil")
local var_0_4 = require("requests")
local encoding = require("encoding")
encoding.default = "CP1251"
u8 = encoding.UTF8
local requests = require 'requests'
local LICENSE_OK = false

local prefix = "{0066FF}[TRP]: {FFFFFF}"
local var_0_7
local var_0_8
local var_0_9 = false 
local dataBase
local dataTime

local main_window_state = imgui.ImBool(false)
local showTime = imgui.ImBool(false)
local var_0_12 = 0
local var_0_13 = {}
local var_0_14 = {}
local var_0_15 = {}
local var_0_16 = {}
local var_0_17 = 0
local var_0_18 = {
	gps = imgui.ImBuffer(500),
	park = imgui.ImBuffer(500),
	area = imgui.ImBuffer(500),
	lastOwner = imgui.ImBuffer(500)
}
local var_0_19 = imgui.ImBool(false)
local fa0 = imgui.ImBool(false)
local offplayer = imgui.ImBool(false)
local chateses = imgui.ImBool(false)


if not doesDirectoryExist(getWorkingDirectory() .. "\\config\\InfoHome") then
	createDirectory(getWorkingDirectory() .. "\\config\\InfoHome")
end

if not doesDirectoryExist(getWorkingDirectory() .. "\\resource\\fonts\\") then
	createDirectory(getWorkingDirectory() .. "\\resource\\fonts\\")
end

if not doesFileExist(getWorkingDirectory() .. "\\resource\\fonts\\fAwesome5.ttf") then
	downloadUrlToFile("https://dl.dropboxusercontent.com/s/zgfq5juurf7yvru/fAwesome5.ttf", getWorkingDirectory() .. "\\resource\\fonts\\fAwesome5.ttf")
end

local fa1
local fa2 = imgui.ImGlyphRanges({
	fa.min_range,
	fa.max_range
})

function imgui.BeforeDrawFrame()
	if fa1 == nil then
		local font_config = imgui.ImFontConfig()

		font_config.MergeMode = true
		font_config.SizePixels = 15
		font_config.GlyphExtraSpacing.x = 0.1
		font_config.GlyphOffset.y = 1.5
		fa1 = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. "\\resource\\fonts\\fAwesome5.ttf", font_config.SizePixels, font_config, fa2)
	end
end

function onD3DPresent()
	if var_0_8 ~= nil and var_0_9 and var_0_7 then
		if var_0_8 ~= "err" then
			var_0_7.getBanlist()
		end

		var_0_9 = false
	end
end

local function daysSinceLastConnect(lastConnectString)
  if not lastConnectString then return 0 end --Never connected
  local _, _, d, m, y = string.match(lastConnectString, "(%d+):(%d+) (%d+)/(%d+)/(%d+)")
  if not d or not m or not y then return nil end --Invalid format
  local lastConnectTime = os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d)})
  local currentTime = os.time()
  return math.floor((currentTime - lastConnectTime) / (60 * 60 * 24))
end

local off_players_days = 19

numPage = 1

function imgui.OnDrawFrame()
	if main_window_state.v then
		local var_5_0, var_5_1 = getScreenResolution()
		local var_5_2 = 1020
		local var_5_3 = 470

		imgui.SetNextWindowSize(imgui.ImVec2(var_5_2, var_5_3))
		imgui.SetNextWindowPos(imgui.ImVec2(var_5_0 / 2, var_5_1 / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8("InfoHome " .. thisScript().version .. " | Trinity Coders  "), main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

		imgui.BeginChild("##UP", imgui.ImVec2(0, 35), true)
		imgui.BeginChild("##SIGN", imgui.ImVec2(25, 25), false)
		
		if imgui.Checkbox(u8("##SIGN"), fa0) then
			var_0_19.v = false
			offplayer.v = false
		end

		imgui.Hint(u8("Если включена данная функция, то будут выводится только дома с табличками (/saleset)."))
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##SEARCH_GPS", imgui.ImVec2(60, 25), false)

		if imgui.NewInputText("##COLUMNS_SEARCH_GPS", var_0_18.gps, 60, u8("Дома"), 2) then
			-- block empty
		end

		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##SEARCH_PARK", imgui.ImVec2(45, 25), false)

		if imgui.NewInputText("##COLUMNS_SEARCH_PARK", var_0_18.park, 40, "1-3G", 2) then
			-- block empty
		end

		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##SEARCH_AREA", imgui.ImVec2(110, 25), false)

		if imgui.NewInputText("##COLUMNS_SEARCH_AREA", var_0_18.area, 105, u8("Район"), 2) then
			-- block empty
		end

		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##SEARCH_OWNER", imgui.ImVec2(200, 25), false)

		if imgui.NewInputText("##COLUMNS_SEARCH_NAME", var_0_18.lastOwner, 195, u8("Владелец"), 2) then
			-- block empty
		end
		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##SEARCH_TEXT", imgui.ImVec2(100, 25), false)
		imgui.Text(fa.ICON_HOME .. u8(" Домов: " .. #dataBase.house))
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##SEARCH_BUTTON", imgui.ImVec2(420, 25), false)
		imgui.SameLine()
		
		if imgui.Checkbox(u8("БАНЫ  ##ONLY_BAN"), var_0_19) then
			fa0.v = false
			offplayer.v = false
		end

		imgui.Hint(u8("Если включена данная функция, то будут выводится только дома в бане."))
		imgui.SameLine()
		
		if imgui.Checkbox(u8("ОФФЛАЙН  ##OFFLAYN_DAYS"), offplayer) then
			fa0.v = false
			var_0_19.v = false
		end
		
		imgui.Hint(u8("Если включена данная функция, то будут выводится только неактивные владельцы домов."))
		imgui.SameLine()
			
		if dataBase.settings.chates then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.0, 0.0, 1.0)) -- Задаем красный цвет для кнопки
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.0, 0.0, 1.0)) -- Задаем чуть более темный красный при наведении
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.6, 0.0, 0.0, 1.0)) -- Задаем еще более темный красный при нажатии

			if imgui.Button(fa.ICON_COMMENT .. u8("##ВЫКЛ"), imgui.ImVec2(50, 20)) then
				dataBase.settings.chates = false

				saveDB()
				sampAddChatMessage(prefix .. "Автоматическое добавление табличек/обновление домов - деактивировано.", -1)
			end
			
			imgui.PopStyleColor(3)
			imgui.Hint(u8("На данных момент автоматическое добавление - активировано. После нажатия на клавишу оно деактивируется."))
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 0.0, 1.0)) -- Задаем зеленый цвет для кнопки
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.8, 0.0, 1.0)) -- Задаем чуть более темный зеленый при наведении
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.0, 0.6, 0.0, 1.0))
			if imgui.Button(fa.ICON_COMMENT .. u8("##ВКЛ"), imgui.ImVec2(50, 20)) then
				dataBase.settings.chates = true
				
				saveDB()
				sampAddChatMessage(prefix .. "Автоматическое добавление табличек/обновление домов - активировано.", -1)
			end
			
			imgui.PopStyleColor(3)
			imgui.Hint(u8("На данных момент автоматическое добавление - деактивировано. После нажатия на клавишу оно активируется."))
		end	
			
		imgui.SameLine()
	
		if dataBase.settings.addToBase then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.0, 0.0, 1.0)) -- Задаем красный цвет для кнопки
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.8, 0.0, 0.0, 1.0)) -- Задаем чуть более темный красный при наведении
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.6, 0.0, 0.0, 1.0)) -- Задаем еще более темный красный при нажатии

			if imgui.Button(fa.ICON_POWER_OFF .. u8("##ВЫКЛ"), imgui.ImVec2(50, 20)) then
				dataBase.settings.addToBase = false

				saveDB()
				sampAddChatMessage(prefix .. "Автоматическое добавление домов - деактивировано.", -1)
			end
			
			imgui.PopStyleColor(3)
			imgui.Hint(u8("На данных момент автоматическое добавление - активировано. После нажатия на клавишу оно деактивируется. Так же это можно сделать командой: /home off"))
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 1.0, 0.0, 1.0)) -- Задаем зеленый цвет для кнопки
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.8, 0.0, 1.0)) -- Задаем чуть более темный зеленый при наведении
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.0, 0.6, 0.0, 1.0)) -- Задаем еще более темный зеленый при нажатии
			if imgui.Button(fa.ICON_POWER_OFF .. u8("##ВКЛ"), imgui.ImVec2(50, 20)) then
				dataBase.settings.addToBase = true

				saveDB()
				sampAddChatMessage(prefix .. "Автоматическое добавление домов - активировано.", -1)
			end
			
			imgui.PopStyleColor(3)
			imgui.Hint(u8("На данных момент автоматическое добавление - деактивировано. После нажатия на клавишу оно активируется. Так же это можно сделать командой: /home on"))
		end

		imgui.SameLine()
		
		if imgui.Button(fa.ICON_CLOUD_DOWNLOAD_ALT .. u8("##Обновить баны"), imgui.ImVec2(50, 20)) then
			
			if not var_0_7 then
				var_0_7 = TrinityApi()

				var_0_7.getReactLabCookie()
			end
			
			var_0_9 = true
		end	
		
		imgui.Hint(u8("Нажав на кнопку обновится список домов в банлисте."))
		imgui.SameLine()
		
		if imgui.Button(fa.ICON_TRASH .. u8(""), imgui.ImVec2(50, 20)) then
			imgui.OpenPopup(u8("Удалить базу данных?"))
		end
        
		imgui.Hint(u8("Нажав на кнопку - все добавленные дома автоматически удалятся."))
		imgui.SetNextWindowSize(imgui.ImVec2(150, 60))
		imgui.SameLine()

		if imgui.BeginPopupModal(u8("Удалить базу данных?"), true, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			if imgui.Button(u8("ДА##DELETE_DB"), imgui.ImVec2(65, 25)) then
				dataBase.house = {}

				saveDB()
				sampAddChatMessage(prefix .. "База данных домов, была очищена полностью.", -1)
				imgui.CloseCurrentPopup()
			end
			
			imgui.SameLine()

			if imgui.Button(u8("НЕТ##DELETE_DB"), imgui.ImVec2(65, 25)) then
				imgui.CloseCurrentPopup()
			end
			
			imgui.EndPopup()
		end
		
--		if imgui.Button(fa.ICON_COGS .. u8(""), imgui.ImVec2(28, 20)) then
--			imgui.OpenPopup(u8("Настройки и общая информация"))
--		end
--		
--		imgui.Hint(u8("Нажав на кнопку - все добавленные дома автоматически удалятся."))
--		imgui.SetNextWindowSize(imgui.ImVec2(1020, 470))
--		imgui.SameLine()
--
--		if imgui.BeginPopupModal(u8("Настройки и общая информация"), true, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
--
--
--			imgui.SetCursorPosX(450, 460)
--			imgui.SetCursorPosY(430, 460)
--			if imgui.Button(u8("ЗАКРЫТЬ##DELETE_DB"), imgui.ImVec2(65, 25)) then
--				imgui.CloseCurrentPopup()
--			end
--			
--			imgui.EndPopup()
--		end
--		
		imgui.EndChild()
		imgui.EndChild()

		local var_5_4 = imgui.ImVec2(-1, -1)

		if #dataBase.house > 0 and not var_0_19.v and not fa0.v and not offplayer.v and var_0_18.gps.v == "" and var_0_18.area.v == "" and var_0_18.lastOwner.v == "" and var_0_18.park.v == "" then
			var_5_4 = imgui.ImVec2(0, 350)
		end

		imgui.BeginChild("##CENTER", var_5_4, true)

		if #dataBase.house > 0 then
			imgui.Separator()
			imgui.Columns(8, "COLUMNS_UP", true)
			imgui.SetColumnWidth(-1, 35)
			imgui.CenterColumnText(fa.ICON_MAP_SIGNS)
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 35)
			imgui.CenterColumnText(fa.ICON_USER_MINUS)
			imgui.Hint(u8("Ниже кнопки удаление не нужных домов."))
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 35)
			imgui.CenterColumnText(fa.ICON_WAREHOUSE)
			imgui.Hint(u8("Кол-во парковок дома."))
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 40)
			imgui.CenterColumnText(fa.ICON_MAP_MARKER_ALT .. u8(" "))
			imgui.Hint(u8("Нажав на ID дома - он будет скопирован. Так же вывод информации о слете дома."))
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 115)
			imgui.CenterColumnText(fa.ICON_CHART_AREA .. u8(" РАЙОНЫ"))
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 180)
			imgui.CenterColumnText(fa.ICON_USER .. u8(" ВЛАДЕЛЕЦ"))
			imgui.SameLine()
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			imgui.Hint(u8("Нажав на ник игрока - он будет скопирован и откроется меню 5-ти старых владельцев. Так же можно делать и с GPS, РАЙОНАМИ и ПРИЧИНОЙ БАНА."))
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 130)
			imgui.CenterColumnText(fa.ICON_CLOCK .. u8(" ВРЕМЯ CЛЕТА"))
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 370)
			imgui.CenterColumnText(fa.ICON_USER_SLASH .. u8(" НАКАЗАНИЯ ВЛАДЕЛЬЦА"))
			imgui.Columns(1)
			imgui.Separator()
			
			if not var_0_19.v and not fa0.v and not offplayer.v and var_0_18.gps.v == "" and var_0_18.area.v == "" and var_0_18.lastOwner.v == "" and var_0_18.park.v == "" then
				baseSplit = splitTable(dataBase.house, 100)

				if baseSplit ~= nil then
					if numPage > #baseSplit then
						numPage = #baseSplit
					end

					for iter_5_0, iter_5_1 in ipairs(baseSplit) do
						if numPage == iter_5_0 then
							for iter_5_2 = #iter_5_1, 1, -1 do
								local var_5_5 = iter_5_1[iter_5_2].VAL
								local var_5_6 = iter_5_1[iter_5_2].ID

								imgui.GetDate(var_5_6)
								ownerPlayer(var_5_6)
								signLogs(var_5_6)
							end
						end
					end
				end
			else
				for iter_5_3 = #dataBase.house, 1, -1 do
				 local ownerName = dataBase.house[iter_5_3].lastOwner
				 local daysAbsent = daysSinceLastConnect(dataBase.house[iter_5_3].lastConnect) or 0
				 
					if var_0_19.v then
						if var_0_13[iter_5_3] ~= nil and seaTable(iter_5_3) then
							imgui.GetDate(iter_5_3)
						end
						elseif offplayer.v then
							if daysAbsent >= 19 and daysAbsent <= 22 then

							local var_11_0 = sampGetPlayerIdByNickname(ownerName)

							local displayText = string.format("%s [ID:%d] [%d]", ownerName, var_11_0 or 0, daysAbsent)

							if var_11_0 then
								imgui.Text(u8(displayText))
							else
								imgui.GetDate(iter_5_3)
							end
						end
					elseif fa0.v then
						if dataBase.house[iter_5_3].sign.name ~= nil and seaTable(iter_5_3) then
							imgui.GetDate(iter_5_3)
						end
					elseif seaTable(iter_5_3) then
						imgui.GetDate(iter_5_3)
					end

					ownerPlayer(iter_5_3)
					signLogs(iter_5_3)
				end
			end
		else
			imgui.Text(fa.ICON_ARCHIVE .. u8(" База данных пустая. Включите скрипт для добавление домов."))
		end
	
		imgui.EndChild()

		if #dataBase.house > 0 and not var_0_19.v and not fa0.v and not offplayer.v and var_0_18.gps.v == "" and var_0_18.area.v == "" and var_0_18.lastOwner.v == "" and var_0_18.park.v == "" then
			imgui.BeginChild("##BUTTON_MENU_FOOTER", imgui.ImVec2(-1, 45), true)

			if baseSplit ~= nil then
				makePagerButton(numPage, #baseSplit, 4, 4)
			end
			
			imgui.EndChild()
		end
		
		imgui.End()
	end
end

function ownerPlayer(arg_6_0)
	imgui.SetNextWindowSize(imgui.ImVec2(500, 480))

	if imgui.BeginPopupModal(u8("Владельцы | Дом: #" .. dataBase.house[arg_6_0].gps .. "##" .. arg_6_0), true, imgui.WindowFlags.NoResize) then
		imgui.BeginChild("##BEGIN_CENTER" .. arg_6_0, imgui.ImVec2(500, 400), true)

		for iter_6_0 = #dataBase.house[arg_6_0].owners, 1, -1 do
			local var_6_0 = dataBase.house[arg_6_0].owners[iter_6_0]

			imgui.BeginChild("##BEGIN_OWNER" .. iter_6_0, imgui.ImVec2(360, 25), false)

			if dataBase.house[arg_6_0].lastOwner == "ПРОДАЕТСЯ" then
				imgui.Text(fa.ICON_WINDOW_CLOSE .. " " .. iter_6_0 .. ") " .. var_6_0.name)
			elseif iter_6_0 == #dataBase.house[arg_6_0].owners then
				imgui.Text(fa.ICON_CHECK_SQUARE .. " " .. iter_6_0 .. ") " .. var_6_0.name)
			else
				imgui.Text(fa.ICON_WINDOW_CLOSE .. " " .. iter_6_0 .. ") " .. var_6_0.name)
			end

			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##BEGIN_BUTTON" .. iter_6_0, imgui.ImVec2(90, 25), false)

			if imgui.Button(fa.ICON_CLOCK .. "##" .. iter_6_0, imgui.ImVec2(25, 20)) then
				setClipboardText(var_6_0.time)
			end

			imgui.Hint(u8("Дата добавления владельца: " .. var_6_0.time))
			imgui.SameLine()

			if imgui.Button(fa.ICON_TRASH .. "##" .. iter_6_0, imgui.ImVec2(25, 20)) then
				table.remove(dataBase.house[arg_6_0].owners, iter_6_0)
				saveDB()
			end

			imgui.SameLine()

			if imgui.Button(fa.ICON_COPY .. "##" .. iter_6_0, imgui.ImVec2(25, 20)) then
				setClipboardText(var_6_0.name)
			end

			imgui.EndChild()
		end
		
		imgui.SetCursorPosY(370)
		
		if dataBase.house[arg_6_0].lastConnect == nil then
			lastConnected = "неизвестно."
		else
			lastConnected = dataBase.house[arg_6_0].lastConnect
		end
		
		imgui.Text(u8("Последний онлайн владельца — " .. lastConnected))
		
		imgui.SetCursorPosY(460)
		
		imgui.EndChild()

		if imgui.Button(fa.ICON_TIMES .. u8(" ЗАКРЫТЬ##" .. arg_6_0), imgui.ImVec2(485, 25)) then
			imgui.CloseCurrentPopup()
		end

		imgui.EndPopup()
	end
end

function signLogs(arg_7_0)
	imgui.SetNextWindowSize(imgui.ImVec2(700, 265))

	if imgui.BeginPopupModal(u8("Лог табличек | Дом: #" .. dataBase.house[arg_7_0].gps .. "##" .. arg_7_0), true, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
		imgui.BeginChild("##BEGIN_CENTER_SIGN" .. arg_7_0, imgui.ImVec2(0, 200), true)

		for iter_7_0 = #dataBase.house[arg_7_0].signLog, 1, -1 do
			local var_7_0 = dataBase.house[arg_7_0].signLog[iter_7_0]

			imgui.Hint(u8("Время лога: " .. var_7_0.time))
			imgui.Text(fa.ICON_CLOCK)
			imgui.SameLine()
			imgui.Text(u8(" " .. iter_7_0 .. ") " .. var_7_0.text))
		end

		imgui.EndChild()

		if imgui.Button(fa.ICON_TIMES .. u8(" ЗАКРЫТЬ##SIGN_" .. arg_7_0), imgui.ImVec2(-1, 25)) then
			imgui.CloseCurrentPopup()
		end

		imgui.EndPopup()
	end
end

function seaTable(arg_8_0)
	if arg_8_0 ~= nil then
		local var_8_0 = var_0_18.gps.v == nil and "" or var_0_18.gps.v
		local var_8_1 = var_0_18.area.v == nil and "" or var_0_18.area.v
		local var_8_2 = var_0_18.lastOwner.v == nil and "" or var_0_18.lastOwner.v
		local var_8_3 = var_0_18.park.v == nil and "" or var_0_18.park.v

		if dataBase.house[arg_8_0].gps:lower():find(var_8_0:lower(), nil, true) and dataBase.house[arg_8_0].area:lower():find(var_8_1:lower(), nil, true) and dataBase.house[arg_8_0].lastOwner:lower():find(var_8_2:lower(), nil, true) and dataBase.house[arg_8_0].park:lower():find(var_8_3:lower(), nil, true) then
			return true
		end
	end

	return false
end

function makePagerButton(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
	imgui.SetCursorPosY(10)

	if imgui.Button("<<", imgui.ImVec2(88, 25)) then
		numPage = 1
	end

	imgui.SameLine()

	if arg_9_2 < arg_9_0 and arg_9_0 < arg_9_1 - arg_9_3 then
		for iter_9_0 = arg_9_0 - arg_9_2, arg_9_0 + arg_9_3 do
			imgui.SetCursorPosY(iter_9_0 == arg_9_0 and 5 or 10)

			if imgui.Button(iter_9_0 == arg_9_0 and "[" .. iter_9_0 .. "]" or "" .. iter_9_0 .. "", iter_9_0 == arg_9_0 and imgui.ImVec2(85, 35) or imgui.ImVec2(85, 25)) then
				numPage = iter_9_0
			end

			if iter_9_0 ~= arg_9_0 + arg_9_3 then
				imgui.SameLine()
			end
		end
	elseif arg_9_0 <= arg_9_2 then
		iSlice = 1 + arg_9_2 - arg_9_0

		for iter_9_1 = 1, arg_9_0 + (arg_9_3 + iSlice) do
			if iter_9_1 < 1 or arg_9_1 < iter_9_1 then
				imgui.SetCursorPosY(10)
				imgui.Button("##" .. iter_9_1, imgui.ImVec2(85, 25))
			else
				imgui.SetCursorPosY(iter_9_1 == arg_9_0 and 5 or 10)

				if imgui.Button(iter_9_1 == arg_9_0 and "[" .. iter_9_1 .. "]" or "" .. iter_9_1 .. "", iter_9_1 == arg_9_0 and imgui.ImVec2(85, 30) or imgui.ImVec2(85, 25)) then
					numPage = iter_9_1
				end
			end

			if iter_9_1 ~= arg_9_0 + (arg_9_3 + iSlice) then
				imgui.SameLine()
			end
		end
	else
		iSlice = arg_9_3 - (arg_9_1 - arg_9_0)

		for iter_9_2 = arg_9_0 - (arg_9_2 + iSlice), arg_9_1 do
			if iter_9_2 < 1 or arg_9_1 < iter_9_2 then
				imgui.SetCursorPosY(10)
				imgui.Button("##" .. iter_9_2, imgui.ImVec2(88, 25))
			else
				imgui.SetCursorPosY(iter_9_2 == arg_9_0 and 5 or 10)

				if imgui.Button(iter_9_2 == arg_9_0 and "[" .. iter_9_2 .. "]" or "" .. iter_9_2 .. "", iter_9_2 == arg_9_0 and imgui.ImVec2(85, 30) or imgui.ImVec2(85, 25)) then
					numPage = iter_9_2
				end
			end

			if iter_9_2 ~= arg_9_1 then
				imgui.SameLine()
			end
		end
	end

	imgui.SameLine()
	imgui.SetCursorPosY(10)

	if imgui.Button(">>", imgui.ImVec2(85, 25)) then
		numPage = arg_9_1	
	end
end

function splitTable(arg_10_0, arg_10_1)
	local var_10_0 = {}

	if #arg_10_0 > 0 then
		for iter_10_0 = math.ceil(#arg_10_0 / arg_10_1), 1, -1 do
			local var_10_1 = {}
			local var_10_2 = (iter_10_0 - 1) * arg_10_1

			for iter_10_1 = var_10_2 + 1, var_10_2 + arg_10_1 do
				if arg_10_0[iter_10_1] ~= nil then
					table.insert(var_10_1, {
						ID = iter_10_1,
						VAL = arg_10_0[iter_10_1]
					})
				end
			end

			table.insert(var_10_0, var_10_1)
		end
	end

	return var_10_0
end

function imgui.GetDate(arg_11_0)
	imgui.Columns(8, "COLUMNS_CENTER", true)
	imgui.SetColumnWidth(-1, 35)

	if dataBase.house[arg_11_0].sign.name ~= nil then
		if imgui.Selectable(" " .. fa.ICON_MAP_SIGNS .. "##" .. arg_11_0, false) and #dataBase.house[arg_11_0].signLog > 0 then
			imgui.OpenPopup(u8("Лог табличек | Дом: #" .. dataBase.house[arg_11_0].gps .. "##" .. arg_11_0))
		end

		if #dataBase.house[arg_11_0].signLog > 0 then
			imgui.Hint(u8("Дата внесения таблички: " .. dataBase.house[arg_11_0].sign.date .. "\nЦена по табличке: " .. dataBase.house[arg_11_0].sign.price .. "$\nЛКМ - для открытия меню"))
		else
			imgui.Hint(u8("Дата внесения таблички: " .. dataBase.house[arg_11_0].sign.date .. "\nЦена по табличке: " .. dataBase.house[arg_11_0].sign.price .. "$"))
		end
	elseif #dataBase.house[arg_11_0].signLog > 0 then
		if imgui.Selectable(" " .. fa.ICON_LIST .. "##" .. arg_11_0, false) then
			imgui.OpenPopup(u8("Лог табличек | Дом: #" .. dataBase.house[arg_11_0].gps .. "##" .. arg_11_0))
		end

		imgui.Hint(u8("ЛКМ - для открытия меню"))
	else
		imgui.CenterColumnText(u8(""))
	end
	
	------------------------тут кнопка делит должна быть
	imgui.NextColumn()
	imgui.SetColumnWidth(-1, 35)
	
	local lastIndex = #dataBase.house
	
	if arg_11_0 < lastIndex then
		-- Кнопка удаления для всех домов, кроме последнего
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0, 0, 0))
	
		if imgui.Button("DEL##" .. arg_11_0, imgui.ImVec2(30, 20)) then
			imgui.OpenPopup("DEL_POPUP" .. arg_11_0)
		end
	
		imgui.PopStyleColor(3)
	
		if imgui.BeginPopup("DEL_POPUP" .. arg_11_0) then
			imgui.Text(u8("Удалить дом #") .. dataBase.house[arg_11_0].gps .. "?")
	
			if imgui.Button(u8("Да##YES") .. arg_11_0, imgui.ImVec2(60, 25)) then
				table.remove(dataBase.house, arg_11_0)
				saveDB()
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if imgui.Button(u8("Нет##NO") .. arg_11_0, imgui.ImVec2(60, 25)) then
				imgui.CloseCurrentPopup()
			end
	
			imgui.EndPopup()
		end
	else
		-- Последний дом: показываем иконку вместо кнопки
		local icon = fa.ICON_QUESTION_CIRCLE
		local icon_width = imgui.CalcTextSize(icon).x
		local cell_width = 30
		local offset = (cell_width - icon_width) / 2
		if offset < 0 then offset = 0 end
		imgui.SetCursorPosX(imgui.GetCursorPosX() + offset)
		imgui.TextDisabled(icon)
	
		if imgui.IsItemHovered() then
			imgui.BeginTooltip()
			imgui.Text(u8("Нельзя удалить последний дом :("))
			imgui.EndTooltip()
		end
	end

  if imgui.BeginPopupModal(u8("Удалить базу данных?."), true, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
  
    if imgui.Button(u8("ДА##DELETE_DB_CONFIRM"), imgui.ImVec2(65, 25)) then
        table.remove(dataBase.house)
        saveDB()
        imgui.CloseCurrentPopup()
    end

    imgui.SameLine()
    if imgui.Button(u8("НЕТ##DELETE_DB_CANCEL"), imgui.ImVec2(65, 25)) then
        imgui.CloseCurrentPopup()
    end
   imgui.EndPopup()
  end
	
	----------------------------------
	imgui.NextColumn()
	imgui.SetColumnWidth(-1, 35)
	imgui.CenterColumnText(u8(dataBase.house[arg_11_0].park))

	imgui.NextColumn()
	imgui.SetColumnWidth(-1, 40)
	imgui.CenterColumnText(u8(dataBase.house[arg_11_0].gps))
	
	if imgui.IsItemClicked() then
		setClipboardText(u8(dataBase.house[arg_11_0].gps))
		sampSendChat(u8("/gps h " .. dataBase.house[arg_11_0].gps))
		sampProcessChatInput(u8("/inf " .. dataBase.house[arg_11_0].gps))
	end
	
	imgui.NextColumn()
	imgui.SetColumnWidth(-1, 115)
	imgui.Text(u8(" " .. dataBase.house[arg_11_0].area))

	if imgui.IsItemClicked() then
		setClipboardText(u8(dataBase.house[arg_11_0].area))
	end

	imgui.NextColumn()
	imgui.SetColumnWidth(-1, 180)
---------------------------------------------вывод ID в табл1
	local function daysSinceLastConnect(lastConnectString)
	if not lastConnectString then return 0 end --Never connected
	local _, _, d, m, y = string.match(lastConnectString, "(%d+):(%d+) (%d+)/(%d+)/(%d+)")
	if not d or not m or not y then return nil end --Invalid format
	local lastConnectTime = os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d)})
	local currentTime = os.time()
	return math.floor((currentTime - lastConnectTime) / (60 * 60 * 24))
	end

	local var_11_0 = sampGetPlayerIdByNickname(dataBase.house[arg_11_0].lastOwner)

	local ownerName = dataBase.house[arg_11_0].lastOwner
	local daysAbsent = daysSinceLastConnect(dataBase.house[arg_11_0].lastConnect) or 0 -- 0 if never connected, nil if format error, otherwise days

	local displayText = string.format("%s [ID:%d] [%d]", ownerName, var_11_0 or 0, daysAbsent)  -- Improved formatting

	if var_11_0 then
		imgui.Text(u8(displayText))
	else
		imgui.Text(u8(string.format("%s [%d]", ownerName, daysAbsent))) -- Handle case where player ID is not found
	end

	if imgui.IsItemClicked() then
		setClipboardText(u8(ownerName))
		imgui.OpenPopup(u8("Владельцы | Дом: #" .. dataBase.house[arg_11_0].gps .. "##" .. arg_11_0))
	end
		
	imgui.NextColumn()
	imgui.SetColumnWidth(-1, 130)
	
	if showTime then
	  local foundData = false
	  local timeToCopy = nil
      for i = 1, #dataTime["Infaa"] do
		if dataTime["Infaa"][i].home == dataBase.house[arg_11_0].gps then
			timeToCopy = dataTime["Infaa"][i].time .. ":00 " .. dataTime["Infaa"][i].data
			imgui.CenterColumnText(u8(timeToCopy .. " "))
			foundData = true
			break
		end
	end
	if not foundData then
		imgui.CenterColumnText(u8("—"))
	end

	if imgui.IsItemClicked() and timeToCopy then
		setClipboardText(u8(timeToCopy))
	end
	else
	imgui.CenterColumnText(u8("—"))
	end
	
	imgui.NextColumn()
	
	if var_0_13[arg_11_0] ~= nil then
		local var_11_1 = var_0_13[arg_11_0].date.day .. ":" .. var_0_13[arg_11_0].date.month .. ":" .. var_0_13[arg_11_0].date.year

		imgui.Text(u8("[" .. var_11_1 .. "]  " .. var_0_13[arg_11_0].reason))
		imgui.Hint(u8("[" .. var_11_1 .. "]  " .. var_0_13[arg_11_0].reason))
	end
	
	imgui.Columns(1)
	imgui.Separator()
end

function var_0_0.onSetObjectMaterialText(arg_12_0, arg_12_1)
	local var_12_0 = replaceText(arg_12_1.text)

	if dataBase.settings.addToBase then
		if var_12_0:find("^%d+  %S+\n\n{ffffff}Это жилье продается за {33aa33}.* %${ffffff}.") then
			local var_12_1 = sampGetObjectHandleBySampId(arg_12_0)
			local var_12_2, var_12_3, var_12_4, var_12_5 = getObjectCoordinates(var_12_1)

			if var_12_2 then
				local var_12_6, var_12_7 = var_12_0:match("^(%d+)  (%S+)\n\n{ffffff}Это жилье продается за {33aa33}.* %${ffffff}.")

				if var_12_6 and var_12_7 then
					addFlatSell(var_12_6, var_12_7, var_12_3, var_12_4, var_12_5)
				end
			end
		elseif var_12_0:find("^%d+  %S+\n\n{ffffff}Владелец:{fbec5d} %S+\n\n{ffffff}.*\n\n{ffffff}.*") then
			local var_12_8 = sampGetObjectHandleBySampId(arg_12_0)
			local var_12_9, var_12_10, var_12_11, var_12_12 = getObjectCoordinates(var_12_8)

			if var_12_9 then
				local var_12_13, var_12_14, var_12_15 = var_12_0:match("^(%d+)  (%S+)\n\n{ffffff}Владелец:{fbec5d} (%S+)\n\n{ffffff}.*\n\n{ffffff}.*")

				if var_12_13 and var_12_14 and var_12_15 then
					local var_12_16 = {}

					if var_12_0:find("{ffffff}Владелец продает дом за {33aa33}%S+ %${ffffff}.") then
						local var_12_17 = var_12_0:match("{ffffff}Владелец продает дом за {33aa33}(%S+) %${ffffff}.")

						var_12_16 = {
							name = var_12_15,
							num = var_12_13,
							date = os.date("%X %d/%m/%Y"),
							price = var_12_17
						}
					end

					addFlatBuyer(var_12_16, var_12_13, var_12_14, var_12_15, var_12_10, var_12_11, var_12_12)
				end
			end
		elseif var_12_0:find("^%d+  %S+\n\n{ffffff}Владелец:{fbec5d} %S+\n\n{ffffff}.*") then
			local var_12_18 = sampGetObjectHandleBySampId(arg_12_0)
			local var_12_19, var_12_20, var_12_21, var_12_22 = getObjectCoordinates(var_12_18)

			if var_12_19 then
				local var_12_23, var_12_24, var_12_25 = var_12_0:match("^(%d+)  (%S+)\n\n{ffffff}Владелец:{fbec5d} (%S+)\n\n{ffffff}.*")

				if var_12_23 and var_12_24 and var_12_25 then
					local var_12_26 = {}

					if var_12_0:find("{ffffff}Владелец продает дом за {33aa33}%S+ %${ffffff}.") then
						local var_12_27 = var_12_0:match("{ffffff}Владелец продает дом за {33aa33}(%S+) %${ffffff}.")

						var_12_26 = {
							name = var_12_25,
							num = var_12_23,
							date = os.date("%X %d/%m/%Y"),
							price = var_12_27
						}
					end

					addFlatBuyer(var_12_26, var_12_23, var_12_24, var_12_25, var_12_20, var_12_21, var_12_22)
				end
			end
		elseif var_12_0:find("^%d+  %S+\n\n{ffffff}Владелец:{fbec5d} %S+") then
			local var_12_28 = sampGetObjectHandleBySampId(arg_12_0)
			local var_12_29, var_12_30, var_12_31, var_12_32 = getObjectCoordinates(var_12_28)

			if var_12_29 then
				local var_12_33, var_12_34, var_12_35 = var_12_0:match("^(%d+)  (%S+)\n\n{ffffff}Владелец:{fbec5d} (%S+)")

				if var_12_33 and var_12_34 and var_12_35 then
					local var_12_36 = {}

					if var_12_0:find("{ffffff}Владелец продает дом за {33aa33}%S+ %${ffffff}.") then
						local var_12_37 = var_12_0:match("{ffffff}Владелец продает дом за {33aa33}(%S+) %${ffffff}.")

						var_12_36 = {
							name = var_12_35,
							num = var_12_33,
							date = os.date("%X %d/%m/%Y"),
							price = var_12_37
						}
					end

					addFlatBuyer(var_12_36, var_12_33, var_12_34, var_12_35, var_12_30, var_12_31, var_12_32)
				end
			end
		end
	end
end


function addFlatSell(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4)
	if findNumHouse(arg_13_0) then
		if #dataBase.house > 0 then
			for iter_13_0, iter_13_1 in pairs(dataBase.house) do
				if iter_13_1.gps == arg_13_0 then
					if iter_13_1.sign.name ~= nil then
						addSignLog(iter_13_0, "Слетела табличка. Дом в госс.")
						sampAddChatMessage(prefix .. "Слетела табличка у дома #" .. arg_13_0 .. " | Добавлена: " .. iter_13_1.sign.date .. " | Бывший владелец: " .. iter_13_1.sign.name, -1)
						sampAddChatMessage(prefix .. "Причина: дом находится в госс.", -1)

						iter_13_1.sign = {}

						saveDB()
					end

					if iter_13_1.lastOwner ~= "Без владельца" then
						sampAddChatMessage(prefix .. "{E9967A}Дом #" .. arg_13_0 .. " теперь находится в госсе.", -1)

						iter_13_1.lastOwner = "Без владельца"

						saveDB()
					end
				end
			end
		end
	else
		table.insert(dataBase.house, {
			lastOwner = "Без владельца",
			gps = arg_13_0,
			park = arg_13_1,
			owners = {},
			area = getArea(arg_13_2, arg_13_3, arg_13_4),
			sign = {},
			signLog = {}
		})
		runBlip(arg_13_2, arg_13_3, arg_13_4)
		saveDB()
	end

	var_0_17 = var_0_17 + 1
end

function addFlatBuyer(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6)
	if #dataBase.house > 0 then
		if checkerGPS(arg_14_1) then
			for iter_14_0, iter_14_1 in pairs(dataBase.house) do
				if iter_14_1.gps == arg_14_1 then
				local nextsOwner = iter_14_1.lastOwner
					if not checkerNAME(iter_14_1.owners, arg_14_3) then
						if #iter_14_1.owners > 4 then
							local var_14_0 = {}

							for iter_14_2, iter_14_3 in ipairs(iter_14_1.owners) do
								if iter_14_2 ~= 1 then
									table.insert(var_14_0, iter_14_3)
								end
							end

							iter_14_1.owners = {}
							iter_14_1.owners = var_14_0
							iter_14_1.lastOwner = arg_14_3

							table.insert(iter_14_1.owners, {
								name = arg_14_3,
								time = os.date("%X %d/%m/%Y")
							})
						else
							iter_14_1.lastOwner = arg_14_3

							table.insert(iter_14_1.owners, {
								name = arg_14_3,
								time = os.date("%X %d/%m/%Y")
							})
						end
		
						saveDB()
					if nextsOwner and dataBase.settings.chates then
						sampAddChatMessage(prefix .. "Был обнаружен новый владелец дома - #" .. arg_14_1 .. " | " .. arg_14_3 .. " | Cтарый владелец - " .. nextsOwner, -1)
					elseif not dataBase.settings.chates then
						sampAddChatMessage(prefix .. "Был обнаружен новый владелец дома - #" .. arg_14_1 .. " | " .. arg_14_3, -1)
					end
				end	

					if iter_14_1.sign.name ~= nil then
						if arg_14_0.name ~= nil then
							if iter_14_1.sign.name:lower() ~= arg_14_0.name:lower() then
								addSignLog(iter_14_0, "Слетела табличка из за обновления владельца | Был: " .. iter_14_1.sign.name .. " | Стал: " .. arg_14_0.name)
								if dataBase.settings.chates then
								sampAddChatMessage(prefix .. "Дата таблички дома #" .. arg_14_1 .. " - обновлена из за смены владельца", -1)
								end
								iter_14_1.sign = arg_14_0

								saveDB()
							end
						else
							addSignLog(iter_14_0, "[!] Слёт таблички | Добавлена была: " .. iter_14_1.sign.date .. " | Владельцем: " .. iter_14_1.sign.name)
							if dataBase.settings.chates then
							sampAddChatMessage(prefix .. "{E9967A}Слетела табличка #" .. arg_14_1 .. " | Добавлена: " .. iter_14_1.sign.date .. " | Владелец: " .. iter_14_1.sign.name, -1)
							end
							
							iter_14_1.sign = {}

							saveDB()
						end
					elseif arg_14_0.name ~= nil then
						addSignLog(iter_14_0, arg_14_3 .. " добавил табличку с ценником " .. arg_14_0.price)
						if dataBase.settings.chates then
						sampAddChatMessage(prefix .. "Табличка для дома #" .. arg_14_1 .. " - добавлена | " .. os.date("%X  %d/%m/%Y"), -1)
						end
						
						iter_14_1.sign = arg_14_0

						saveDB()
					end
				end
			end

			runBlip(arg_14_4, arg_14_5, arg_14_6)
		else
			table.insert(dataBase.house, {
				gps = arg_14_1,
				park = arg_14_2,
				lastOwner = arg_14_3,
				owners = {
					{
						name = arg_14_3,
						time = os.date("%X %d/%m/%Y")
					}
				},
				area = getArea(arg_14_4, arg_14_5, arg_14_6),
				sign = arg_14_0,
				signLog = {}
			})
			runBlip(arg_14_4, arg_14_5, arg_14_6)
			saveDB()
		end
	else
		table.insert(dataBase.house, {
			gps = arg_14_1,
			park = arg_14_2,
			lastOwner = arg_14_3,
			owners = {
				{
					name = arg_14_3,
					time = os.date("%X %d/%m/%Y")
				}
			},
			area = getArea(arg_14_4, arg_14_5, arg_14_6),
			sign = arg_14_0,
			signLog = {}
		})
		runBlip(arg_14_4, arg_14_5, arg_14_6)
		saveDB()
	end

	var_0_17 = var_0_17 + 1
end

function var_0_0.onCreate3DText(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7)
	local var_15_0 = replaceText(arg_15_7)

	if dataBase.settings.addToBase then
		if var_15_0:find("^%d+  %S+\n\n{ffffff}Это жилье продается за {33aa33}.* %${ffffff}.") then
			local var_15_1, var_15_2 = var_15_0:match("^(%d+)  (%S+)\n\n{ffffff}Это жилье продается за {33aa33}.* %${ffffff}.")

			if var_15_1 and var_15_2 then
				addHouseSell(var_15_1, var_15_2, arg_15_2)
			end
		elseif var_15_0:find("^%d+  %S+\n\n{ffffff}Владелец:{fbec5d} %S+\n\n{ffffff}.*\n\n{ffffff}.*") then
			local var_15_3, var_15_4, var_15_5 = var_15_0:match("^(%d+)  (%S+)\n\n{ffffff}Владелец:{fbec5d} (%S+)\n\n{ffffff}.*\n\n{ffffff}.*")

			if var_15_3 and var_15_4 and var_15_5 then
				local var_15_6 = {}

				if var_15_0:find("{ffffff}Владелец продает дом за {33aa33}%S+ %${ffffff}.") then
					local var_15_7 = var_15_0:match("{ffffff}Владелец продает дом за {33aa33}(%S+) %${ffffff}.")

					var_15_6 = {
						name = var_15_5,
						num = var_15_3,
						date = os.date("%X %d/%m/%Y"),
						price = var_15_7
					}
				end

				addHouseBuyer(var_15_6, var_15_3, var_15_4, var_15_5, arg_15_2)
			end
		elseif var_15_0:find("^%d+  %S+\n\n{ffffff}Владелец:{fbec5d} %S+\n\n{ffffff}.*") then
			local var_15_8, var_15_9, var_15_10 = var_15_0:match("^(%d+)  (%S+)\n\n{ffffff}Владелец:{fbec5d} (%S+)\n\n{ffffff}.*")

			if var_15_8 and var_15_9 and var_15_10 then
				local var_15_11 = {}

				if var_15_0:find("{ffffff}Владелец продает дом за {33aa33}%S+ %${ffffff}.") then
					local var_15_12 = var_15_0:match("{ffffff}Владелец продает дом за {33aa33}(%S+) %${ffffff}.")

					var_15_11 = {
						name = var_15_10,
						num = var_15_8,
						date = os.date("%X %d/%m/%Y"),
						price = var_15_12
					}
				end

				addHouseBuyer(var_15_11, var_15_8, var_15_9, var_15_10, arg_15_2)
			end
		elseif var_15_0:find("^%d+  %S+\n\n{ffffff}Владелец:{fbec5d} %S+") then
			local var_15_13, var_15_14, var_15_15 = var_15_0:match("^(%d+)  (%S+)\n\n{ffffff}Владелец:{fbec5d} (%S+)")

			if var_15_13 and var_15_14 and var_15_15 then
				local var_15_16 = {}

				if var_15_0:find("{ffffff}Владелец продает дом за {33aa33}%S+ %${ffffff}.") then
					local var_15_17 = var_15_0:match("{ffffff}Владелец продает дом за {33aa33}(%S+) %${ffffff}.")

					var_15_16 = {
						name = var_15_15,
						num = var_15_13,
						date = os.date("%X %d/%m/%Y"),
						price = var_15_17
					}
				end

				addHouseBuyer(var_15_16, var_15_13, var_15_14, var_15_15, arg_15_2)
			end
		end
	end
end

function addHouseSell(arg_16_0, arg_16_1, arg_16_2)
	if findNumHouse(arg_16_0) then
		if #dataBase.house > 0 then
			for iter_16_0, iter_16_1 in pairs(dataBase.house) do
				if iter_16_1.gps == arg_16_0 then
					if iter_16_1.sign.name ~= nil then
						addSignLog(iter_16_0, "Слетела табличка. Дом в госс.")
						sampAddChatMessage(prefix .. "Слетела табличка у дома #" .. arg_16_0 .. " | Добавлена: " .. iter_16_1.sign.date .. " | Бывший владелец: " .. iter_16_1.sign.name, -1)
						sampAddChatMessage(prefix .. "Причина: дом находится в госс.", -1)

						iter_16_1.sign = {}

						saveDB()
					end

					if iter_16_1.lastOwner ~= "Без владельца" then
						sampAddChatMessage(prefix .. "{E9967A}Дом #" .. arg_16_0 .. " теперь находится в госсе.", -1)

						iter_16_1.lastOwner = "Без владельца"

						saveDB()
					end
				end
			end
		end
	else
		table.insert(dataBase.house, {
			lastOwner = "Без владельца",
			gps = arg_16_0,
			park = arg_16_1,
			owners = {},
			area = getArea(arg_16_2.x, arg_16_2.y, arg_16_2.z),
			sign = {},
			signLog = {}
		})
		runBlip(arg_16_2.x, arg_16_2.y, arg_16_2.z)
		saveDB()
	end

	var_0_17 = var_0_17 + 1
end

function addHouseBuyer(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4)
	if #dataBase.house > 0 then
		if checkerGPS(arg_17_1) then
			for iter_17_0, iter_17_1 in pairs(dataBase.house) do
				if iter_17_1.gps == arg_17_1 then
				local previousOwner = iter_17_1.lastOwner
					if not checkerNAME(iter_17_1.owners, arg_17_3) then
						if #iter_17_1.owners > 4 then
							local var_17_0 = {}

							for iter_17_2, iter_17_3 in ipairs(iter_17_1.owners) do
								if iter_17_2 ~= 1 then
									table.insert(var_17_0, iter_17_3)
								end
							end

							iter_17_1.owners = {}
							iter_17_1.owners = var_17_0
							iter_17_1.lastOwner = arg_17_3

							table.insert(iter_17_1.owners, {
								name = arg_17_3,
								time = os.date("%X %d/%m/%Y")
							})

							local var_17_1 = {}
						else
							iter_17_1.lastOwner = arg_17_3

							table.insert(iter_17_1.owners, {
								name = arg_17_3,
								time = os.date("%X %d/%m/%Y")
							})
						end

						saveDB()
						if previousOwner and dataBase.settings.chates then
						sampAddChatMessage(prefix .. "Был обнаружен новый владелец дома - #" .. arg_17_1 .. " | " .. arg_17_3 .. " | Cтарый владелец - " .. previousOwner, -1)
					elseif dataBase.settings.chates then
						sampAddChatMessage(prefix .. "Был обнаружен новый владелец дома - #" .. arg_17_1 .. " | " .. arg_17_3, -1)
					end
				end	
					
					if iter_17_1.sign.name ~= nil then
						if arg_17_0.name ~= nil then
							if iter_17_1.sign.name:lower() ~= arg_17_0.name:lower() then
								addSignLog(iter_17_0, "Слетела табличка из за обновления владельца | Был: " .. iter_17_1.sign.name .. " | Стал: " .. arg_17_0.name)
								if dataBase.settings.chates then
								sampAddChatMessage(prefix .. "Дата таблички дома #" .. arg_17_1 .. " - обновлена из за смены владельца", -1)
								end
								
								iter_17_1.sign = arg_17_0

								saveDB()
							end
						else
							addSignLog(iter_17_0, "[!] Слёт таблички | Добавлена была: " .. iter_17_1.sign.date .. " | Владельцем: " .. iter_17_1.sign.name)
							if dataBase.settings.chates then
							sampAddChatMessage(prefix .. "{E9967A}Слетела табличка #" .. arg_17_1 .. " | Добавлена: " .. iter_17_1.sign.date .. " | Владелец: " .. iter_17_1.sign.name, -1)
							end
							
							iter_17_1.sign = {}

							saveDB()
						end
					elseif arg_17_0.name ~= nil then
						iter_17_1.sign = arg_17_0

						addSignLog(iter_17_0, arg_17_3 .. " добавил табличку с ценником " .. arg_17_0.price)
						if dataBase.settings.chates then
						sampAddChatMessage(prefix .. "Табличка для дома #" .. arg_17_1 .. " - добавлена | " .. os.date("%X  %d/%m/%Y"), -1)
						end
						saveDB()
					end
				end
			end

			runBlip(arg_17_4.x, arg_17_4.y, arg_17_4.z)
		else
			table.insert(dataBase.house, {
				gps = arg_17_1,
				park = arg_17_2,
				lastOwner = arg_17_3,
				owners = {
					{
						name = arg_17_3,
						time = os.date("%X %d/%m/%Y")
					}
				},
				area = getArea(arg_17_4.x, arg_17_4.y, arg_17_4.z),
				sign = arg_17_0,
				signLog = {}
			})
			runBlip(arg_17_4.x, arg_17_4.y, arg_17_4.z)
			saveDB()
		end
	else
		table.insert(dataBase.house, {
			gps = arg_17_1,
			park = arg_17_2,
			lastOwner = arg_17_3,
			owners = {
				{
					name = arg_17_3,
					time = os.date("%X %d/%m/%Y")
				}
			},
			area = getArea(arg_17_4.x, arg_17_4.y, arg_17_4.z),
			sign = arg_17_0,
			signLog = {}
		})
		runBlip(arg_17_4.x, arg_17_4.y, arg_17_4.z)
		saveDB()
	end

	var_0_17 = var_0_17 + 1
end

function replaceText(arg_18_0)
	arg_18_0 = arg_18_0 and arg_18_0:gsub("{C2A2DA}\n\nДверь в дом была .* изнутри.", "")

	return arg_18_0
end

function addSignLog(arg_19_0, arg_19_1)
	local var_19_0 = dataBase.house[arg_19_0].signLog

	if arg_19_1 and var_19_0 ~= nil then
		local var_19_1 = os.date("%X %d/%m/%Y")

		if #var_19_0 > 9 then
			local var_19_2 = {}

			for iter_19_0, iter_19_1 in ipairs(var_19_0) do
				if iter_19_0 ~= 1 then
					table.insert(var_19_2, iter_19_1)
				end
			end

			dataBase.house[arg_19_0].signLog = {}
			dataBase.house[arg_19_0].signLog = var_19_2

			table.insert(dataBase.house[arg_19_0].signLog, {
				text = arg_19_1,
				time = var_19_1
			})

			local var_19_3 = {}

			saveDB()
		else
			table.insert(dataBase.house[arg_19_0].signLog, {
				text = arg_19_1,
				time = var_19_1
			})
			saveDB()
		end
	end
end
function cmd_help()
sampAddChatMessage('InfoHome {ffffff}доступные команды.', -1)
sampAddChatMessage('{0066FF}/home {FFFFFF}- основное меню', -1)
sampAddChatMessage('{0066FF}/home [on | off] {FFFFFF}- добавление домов в базу.', -1)
sampAddChatMessage('{0066FF}/home [blip | deblip]{ffffff} - метки для добавления домов.', -1)
sampAddChatMessage('{0066FF}/getonline [количество дней | full]{ffffff}-  информация о владельцах домов оффлайн.', -1)
sampAddChatMessage('{0066FF}/now -{ffffff} добавление нового дома в базу времени.', -1)
sampAddChatMessage('{0066FF}/myinf -{ffffff} cамостоятельно добавить дом со временем.', -1)
sampAddChatMessage('{0066FF}/inftoday -{ffffff} просмотреть дома которые слетят сегодня.', -1)
sampAddChatMessage('{0066FF}/zavta -{ffffff} просмотреть дома которые слетят завтра.', -1)
sampAddChatMessage('{0066FF}/inf -{ffffff} узнать время слета дома.', -1)
end
function main()
	repeat
		wait(0)
	until isSampAvailable()
	
   
   if not checkLicenseOnline() then
        --sampAddChatMessage(prefix .. "Скрипт заблокирован из-за недействительной лицензии.", -1)
        return 
    end

	local ip = sampGetCurrentServerAddress()

	if ip:find("185.169.134.83") or ip:find("185.169.134.84") or ip:find("185.169.134.85") then
		if not doesFileExist(getWorkingDirectory() .. "\\config\\InfoHome\\" .. ip .. ".json") then
			local var_20_1 = io.open(getWorkingDirectory() .. "\\config\\InfoHome\\" .. ip .. ".json", "w")

			var_20_1:write(encodeJson({
				house = {},
				settings = {
					addToBase = false,
					chates = true
				}
			}))
			io.close(var_20_1)
		end

		if doesFileExist(getWorkingDirectory() .. "\\config\\InfoHome\\" .. ip .. ".json") then
			local var_20_2 = io.open(getWorkingDirectory() .. "\\config\\InfoHome\\" .. ip .. ".json", "r")

			if var_20_2 then
				dataBase = decodeJson(var_20_2:read("*a"))
			end

			io.close(var_20_2)
		end
		
		if doesFileExist(getWorkingDirectory() .. "\\config\\inflog.json") then
			local ft = io.open(getWorkingDirectory() .. "\\config\\inflog.json", "r")
			
			if ft then
				dataTime = decodeJson(ft:read("*a"))
			end
			
			io.close(ft)
		end
		if #dataBase.house > 0 then
			for iter_20_0, iter_20_1 in ipairs(dataBase.house) do
				if not table.ckey(iter_20_1, "sign") then
					iter_20_1.sign = {}

					saveDB()
				end
			end
		end

		var_0_12 = ip

		if checkLicenseOnline() then
			if not var_0_7 then
				var_0_7 = TrinityApi()

				var_0_7.getReactLabCookie()
			end

			var_0_9 = true

			sampAddChatMessage(prefix .. "Используйте: {0066FF}/home help {FFFFFF}для просмотра всех команд скрипта.", -1)
			autoUpdate()
		end
	else
		sampAddChatMessage(prefix .. "Скрипт не активирован так как вы играете не на Trinity GTA. " .. ip, -1)

		return
	end

	sampRegisterChatCommand("home", function(arg_21_0)
		if arg_21_0 ~= nil and arg_21_0 ~= "" then
			if arg_21_0 == "on" then
				dataBase.settings.addToBase = true

				saveDB()
				sampAddChatMessage(prefix .. "Добавление домов в базу данных - активировано.", -1)
			elseif arg_21_0 == "off" then
				dataBase.settings.addToBase = false	

				saveDB()
				sampAddChatMessage(prefix .. "Добавление домов в базу данных - деактивировано.", -1)
			elseif arg_21_0 == "blip" then
				enableAddBlip = not enableAddBlip

				if enableAddBlip then
					addBlip()
					sampAddChatMessage(prefix .. "Добавление меток на дом - активировано. Метки - показаны.", -1)
				else
					hideBlip()
					sampAddChatMessage(prefix .. "Добавление меток на дом - деактивировано. Метки - скрыты.", -1)
				end
			elseif arg_21_0 == "help" then
				cmd_help()	
			elseif arg_21_0 == "dblip" or arg_21_0 == "delblip" then
				deleteBlip()
				sampAddChatMessage(prefix .. "Метки полностью удалены.", -1)
			else
				sampAddChatMessage(prefix .. "Используйте: /home [on | off] для активации добавления домов.", -1)
			end
		else
			main_window_state.v = not main_window_state.v
		end
	end)
	sampRegisterChatCommand("getonline", function(input)
  if input == "full" then
    OnlineCheckRange(18, 21) 
  elseif input then
    local days = tonumber(input)
    if not days or days <= 0 then
      sampAddChatMessage(prefix .. "Введите количество дней 1 до 21 или '/getonline full'.", -1)
    else
      OnlineCheck(days) 
    end
  else
    sampAddChatMessage(prefix .. "Введите количество дней 1 до 21 или '/getonline full'.", -1)
  end
end)
    lua_thread.create(updater)
	while true do
		wait(0)

		imgui.Process = main_window_state.v

		if var_0_17 == 30 then
			cleanBanlist()

			var_0_17 = 0
		end
	end

	wait(-1)
end

function TrinityApi(bans)
	local var_22_0 = {}
	local var_22_1 = {
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 Edg/106.0.1370.52",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36 OPR/91.0.4516.65"
	}
	local var_22_2 = var_22_1[math.random(1, #var_22_1)]
	local var_22_3 = sampGetCurrentServerAddress()

	banlist_name = {
		["185.169.134.83"] = {
			count = 2000,
			name = "rpg"
		},
		["185.169.134.84"] = {
			count = 15000,
			name = "1rp"
		},
		["185.169.134.85"] = {
			count = 15000,
			name = "2rp"
		}
	}
	bans = bans or "https://gta-trinity.com/forum/api/monitoring/?draw=0&columns[0][data]=0&columns[0][searchable]=true&columns[0][orderable]=true&columns[0][search][value]=&columns[0][search][regex]=false&columns[1][data]=1&columns[1][name]=&columns[1][searchable]=true&columns[1][orderable]=false&columns[1][search][value]=&columns[1][search][regex]=false&order[0][column]=0&order[0][dir]=desc&start=0&length=1B&search[regex]=true&server=1&monitoring=" .. banlist_name[var_22_3].name .. "ban"

	function var_22_0.getReactLabCookie(arg_23_0, arg_23_1)
		local function var_23_0(arg_24_0, arg_24_1, arg_24_2)
			local var_24_0 = require("lockbox.util.stream")
			local var_24_1 = require("lockbox.cipher.mode.cbc")
			local var_24_2 = require("lockbox.cipher.aes128")
			local var_24_3 = require("lockbox.padding.pkcs7")

			local function var_24_4(arg_25_0)
				local var_25_0 = {}

				arg_25_0:gsub("..", function(arg_26_0)
					table.insert(var_25_0, tonumber(arg_26_0, 16))
				end)

				return var_25_0
			end

			return var_24_1.Decipher().setKey(var_24_4(arg_24_0)).setBlockCipher(var_24_2).setPadding(var_24_3).init().update(var_24_0.fromArray(var_24_4(arg_24_1))).update(var_24_0.fromArray(var_24_4(arg_24_2))).finish().asHex():lower()
		end

		asyncHttpRequest("GET", bans, {
			headers = {
				["User-Agent"] = var_22_2
			}
		}, function(arg_27_0)
			if arg_27_0.text then
				local var_27_0 = ("%x"):rep(32)
				local var_27_1 = arg_27_0.text:gmatch(var_27_0)
				local var_27_2 = var_27_1()
				local var_27_3 = var_27_1()
				local var_27_4 = var_27_1()

				if var_27_2 and var_27_3 and var_27_4 then
					local var_27_5, var_27_6 = pcall(var_23_0, var_27_2, var_27_3, var_27_4)

					if not var_27_5 then
						var_0_8 = "err"

						return false
					end

					var_0_8 = "REACTLABSPROTECTION=" .. tostring(var_27_6)
				else
					var_0_8 = "err"
				end
			else
				var_0_8 = "err"
			end
		end, function()
			var_0_8 = "err"
		end)
	end

	function var_22_0.getBanlist()
		if not var_0_8 then
			sampAddChatMessage(prefix .. "Ошибка: отсутствует cookie для запроса банлиста.", -1)

			return
		end

		local var_29_0 = sampGetCurrentServerAddress()

		if not var_29_0 then
			sampAddChatMessage(prefix .. "Ошибка: не удалось получить IP-адрес сервера.", -1)

			return
		end

		if var_29_0 then
			sampAddChatMessage(prefix .. "Загрузка банлиста. Подождите немного . . .", -1)
			asyncHttpRequest("GET", "https://gta-trinity.com/forum/api/monitoring/?draw=0&columns[0][data]=0&columns[0][searchable]=true&columns[0][orderable]=true&columns[0][search][value]=&columns[0][search][regex]=false&columns[1][data]=1&columns[1][name]=&columns[1][searchable]=true&columns[1][orderable]=false&columns[1][search][value]=&columns[1][search][regex]=false&order[0][column]=0&order[0][dir]=desc&start=0&length=" .. tostring(banlist_name[var_29_0].count) .. "B&search[regex]=true&server=1&monitoring=" .. banlist_name[var_29_0].name .. "ban", {
				cookies = var_0_8,
				headers = {
					["User-Agent"] = var_22_2
				}
			}, function(arg_30_0)
				if not arg_30_0.text then
					return
				end

				banTab = {}

				if arg_30_0.text then
					local var_30_0 = decodeJson(arg_30_0.text)

					if var_30_0 and var_30_0.data then
						var_0_14, var_0_15 = {}, {}

						local var_30_1 = os.time()
						local var_30_2 = 86400

						for iter_30_0, iter_30_1 in ipairs(var_30_0.data) do
							if iter_30_1[2] then
								iter_30_1[2] = u8:decode(iter_30_1[2])

								local var_30_3, var_30_4, var_30_5 = iter_30_1[2]:match("%[(%d+)%:(%d+)%:(%d+)%]")

								if var_30_3 and var_30_4 and var_30_5 then
									local var_30_6 = {
										hour = 0,
										min = 0,
										sec = 0,
										year = var_30_5,
										month = var_30_4,
										day = var_30_3
									}
									local var_30_7 = os.time(var_30_6)

									if (iter_30_1[2]:find("%[.*%] B") or iter_30_1[2]:find("%[.*%] U")) and var_30_1 - var_30_7 <= 21 * var_30_2 then
										if iter_30_1[2]:find("%[.*%] B: .* был забанен, причина: .*") then
											local var_30_8, var_30_9, var_30_10, var_30_11, var_30_12 = iter_30_1[2]:match("%[(%d+)%:(%d+)%:(%d+)%] B: (.*) был забанен, причина: (.*)")

											table.insert(var_0_14, {
												date = {
													year = var_30_10,
													month = var_30_9,
													day = var_30_8
												},
												name = var_30_11,
												reason = var_30_12
											})
										elseif iter_30_1[2]:find("%[.*%] B: .* был забанен администратором .*, причина: .*") then
											local var_30_13, var_30_14, var_30_15, var_30_16, var_30_17 = iter_30_1[2]:match("%[(%d+)%:(%d+)%:(%d+)%] B: (.*) был забанен администратором .*, причина: (.*)")

											table.insert(var_0_14, {
												date = {
													year = var_30_15,
													month = var_30_14,
													day = var_30_13
												},
												name = var_30_16,
												reason = var_30_17
											})
										elseif iter_30_1[2]:find("%[.*%] U: Администратор разбанил по ошибке забаненный ранее аккаунт .*") then
											local var_30_18, var_30_19, var_30_20, var_30_21 = iter_30_1[2]:match("%[(%d+)%:(%d+)%:(%d+)%] U: Администратор разбанил по ошибке забаненный ранее аккаунт (.*).")

											table.insert(var_0_15, {
												date = {
													year = var_30_20,
													month = var_30_19,
													day = var_30_18
												},
												name = var_30_21
											})
										elseif iter_30_1[2]:find("%[.*%] U: Администратор .* разбанил по ошибке забаненный ранее аккаунт .*") then
											local var_30_22, var_30_23, var_30_24, var_30_25 = iter_30_1[2]:match("%[(%d+)%:(%d+)%:(%d+)%] U: Администратор .* разбанил по ошибке забаненный ранее аккаунт (.*).")

											table.insert(var_0_15, {
												date = {
													year = var_30_24,
													month = var_30_23,
													day = var_30_22
												},
												name = var_30_25
											})
										end
									end
								end
							end
						end

						sampAddChatMessage(prefix .. "База банов успешно обновлена. Можно работать.", -1)
						cleanBanlist()

						local var_30_26 = {}
					end

					arg_30_0.text = ""
				end
			end, nil)
		end
	end

	return var_22_0
end

function cleanBanlist()
	if #var_0_14 > 0 and #dataBase.house > 0 then
		var_0_13 = {}

		for iter_31_0 = #dataBase.house, 1, -1 do
			for iter_31_1, iter_31_2 in pairs(var_0_14) do
				if dataBase.house[iter_31_0].lastOwner:lower() == iter_31_2.name:lower() and not checkUnBan(var_0_15, iter_31_2.name, iter_31_2.date) then
					if iter_31_2.reason:find("%[R %- %d+ дн") then
						local var_31_0 = iter_31_2.reason:match("%[R %- (%d+) дн")
						local var_31_1 = {
							hour = 0,
							min = 0,
							sec = 0,
							year = iter_31_2.date.year,
							month = iter_31_2.date.month,
							day = iter_31_2.date.day
						}
						local var_31_2 = os.time(var_31_1)

						if os.time() < var_31_2 + 86400 * tonumber(var_31_0) then
							var_0_13[iter_31_0] = iter_31_2
						end
					elseif iter_31_2.reason:find("%[C %- %d+ нед") then
						local var_31_3 = iter_31_2.reason:match("%[C %- (%d+) нед")
						local var_31_4 = {
							hour = 0,
							min = 0,
							sec = 0,
							year = iter_31_2.date.year,
							month = iter_31_2.date.month,
							day = iter_31_2.date.day
						}
						local var_31_5 = os.time(var_31_4)

						if os.time() < var_31_5 + 86400 * tonumber(var_31_3) * 7 then
							var_0_13[iter_31_0] = iter_31_2
						end
					elseif iter_31_2.reason:find("%[C %- %d+ сут") then
						local var_31_6 = iter_31_2.reason:match("%[C %- (%d+) сут")
						local var_31_7 = {
							hour = 0,
							min = 0,
							sec = 0,
							year = iter_31_2.date.year,
							month = iter_31_2.date.month,
							day = iter_31_2.date.day
						}
						local var_31_8 = os.time(var_31_7)

						if os.time() < var_31_8 + 86400 * tonumber(var_31_6) then
							var_0_13[iter_31_0] = iter_31_2
						end
					elseif iter_31_2.reason:find("%[R %- %d+ час") then
						local var_31_9 = iter_31_2.reason:match("%[R %- (%d+) час")
						local var_31_10 = {
							hour = 0,
							min = 0,
							sec = 0,
							year = iter_31_2.date.year,
							month = iter_31_2.date.month,
							day = iter_31_2.date.day
						}
						local var_31_11 = os.time(var_31_10)

						if os.time() < var_31_11 + 3600 * var_31_9 then
							var_0_13[iter_31_0] = iter_31_2
						end
					elseif iter_31_2.reason:find("%[W %- %d+ дн") then
						local var_31_12 = iter_31_2.reason:match("%[W %- (%d+) дн")
						local var_31_13 = {
							hour = 0,
							min = 0,
							sec = 0,
							year = iter_31_2.date.year,
							month = iter_31_2.date.month,
							day = iter_31_2.date.day
						}
						local var_31_14 = os.time(var_31_13)

						if os.time() < var_31_14 + 86400 * var_31_12 then
							var_0_13[iter_31_0] = iter_31_2
						end
					else
						var_0_13[iter_31_0] = iter_31_2
					end
				end
			end
		end
	end
end

function findNumHouse(arg_32_0)
	if tonumber(arg_32_0) then
		for iter_32_0, iter_32_1 in pairs(dataBase.house) do
			if iter_32_1.gps == arg_32_0 then
				return true
			end
		end
	end

	return false
end

function checkUnBan(arg_33_0, arg_33_1, arg_33_2)
	if arg_33_1 then
		for iter_33_0, iter_33_1 in pairs(arg_33_0) do
			if arg_33_1:lower() == iter_33_1.name:lower() and arg_33_2.month <= iter_33_1.date.month and arg_33_2.day <= iter_33_1.date.day then
				return true
			end
		end
	end

	return false
end

function checkerGPS(arg_34_0)
	for iter_34_0, iter_34_1 in pairs(dataBase.house) do
		if iter_34_1.gps == arg_34_0 then
			return true
		end
	end

	return false
end

function checkerNAME(arg_35_0, arg_35_1)
	if #arg_35_0 > 0 and arg_35_0[#arg_35_0].name:lower() == arg_35_1:lower() then
		return true
	end

	return false
end

function runBlip(arg_36_0, arg_36_1, arg_36_2)
	if enableAddBlip then
		table.insert(var_0_16, {
			x = arg_36_0,
			y = arg_36_1,
			z = arg_36_2
		})
		addBlip()
	end
end

function addBlip()
	if #var_0_16 > 0 then
		hideBlip()

		for iter_37_0, iter_37_1 in pairs(var_0_16) do
			iter_37_1.handle = addBlipForCoord(iter_37_1.x, iter_37_1.y, iter_37_1.z)

			changeBlipColour(iter_37_1.handle, 2332033279)
		end
	end
end

function hideBlip()
	if #var_0_16 > 0 then
		for iter_38_0, iter_38_1 in pairs(var_0_16) do
			if iter_38_1.handle ~= nil then
				removeBlip(iter_38_1.handle)
			end
		end
	end
end

function deleteBlip()
	if #var_0_16 > 0 then
		for iter_39_0, iter_39_1 in pairs(var_0_16) do
			removeBlip(iter_39_1.handle)
		end

		var_0_16 = {}
	end
end

function saveDB()
	local var_40_0 = sampGetCurrentServerAddress()

	if not var_40_0 then
		sampAddChatMessage(prefix .. "Ошибка: не удалось получить IP-адрес сервера.", -1)

		return
	end

	local var_40_1 = io.open(getWorkingDirectory() .. "\\config\\InfoHome\\" .. var_40_0 .. ".json", "w+")

	var_40_1:write(encodeJson(dataBase))
	var_40_1:close()
end

function table.ckey(arg_41_0, arg_41_1)
	if arg_41_0 ~= nil then
		for iter_41_0, iter_41_1 in pairs(arg_41_0) do
			if iter_41_0 == arg_41_1 then
				return true
			end
		end

		return false
	end

	return false
end

function getMyName()
	local var_42_0, var_42_1 = sampGetPlayerIdByCharHandle(PLAYER_PED)

	if var_42_0 then
		return sampGetPlayerNickname(var_42_1)
	end
end

function sampGetPlayerIdByNickname(arg_43_0)
	arg_43_0 = tostring(arg_43_0)

	local var_43_0, var_43_1 = sampGetPlayerIdByCharHandle(PLAYER_PED)

	if arg_43_0 == sampGetPlayerNickname(var_43_1) then
		return var_43_1
	end

	for iter_43_0 = 0, sampGetMaxPlayerId(true) do
		if sampIsPlayerConnected(iter_43_0) and sampGetPlayerNickname(iter_43_0) == arg_43_0 then
			return iter_43_0
		end
	end
end

function updater()
  while true do
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    myName = sampGetPlayerNickname(myid)
    connectedPlayers = {}
    for i = 0, sampGetMaxPlayerId(false) do
      if sampIsPlayerConnected(i) then
        connectedPlayers[sampGetPlayerNickname(i)] = true
      end
    end
    for key = 1, #dataBase.house do
      local nik = dataBase.house[key].lastOwner

      if nik ~= nil and (nik == myName or connectedPlayers[nik]) then
        dataBase.house[key].lastConnect = os.date("%H:%M %d/%m/%Y") 
      end
    end
    saveDB()
    wait(10000)
  end
end

-------------------------getonline
local function dateToTimestamp(dateString)
  if dateString == nil or dateString == "" then  -- Check if dateString is nil or empty
    return nil  -- Return nil to indicate no timestamp available
  end
  local year, month, day = string.match(dateString, "(%d+)/(%d+)/(%d+)")
  local hour, minute = string.match(dateString, "(%d+):(%d+)")
  if year and month and day and hour and minute then -- Check if all parts are found
      return os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute)})
  else
      return nil -- Return nil if date string is malformed
  end
end

function OnlineCheck(days)
  local daysNum = tonumber(days)

  if not daysNum or daysNum <= 0 then
    sampAddChatMessage(prefix .. "Неверное количество дней.", -1)
    return
  end

  local currentTime = os.time()
  local absentPlayers = {}

  for i = 1, #dataBase.house do
    local lastConnect = dataBase.house[i].lastConnect
    if lastConnect then
      local _, _, d, m, y = string.match(lastConnect, "(%d+):(%d+) (%d+)/(%d+)/(%d+)")
      if d and m and y then
        local lastConnectTime = os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d)})
        local daysSinceLastConnect = math.floor((currentTime - lastConnectTime) / (60 * 60 * 24))
        -- Check if the player hasn't logged in for more than 25 days
        if daysSinceLastConnect < 25 and daysSinceLastConnect >= daysNum then
          table.insert(absentPlayers, {name = dataBase.house[i].lastOwner, houseGPS = dataBase.house[i].gps, days = daysSinceLastConnect})
        end
      else
        sampAddChatMessage(prefix .. "Ошибка: Неверный формат даты в записи " .. i .. " базы данных.", -1)
      end
    end
  end

  if #absentPlayers > 0 then
    for _, player in ipairs(absentPlayers) do
      sampAddChatMessage(prefix .. "Владелец дома #" .. player.houseGPS .. ": " .. player.name .. " не заходил " .. player.days .. " дней.", -1)
    end
  else
    sampAddChatMessage(prefix .. "Нет владельцев домов, не заходивших " .. daysNum .. " дней.", -1)
  end
end

function OnlineCheckRange(minDays, maxDays)
  local currentTime = os.time()
  local absentPlayers = {}

  for i = 1, #dataBase.house do
    local lastConnect = dataBase.house[i].lastConnect
    if lastConnect then
      local _, _, d, m, y = string.match(lastConnect, "(%d+):(%d+) (%d+)/(%d+)/(%d+)")
      if d and m and y then
        local lastConnectTime = os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d)})
        local daysSinceLastConnect = math.floor((currentTime - lastConnectTime) / (60 * 60 * 24))
        if daysSinceLastConnect >= minDays and daysSinceLastConnect <= maxDays then
          table.insert(absentPlayers, {name = dataBase.house[i].lastOwner, houseGPS = dataBase.house[i].gps, days = daysSinceLastConnect})
        end
      else
        sampAddChatMessage(prefix .. "Ошибка: Неверный формат даты в записи " .. i .. " базы данных.", -1)
      end
    end
  end

  -- Added this missing if/else block
  if #absentPlayers > 0 then
    for _, player in ipairs(absentPlayers) do
      sampAddChatMessage(prefix .. "Владелец дома #" .. player.houseGPS .. ": " .. player.name .. " отсутствует: " .. player.days .. " дней.", -1)
    end
  else
    sampAddChatMessage(prefix .. "Нет владельцев домов отсутствующих " .. minDays .. "-" .. maxDays .. " дней.", -1)
  end
end

function OnlineCheckLess23()
    local currentTime = os.time()
    local absentPlayers = {}

    for i = 1, #dataBase.house do
        local lastConnect = dataBase.house[i].lastConnect
        if lastConnect then
            local _, _, d, m, y = string.match(lastConnect, "(%d+):(%d+) (%d+)/(%d+)/(%d+)")
            if d and m and y then
                local lastConnectTime = os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d)})
                local daysSinceLastConnect = math.floor((currentTime - lastConnectTime) / (60 * 60 * 24))
                if daysSinceLastConnect < 23 then -- Filter for owners inactive less than 23 days
                    table.insert(absentPlayers, {name = dataBase.house[i].lastOwner, houseGPS = dataBase.house[i].gps, days = daysSinceLastConnect})
                end
            else
                sampAddChatMessage(prefix .. "Ошибка: Неверный формат даты в записи " .. i .. " базы данных.", -1)
            end
        end
    end

    if #absentPlayers > 0 then
        for _, player in ipairs(absentPlayers) do
           sampAddChatMessage(prefix .. "Владелец дома #" .. player.houseGPS .. ": " .. player.name .. " не заходил " .. player.days .. " дней, меньше 23.", -1)
        end
    else
        sampAddChatMessage(prefix .. "Нет владельцев домов, не заходивших меньше 23 дней.", -1)
    end
end

function imgui.CenterColumnText(arg_44_0)
	imgui.SetCursorPosX(imgui.GetColumnOffset() + imgui.GetColumnWidth() / 2 - imgui.CalcTextSize(arg_44_0).x / 2)
	imgui.Text(arg_44_0)
end

function imgui.NewInputText(arg_45_0, arg_45_1, arg_45_2, arg_45_3, arg_45_4)
	local var_45_0 = arg_45_3 and arg_45_3 or ""
	local var_45_1 = tonumber(arg_45_4) and tonumber(arg_45_4) or 1
	local var_45_2 = imgui.GetCursorPos()

	imgui.PushItemWidth(arg_45_2)

	local var_45_3 = imgui.InputText(arg_45_0, arg_45_1)

	if #arg_45_1.v == 0 then
		local var_45_4 = imgui.CalcTextSize(var_45_0)

		if var_45_1 == 2 then
			imgui.SameLine(var_45_2.x + (arg_45_2 - var_45_4.x) / 2)
		elseif var_45_1 == 3 then
			imgui.SameLine(var_45_2.x + (arg_45_2 - var_45_4.x - 5))
		else
			imgui.SameLine(var_45_2.x + 5)
		end

		imgui.TextColored(imgui.ImVec4(1, 1, 1, 0.4), tostring(var_45_0))
	end

	imgui.PopItemWidth()

	return var_45_3
end

function imgui.Hint(arg_46_0, arg_46_1)
	if imgui.IsItemHovered() then
		if go_hint == nil then
			go_hint = os.clock() + (arg_46_1 and arg_46_1 or 0)
		end

		local var_46_0 = (os.clock() - go_hint) * 5

		if os.clock() >= go_hint then
			imgui.PushStyleVar(imgui.StyleVar.Alpha, var_46_0 <= 1 and var_46_0 or 1)
			imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
			imgui.BeginTooltip()
			imgui.PushTextWrapPos(450)
			imgui.TextUnformatted(arg_46_0)

			if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1 then
				go_hint = nil
			end

			imgui.PopTextWrapPos()
			imgui.EndTooltip()
			imgui.PopStyleColor()
			imgui.PopStyleVar()
		end
	end
end

function getArea(arg_47_0, arg_47_1, arg_47_2)
	local var_47_0 = {
		{
			"Avispa Country Club",
			-2667.81,
			-302.135,
			-28.831,
			-2646.4,
			-262.32,
			71.169
		},
		{
			"Easter Bay Airport",
			-1315.42,
			-405.388,
			15.406,
			-1264.4,
			-209.543,
			25.406
		},
		{
			"Avispa Country Club",
			-2550.04,
			-355.493,
			0,
			-2470.04,
			-318.493,
			39.7
		},
		{
			"Easter Bay Airport",
			-1490.33,
			-209.543,
			15.406,
			-1264.4,
			-148.388,
			25.406
		},
		{
			"Garcia",
			-2395.14,
			-222.589,
			-5.3,
			-2354.09,
			-204.792,
			200
		},
		{
			"Shady Cabin",
			-1632.83,
			-2263.44,
			-3,
			-1601.33,
			-2231.79,
			200
		},
		{
			"East Los Santos",
			2381.68,
			-1494.03,
			-89.084,
			2421.03,
			-1454.35,
			110.916
		},
		{
			"LVA Freight Depot",
			1236.63,
			1163.41,
			-89.084,
			1277.05,
			1203.28,
			110.916
		},
		{
			"Blackfield Intersection",
			1277.05,
			1044.69,
			-89.084,
			1315.35,
			1087.63,
			110.916
		},
		{
			"Avispa Country Club",
			-2470.04,
			-355.493,
			0,
			-2270.04,
			-318.493,
			46.1
		},
		{
			"Temple",
			1252.33,
			-926.999,
			-89.084,
			1357,
			-910.17,
			110.916
		},
		{
			"Unity Station",
			1692.62,
			-1971.8,
			-20.492,
			1812.62,
			-1932.8,
			79.508
		},
		{
			"LVA Freight Depot",
			1315.35,
			1044.69,
			-89.084,
			1375.6,
			1087.63,
			110.916
		},
		{
			"Los Flores",
			2581.73,
			-1454.35,
			-89.084,
			2632.83,
			-1393.42,
			110.916
		},
		{
			"Starfish Casino",
			2437.39,
			1858.1,
			-39.084,
			2495.09,
			1970.85,
			60.916
		},
		{
			"Easter Bay Chemicals",
			-1132.82,
			-787.391,
			0,
			-956.476,
			-768.027,
			200
		},
		{
			"Downtown Los Santos",
			1370.85,
			-1170.87,
			-89.084,
			1463.9,
			-1130.85,
			110.916
		},
		{
			"Esplanade East",
			-1620.3,
			1176.52,
			-4.5,
			-1580.01,
			1274.26,
			200
		},
		{
			"Market Station",
			787.461,
			-1410.93,
			-34.126,
			866.009,
			-1310.21,
			65.874
		},
		{
			"Linden Station",
			2811.25,
			1229.59,
			-39.594,
			2861.25,
			1407.59,
			60.406
		},
		{
			"Montgomery Intersection",
			1582.44,
			347.457,
			0,
			1664.62,
			401.75,
			200
		},
		{
			"Frederick Bridge",
			2759.25,
			296.501,
			0,
			2774.25,
			594.757,
			200
		},
		{
			"Yellow Bell Station",
			1377.48,
			2600.43,
			-21.926,
			1492.45,
			2687.36,
			78.074
		},
		{
			"Downtown Los Santos",
			1507.51,
			-1385.21,
			110.916,
			1582.55,
			-1325.31,
			335.916
		},
		{
			"Jefferson",
			2185.33,
			-1210.74,
			-89.084,
			2281.45,
			-1154.59,
			110.916
		},
		{
			"Mulholland",
			1318.13,
			-910.17,
			-89.084,
			1357,
			-768.027,
			110.916
		},
		{
			"Avispa Country Club",
			-2361.51,
			-417.199,
			0,
			-2270.04,
			-355.493,
			200
		},
		{
			"Jefferson",
			1996.91,
			-1449.67,
			-89.084,
			2056.86,
			-1350.72,
			110.916
		},
		{
			"Julius Thruway West",
			1236.63,
			2142.86,
			-89.084,
			1297.47,
			2243.23,
			110.916
		},
		{
			"Jefferson",
			2124.66,
			-1494.03,
			-89.084,
			2266.21,
			-1449.67,
			110.916
		},
		{
			"Julius Thruway North",
			1848.4,
			2478.49,
			-89.084,
			1938.8,
			2553.49,
			110.916
		},
		{
			"Rodeo",
			422.68,
			-1570.2,
			-89.084,
			466.223,
			-1406.05,
			110.916
		},
		{
			"Cranberry Station",
			-2007.83,
			56.306,
			0,
			-1922,
			224.782,
			100
		},
		{
			"Downtown Los Santos",
			1391.05,
			-1026.33,
			-89.084,
			1463.9,
			-926.999,
			110.916
		},
		{
			"Redsands West",
			1704.59,
			2243.23,
			-89.084,
			1777.39,
			2342.83,
			110.916
		},
		{
			"Little Mexico",
			1758.9,
			-1722.26,
			-89.084,
			1812.62,
			-1577.59,
			110.916
		},
		{
			"Blackfield Intersection",
			1375.6,
			823.228,
			-89.084,
			1457.39,
			919.447,
			110.916
		},
		{
			"Los Santos International",
			1974.63,
			-2394.33,
			-39.084,
			2089,
			-2256.59,
			60.916
		},
		{
			"Beacon Hill",
			-399.633,
			-1075.52,
			-1.489,
			-319.033,
			-977.516,
			198.511
		},
		{
			"Rodeo",
			334.503,
			-1501.95,
			-89.084,
			422.68,
			-1406.05,
			110.916
		},
		{
			"Richman",
			225.165,
			-1369.62,
			-89.084,
			334.503,
			-1292.07,
			110.916
		},
		{
			"Downtown Los Santos",
			1724.76,
			-1250.9,
			-89.084,
			1812.62,
			-1150.87,
			110.916
		},
		{
			"The Strip",
			2027.4,
			1703.23,
			-89.084,
			2137.4,
			1783.23,
			110.916
		},
		{
			"Downtown Los Santos",
			1378.33,
			-1130.85,
			-89.084,
			1463.9,
			-1026.33,
			110.916
		},
		{
			"Blackfield Intersection",
			1197.39,
			1044.69,
			-89.084,
			1277.05,
			1163.39,
			110.916
		},
		{
			"Conference Center",
			1073.22,
			-1842.27,
			-89.084,
			1323.9,
			-1804.21,
			110.916
		},
		{
			"Montgomery",
			1451.4,
			347.457,
			-6.1,
			1582.44,
			420.802,
			200
		},
		{
			"Foster Valley",
			-2270.04,
			-430.276,
			-1.2,
			-2178.69,
			-324.114,
			200
		},
		{
			"Blackfield Chapel",
			1325.6,
			596.349,
			-89.084,
			1375.6,
			795.01,
			110.916
		},
		{
			"Los Santos International",
			2051.63,
			-2597.26,
			-39.084,
			2152.45,
			-2394.33,
			60.916
		},
		{
			"Mulholland",
			1096.47,
			-910.17,
			-89.084,
			1169.13,
			-768.027,
			110.916
		},
		{
			"Yellow Bell Gol Course",
			1457.46,
			2723.23,
			-89.084,
			1534.56,
			2863.23,
			110.916
		},
		{
			"The Strip",
			2027.4,
			1783.23,
			-89.084,
			2162.39,
			1863.23,
			110.916
		},
		{
			"Jefferson",
			2056.86,
			-1210.74,
			-89.084,
			2185.33,
			-1126.32,
			110.916
		},
		{
			"Mulholland",
			952.604,
			-937.184,
			-89.084,
			1096.47,
			-860.619,
			110.916
		},
		{
			"Aldea Malvada",
			-1372.14,
			2498.52,
			0,
			-1277.59,
			2615.35,
			200
		},
		{
			"Las Colinas",
			2126.86,
			-1126.32,
			-89.084,
			2185.33,
			-934.489,
			110.916
		},
		{
			"Las Colinas",
			1994.33,
			-1100.82,
			-89.084,
			2056.86,
			-920.815,
			110.916
		},
		{
			"Richman",
			647.557,
			-954.662,
			-89.084,
			768.694,
			-860.619,
			110.916
		},
		{
			"LVA Freight Depot",
			1277.05,
			1087.63,
			-89.084,
			1375.6,
			1203.28,
			110.916
		},
		{
			"Julius Thruway North",
			1377.39,
			2433.23,
			-89.084,
			1534.56,
			2507.23,
			110.916
		},
		{
			"Willowfield",
			2201.82,
			-2095,
			-89.084,
			2324,
			-1989.9,
			110.916
		},
		{
			"Julius Thruway North",
			1704.59,
			2342.83,
			-89.084,
			1848.4,
			2433.23,
			110.916
		},
		{
			"Temple",
			1252.33,
			-1130.85,
			-89.084,
			1378.33,
			-1026.33,
			110.916
		},
		{
			"Little Mexico",
			1701.9,
			-1842.27,
			-89.084,
			1812.62,
			-1722.26,
			110.916
		},
		{
			"Queens",
			-2411.22,
			373.539,
			0,
			-2253.54,
			458.411,
			200
		},
		{
			"Las Venturas Airport",
			1515.81,
			1586.4,
			-12.5,
			1729.95,
			1714.56,
			87.5
		},
		{
			"Richman",
			225.165,
			-1292.07,
			-89.084,
			466.223,
			-1235.07,
			110.916
		},
		{
			"Temple",
			1252.33,
			-1026.33,
			-89.084,
			1391.05,
			-926.999,
			110.916
		},
		{
			"East Los Santos",
			2266.26,
			-1494.03,
			-89.084,
			2381.68,
			-1372.04,
			110.916
		},
		{
			"Julius Thruway East",
			2623.18,
			943.235,
			-89.084,
			2749.9,
			1055.96,
			110.916
		},
		{
			"Willowfield",
			2541.7,
			-1941.4,
			-89.084,
			2703.58,
			-1852.87,
			110.916
		},
		{
			"Las Colinas",
			2056.86,
			-1126.32,
			-89.084,
			2126.86,
			-920.815,
			110.916
		},
		{
			"Julius Thruway East",
			2625.16,
			2202.76,
			-89.084,
			2685.16,
			2442.55,
			110.916
		},
		{
			"Rodeo",
			225.165,
			-1501.95,
			-89.084,
			334.503,
			-1369.62,
			110.916
		},
		{
			"Las Brujas",
			-365.167,
			2123.01,
			-3,
			-208.57,
			2217.68,
			200
		},
		{
			"Julius Thruway East",
			2536.43,
			2442.55,
			-89.084,
			2685.16,
			2542.55,
			110.916
		},
		{
			"Rodeo",
			334.503,
			-1406.05,
			-89.084,
			466.223,
			-1292.07,
			110.916
		},
		{
			"Vinewood",
			647.557,
			-1227.28,
			-89.084,
			787.461,
			-1118.28,
			110.916
		},
		{
			"Rodeo",
			422.68,
			-1684.65,
			-89.084,
			558.099,
			-1570.2,
			110.916
		},
		{
			"Julius Thruway North",
			2498.21,
			2542.55,
			-89.084,
			2685.16,
			2626.55,
			110.916
		},
		{
			"Downtown Los Santos",
			1724.76,
			-1430.87,
			-89.084,
			1812.62,
			-1250.9,
			110.916
		},
		{
			"Rodeo",
			225.165,
			-1684.65,
			-89.084,
			312.803,
			-1501.95,
			110.916
		},
		{
			"Jefferson",
			2056.86,
			-1449.67,
			-89.084,
			2266.21,
			-1372.04,
			110.916
		},
		{
			"Hampton Barns",
			603.035,
			264.312,
			0,
			761.994,
			366.572,
			200
		},
		{
			"Temple",
			1096.47,
			-1130.84,
			-89.084,
			1252.33,
			-1026.33,
			110.916
		},
		{
			"Kincaid Bridge",
			-1087.93,
			855.37,
			-89.084,
			-961.95,
			986.281,
			110.916
		},
		{
			"Verona Beach",
			1046.15,
			-1722.26,
			-89.084,
			1161.52,
			-1577.59,
			110.916
		},
		{
			"Commerce",
			1323.9,
			-1722.26,
			-89.084,
			1440.9,
			-1577.59,
			110.916
		},
		{
			"Mulholland",
			1357,
			-926.999,
			-89.084,
			1463.9,
			-768.027,
			110.916
		},
		{
			"Rodeo",
			466.223,
			-1570.2,
			-89.084,
			558.099,
			-1385.07,
			110.916
		},
		{
			"Mulholland",
			911.802,
			-860.619,
			-89.084,
			1096.47,
			-768.027,
			110.916
		},
		{
			"Mulholland",
			768.694,
			-954.662,
			-89.084,
			952.604,
			-860.619,
			110.916
		},
		{
			"Julius Thruway South",
			2377.39,
			788.894,
			-89.084,
			2537.39,
			897.901,
			110.916
		},
		{
			"Idlewood",
			1812.62,
			-1852.87,
			-89.084,
			1971.66,
			-1742.31,
			110.916
		},
		{
			"Ocean Docks",
			2089,
			-2394.33,
			-89.084,
			2201.82,
			-2235.84,
			110.916
		},
		{
			"Commerce",
			1370.85,
			-1577.59,
			-89.084,
			1463.9,
			-1384.95,
			110.916
		},
		{
			"Julius Thruway North",
			2121.4,
			2508.23,
			-89.084,
			2237.4,
			2663.17,
			110.916
		},
		{
			"Temple",
			1096.47,
			-1026.33,
			-89.084,
			1252.33,
			-910.17,
			110.916
		},
		{
			"Glen Park",
			1812.62,
			-1449.67,
			-89.084,
			1996.91,
			-1350.72,
			110.916
		},
		{
			"Easter Bay Airport",
			-1242.98,
			-50.096,
			0,
			-1213.91,
			578.396,
			200
		},
		{
			"Martin Bridge",
			-222.179,
			293.324,
			0,
			-122.126,
			476.465,
			200
		},
		{
			"The Strip",
			2106.7,
			1863.23,
			-89.084,
			2162.39,
			2202.76,
			110.916
		},
		{
			"Willowfield",
			2541.7,
			-2059.23,
			-89.084,
			2703.58,
			-1941.4,
			110.916
		},
		{
			"Marina",
			807.922,
			-1577.59,
			-89.084,
			926.922,
			-1416.25,
			110.916
		},
		{
			"Las Venturas Airport",
			1457.37,
			1143.21,
			-89.084,
			1777.4,
			1203.28,
			110.916
		},
		{
			"Idlewood",
			1812.62,
			-1742.31,
			-89.084,
			1951.66,
			-1602.31,
			110.916
		},
		{
			"Esplanade East",
			-1580.01,
			1025.98,
			-6.1,
			-1499.89,
			1274.26,
			200
		},
		{
			"Downtown Los Santos",
			1370.85,
			-1384.95,
			-89.084,
			1463.9,
			-1170.87,
			110.916
		},
		{
			"The Mako Span",
			1664.62,
			401.75,
			0,
			1785.14,
			567.203,
			200
		},
		{
			"Rodeo",
			312.803,
			-1684.65,
			-89.084,
			422.68,
			-1501.95,
			110.916
		},
		{
			"Pershing Square",
			1440.9,
			-1722.26,
			-89.084,
			1583.5,
			-1577.59,
			110.916
		},
		{
			"Mulholland",
			687.802,
			-860.619,
			-89.084,
			911.802,
			-768.027,
			110.916
		},
		{
			"Gant Bridge",
			-2741.07,
			1490.47,
			-6.1,
			-2616.4,
			1659.68,
			200
		},
		{
			"Las Colinas",
			2185.33,
			-1154.59,
			-89.084,
			2281.45,
			-934.489,
			110.916
		},
		{
			"Mulholland",
			1169.13,
			-910.17,
			-89.084,
			1318.13,
			-768.027,
			110.916
		},
		{
			"Julius Thruway North",
			1938.8,
			2508.23,
			-89.084,
			2121.4,
			2624.23,
			110.916
		},
		{
			"Commerce",
			1667.96,
			-1577.59,
			-89.084,
			1812.62,
			-1430.87,
			110.916
		},
		{
			"Rodeo",
			72.648,
			-1544.17,
			-89.084,
			225.165,
			-1404.97,
			110.916
		},
		{
			"Roca Escalante",
			2536.43,
			2202.76,
			-89.084,
			2625.16,
			2442.55,
			110.916
		},
		{
			"Rodeo",
			72.648,
			-1684.65,
			-89.084,
			225.165,
			-1544.17,
			110.916
		},
		{
			"Market",
			952.663,
			-1310.21,
			-89.084,
			1072.66,
			-1130.85,
			110.916
		},
		{
			"Las Colinas",
			2632.74,
			-1135.04,
			-89.084,
			2747.74,
			-945.035,
			110.916
		},
		{
			"Mulholland",
			861.085,
			-674.885,
			-89.084,
			1156.55,
			-600.896,
			110.916
		},
		{
			"King's",
			-2253.54,
			373.539,
			-9.1,
			-1993.28,
			458.411,
			200
		},
		{
			"Redsands East",
			1848.4,
			2342.83,
			-89.084,
			2011.94,
			2478.49,
			110.916
		},
		{
			"Downtown",
			-1580.01,
			744.267,
			-6.1,
			-1499.89,
			1025.98,
			200
		},
		{
			"Conference Center",
			1046.15,
			-1804.21,
			-89.084,
			1323.9,
			-1722.26,
			110.916
		},
		{
			"Richman",
			647.557,
			-1118.28,
			-89.084,
			787.461,
			-954.662,
			110.916
		},
		{
			"Ocean Flats",
			-2994.49,
			277.411,
			-9.1,
			-2867.85,
			458.411,
			200
		},
		{
			"Greenglass College",
			964.391,
			930.89,
			-89.084,
			1166.53,
			1044.69,
			110.916
		},
		{
			"Glen Park",
			1812.62,
			-1100.82,
			-89.084,
			1994.33,
			-973.38,
			110.916
		},
		{
			"LVA Freight Depot",
			1375.6,
			919.447,
			-89.084,
			1457.37,
			1203.28,
			110.916
		},
		{
			"Regular Tom",
			-405.77,
			1712.86,
			-3,
			-276.719,
			1892.75,
			200
		},
		{
			"Verona Beach",
			1161.52,
			-1722.26,
			-89.084,
			1323.9,
			-1577.59,
			110.916
		},
		{
			"East Los Santos",
			2281.45,
			-1372.04,
			-89.084,
			2381.68,
			-1135.04,
			110.916
		},
		{
			"Caligula's Palace",
			2137.4,
			1703.23,
			-89.084,
			2437.39,
			1783.23,
			110.916
		},
		{
			"Idlewood",
			1951.66,
			-1742.31,
			-89.084,
			2124.66,
			-1602.31,
			110.916
		},
		{
			"Pilgrim",
			2624.4,
			1383.23,
			-89.084,
			2685.16,
			1783.23,
			110.916
		},
		{
			"Idlewood",
			2124.66,
			-1742.31,
			-89.084,
			2222.56,
			-1494.03,
			110.916
		},
		{
			"Queens",
			-2533.04,
			458.411,
			0,
			-2329.31,
			578.396,
			200
		},
		{
			"Downtown",
			-1871.72,
			1176.42,
			-4.5,
			-1620.3,
			1274.26,
			200
		},
		{
			"Commerce",
			1583.5,
			-1722.26,
			-89.084,
			1758.9,
			-1577.59,
			110.916
		},
		{
			"East Los Santos",
			2381.68,
			-1454.35,
			-89.084,
			2462.13,
			-1135.04,
			110.916
		},
		{
			"Marina",
			647.712,
			-1577.59,
			-89.084,
			807.922,
			-1416.25,
			110.916
		},
		{
			"Richman",
			72.648,
			-1404.97,
			-89.084,
			225.165,
			-1235.07,
			110.916
		},
		{
			"Vinewood",
			647.712,
			-1416.25,
			-89.084,
			787.461,
			-1227.28,
			110.916
		},
		{
			"East Los Santos",
			2222.56,
			-1628.53,
			-89.084,
			2421.03,
			-1494.03,
			110.916
		},
		{
			"Rodeo",
			558.099,
			-1684.65,
			-89.084,
			647.522,
			-1384.93,
			110.916
		},
		{
			"Easter Tunnel",
			-1709.71,
			-833.034,
			-1.5,
			-1446.01,
			-730.118,
			200
		},
		{
			"Rodeo",
			466.223,
			-1385.07,
			-89.084,
			647.522,
			-1235.07,
			110.916
		},
		{
			"Redsands East",
			1817.39,
			2202.76,
			-89.084,
			2011.94,
			2342.83,
			110.916
		},
		{
			"The Clown's Pocket",
			2162.39,
			1783.23,
			-89.084,
			2437.39,
			1883.23,
			110.916
		},
		{
			"Idlewood",
			1971.66,
			-1852.87,
			-89.084,
			2222.56,
			-1742.31,
			110.916
		},
		{
			"Montgomery Intersection",
			1546.65,
			208.164,
			0,
			1745.83,
			347.457,
			200
		},
		{
			"Willowfield",
			2089,
			-2235.84,
			-89.084,
			2201.82,
			-1989.9,
			110.916
		},
		{
			"Temple",
			952.663,
			-1130.84,
			-89.084,
			1096.47,
			-937.184,
			110.916
		},
		{
			"Prickle Pine",
			1848.4,
			2553.49,
			-89.084,
			1938.8,
			2863.23,
			110.916
		},
		{
			"Los Santos International",
			1400.97,
			-2669.26,
			-39.084,
			2189.82,
			-2597.26,
			60.916
		},
		{
			"Garver Bridge",
			-1213.91,
			950.022,
			-89.084,
			-1087.93,
			1178.93,
			110.916
		},
		{
			"Garver Bridge",
			-1339.89,
			828.129,
			-89.084,
			-1213.91,
			1057.04,
			110.916
		},
		{
			"Kincaid Bridge",
			-1339.89,
			599.218,
			-89.084,
			-1213.91,
			828.129,
			110.916
		},
		{
			"Kincaid Bridge",
			-1213.91,
			721.111,
			-89.084,
			-1087.93,
			950.022,
			110.916
		},
		{
			"Verona Beach",
			930.221,
			-2006.78,
			-89.084,
			1073.22,
			-1804.21,
			110.916
		},
		{
			"Verdant Bluffs",
			1073.22,
			-2006.78,
			-89.084,
			1249.62,
			-1842.27,
			110.916
		},
		{
			"Vinewood",
			787.461,
			-1130.84,
			-89.084,
			952.604,
			-954.662,
			110.916
		},
		{
			"Vinewood",
			787.461,
			-1310.21,
			-89.084,
			952.663,
			-1130.84,
			110.916
		},
		{
			"Commerce",
			1463.9,
			-1577.59,
			-89.084,
			1667.96,
			-1430.87,
			110.916
		},
		{
			"Market",
			787.461,
			-1416.25,
			-89.084,
			1072.66,
			-1310.21,
			110.916
		},
		{
			"Rockshore West",
			2377.39,
			596.349,
			-89.084,
			2537.39,
			788.894,
			110.916
		},
		{
			"Julius Thruway North",
			2237.4,
			2542.55,
			-89.084,
			2498.21,
			2663.17,
			110.916
		},
		{
			"East Beach",
			2632.83,
			-1668.13,
			-89.084,
			2747.74,
			-1393.42,
			110.916
		},
		{
			"Fallow Bridge",
			434.341,
			366.572,
			0,
			603.035,
			555.68,
			200
		},
		{
			"Willowfield",
			2089,
			-1989.9,
			-89.084,
			2324,
			-1852.87,
			110.916
		},
		{
			"Chinatown",
			-2274.17,
			578.396,
			-7.6,
			-2078.67,
			744.17,
			200
		},
		{
			"El Castillo del Diablo",
			-208.57,
			2337.18,
			0,
			8.43,
			2487.18,
			200
		},
		{
			"Ocean Docks",
			2324,
			-2145.1,
			-89.084,
			2703.58,
			-2059.23,
			110.916
		},
		{
			"Easter Bay Chemicals",
			-1132.82,
			-768.027,
			0,
			-956.476,
			-578.118,
			200
		},
		{
			"The Visage",
			1817.39,
			1703.23,
			-89.084,
			2027.4,
			1863.23,
			110.916
		},
		{
			"Ocean Flats",
			-2994.49,
			-430.276,
			-1.2,
			-2831.89,
			-222.589,
			200
		},
		{
			"Richman",
			321.356,
			-860.619,
			-89.084,
			687.802,
			-768.027,
			110.916
		},
		{
			"Green Palms",
			176.581,
			1305.45,
			-3,
			338.658,
			1520.72,
			200
		},
		{
			"Richman",
			321.356,
			-768.027,
			-89.084,
			700.794,
			-674.885,
			110.916
		},
		{
			"Starfish Casino",
			2162.39,
			1883.23,
			-89.084,
			2437.39,
			2012.18,
			110.916
		},
		{
			"East Beach",
			2747.74,
			-1668.13,
			-89.084,
			2959.35,
			-1498.62,
			110.916
		},
		{
			"Jefferson",
			2056.86,
			-1372.04,
			-89.084,
			2281.45,
			-1210.74,
			110.916
		},
		{
			"Downtown Los Santos",
			1463.9,
			-1290.87,
			-89.084,
			1724.76,
			-1150.87,
			110.916
		},
		{
			"Downtown Los Santos",
			1463.9,
			-1430.87,
			-89.084,
			1724.76,
			-1290.87,
			110.916
		},
		{
			"Garver Bridge",
			-1499.89,
			696.442,
			-179.615,
			-1339.89,
			925.353,
			20.385
		},
		{
			"Julius Thruway South",
			1457.39,
			823.228,
			-89.084,
			2377.39,
			863.229,
			110.916
		},
		{
			"East Los Santos",
			2421.03,
			-1628.53,
			-89.084,
			2632.83,
			-1454.35,
			110.916
		},
		{
			"Greenglass College",
			964.391,
			1044.69,
			-89.084,
			1197.39,
			1203.22,
			110.916
		},
		{
			"Las Colinas",
			2747.74,
			-1120.04,
			-89.084,
			2959.35,
			-945.035,
			110.916
		},
		{
			"Mulholland",
			737.573,
			-768.027,
			-89.084,
			1142.29,
			-674.885,
			110.916
		},
		{
			"Ocean Docks",
			2201.82,
			-2730.88,
			-89.084,
			2324,
			-2418.33,
			110.916
		},
		{
			"East Los Santos",
			2462.13,
			-1454.35,
			-89.084,
			2581.73,
			-1135.04,
			110.916
		},
		{
			"Ganton",
			2222.56,
			-1722.33,
			-89.084,
			2632.83,
			-1628.53,
			110.916
		},
		{
			"Avispa Country Club",
			-2831.89,
			-430.276,
			-6.1,
			-2646.4,
			-222.589,
			200
		},
		{
			"Willowfield",
			1970.62,
			-2179.25,
			-89.084,
			2089,
			-1852.87,
			110.916
		},
		{
			"Esplanade North",
			-1982.32,
			1274.26,
			-4.5,
			-1524.24,
			1358.9,
			200
		},
		{
			"The High Roller",
			1817.39,
			1283.23,
			-89.084,
			2027.39,
			1469.23,
			110.916
		},
		{
			"Ocean Docks",
			2201.82,
			-2418.33,
			-89.084,
			2324,
			-2095,
			110.916
		},
		{
			"Last Dime Motel",
			1823.08,
			596.349,
			-89.084,
			1997.22,
			823.228,
			110.916
		},
		{
			"Bayside Marina",
			-2353.17,
			2275.79,
			0,
			-2153.17,
			2475.79,
			200
		},
		{
			"King's",
			-2329.31,
			458.411,
			-7.6,
			-1993.28,
			578.396,
			200
		},
		{
			"El Corona",
			1692.62,
			-2179.25,
			-89.084,
			1812.62,
			-1842.27,
			110.916
		},
		{
			"Blackfield Chapel",
			1375.6,
			596.349,
			-89.084,
			1558.09,
			823.228,
			110.916
		},
		{
			"The Pink Swan",
			1817.39,
			1083.23,
			-89.084,
			2027.39,
			1283.23,
			110.916
		},
		{
			"Julius Thruway West",
			1197.39,
			1163.39,
			-89.084,
			1236.63,
			2243.23,
			110.916
		},
		{
			"Los Flores",
			2581.73,
			-1393.42,
			-89.084,
			2747.74,
			-1135.04,
			110.916
		},
		{
			"The Visage",
			1817.39,
			1863.23,
			-89.084,
			2106.7,
			2011.83,
			110.916
		},
		{
			"Prickle Pine",
			1938.8,
			2624.23,
			-89.084,
			2121.4,
			2861.55,
			110.916
		},
		{
			"Verona Beach",
			851.449,
			-1804.21,
			-89.084,
			1046.15,
			-1577.59,
			110.916
		},
		{
			"Robada Intersection",
			-1119.01,
			1178.93,
			-89.084,
			-862.025,
			1351.45,
			110.916
		},
		{
			"Linden Side",
			2749.9,
			943.235,
			-89.084,
			2923.39,
			1198.99,
			110.916
		},
		{
			"Ocean Docks",
			2703.58,
			-2302.33,
			-89.084,
			2959.35,
			-2126.9,
			110.916
		},
		{
			"Willowfield",
			2324,
			-2059.23,
			-89.084,
			2541.7,
			-1852.87,
			110.916
		},
		{
			"King's",
			-2411.22,
			265.243,
			-9.1,
			-1993.28,
			373.539,
			200
		},
		{
			"Commerce",
			1323.9,
			-1842.27,
			-89.084,
			1701.9,
			-1722.26,
			110.916
		},
		{
			"Mulholland",
			1269.13,
			-768.027,
			-89.084,
			1414.07,
			-452.425,
			110.916
		},
		{
			"Marina",
			647.712,
			-1804.21,
			-89.084,
			851.449,
			-1577.59,
			110.916
		},
		{
			"Battery Point",
			-2741.07,
			1268.41,
			-4.5,
			-2533.04,
			1490.47,
			200
		},
		{
			"The Four Dragons Casino",
			1817.39,
			863.232,
			-89.084,
			2027.39,
			1083.23,
			110.916
		},
		{
			"Blackfield",
			964.391,
			1203.22,
			-89.084,
			1197.39,
			1403.22,
			110.916
		},
		{
			"Julius Thruway North",
			1534.56,
			2433.23,
			-89.084,
			1848.4,
			2583.23,
			110.916
		},
		{
			"Yellow Bell Gol Course",
			1117.4,
			2723.23,
			-89.084,
			1457.46,
			2863.23,
			110.916
		},
		{
			"Idlewood",
			1812.62,
			-1602.31,
			-89.084,
			2124.66,
			-1449.67,
			110.916
		},
		{
			"Redsands West",
			1297.47,
			2142.86,
			-89.084,
			1777.39,
			2243.23,
			110.916
		},
		{
			"Doherty",
			-2270.04,
			-324.114,
			-1.2,
			-1794.92,
			-222.589,
			200
		},
		{
			"Hilltop Farm",
			967.383,
			-450.39,
			-3,
			1176.78,
			-217.9,
			200
		},
		{
			"Las Barrancas",
			-926.13,
			1398.73,
			-3,
			-719.234,
			1634.69,
			200
		},
		{
			"Pirates in Men's Pants",
			1817.39,
			1469.23,
			-89.084,
			2027.4,
			1703.23,
			110.916
		},
		{
			"City Hall",
			-2867.85,
			277.411,
			-9.1,
			-2593.44,
			458.411,
			200
		},
		{
			"Avispa Country Club",
			-2646.4,
			-355.493,
			0,
			-2270.04,
			-222.589,
			200
		},
		{
			"The Strip",
			2027.4,
			863.229,
			-89.084,
			2087.39,
			1703.23,
			110.916
		},
		{
			"Hashbury",
			-2593.44,
			-222.589,
			-1,
			-2411.22,
			54.722,
			200
		},
		{
			"Los Santos International",
			1852,
			-2394.33,
			-89.084,
			2089,
			-2179.25,
			110.916
		},
		{
			"Whitewood Estates",
			1098.31,
			1726.22,
			-89.084,
			1197.39,
			2243.23,
			110.916
		},
		{
			"Sherman Reservoir",
			-789.737,
			1659.68,
			-89.084,
			-599.505,
			1929.41,
			110.916
		},
		{
			"El Corona",
			1812.62,
			-2179.25,
			-89.084,
			1970.62,
			-1852.87,
			110.916
		},
		{
			"Downtown",
			-1700.01,
			744.267,
			-6.1,
			-1580.01,
			1176.52,
			200
		},
		{
			"Foster Valley",
			-2178.69,
			-1250.97,
			0,
			-1794.92,
			-1115.58,
			200
		},
		{
			"Las Payasadas",
			-354.332,
			2580.36,
			2,
			-133.625,
			2816.82,
			200
		},
		{
			"Valle Ocultado",
			-936.668,
			2611.44,
			2,
			-715.961,
			2847.9,
			200
		},
		{
			"Blackfield Intersection",
			1166.53,
			795.01,
			-89.084,
			1375.6,
			1044.69,
			110.916
		},
		{
			"Ganton",
			2222.56,
			-1852.87,
			-89.084,
			2632.83,
			-1722.33,
			110.916
		},
		{
			"Easter Bay Airport",
			-1213.91,
			-730.118,
			0,
			-1132.82,
			-50.096,
			200
		},
		{
			"Redsands East",
			1817.39,
			2011.83,
			-89.084,
			2106.7,
			2202.76,
			110.916
		},
		{
			"Esplanade East",
			-1499.89,
			578.396,
			-79.615,
			-1339.89,
			1274.26,
			20.385
		},
		{
			"Caligula's Palace",
			2087.39,
			1543.23,
			-89.084,
			2437.39,
			1703.23,
			110.916
		},
		{
			"Royal Casino",
			2087.39,
			1383.23,
			-89.084,
			2437.39,
			1543.23,
			110.916
		},
		{
			"Richman",
			72.648,
			-1235.07,
			-89.084,
			321.356,
			-1008.15,
			110.916
		},
		{
			"Starfish Casino",
			2437.39,
			1783.23,
			-89.084,
			2685.16,
			2012.18,
			110.916
		},
		{
			"Mulholland",
			1281.13,
			-452.425,
			-89.084,
			1641.13,
			-290.913,
			110.916
		},
		{
			"Downtown",
			-1982.32,
			744.17,
			-6.1,
			-1871.72,
			1274.26,
			200
		},
		{
			"Hankypanky Point",
			2576.92,
			62.158,
			0,
			2759.25,
			385.503,
			200
		},
		{
			"K.A.C.C. Military Fuels",
			2498.21,
			2626.55,
			-89.084,
			2749.9,
			2861.55,
			110.916
		},
		{
			"Harry Gold Parkway",
			1777.39,
			863.232,
			-89.084,
			1817.39,
			2342.83,
			110.916
		},
		{
			"Bayside Tunnel",
			-2290.19,
			2548.29,
			-89.084,
			-1950.19,
			2723.29,
			110.916
		},
		{
			"Ocean Docks",
			2324,
			-2302.33,
			-89.084,
			2703.58,
			-2145.1,
			110.916
		},
		{
			"Richman",
			321.356,
			-1044.07,
			-89.084,
			647.557,
			-860.619,
			110.916
		},
		{
			"Randolph Industrial Estate",
			1558.09,
			596.349,
			-89.084,
			1823.08,
			823.235,
			110.916
		},
		{
			"East Beach",
			2632.83,
			-1852.87,
			-89.084,
			2959.35,
			-1668.13,
			110.916
		},
		{
			"Flint Water",
			-314.426,
			-753.874,
			-89.084,
			-106.339,
			-463.073,
			110.916
		},
		{
			"Blueberry",
			19.607,
			-404.136,
			3.8,
			349.607,
			-220.137,
			200
		},
		{
			"Linden Station",
			2749.9,
			1198.99,
			-89.084,
			2923.39,
			1548.99,
			110.916
		},
		{
			"Glen Park",
			1812.62,
			-1350.72,
			-89.084,
			2056.86,
			-1100.82,
			110.916
		},
		{
			"Downtown",
			-1993.28,
			265.243,
			-9.1,
			-1794.92,
			578.396,
			200
		},
		{
			"Redsands West",
			1377.39,
			2243.23,
			-89.084,
			1704.59,
			2433.23,
			110.916
		},
		{
			"Richman",
			321.356,
			-1235.07,
			-89.084,
			647.522,
			-1044.07,
			110.916
		},
		{
			"Gant Bridge",
			-2741.45,
			1659.68,
			-6.1,
			-2616.4,
			2175.15,
			200
		},
		{
			"Lil' Probe Inn",
			-90.218,
			1286.85,
			-3,
			153.859,
			1554.12,
			200
		},
		{
			"Flint Intersection",
			-187.7,
			-1596.76,
			-89.084,
			17.063,
			-1276.6,
			110.916
		},
		{
			"Las Colinas",
			2281.45,
			-1135.04,
			-89.084,
			2632.74,
			-945.035,
			110.916
		},
		{
			"Sobell Rail Yards",
			2749.9,
			1548.99,
			-89.084,
			2923.39,
			1937.25,
			110.916
		},
		{
			"The Emerald Isle",
			2011.94,
			2202.76,
			-89.084,
			2237.4,
			2508.23,
			110.916
		},
		{
			"El Castillo del Diablo",
			-208.57,
			2123.01,
			-7.6,
			114.033,
			2337.18,
			200
		},
		{
			"Santa Flora",
			-2741.07,
			458.411,
			-7.6,
			-2533.04,
			793.411,
			200
		},
		{
			"Playa del Seville",
			2703.58,
			-2126.9,
			-89.084,
			2959.35,
			-1852.87,
			110.916
		},
		{
			"Market",
			926.922,
			-1577.59,
			-89.084,
			1370.85,
			-1416.25,
			110.916
		},
		{
			"Queens",
			-2593.44,
			54.722,
			0,
			-2411.22,
			458.411,
			200
		},
		{
			"Pilson Intersection",
			1098.39,
			2243.23,
			-89.084,
			1377.39,
			2507.23,
			110.916
		},
		{
			"Spinybed",
			2121.4,
			2663.17,
			-89.084,
			2498.21,
			2861.55,
			110.916
		},
		{
			"Pilgrim",
			2437.39,
			1383.23,
			-89.084,
			2624.4,
			1783.23,
			110.916
		},
		{
			"Blackfield",
			964.391,
			1403.22,
			-89.084,
			1197.39,
			1726.22,
			110.916
		},
		{
			"'The Big Ear'",
			-410.02,
			1403.34,
			-3,
			-137.969,
			1681.23,
			200
		},
		{
			"Dillimore",
			580.794,
			-674.885,
			-9.5,
			861.085,
			-404.79,
			200
		},
		{
			"El Quebrados",
			-1645.23,
			2498.52,
			0,
			-1372.14,
			2777.85,
			200
		},
		{
			"Esplanade North",
			-2533.04,
			1358.9,
			-4.5,
			-1996.66,
			1501.21,
			200
		},
		{
			"Easter Bay Airport",
			-1499.89,
			-50.096,
			-1,
			-1242.98,
			249.904,
			200
		},
		{
			"Fisher's Lagoon",
			1916.99,
			-233.323,
			-100,
			2131.72,
			13.8,
			200
		},
		{
			"Mulholland",
			1414.07,
			-768.027,
			-89.084,
			1667.61,
			-452.425,
			110.916
		},
		{
			"East Beach",
			2747.74,
			-1498.62,
			-89.084,
			2959.35,
			-1120.04,
			110.916
		},
		{
			"San Andreas Sound",
			2450.39,
			385.503,
			-100,
			2759.25,
			562.349,
			200
		},
		{
			"Shady Creeks",
			-2030.12,
			-2174.89,
			-6.1,
			-1820.64,
			-1771.66,
			200
		},
		{
			"Market",
			1072.66,
			-1416.25,
			-89.084,
			1370.85,
			-1130.85,
			110.916
		},
		{
			"Rockshore West",
			1997.22,
			596.349,
			-89.084,
			2377.39,
			823.228,
			110.916
		},
		{
			"Prickle Pine",
			1534.56,
			2583.23,
			-89.084,
			1848.4,
			2863.23,
			110.916
		},
		{
			"Easter Basin",
			-1794.92,
			-50.096,
			-1.04,
			-1499.89,
			249.904,
			200
		},
		{
			"Leafy Hollow",
			-1166.97,
			-1856.03,
			0,
			-815.624,
			-1602.07,
			200
		},
		{
			"LVA Freight Depot",
			1457.39,
			863.229,
			-89.084,
			1777.4,
			1143.21,
			110.916
		},
		{
			"Prickle Pine",
			1117.4,
			2507.23,
			-89.084,
			1534.56,
			2723.23,
			110.916
		},
		{
			"Blueberry",
			104.534,
			-220.137,
			2.3,
			349.607,
			152.236,
			200
		},
		{
			"El Castillo del Diablo",
			-464.515,
			2217.68,
			0,
			-208.57,
			2580.36,
			200
		},
		{
			"Downtown",
			-2078.67,
			578.396,
			-7.6,
			-1499.89,
			744.267,
			200
		},
		{
			"Rockshore East",
			2537.39,
			676.549,
			-89.084,
			2902.35,
			943.235,
			110.916
		},
		{
			"San Fierro Bay",
			-2616.4,
			1501.21,
			-3,
			-1996.66,
			1659.68,
			200
		},
		{
			"Paradiso",
			-2741.07,
			793.411,
			-6.1,
			-2533.04,
			1268.41,
			200
		},
		{
			"The Camel's Toe",
			2087.39,
			1203.23,
			-89.084,
			2640.4,
			1383.23,
			110.916
		},
		{
			"Old Venturas Strip",
			2162.39,
			2012.18,
			-89.084,
			2685.16,
			2202.76,
			110.916
		},
		{
			"Juniper Hill",
			-2533.04,
			578.396,
			-7.6,
			-2274.17,
			968.369,
			200
		},
		{
			"Juniper Hollow",
			-2533.04,
			968.369,
			-6.1,
			-2274.17,
			1358.9,
			200
		},
		{
			"Roca Escalante",
			2237.4,
			2202.76,
			-89.084,
			2536.43,
			2542.55,
			110.916
		},
		{
			"Julius Thruway East",
			2685.16,
			1055.96,
			-89.084,
			2749.9,
			2626.55,
			110.916
		},
		{
			"Verona Beach",
			647.712,
			-2173.29,
			-89.084,
			930.221,
			-1804.21,
			110.916
		},
		{
			"Foster Valley",
			-2178.69,
			-599.884,
			-1.2,
			-1794.92,
			-324.114,
			200
		},
		{
			"Arco del Oeste",
			-901.129,
			2221.86,
			0,
			-592.09,
			2571.97,
			200
		},
		{
			"Fallen Tree",
			-792.254,
			-698.555,
			-5.3,
			-452.404,
			-380.043,
			200
		},
		{
			"The Farm",
			-1209.67,
			-1317.1,
			114.981,
			-908.161,
			-787.391,
			251.981
		},
		{
			"The Sherman Dam",
			-968.772,
			1929.41,
			-3,
			-481.126,
			2155.26,
			200
		},
		{
			"Esplanade North",
			-1996.66,
			1358.9,
			-4.5,
			-1524.24,
			1592.51,
			200
		},
		{
			"Financial",
			-1871.72,
			744.17,
			-6.1,
			-1701.3,
			1176.42,
			300
		},
		{
			"Garcia",
			-2411.22,
			-222.589,
			-1.14,
			-2173.04,
			265.243,
			200
		},
		{
			"Montgomery",
			1119.51,
			119.526,
			-3,
			1451.4,
			493.323,
			200
		},
		{
			"Creek",
			2749.9,
			1937.25,
			-89.084,
			2921.62,
			2669.79,
			110.916
		},
		{
			"Los Santos International",
			1249.62,
			-2394.33,
			-89.084,
			1852,
			-2179.25,
			110.916
		},
		{
			"Santa Maria",
			72.648,
			-2173.29,
			-89.084,
			342.648,
			-1684.65,
			110.916
		},
		{
			"Mulholland",
			1463.9,
			-1150.87,
			-89.084,
			1812.62,
			-768.027,
			110.916
		},
		{
			"Angel Pine",
			-2324.94,
			-2584.29,
			-6.1,
			-1964.22,
			-2212.11,
			200
		},
		{
			"Verdant Meadows",
			37.032,
			2337.18,
			-3,
			435.988,
			2677.9,
			200
		},
		{
			"Octane Springs",
			338.658,
			1228.51,
			0,
			664.308,
			1655.05,
			200
		},
		{
			"Come-A-Lot",
			2087.39,
			943.235,
			-89.084,
			2623.18,
			1203.23,
			110.916
		},
		{
			"Redsands West",
			1236.63,
			1883.11,
			-89.084,
			1777.39,
			2142.86,
			110.916
		},
		{
			"Santa Maria",
			342.648,
			-2173.29,
			-89.084,
			647.712,
			-1684.65,
			110.916
		},
		{
			"Verdant Bluffs",
			1249.62,
			-2179.25,
			-89.084,
			1692.62,
			-1842.27,
			110.916
		},
		{
			"Las Venturas Airport",
			1236.63,
			1203.28,
			-89.084,
			1457.37,
			1883.11,
			110.916
		},
		{
			"Flint Range",
			-594.191,
			-1648.55,
			0,
			-187.7,
			-1276.6,
			200
		},
		{
			"Verdant Bluffs",
			930.221,
			-2488.42,
			-89.084,
			1249.62,
			-2006.78,
			110.916
		},
		{
			"Palomino Creek",
			2160.22,
			-149.004,
			0,
			2576.92,
			228.322,
			200
		},
		{
			"Ocean Docks",
			2373.77,
			-2697.09,
			-89.084,
			2809.22,
			-2330.46,
			110.916
		},
		{
			"Easter Bay Airport",
			-1213.91,
			-50.096,
			-4.5,
			-947.98,
			578.396,
			200
		},
		{
			"Whitewood Estates",
			883.308,
			1726.22,
			-89.084,
			1098.31,
			2507.23,
			110.916
		},
		{
			"Calton Heights",
			-2274.17,
			744.17,
			-6.1,
			-1982.32,
			1358.9,
			200
		},
		{
			"Easter Basin",
			-1794.92,
			249.904,
			-9.1,
			-1242.98,
			578.396,
			200
		},
		{
			"Los Santos Inlet",
			-321.744,
			-2224.43,
			-89.084,
			44.615,
			-1724.43,
			110.916
		},
		{
			"Doherty",
			-2173.04,
			-222.589,
			-1,
			-1794.92,
			265.243,
			200
		},
		{
			"Mount Chiliad",
			-2178.69,
			-2189.91,
			-47.917,
			-2030.12,
			-1771.66,
			576.083
		},
		{
			"Fort Carson",
			-376.233,
			826.326,
			-3,
			123.717,
			1220.44,
			200
		},
		{
			"Foster Valley",
			-2178.69,
			-1115.58,
			0,
			-1794.92,
			-599.884,
			200
		},
		{
			"Ocean Flats",
			-2994.49,
			-222.589,
			-1,
			-2593.44,
			277.411,
			200
		},
		{
			"Fern Ridge",
			508.189,
			-139.259,
			0,
			1306.66,
			119.526,
			200
		},
		{
			"Bayside",
			-2741.07,
			2175.15,
			0,
			-2353.17,
			2722.79,
			200
		},
		{
			"Las Venturas Airport",
			1457.37,
			1203.28,
			-89.084,
			1777.39,
			1883.11,
			110.916
		},
		{
			"Blueberry Acres",
			-319.676,
			-220.137,
			0,
			104.534,
			293.324,
			200
		},
		{
			"Palisades",
			-2994.49,
			458.411,
			-6.1,
			-2741.07,
			1339.61,
			200
		},
		{
			"North Rock",
			2285.37,
			-768.027,
			0,
			2770.59,
			-269.74,
			200
		},
		{
			"Hunter Quarry",
			337.244,
			710.84,
			-115.239,
			860.554,
			1031.71,
			203.761
		},
		{
			"Los Santos International",
			1382.73,
			-2730.88,
			-89.084,
			2201.82,
			-2394.33,
			110.916
		},
		{
			"Missionary Hill",
			-2994.49,
			-811.276,
			0,
			-2178.69,
			-430.276,
			200
		},
		{
			"San Fierro Bay",
			-2616.4,
			1659.68,
			-3,
			-1996.66,
			2175.15,
			200
		},
		{
			"Restricted Area",
			-91.586,
			1655.05,
			-50,
			421.234,
			2123.01,
			250
		},
		{
			"Mount Chiliad",
			-2997.47,
			-1115.58,
			-47.917,
			-2178.69,
			-971.913,
			576.083
		},
		{
			"Mount Chiliad",
			-2178.69,
			-1771.66,
			-47.917,
			-1936.12,
			-1250.97,
			576.083
		},
		{
			"Easter Bay Airport",
			-1794.92,
			-730.118,
			-3,
			-1213.91,
			-50.096,
			200
		},
		{
			"The Panopticon",
			-947.98,
			-304.32,
			-1.1,
			-319.676,
			327.071,
			200
		},
		{
			"Shady Creeks",
			-1820.64,
			-2643.68,
			-8,
			-1226.78,
			-1771.66,
			200
		},
		{
			"Back o Beyond",
			-1166.97,
			-2641.19,
			0,
			-321.744,
			-1856.03,
			200
		},
		{
			"Mount Chiliad",
			-2994.49,
			-2189.91,
			-47.917,
			-2178.69,
			-1115.58,
			576.083
		},
		{
			"Tierra Robada",
			-1213.91,
			596.349,
			-242.99,
			-480.539,
			1659.68,
			900
		},
		{
			"Flint County",
			-1213.91,
			-2892.97,
			-242.99,
			44.615,
			-768.027,
			900
		},
		{
			"Whetstone",
			-2997.47,
			-2892.97,
			-242.99,
			-1213.91,
			-1115.58,
			900
		},
		{
			"Bone County",
			-480.539,
			596.349,
			-242.99,
			869.461,
			2993.87,
			900
		},
		{
			"Tierra Robada",
			-2997.47,
			1659.68,
			-242.99,
			-480.539,
			2993.87,
			900
		},
		{
			"San Fierro",
			-2997.47,
			-1115.58,
			-242.99,
			-1213.91,
			1659.68,
			900
		},
		{
			"Las Venturas",
			869.461,
			596.349,
			-242.99,
			2997.06,
			2993.87,
			900
		},
		{
			"Red County",
			-1213.91,
			-768.027,
			-242.99,
			2997.06,
			596.349,
			900
		},
		{
			"Los Santos",
			44.615,
			-2892.97,
			-242.99,
			2997.06,
			-768.027,
			900
		}
	}

	if arg_47_0 ~= nil and arg_47_1 ~= nil and arg_47_2 ~= nil then
		for iter_47_0, iter_47_1 in ipairs(var_47_0) do
			if arg_47_0 >= iter_47_1[2] and arg_47_1 >= iter_47_1[3] and arg_47_2 >= iter_47_1[4] and arg_47_0 <= iter_47_1[5] and arg_47_1 <= iter_47_1[6] and arg_47_2 <= iter_47_1[7] then
				return iter_47_1[1]
			end
		end
	end

	return "Квартира"
end

function checkLicenseOnline()
    local token = tostring(getToken())
    local baseUrl = "https://license-server-6fq2.onrender.com"

    local jsonBody = encodeJson({ hwid = token })

    local response
    local ok = pcall(function()
        response = requests.post(baseUrl .. "/check", {
            headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json"
            },
            data = jsonBody
        })
    end)

    if not ok or not response then
        print("Нет соединения с сервером лицензий")
        return false
    end

    if response.status_code ~= 200 then
        print("Ошибка HTTP: " .. response.status_code)
        return false
    end

    local data = decodeJson(response.text)
    if not data then
        print("Ошибка JSON от сервера")
        return false
    end

    if data.status == "ok" then
       -- print("Лицензия активна. Осталось дней: " .. data.days_left)
        return true
    elseif data.status == "inactive" then
        --print("Лицензия найдена, но не активирована")
        return false
    elseif data.status == "expired" then
        print("Срок действия лицензии истёк")
        return false
    elseif data.status == "banned" then
       -- print("Лицензия заблокирована")
        return false
    elseif data.status == "unregistered" then
       -- print("HWID не зарегистрирован")
        return false
    else
        --print("Неизвестный статус лицензии")
        return false
    end
end


function asyncHttpRequest(arg_53_0, arg_53_1, arg_53_2, arg_53_3, arg_53_4)
	local var_53_0 = effil.thread(function(arg_54_0, arg_54_1, arg_54_2)
		local var_54_0 = require("requests")
		local var_54_1, var_54_2 = pcall(var_54_0.request, arg_54_0, arg_54_1, arg_54_2)

		if var_54_1 then
			var_54_2.json, var_54_2.xml = nil

			return true, var_54_2
		else
			return false, var_54_2
		end
	end)(arg_53_0, arg_53_1, arg_53_2)

	arg_53_3 = arg_53_3 or function()
		return
	end
	arg_53_4 = arg_53_4 or function()
		return
	end

	lua_thread.create(function()
		local var_57_0 = var_53_0

		while true do
			local var_57_1, var_57_2 = var_57_0:status()

			if not var_57_2 then
				if var_57_1 == "completed" then
					local var_57_3, var_57_4 = var_57_0:get()

					if var_57_3 then
						arg_53_3(var_57_4)
					else
						arg_53_4(var_57_4)
					end

					return
				elseif var_57_1 == "canceled" then
					return arg_53_4(var_57_1)
				end
			else
				return arg_53_4(var_57_2)
			end

			wait(0)
		end
	end)
end

function autoUpdate()
	local var_58_0 = require("moonloader").download_status
	local var_58_1 = getWorkingDirectory() .. "\\" .. thisScript().name .. "-version.json"

	if doesFileExist(var_58_1) then
		os.remove(var_58_1)
	end

	downloadUrlToFile("https://drive.google.com/uc?export=download&id=1q2YHQ9MrPJlTRPpRk4DNZ2hKE9_d4rt1", var_58_1, function(arg_59_0, arg_59_1, arg_59_2, arg_59_3)
		if arg_59_1 == var_58_0.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(var_58_1) then
				local var_59_0 = io.open(var_58_1, "r")

				if var_59_0 then
					local var_59_1 = decodeJson(var_59_0:read("*a"))

					updatelink = var_59_1.updateurl
					updateversion = var_59_1.latest

					var_59_0:close()
					os.remove(var_58_1)

					if updateversion ~= thisScript().version then
						lua_thread.create(function()
							local var_60_0 = require("moonloader").download_status

							sampAddChatMessage(prefix .. "{FFAA11}Обнаружено обновление. AutoReload может конфликтовать. Обновляюсь...", 11184810)
							sampAddChatMessage(prefix .. "{FFAA11}Текущая версия: {00BFFF}" .. thisScript().version .. "{FFAA11}. Новая версия: {00BFFF} " .. updateversion, 11184810)
							wait(250)
							downloadUrlToFile(updatelink, thisScript().path, function(arg_61_0, arg_61_1, arg_61_2, arg_61_3)
								if arg_61_1 == var_60_0.STATUS_DOWNLOADINGDATA then
									print(string.format("Загружено %d из %d.", arg_61_2, arg_61_3))
								elseif arg_61_1 == var_60_0.STATUS_ENDDOWNLOADDATA then
									print("Загрузка обновления завершена.")
									sampAddChatMessage(prefix .. "{7FFF00}Обновление завершено!", 11184810)

									goupdatestatus = true

									lua_thread.create(function()
										wait(500)
										thisScript():reload()
									end)
								end

								if arg_61_1 == var_60_0.STATUSEX_ENDDOWNLOAD and goupdatestatus == nil then
									sampAddChatMessage(prefix .. "{EF435D}Обновление прошло с ошибкой. Запускаем старую версию...", 11184810)

									update = false
								end
							end)
						end)
					else
						update = false

						sampAddChatMessage(prefix .. "{FFAA11}Самая свежая версия - v" .. thisScript().version .. ". Обновление не требуется.", 11184810)
					end
				end
			else
				sampAddChatMessage(prefix .. "{FFAA11}Сейчас у Вас версия " .. thisScript().version .. " {FFFFFF}: {EF435D}Не могу проверить обновление. Смиритесь или напишите создателю скрипта - t.me/ash4o1", 11184810)

				update = false
			end
		end
	end)

	while update ~= false do
		wait(100)
	end
end

function getToken()
    local ffi = require("ffi")

    ffi.cdef([[
        int __stdcall GetVolumeInformationA(
            const char* lpRootPathName,
            char* lpVolumeNameBuffer,
            uint32_t nVolumeNameSize,
            uint32_t* lpVolumeSerialNumber,
            uint32_t* lpMaximumComponentLength,
            uint32_t* lpFileSystemFlags,
            char* lpFileSystemNameBuffer,
            uint32_t nFileSystemNameSize
        );
    ]])

    local var_63_1 = ffi.new("unsigned long[1]", 0)
    ffi.C.GetVolumeInformationA(nil, nil, 0, var_63_1, nil, nil, nil, 0)

    return var_63_1[0]
end

function imgui.TextColoredRGB(text, render_text)
    local max_float = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end

            local length = imgui.CalcTextSize(w)
            if render_text == 2 then
                imgui.NewLine()
                imgui.SameLine(max_float / 2 - ( length.x / 2 ))
            elseif render_text == 3 then
                imgui.NewLine()
                imgui.SameLine(max_float - length.x - 5 )
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end


        end
    end

    render_text(text)
end

function style_main()
  imgui.SwitchContext()

  local var_64_0 = imgui.GetStyle()
  local var_64_1 = var_64_0.Colors
  local var_64_2 = imgui.Col
  local var_64_3 = imgui.ImVec4
  local var_64_4 = imgui.ImVec2

  var_64_0.WindowPadding = imgui.ImVec2(8, 8)
  var_64_0.WindowRounding = 6
  var_64_0.ChildWindowRounding = 5
  var_64_0.FramePadding = imgui.ImVec2(5, 3)
  var_64_0.FrameRounding = 3
  var_64_0.ItemSpacing = imgui.ImVec2(5, 4)
  var_64_0.ItemInnerSpacing = imgui.ImVec2(4, 4)
  var_64_0.IndentSpacing = 21
  var_64_0.ScrollbarSize = 10
  var_64_0.ScrollbarRounding = 13
  var_64_0.GrabMinSize = 8
  var_64_0.GrabRounding = 1
  var_64_0.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
  var_64_0.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

  -- Цвета интерфейса
  var_64_1[var_64_2.Text] = var_64_3(1.00, 1.00, 1.00, 1) -- Белый текст
  var_64_1[var_64_2.TextDisabled] = var_64_3(0.6, 0.6, 0.6, 1) -- Светло-серый для неактивного текста
  var_64_1[var_64_2.WindowBg] = var_64_3(0.10, 0.10, 0.10, 1) -- Темный фон окна
  var_64_1[var_64_2.ChildWindowBg] = var_64_3(0.15, 0.15, 0.15, 1) -- Фон дочернего окна
  var_64_1[var_64_2.PopupBg] = var_64_3(0.20, 0.20, 0.20, 1) -- Фон всплывающего окна
  var_64_1[var_64_2.Border] = var_64_3(0.25, 0.25, 0.25, 1) -- Цвет границы
  var_64_1[var_64_2.BorderShadow] = var_64_3(0, 0, 0, 0) -- Тень границы (прозрачная)
  
  -- Цвета рамок и фона элементов управления
  var_64_1[var_64_2.FrameBg] = var_64_3(0.18, 0.18, 0.18, 1) -- Фон рамки
  var_64_1[var_64_2.FrameBgHovered] = var_64_3(0.25, 0.25, 0.25, 1) -- Фон рамки при наведении
  var_64_1[var_64_2.FrameBgActive] = var_64_3(0.30, 0.30, 0.30, 1) -- Фон активной рамки

  -- Цвета кнопок
  var_64_1[var_64_2.Button] = var_64_3(0.25, 0.55, 0.75, 1) -- Основной цвет кнопок (синий)
  var_64_1[var_64_2.ButtonHovered] = var_64_3(0.35, 0.65, 0.85, 1) -- Цвет кнопки при наведении
  var_64_1[var_64_2.ButtonActive] = var_64_3(0.15, 0.45, 0.65, 1) -- Цвет кнопки при активации

   -- Заголовки и другие элементы управления
   var_64_1[var_64_2.Header] = var_64_3(0.30, 0.30, 0.30, 1) 
   var_64_1[var_64_2.HeaderHovered] = var_64_3(0.45, 0.45, 0.45, 1)
   var_64_1[var_64_2.HeaderActive] = var_64_3(0.60, 0.60, 0.60, 1)

   -- Цвета для скроллбаров и других элементов управления
   var_64_1[var_64_2.ScrollbarBg] = var_64_3(0.15, 0.15, 0.15, 1)
   var_64_1[var_64_2.ScrollbarGrab] = var_64_3(0.35, 0.35, 0.35, 1)
   var_64_1[var_64_2.ScrollbarGrabHovered] = var_64_3(0.45, 0.45, 0.45, 1)
   var_64_1[var_64_2.ScrollbarGrabActive] = var_64_3(0.55, 0.55, 0.55, 1)

   -- Другие элементы управления
   var_64_1[var_64_2.CheckMark] = var_64_3(0.75, 1.00, 0.75, 1) -- Зеленая галочка
   var_64_1[var_64_2.SliderGrab] = var_64_3(0.75, 1.00, 0.75, 1) -- Зеленый ползунок
   var_64_1[var_64_2.SliderGrabActive] = var_64_3(1, .28,.28 ,1) -- Цвет активного ползунка

   -- Графики и диаграммы
   var_64_1[var_64_2.PlotLines] =var_64_3(.61,.61,.61 ,1)
   var_64_1[var_64_2.PlotLinesHovered]=var_64_3(1,.43,.35 ,1)
   var_64_1[var_64_2.PlotHistogram]=var_64_3(1,.21,.21 ,1)
   var_64_1[var_64_2.PlotHistogramHovered]=var_64_3(1,.18,.18 ,1)

   -- Выделенный текст и модальные окна
   var_64_1[var_64_2.TextSelectedBg]=var_64_3( .75,.32,.32 , .5)
   var_64_1[var_64_2.ModalWindowDarkening]=var_64_3(.26,.26,.26 ,.6)
end

style_main()
