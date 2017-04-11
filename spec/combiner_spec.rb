require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'combiner'

def read_from_enumerator(enumerator)
	result = []
	loop {
		begin
			result << enumerator.next
		rescue StopIteration
			break
		end
	}

	result
end

RSpec::Matchers.define(:be_empty) {
  match { |enumerator| read_from_enumerator(enumerator).empty? }
}

RSpec::Matchers.define(:return_elements) { |*expected|
	read_elements = nil

	match { |enumerator|
		read_elements = read_from_enumerator(enumerator)

		read_elements == expected
  }

  failure_message { |enumerator|
		"expected that #{enumerator} would return #{expected.inspect}, but it returned #{read_elements.inspect}"
  }
}

describe(Combiner) {
	let(:key_extractor) { Proc.new { |arg| arg} }
	let(:input_enumerators) { [] }
	let(:combiner) { Combiner.new(&key_extractor) }

	def enumerator_for(*array)
		array.to_enum(:each)
  end

	context('#combine') {
		subject {
      combiner.combine(*input_enumerators)
    }
	
		context('when an empty set of enumerators are combined') {
			let(:input_enumerators) { [] }

			it { should be_empty }
    }

		context('when all enumerators are empty') {
			let(:input_enumerators) { [enumerator_for(), enumerator_for()] }

			it { should be_empty }
    }

		context('when all enumerators have one element with the same key') {
			let(:input_enumerators) { [enumerator_for(1), enumerator_for(1)] }

			it { should_not be_empty }

			it('should return an array with the key-identical elements') {
				should return_elements([1,1])
      }
    }

		context('when all enumerators have a sequence of elements with the same key') {
      let(:input_enumerators) { [enumerator_for(1, 2), enumerator_for(1, 2)] }

      it { should_not be_empty }

      it('should return arrays with the key-identical elements') {
        should return_elements([1, 1], [2, 2])
      }
    }

		context('when all enumerators have a sequence of elements with the same key, but one is longer') {
      let(:input_enumerators) {
        [enumerator_for(1, 2), enumerator_for(1, 2, 3)]
      }

      it { should_not be_empty }

      it('should return arrays with the key-identical elements') {
        should return_elements([1, 1], [2, 2], [nil, 3])
      }
    }

		context('when all enumerators have same length but different elements') {
      let(:input_enumerators) { [enumerator_for(2), enumerator_for(1)] }

      it { should_not be_empty }

      it('should return arrays with the key-identical elements in the correct order') {
        should return_elements([nil, 1], [2, nil])
      }
    }

		context('for a complex example using a key extractor') {
      let(:key_extractor) { Proc.new { |number| -number } }
      let(:input_enumerators) {
        [enumerator_for(5, 3, 2, 0), enumerator_for(5, 4, 3, 1), enumerator_for(5, 4)]
      }

      it { should_not be_empty }
      it('should return arrays with the key-identical elements in the correct order') {
        should return_elements(
                 [5, 5, 5], [nil, 4, 4], [3, 3, nil],
                 [2, nil, nil], [nil, 1, nil], [0, nil, nil]
               )
      }
    }
  }
}
