require_relative 'base_screen'

class MenuScreen < BaseScreen
  BTN_WIDTH = 260
  BTN_HEIGHT = 44
  BTN_SPACING = 58
  START_Y = 155
  TOTAL_BTNS = 6

  def initialize(window)
    super(window)
    @selected_index = 0

    begin
      path = File.join("assets", "images", "logo.png")
      @logo = Gosu::Image.new(path)
    rescue => e
      puts "Aviso: Não foi possível carregar o logo. Erro: #{e.message}"
      @logo = nil
    end
  end

  def update
    x = (@window.dw - BTN_WIDTH) / 2
    mx, my = @window.mx, @window.my

    if mx.between?(x, x + BTN_WIDTH)
      index = ((my - START_Y) / BTN_SPACING).to_i
      relative_y = (my - START_Y) % BTN_SPACING

      if index.between?(0, TOTAL_BTNS - 1) && relative_y <= BTN_HEIGHT
        @selected_index = index
      end
    end
  end

  def draw
    draw_background

    if @logo
      scale = 0.5
      img_w = @logo.width * scale
      img_h = @logo.height * scale

      x = (@window.dw - img_w) / 2

      overlap = 15
      y = START_Y + overlap - img_h

      @logo.draw(x, y, 1, scale, scale)
    else
      draw_header("BATALHA NAVAL")
    end

    draw_menu_btn("MODO CAMPANHA", 0)
    draw_menu_btn("MODO DINÂMICO", 1)
    draw_menu_btn("PLACAR", 2)
    draw_menu_btn("CONQUISTAS", 3)
    draw_menu_btn("OPÇÕES", 4)
    draw_menu_btn("SAIR", 5)

    draw_centered_text("v1.0 - PLP", 548, Gosu::Color.new(0xff_475569), @info_font)
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      execute_action(@selected_index) if mouse_hovering_button?
    when Gosu::KB_UP
      @selected_index = (@selected_index - 1) % TOTAL_BTNS
    when Gosu::KB_DOWN
      @selected_index = (@selected_index + 1) % TOTAL_BTNS
    when Gosu::KB_RETURN, Gosu::KB_ENTER
      execute_action(@selected_index)
    end
  end

  private

  def draw_menu_btn(text, index)
    x = (@window.dw - BTN_WIDTH) / 2
    y = START_Y + (index * BTN_SPACING)

    draw_btn(text, x, y, BTN_WIDTH, BTN_HEIGHT)

    if index == @selected_index
      t = 3
      color = Gosu::Color.new(0xff_d97706)

      @window.draw_rect(x - t, y - t, BTN_WIDTH + t * 2, t, color)
      @window.draw_rect(x - t, y + BTN_HEIGHT, BTN_WIDTH + t * 2, t, color)
      @window.draw_rect(x - t, y - t, t, BTN_HEIGHT + t * 2, color)
      @window.draw_rect(x + BTN_WIDTH, y - t, t, BTN_HEIGHT + t * 2, color)
    end
  end

  def mouse_hovering_button?
    x = (@window.dw - BTN_WIDTH) / 2
    mx, my = @window.mx, @window.my

    if mx.between?(x, x + BTN_WIDTH)
      index = ((my - START_Y) / BTN_SPACING).to_i
      relative_y = (my - START_Y) % BTN_SPACING
      return index.between?(0, TOTAL_BTNS - 1) && relative_y <= BTN_HEIGHT
    end
    false
  end

  def execute_action(index)
    case index
    when 0 then @window.request_screen(:campaign)
    when 1 then @window.request_screen(:dynamic)
    when 2 then @window.request_screen(:ranking)
    when 3 then @window.request_screen(:achievements)
    when 4 then @window.request_screen(:options)
    when 5 then @window.close
    end
  end
end