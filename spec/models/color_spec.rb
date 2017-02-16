require 'rails_helper'
require 'models/shared_examples/examples_for_likable.rb'

RSpec.describe Color, type: :model do

  describe ".convert_to_hex" do

    it "'red basic' returns '#f44336'" do
      expect(Color.convert_to_hex('red basic')).to eq '#f44336'
    end

    it "'cyan basic' returns '#00bcd4'" do
      expect(Color.convert_to_hex('cyan basic')).to eq '#00bcd4'
    end

    it "'light-blue basic' returns '#03a9f4'" do
      expect(Color.convert_to_hex('light-blue basic')).to eq '#03a9f4'
    end

  end

  describe ".font_color_for" do

    it "'red basic' returns 'black-text text-basic'" do
      expect(Color.font_color_for('yellow basic')).to eq 'black-text text-basic'
    end

    it "'indigo basic' returns 'white-text text-basic'" do
      expect(Color.font_color_for('indigo basic')).to eq 'white-text text-basic'
    end

    it "'black basic' returns 'white-text text-basic'" do
      expect(Color.font_color_for('black basic')).to eq 'white-text text-basic'
    end

  end

  describe ".colors" do

    it "has a unique hex code associated with every color name" do
      past_color_values = []
      Color.colors.values.each do |color|
        color.each do |name, color_value|
          expect(past_color_values).not_to include(color_value)
          past_color_values << color_value
        end
      end
    end

    it "has 21 primary colors" do
      expect(Color.colors.size).to eq 21
    end
  end

  describe ".color_options" do
    it "returns a one-dimensional array" do
      Color.color_options.each do |option|
        expect(option).to be_a String
      end
    end

    it "returns 256 options" do
      expect(Color.color_options.size).to eq 256
    end
  end

end
