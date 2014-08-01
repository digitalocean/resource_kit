require 'spec_helper'

RSpec.describe ResourceKit::StatusCodeMapper do
  describe '.code_for' do
    it 'returns the status code for a symbol' do
      expect(described_class.code_for(:ok)).to eq(200)
    end
  end
end