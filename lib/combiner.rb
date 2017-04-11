# *Input*
#   - two enumerators returning elements sorted by their key
#   - block calculating the key for each element
#   - block combining two elements having the same key or a single element, if there is no partner
#
# *Output*
#   - enumerator for the combined elements

class Combiner
	def initialize(&key_extractor)
		@key_extractor = key_extractor
	end

	def key(value)
		@key_extractor.call(value) if value
	end

	def combine(*enumerators)
		Enumerator.new { |yielder|
			last_values = Array.new(enumerators.size)
			done = enumerators.all?(&:nil?)

      until done
        last_values.each_with_index { |value, index|
          if value.nil? && !enumerators[index].nil?
            begin
              last_values[index] = enumerators[index].next
            rescue StopIteration
              enumerators[index] = nil
            end
          end
        }

        done = enumerators.all?(&:nil?) && last_values.compact.empty?

        unless done
          min_key = last_values.map { |e| key(e) }.min { |a, b|
            case
              when a.nil? && b.nil?
                0
              when a.nil?
                1
              when b.nil?
                -1
              else
                a <=> b
            end
          }

          values = Array.new(last_values.size)

          last_values.each_with_index { |value, index|
            if key(value) == min_key
              values[index] = value
              last_values[index] = nil
            end
          }

          yielder.yield(values)
        end
      end
    }
	end
end
