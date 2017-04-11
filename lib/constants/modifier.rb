module Constants
  module Modifier
    KEYWORD_UNIQUE_ID = 'Keyword Unique ID'.freeze
    LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos'].freeze
    FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos'].freeze
    LINES_PER_FILE = 120000.freeze
    COMMISSION_NUMBER = ['number of commissions'].freeze
    LAST_VALUE_WINS = [
      'Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword',
      'Keyword Type', 'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID',
      'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD'
    ].freeze
    INT_VALUES = [
      'Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks',
      'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks'
    ].freeze
    COMMISSION_TYPES = [
      'Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value',
      'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value',
      'KEYWORD - Commission Value'
    ].freeze
    DEFAULT_CSV_OPTIONS = {
      col_sep: "\t",
      headers: :first_row
    }.freeze
  end
end
