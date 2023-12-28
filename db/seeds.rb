User.find_or_create_by!(email: "guest@example.com") do |user|
  user.name = "ゲストユーザー"
  user.email = "guest@example.com"
  user.password = SecureRandom.urlsafe_base64
end

plant1 = Plant.find_or_create_by!(name: "ラウリンゼ") do |plant|
  plant.user_id = 1
  plant.name = "ラウリンゼ"
  plant.next_water_day = Date.new(2024, 1, 20)
  plant.next_fertilizer_day = Date.new(2024, 1, 30)
  plant.next_replant_day = Date.new(2024, 4, 30)
end
attach_image(plant1)

Plant.find_or_create_by!(name: "レツーサ") do |plant|
  plant.user_id = 1
  plant.name = "レツーサ"
  plant.next_water_day = Date.new(2024, 1, 25)
  plant.next_fertilizer_day = Date.new(2024, 2, 5)
end

plant2 = Plant.find_or_create_by!(name: "ドドソン") do |plant|
  plant.user_id = 1
  plant.name = "ドドソン"
  plant.next_water_day = Date.new(2024, 1, 15)
end
attach_image(plant2)

plant3 = Plant.find_or_create_by!(name: "十二の巻") do |plant|
  plant.user_id = 1
  plant.name = "十二の巻"
  plant.next_water_day = Date.new(2024, 1, 10)
  plant.next_replant_day = Date.new(2024, 2, 20)
end
attach_image(plant3)

Plant.find_or_create_by!(name: "玉扇") do |plant|
  plant.user_id = 1
  plant.name = "玉扇"
  plant.next_fertilizer_day = Date.new(2024, 1, 20)
  plant.next_replant_day = Date.new(2024, 2, 15)
end

5.times do |n|
  log1 = Log.find_or_create_by!(start_time: Time.zone.parse("2023-12-10 22:00:00"), plant_id: n + 1) do |log|
    log.user_id = 1
    log.plant_id = n + 1
    log.start_time = Time.zone.parse("2023-12-10 22:00:00")
    log.is_watered = true
    log.memo = "テストデータログ本文"
    log.light_start_at = Time.zone.parse("2023-12-10 09:00:00")
    log.light_end_at = Time.zone.parse("2023-12-10 18:00:00")
  end
  attach_image(log1)

  Log.find_or_create_by!(start_time: Time.zone.parse("2023-12-20 17:00:00"), plant_id: n + 1) do |log|
    log.user_id = 1
    log.plant_id = n + 1
    log.start_time = Time.zone.parse("2023-12-20 17:00:00")
    log.is_watered = true
    log.is_fertilized = true
    log.memo = "テストデータログ本文"
  end

  Log.find_or_create_by!(start_time: Time.zone.parse("2023-12-30 20:30:00"), plant_id: n + 1) do |log|
    log.user_id = 1
    log.plant_id = n + 1
    log.start_time = Time.zone.parse("2023-12-30 20:30:00")
    log.is_replanted = true
    log.memo = "テストデータログ本文テストデータログ本文テストデータログ本文テストデータログ本文テストデータログ本文テストデータログ本文"
  end

  log2 = Log.find_or_create_by!(start_time: Time.zone.parse("2024-01-05 21:30:30"), plant_id: n + 1) do |log|
    log.user_id = 1
    log.plant_id = n + 1
    log.start_time = Time.zone.parse("2024-01-05 21:30:30")
    log.is_watered = true
    log.is_fertilized = true
    log.light_start_at = Time.zone.parse("2024-01-05 10:00:00")
    log.light_end_at = Time.zone.parse("2024-01-05 17:00:00")
  end
  attach_image(log2)

  log3 = Log.find_or_create_by!(start_time: Time.zone.parse("2024-01-10 23:45:00"), plant_id: n + 1) do |log|
    log.user_id = 1
    log.plant_id = n + 1
    log.start_time = Time.zone.parse("2024-01-10 23:45:00")
    log.is_watered = true
    log.is_fertilized = true
    log.is_replanted = true
    log.light_start_at = Time.zone.parse("2024-01-10 08:30:00")
    log.light_end_at = Time.zone.parse("2024-01-10 16:20:50")
  end
  attach_image(log3)
end

def attach_image(target_instance)
  target_instance.image.attach(
  io: File.open(Rails.root.join("db/fixtures/sample_image.jpg").to_s),
  filename: "sample_image.jpg"
  )
end
