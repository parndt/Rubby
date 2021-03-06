require 'spec_helper'

describe Rubby::Nodes::BinaryOp do
  it { should be_a(Rubby::Nodes::Base) }
  it { should respond_to(:operator) }
  it { should respond_to(:left) }
  it { should respond_to(:right) }
end
