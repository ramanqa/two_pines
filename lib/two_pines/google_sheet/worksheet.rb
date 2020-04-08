require 'google_drive'

module TwoPines
module GoogleSheet
class Worksheet

  attr_accessor :sheet, :ws, :data, :headers, :header_row

  def initialize sheet, worksheet, header_row
    @sheet = sheet
    @header_row = header_row.to_i
    @ws = worksheet
    @headers = @ws.rows[@header_row]
    read_data
  end

  def read_data
    @data = Array.new
    @ws.rows
    for row_number in @header_row+1...@ws.rows.count do
      data_row = Hash.new
      headers.count.times do |index|
        data_row[@headers[index]] = @ws.rows[row_number][index] unless @ws.rows[row_number][index] == ""
      end
      if !data_row.empty?
        data_row['__sheet_row_number'] = row_number
      end
      @data.push data_row unless data_row.empty?
    end
  end

  def write_data data
    
  end

  def write_cell row, column, data
    @ws[row+1, column+1] = data
  end

  def paint_cell_red row, column
    @ws.set_background_color row+1, column+1, 1, 1, GoogleDrive::Worksheet::Colors::RED
  end

  def paint_cell_green row, column
    @ws.set_background_color row+1, column+1, 1, 1, GoogleDrive::Worksheet::Colors::GREEN
  end

  def save
    @ws.save
  end

end # class
end # module
end # module
