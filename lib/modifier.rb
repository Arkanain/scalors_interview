require File.expand_path('../lib/constants/modifier', File.dirname(__FILE__))

class Modifier
  include Constants::Modifier

  def initialize(sale_amount_factor, cancellation_factor)
    @sale_amount_factor = sale_amount_factor
    @cancellation_factor = cancellation_factor
  end

  def modify(output, input)
    merger = get_input_data(input)
    set_output_data(output, merger)
  end

  def sort(file)
    output = "#{file}.sorted"
    content_as_table = parse(file)
    headers = content_as_table.headers
    index_of_key = headers.index('Clicks')
    content = content_as_table.sort_by { |a| -a[index_of_key].to_i }

    write(content, headers, output)

    output
  end

  private

  def get_input_data(input_data)
    input = sort(input_data)
    input_enumerator = lazy_read(input)

    combiner = Combiner.new { |value| value[KEYWORD_UNIQUE_ID] }
    combiner.combine(input_enumerator)

    Enumerator.new { |yielder|
      while true
        begin
          list_of_rows = combiner.next
          merged = combine_hashes(list_of_rows)

          yielder.yield(combine_values(merged))
        rescue StopIteration
          break
        end
      end
    }
  end

  def set_output_data(output_data, merged_input_data)
    done = false
    file_index = 0
    file_name = output_data.gsub('.txt', '')

    until done
      new_file_name = file_name + "_#{file_index}.txt"

      CSV.open(new_file_name, 'wb', write_options) { |csv|
        headers_written = false
        line_count = 0

        while line_count < LINES_PER_FILE
          begin
            merged = merged_input_data.next

            unless headers_written
              csv << merged.keys
              headers_written = true
              line_count +=1
            end

            csv << merged
            line_count +=1
          rescue StopIteration
            done = true
            break
          end
        end

        file_index += 1
      }
    end
  end

  def combine(merged)
    merged.inject([]) { |result, (_, hash)|
      result << combine_values(hash)
    }
  end

  def combine_values(hash)
    LAST_VALUE_WINS.each { |key|
      hash[key] = hash[key].last
    }

    LAST_REAL_VALUE_WINS.each { |key|
      hash[key] = hash[key].reject { |v| v.to_i.zero? }.last
    }

    INT_VALUES.each { |key|
      hash[key] = "#{hash[key][0]}"
    }

    FLOAT_VALUES.each { |key|
      hash[key] = hash[key][0].from_german_to_f.to_german_s
    }

    COMMISSION_NUMBER.each { |key|
      calculation = @cancellation_factor * hash[key][0].from_german_to_f
      hash[key] = calculation.to_german_s
    }

    COMMISSION_TYPES.each { |key|
      calculation = @cancellation_factor * @sale_amount_factor * hash[key][0].from_german_to_f
      hash[key] = calculation.to_german_s
    }

    hash
  end

  def combine_hashes(list_of_rows)
    keys = []
    result = {}

    list_of_rows.each { |row|
      next unless row

      row.headers.each { |key| keys << key }
    }

    keys.each { |key|
      result[key] = []

      list_of_rows.each { |row|
        result[key] << (row.nil? ? nil : row[key])
      }
    }

    result
  end

  def parse(file)
    CSV.read(file, DEFAULT_CSV_OPTIONS)
  end

  def lazy_read(file)
    Enumerator.new { |yielder|
      CSV.foreach(file, DEFAULT_CSV_OPTIONS) { |row| yielder.yield(row) }
    }
  end

  def write(content, headers, output)
    CSV.open(output, 'wb', write_options) { |csv|
      csv << headers
      content.each { |row| csv << row }
    }
  end

  def write_options
    DEFAULT_CSV_OPTIONS.merge(row_sep: "\r\n")
  end
end
