require_relative 'base_screen'

class RankingScreen < BaseScreen
  COLOR_GOLD    = Gosu::Color.new(0xff_d97706)
  COLOR_SILVER  = Gosu::Color.new(0xff_94a3b8)
  COLOR_BRONZE  = Gosu::Color.new(0xff_b45309)
  COLOR_SUCCESS = Gosu::Color.new(0xff_22c55e)
  COLOR_ERROR   = Gosu::Color.new(0xff_ef4444)

  COL_POS = { rank: 55, name: 100, score: 480, wins: 580, loss: 650 }.freeze

  def initialize(window)
    super(window)
    @scores    = window.db.leaderboard(limit: 8)
    @row_font  = Gosu::Font.new(20)
    @head_font = Gosu::Font.new(16)
  end

  def draw
    draw_header("HALL DA FAMA")
    draw_back_btn
    draw_column_headers
    draw_rows
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      @window.request_screen(:menu) if back_btn_hit?(@window.mx, @window.my)
    when Gosu::KB_ESCAPE
      @window.request_screen(:menu)
    end
  end

  private

  def draw_column_headers
    y = 135
    color = COLOR_SILVER

    @head_font.draw_text("JOGADOR", COL_POS[:name],  y, 2, 1.0, 1.0, color)
    @head_font.draw_text("PONTOS",  COL_POS[:score], y, 2, 1.0, 1.0, color)
    @head_font.draw_text("V",       COL_POS[:wins],  y, 2, 1.0, 1.0, color)
    @head_font.draw_text("D",       COL_POS[:loss],  y, 2, 1.0, 1.0, color)

    @window.draw_rect(50, 158, 700, 1, COLOR_SILVER)
  end

  def draw_rows
    if @scores.empty?
      draw_centered_text("Nenhuma partida registrada ainda.", 280, COLOR_SILVER, @btn_font)
      return
    end

    @scores.each_with_index do |entry, i|
      y = 170 + i * 45

      row_color = case i
                  when 0 then COLOR_GOLD
                  when 1 then COLOR_SILVER
                  when 2 then COLOR_BRONZE
                  else Theme::COLOR_TEXT
                  end

      if i.odd?
        @window.draw_rect(50, y - 4, 700, 38, Gosu::Color.new(0x18_ffffff))
      end

      rank_str = "#{i + 1}."

      @row_font.draw_text(rank_str,                  COL_POS[:rank],  y, 2, 1.0, 1.0, row_color)
      @row_font.draw_text(entry['username'].upcase,  COL_POS[:name],  y, 2, 1.0, 1.0, row_color)
      @row_font.draw_text(entry['total_score'].to_s, COL_POS[:score], y, 2, 1.0, 1.0, row_color)
      @row_font.draw_text(entry['wins'].to_s,        COL_POS[:wins],  y, 2, 1.0, 1.0, COLOR_SUCCESS)
      @row_font.draw_text(entry['losses'].to_s,      COL_POS[:loss],  y, 2, 1.0, 1.0, COLOR_ERROR)
    end
  end
end