require_relative 'base_screen'
require_relative '../models/board'
require_relative '../models/player'
require_relative '../models/ai/medium_bot'
require_relative '../engine/achievement_manager'
require_relative '../ui/achievement_notification'

class GameScreen < BaseScreen
  def initialize(window)
    super(window)
    @achievement_manager = AchievementManager.new
    @achievement_manager.reset_session
    @notification = AchievementNotification.new
  end

  def update
    @notification.update
  end

  def draw
    draw_header("BATTLE STATIONS")
    draw_centered_text("In progress...", 180, Theme::COLOR_TEXT, @btn_font)
    @notification.draw(@window.width)
  end

  # Exemplo de como registrar um tiro (chamar quando o jogador atirar):
  # result, ship = player.shoot(x, y)
  # register_shot(result, ship)
  def register_shot(result, ship = nil)
    @achievement_manager.register_shot(result, ship)
    newly = @achievement_manager.newly_unlocked.dup
    @achievement_manager.newly_unlocked.clear
    newly.each { |key| @notification.enqueue(key) }
  end

  # Chamar ao fim da partida quando o jogador ganhar:
  # register_victory(player.fleet)
  def register_victory(player_fleet)
    newly = @achievement_manager.register_victory(player_fleet)
    newly.each { |key| @notification.enqueue(key) }
  end
end