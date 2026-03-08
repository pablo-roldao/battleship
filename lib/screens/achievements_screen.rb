require_relative 'base_screen'
require_relative '../engine/achievement_manager'

class AchievementsScreen < BaseScreen
  COLOR_UNLOCKED    = Gosu::Color.new(0xff_d97706)
  COLOR_LOCKED      = Gosu::Color.new(0xff_334155)
  COLOR_LOCKED_TEXT = Gosu::Color.new(0xff_64748b)

  CARD_W       = 680
  CARD_H       = 80
  CARD_X       = 60
  START_Y      = 140
  CARD_SPACING = 95

  def initialize(window, achievement_manager)
    super(window)
    @am = achievement_manager
    @medal_font = Gosu::Font.new(30)
    @name_font  = Gosu::Font.new(22)
    @desc_font  = Gosu::Font.new(16)

    @scroll_y   = 0
    @max_scroll = 0
  end

  def update
    total_list_height = AchievementManager::ACHIEVEMENTS.size * CARD_SPACING

    visible_area = 360

    @max_scroll = [total_list_height - visible_area, 0].max

    @scroll_y = @scroll_y.clamp(-@max_scroll, 0)
  end

  def draw
    draw_header("CONQUISTAS")
    draw_back_btn

    @window.clip_to(0, 120, @window.dw, 380) do
      # translate move o eixo Y de desenho baseado no nosso scroll
      Gosu.translate(0, @scroll_y) do
        AchievementManager::ACHIEVEMENTS.each_with_index do |(key, data), i|
          draw_achievement_card(key, data, CARD_X, START_Y + i * CARD_SPACING)
        end
      end
    end

    total    = AchievementManager::ACHIEVEMENTS.size
    unlocked = @am.unlocked_achievements.size
    summary  = "#{unlocked} / #{total} conquistas desbloqueadas"

    draw_centered_text(summary, 530, Theme::COLOR_ACCENT, @info_font)
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      @window.request_screen(:menu) if back_btn_hit?(@window.mx, @window.my)
    when Gosu::KB_ESCAPE
      @window.request_screen(:menu)
    when Gosu::MS_WHEEL_UP, Gosu::KB_UP
      @scroll_y += 40
    when Gosu::MS_WHEEL_DOWN, Gosu::KB_DOWN
      @scroll_y -= 40
    end
  end

  private

  def draw_achievement_card(key, data, x, y)
    unlocked = @am.unlocked?(key)

    border_color = unlocked ? COLOR_UNLOCKED : COLOR_LOCKED
    bg_color     = unlocked ? Gosu::Color.new(0xff_1c2a1a) : Gosu::Color.new(0xff_1e293b)
    text_color   = unlocked ? Theme::COLOR_TEXT : COLOR_LOCKED_TEXT
    name_color   = unlocked ? COLOR_UNLOCKED   : COLOR_LOCKED_TEXT

    @window.draw_rect(x, y, CARD_W, CARD_H, bg_color)

    @window.draw_rect(x, y, 5, CARD_H, border_color)

    icon_text = unlocked ? data[:icon] : '?'
    @medal_font.draw_text(icon_text, x + 18, y + (CARD_H - @medal_font.height) / 2, 3, 1.0, 1.0, name_color)

    name_x = x + 65

    desc_text  = unlocked ? data[:description] : '??? Bloqueada ???'
    badge_w    = unlocked ? @desc_font.text_width('OBTIDA') + 20 : 0
    max_desc_w = CARD_W - 65 - 10 - badge_w
    desc_lines = wrap_text(desc_text, max_desc_w, @desc_font)

    if desc_lines.size > 1
      name_y  = y + 6
      desc_y0 = y + 32
    else
      name_y  = y + 12
      desc_y0 = y + 42
    end

    @name_font.draw_text(data[:name], name_x, name_y, 3, 1.0, 1.0, name_color)

    desc_lines.first(2).each_with_index do |line, li|
      @desc_font.draw_text(line, name_x, desc_y0 + li * 20, 3, 1.0, 1.0, text_color)
    end

    if unlocked
      badge_text = 'OBTIDA'
      badge_x = x + CARD_W - @desc_font.text_width(badge_text) - 15
      badge_y = y + (CARD_H - @desc_font.height) / 2
      @desc_font.draw_text(badge_text, badge_x, badge_y, 3, 1.0, 1.0, COLOR_UNLOCKED)
    end
  end

  def wrap_text(text, max_width, font)
    words = text.split(' ')
    lines = []
    current = ''
    words.each do |word|
      candidate = current.empty? ? word : "#{current} #{word}"
      if font.text_width(candidate) <= max_width
        current = candidate
      else
        lines << current unless current.empty?
        current = word
      end
    end
    lines << current unless current.empty?
    lines
  end
end