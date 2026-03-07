require_relative '../ui/theme'

class BaseScreen
  attr_reader :window

  def initialize(window)
    @window = window

    @title_font = Gosu::Font.new(50)
    @btn_font   = Gosu::Font.new(22)
    @info_font  = Gosu::Font.new(18)
  end

  def update; end
  def draw; end
  def button_down(id); end


  def draw_header(title)
    draw_centered_text(title, 50, Theme::COLOR_ACCENT, @title_font)

    line_w = 200
    @window.draw_rect((@window.width - line_w)/2, 105, line_w, 2, Theme::COLOR_ACCENT)
  end

  def draw_btn(text, x, y, w, h)
    mouse_x = @window.mouse_x
    mouse_y = @window.mouse_y

    is_hover = mouse_x.between?(x, x + w) && mouse_y.between?(y, y + h)

    bg_color = is_hover ? Theme::COLOR_HOVER : Theme::COLOR_BTN
    border_color = is_hover ? Theme::COLOR_ACCENT : Theme::COLOR_BG

    @window.draw_rect(x, y, w, h, bg_color)

    t = 2
    @window.draw_rect(x, y, w, t, border_color)
    @window.draw_rect(x, y + h - t, w, t, border_color)
    @window.draw_rect(x, y, t, h, border_color)
    @window.draw_rect(x + w - t, y, t, h, border_color)

    text_x = x + (w - @btn_font.text_width(text)) / 2
    text_y = y + (h - @btn_font.height) / 2
    @btn_font.draw_text(text, text_x, text_y, 2, 1.0, 1.0, Theme::COLOR_TEXT)

    return is_hover
  end

  def draw_centered_text(text, y, color, font)
    x = (@window.width - font.text_width(text)) / 2
    font.draw_text(text, x, y, 2, 1.0, 1.0, color)
  end

  def draw_footer_hint
    draw_centered_text("(Pressione ESC para voltar ao Menu)", 560, Gosu::Color.new(0xff_64748b), @info_font)
  end
end
