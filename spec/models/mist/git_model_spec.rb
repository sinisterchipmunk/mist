require 'spec_helper'
require 'mist/git_model'

describe Mist::GitModel do
  describe "active model lint tests" do
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    def model
      @model ||= Class.new(Mist::GitModel) do
        def self.name
          "TestModel"
        end
      end.new
    end

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end
  end
end
