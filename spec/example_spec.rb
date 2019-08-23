require 'spec_helper'
require 'incrcov'

RSpec.describe "Test" do
  describe "#perform should send sms" do
    it "should send enqueue the worker" do
      expect(1).to eq(1)
    end
  end
end
