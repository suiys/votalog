FactoryBot.define do
  factory :plant do
    sequence(:name) { |n| "testplant#{n}" }
    association :user
  end

  factory :plant_with_png_image, class: "Plant" do
    name { "testplant_with_png" }
    association :user

    after(:build) do |plant|
      plant.image.attach(
        io: File.open("spec/fixtures/sample_image.png"),
        filename: "sample_image.png",
        content_type: "image/png"
      )
    end
  end

  factory :plant_with_jpg_image, class: "Plant" do
    name { "testplant_with_jpg" }
    association :user

    after(:build) do |plant|
      plant.image.attach(
        io: File.open("spec/fixtures/sample_image.jpg"),
        filename: "sample_image.jpg",
        content_type: "image/jpg"
      )
    end
  end

  factory :plant_with_gif_image, class: "Plant" do
    name { "testplant_with_gif" }
    association :user

    after(:build) do |plant|
      plant.image.attach(
        io: File.open("spec/fixtures/sample_image.gif"),
        filename: "sample_image.gif",
        content_type: "image/gif"
      )
    end
  end

  factory :plant_with_text, class: "Plant" do
    name { "testplant_with_text" }
    association :user

    after(:build) do |plant|
      plant.image.attach(
        io: File.open("spec/fixtures/sample_image.txt"),
        filename: "sample_image.txt",
        content_type: "text/txt"
      )
    end
  end
end
