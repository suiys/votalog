FactoryBot.define do
  factory :log do
    start_time { Time.zone.today }
    association :user
    association :plant
  end

  factory :log_with_png_image, class: "Log" do
    start_time { Time.zone.today }
    association :user
    association :plant

    after(:build) do |log|
      log.image.attach(
        io: File.open("spec/fixtures/sample_image.png"),
        filename: "sample_image.png",
        content_type: "image/png"
      )
    end
  end

  factory :log_with_jpg_image, class: "Log" do
    start_time { Time.zone.today }
    association :user
    association :plant

    after(:build) do |log|
      log.image.attach(
        io: File.open("spec/fixtures/sample_image.jpg"),
        filename: "sample_image.jpg",
        content_type: "image/jpg"
      )
    end
  end

  factory :log_with_gif_image, class: "Log" do
    start_time { Time.zone.today }
    association :user
    association :plant

    after(:build) do |log|
      log.image.attach(
        io: File.open("spec/fixtures/sample_image.gif"),
        filename: "sample_image.gif",
        content_type: "image/gif"
      )
    end
  end

  factory :log_with_text, class: "Log" do
    start_time { Time.zone.today }
    association :user
    association :plant

    after(:build) do |log|
      log.image.attach(
        io: File.open("spec/fixtures/sample_image.txt"),
        filename: "sample_image.txt",
        content_type: "text/txt"
      )
    end
  end
end
