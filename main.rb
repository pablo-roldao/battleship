require 'gosu'
require_relative 'lib/ui/theme'
require_relative 'lib/screens/base_screen'
require_relative 'lib/screens/menu_screen'
require_relative 'lib/screens/game_screen'
require_relative 'lib/screens/ranking_screen'
require_relative 'lib/screens/options_screen'
require_relative 'lib/screens/campaign_screen'
require_relative 'lib/screens/achievements_screen'
require_relative 'lib/engine/achievement_manager'
require_relative 'lib/ui/achievement_notification'

class GameWindow < Gosu::Window
  def initialize
    super 800, 600
    self.caption = "Battleship"
    @achievement_manager = AchievementManager.new
    show_screen(:menu)
  end

  def show_screen(screen_symbol)
    case screen_symbol
    when :menu         then @current_screen = MenuScreen.new(self)
    when :campaign     then @current_screen = CampaignScreen.new(self)
    when :dynamic      then @current_screen = GameScreen.new(self)
    when :ranking      then @current_screen = RankingScreen.new(self)
    when :options      then @current_screen = OptionsScreen.new(self)
    when :achievements then @current_screen = AchievementsScreen.new(self, @achievement_manager)
    else
      @current_screen = MenuScreen.new(self)
    end
  end

  def needs_cursor?
    true
  end

  def update
    @current_screen.update if @current_screen.respond_to?(:update)
  end

  def draw
    draw_rect(0, 0, width, height, Theme::COLOR_BG)
    @current_screen.draw
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      if @current_screen.is_a?(MenuScreen)
        close
      else
        show_screen(:menu)
      end
    else
      @current_screen.button_down(id)
    end
  end
end

GameWindow.new.show