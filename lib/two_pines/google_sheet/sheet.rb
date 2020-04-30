require 'google_drive'
require 'two_pines/google_sheet/worksheet'

module TwoPines
module GoogleSheet
class Sheet

  attr_accessor :sheet, :session

  def initialize sheet_id
    @session = GoogleDrive::Session.from_config("credentials.json")
    @sheet = session.spreadsheet_by_key sheet_id
  end

  def worksheet_by_title sheet_title, header_row
    ws = @sheet.worksheet_by_title sheet_title
    TwoPines::GoogleSheet::Worksheet.new @sheet, ws, header_row
  end

  def create_worksheet sheet_title
      @sheet.add_worksheet sheet_title, 5000
      worksheet_by_title sheet_title, 0
  end

end # class
end # module
end # module
