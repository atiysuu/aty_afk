afkTimer = Config.AfkTimer * 10

AfkTime = 0
IsAfk = false
camera = nil

CreateThread(function()
    while true do
        Wait(1000)

        if NetworkIsPlayerActive(PlayerId()) then
            local ped = PlayerPedId()
            local isMoving = IsPedRunning(ped) == true or IsPedWalking(ped) == true or IsPedJumping(ped) == true or IsPedSprinting(ped) == true or IsPedFalling(ped) == true or GetEntitySpeed(ped) > 0.0 and not IsControlPressed(0, 1) and not IsControlPressed(0, 2) and not IsControlPressed(0, 3) and not IsControlPressed(0, 4)

            if isMoving and AfkTime > 0 then
                AfkTime = 0
                IsAfk = false
            elseif not isMoving and not IsAfk then
                AfkTime = AfkTime + 1

                print(AfkTime)


                if afkTimer - AfkTime == 10 then
                    Config.Notify("Afk", "You will be marked as AFK in 10 seconds.", "error", source, 5000)
                end

                if AfkTime >= afkTimer then
                    IsAfk = true
                    StartAFKAnimation()
                end
            end
        end
    end
end)

function StartAFKAnimation()
    -- Bildirim gönder
    Config.Notify("Afk", "You are now marked as AFK.", "error", source, 5000)

    -- Animasyonu başlatan bir thread oluştur
    CreateThread(function()
        -- Ekranı karart
        DoScreenFadeOut(200)
        while not IsScreenFadedOut() do Wait(0) end

        -- Telefon animasyonu oynat
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)
        if inVehicle then
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRIVER", 0, true)
        else
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_MOBILE", 0, true)
        end

        -- Kamera oluştur ve ped'in etrafında döndürme işlemi
        local pedCoords = GetEntityCoords(ped)
        local radius = 8.0 -- Kameranın pedden uzaklığı
        local angle = 0.0 -- Başlangıç açısı

        -- Kamera ayarları
        camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pedCoords.x, pedCoords.y, pedCoords.z + 0.5, 0.0, 0.0, 0.0, 30.0, true, 2)
        SetCamActive(camera, true)
        RenderScriptCams(true, false, 0, true, true)

        -- Kamera döndürme işlemi
        CreateThread(function()
            while true do
                if not camera then break end

                for i = 0, 1.0, 1.0 do
                    DrawRect(0.0, 0.0, 2.0, 0.2, 0, 0, 0, 255)
                    DrawRect(0.0, i, 2.0, 0.2, 0, 0, 0, 255)
                end

                -- Açıyı artır (360 derece tamamlanınca sıfırla)
                angle = angle + 0.05
                if angle >= 360.0 then
                    angle = 0.0
                end

                -- Kameranın yeni pozisyonunu hesapla
                local offsetX = pedCoords.x + radius * math.cos(math.rad(angle))
                local offsetY = pedCoords.y + radius * math.sin(math.rad(angle))
                local offsetZ = pedCoords.z + 1.0 -- Kameranın yüksekliği

                -- Kamera konumunu ve yönünü ayarla
                SetCamCoord(camera, offsetX, offsetY, offsetZ)
                PointCamAtCoord(camera, pedCoords.x, pedCoords.y, pedCoords.z)

                if IsControlPressed(0, 1) or IsControlPressed(0, 2) or IsControlPressed(0, 3) or IsControlPressed(0, 4) then
                    AfkTime = 0
                    IsAfk = false
                    StopAFKAnimation()
                    break
                end

                Wait(0) -- Dönüş hızı ayarı
            end
        end)

        -- Ekranı tekrar aç
        DoScreenFadeIn(200)
        while not IsScreenFadedIn() do Wait(0) end

        -- AFK durumundan çıkmak için bekleme veya iptal mekanizması eklenebilir
    end)
end

function CalculateRoundPos(pos)
    return vector3(math.floor(pos.x * 100) / 100, math.floor(pos.y * 100) / 100, math.floor(pos.z * 100) / 100)
end

function StopAFKAnimation()
    -- Kamerayı durdur ve geri yükle
    if camera then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(camera, false)
        camera = nil
    end

    -- Ped'in animasyonunu durdur
    ClearPedTasks(PlayerPedId())

    -- Bildirim gönder
    Config.Notify("Afk", "You are no longer AFK.", "success", source, 5000)
end
