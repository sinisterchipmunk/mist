# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post, :class => Mist::Post do
    title "MyString"
    content "This is content"
  end
end
