require_relative 'base_screen'

# Tela do mapa de campanha.
#
# Apresenta as quatro missões em sequência:
#   Missão 1 → EasyBot
#   Missão 2 → MediumBot    (desbloqueada após vencer a Missão 1)
#   Missão 3 → HardBot       (desbloqueada após vencer a Missão 2)
#   Missão 4 → ImpossibleBot (desbloqueada após vencer a Missão 3) — O ataque de Davy Jones
#
# O progresso é mantido em @campaign_stage (1..5) que o GameWindow repassa.
# stage=5 indica que todas as missões foram vencidas.
#
# @author Jurandir Neto
class CampaignScreen < BaseScreen
  # Dificuldades mapeadas por estágio
  STAGE_LABELS = {
    1 => "MISSÃO 1 – Dia de Treinamento  [Fácil]",
    2 => "MISSÃO 2 – O Atlântico         [Médio]",
    3 => "MISSÃO 3 – Chefe Final         [Difícil]",
    4 => "Missão Final - O Ataque de Davy Jones     [Impossível]"
  }.freeze

  STAGE_DIFFICULTIES = {
    1 => :easy,
    2 => :medium,
    3 => :hard,
    4 => :impossible
  }.freeze

  BTN_W = 500
  BTN_H = 50
  START_Y = 180
  GAP = 70
  TOTAL_MISSIONS = 4

  # @param window     [GameWindow]
  # @param stage      [Integer]  estágio atual desbloqueado (1‑4, onde 4 = campanha concluída)
  def initialize(window, stage: 1)
    super(window)
    @stage = [stage, 1].max # sem clamp superior: stage=4 indica campanha concluída

    # Inicia com o cursor focado na missão mais alta já desbloqueada
    max_unlocked_index = [@stage - 1, 3].min
    @selected_index = max_unlocked_index

    @mission_font = Gosu::Font.new(16)
  end

  # Atualiza a lógica da tela frame a frame (Sincroniza hover do mouse)
  def update
    mx, my = @window.mx, @window.my
    start_x = (@window.dw - BTN_W) / 2

    if mx.between?(start_x, start_x + BTN_W)
      index = ((my - START_Y) / GAP).to_i
      relative_y = (my - START_Y) % GAP

      # Só permite focar com o mouse se a missão estiver desbloqueada
      if index.between?(0, TOTAL_MISSIONS - 1) && relative_y <= BTN_H
        @selected_index = index if (index + 1) <= @stage
      end
    end
  end

  # Renderização
  def draw
    draw_header("MAPA DE CAMPANHA")
    draw_back_btn
    draw_centered_text("Selecione sua missão:", 140, Theme::COLOR_TEXT, @btn_font)

    start_x = (@window.dw - BTN_W) / 2

    STAGE_LABELS.each_with_index do |(stage_num, label), idx|
      y        = START_Y + idx * GAP
      unlocked = stage_num <= @stage
      boss     = stage_num == 4

      draw_mission_btn(label, start_x, y, unlocked, idx, boss: boss)
    end

    draw_stage_info
  end

  # Input
  def button_down(id)
    case id
    when Gosu::MS_LEFT
      handle_clicks
    when Gosu::KB_UP
      move_selection(-1)
    when Gosu::KB_DOWN
      move_selection(1)
    when Gosu::KB_RETURN, Gosu::KB_ENTER
      launch_mission(@selected_index + 1)
    when Gosu::KB_ESCAPE
      @window.request_screen(:menu)
    end
  end

  private

  # Move a seleção do teclado apenas entre as missões já desbloqueadas
  def move_selection(direction)
    max_unlocked_index = [@stage - 1, 3].min
    @selected_index = (@selected_index + direction) % (max_unlocked_index + 1)
  end

  # Processa os cliques do mouse nos botões da tela
  def handle_clicks
    if back_btn_hit?(@window.mx, @window.my)
      @window.request_screen(:menu)
      return
    end

    mx, my = @window.mx, @window.my
    start_x = (@window.dw - BTN_W) / 2
    y = START_Y + @selected_index * GAP

    # Lança a missão se o clique foi em cima do botão atualmente focado
    if mx.between?(start_x, start_x + BTN_W) && my.between?(y, y + BTN_H)
      launch_mission(@selected_index + 1)
    end
  end

  # Desenha um botão de missão, bloqueado ou não.
  # boss: true aplica estilo carmesim para a missão do Davy Jones.
  def draw_mission_btn(label, x, y, unlocked, index, boss: false)
    is_focused = (index == @selected_index) && unlocked

    if boss
      bg_color     = unlocked ? (is_focused ? Gosu::Color.new(0xff_7f1d1d) : Gosu::Color.new(0xff_450a0a)) : Gosu::Color.new(0xff_1c0505)
      border_color = is_focused ? Gosu::Color.new(0xff_ef4444) : Gosu::Color.new(0xff_7f1d1d)
      text_color   = unlocked ? Gosu::Color.new(0xff_fca5a5) : Gosu::Color.new(0xff_4b1c1c)
      focus_color  = Gosu::Color.new(0xff_ef4444)
    else
      bg_color     = unlocked ? (is_focused ? Theme::COLOR_HOVER : Theme::COLOR_BTN) : Gosu::Color.new(0xff_2d3748)
      border_color = is_focused ? Theme::COLOR_ACCENT : Theme::COLOR_BG
      text_color   = unlocked ? Theme::COLOR_TEXT : Gosu::Color.new(0xff_64748b)
      focus_color  = Gosu::Color.new(0xff_d97706)
    end

    @window.draw_rect(x, y, BTN_W, BTN_H, bg_color)
    t = 2
    @window.draw_rect(x,             y,             BTN_W, t, border_color)
    @window.draw_rect(x,             y + BTN_H - t, BTN_W, t, border_color)
    @window.draw_rect(x,             y,             t, BTN_H, border_color)
    @window.draw_rect(x + BTN_W - t, y,             t, BTN_H, border_color)

    # Contorno de foco externo
    if is_focused
      ft = 3
      @window.draw_rect(x - ft, y - ft, BTN_W + ft * 2, ft, focus_color)
      @window.draw_rect(x - ft, y + BTN_H, BTN_W + ft * 2, ft, focus_color)
      @window.draw_rect(x - ft, y - ft, ft, BTN_H + ft * 2, focus_color)
      @window.draw_rect(x + BTN_W, y - ft, ft, BTN_H + ft * 2, focus_color)
    end

    display = unlocked ? label : "#{label}  [BLOQUEADA]"
    tx = x + (BTN_W - @mission_font.text_width(display)) / 2
    ty = y + (BTN_H - @mission_font.height) / 2
    @mission_font.draw_text(display, tx, ty, 2, 1.0, 1.0, text_color)
  end

  # Exibe o estágio atual em texto informativo
  def draw_stage_info
    completed = [[@stage - 1, 0].max, 4].min
    total     = 4
    info = "Progresso: #{completed}/#{total} missões concluídas"
    draw_centered_text(info, 468, Theme::COLOR_ACCENT, @info_font)

    if @stage > 4
      draw_centered_text("Campanha completa! Parabéns, Capitão!", 488, Gosu::Color.new(0xff_d97706), @info_font)
    end
  end

  # Navega para o GameScreen com a dificuldade correta
  def launch_mission(stage_num)
    difficulty = STAGE_DIFFICULTIES[stage_num]
    @window.start_campaign_mission(stage_num, difficulty)
  end
end