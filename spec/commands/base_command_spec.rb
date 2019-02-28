require 'rails_helper'

RSpec.describe BaseCommand do
  class ConcreteCommand < BaseCommand
    def initialize(add_error_flag=false)
      add_error if add_error_flag
    end

    def payload
      @result = 'success response'
    end

    def add_error
      errors.add(:standard, 'test error')
    end
  end

  describe 'class method #call' do
    it 'initializes a new instance and calls the payload method' do
      expect(ConcreteCommand.call.result).to eq('success response')
    end
  end

  describe 'instance #call' do
    it 'calls the payload method' do
      @concrete = ConcreteCommand.new

      expect(@concrete.call.result).to eq('success response')
    end
  end

  describe '#success?' do
    it 'should be true if there are no errors' do
      @concrete = ConcreteCommand.new

      expect(@concrete.success?).to be_truthy
    end

    it 'should be false if there are errors' do
      @concrete = ConcreteCommand.new true

      expect(@concrete.success?).to be_falsey
    end
  end

  describe '#errors' do
    it 'should be empty by default' do
      @concrete = ConcreteCommand.new

      expect(@concrete.errors).to be_empty
    end

    it 'should return errors if they exist' do
      @concrete = ConcreteCommand.new true

      expect(@concrete.errors.messages[:standard].first).to eq('test error')
    end
  end
end
