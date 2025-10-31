FactoryBot.define do
  factory :service_order do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { :pending }
    priority { :medium }
    customer_name { Faker::Name.name }
    customer_email { Faker::Internet.email }
    customer_phone { Faker::PhoneNumber.phone_number }
    equipment_name { Faker::Appliance.equipment }
    equipment_brand { Faker::Appliance.brand }
    equipment_model { Faker::Alphanumeric.alphanumeric(number: 10) }
    service_value { Faker::Commerce.price(range: 50.0..500.0) }
    parts_value { Faker::Commerce.price(range: 0.0..200.0) }
    due_date { Faker::Date.forward(days: 30) }
    payment_status { :pending_payment }

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
      completed_at { Time.current }
      payment_status { :paid }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :overdue do
      due_date { 5.days.ago }
      status { :pending }
    end

    trait :urgent do
      priority { :urgent }
    end

    trait :with_technician do
      association :technician
    end

    trait :high_value do
      service_value { 1000.0 }
      parts_value { 500.0 }
    end
  end
end
