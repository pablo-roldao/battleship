require_relative 'base_screen'

# Tela de Login e Cadastro.
# O jogador pode criar uma conta nova ou entrar com uma existente.
# Após autenticação bem-sucedida chama window.on_login(user).
class LoginScreen < BaseScreen
  # Estados internos da tela
  MODE_LOGIN    = :login
  MODE_REGISTER = :register

  COLOR_INPUT_BG      = Gosu::Color.new(0xff_1e293b)
  COLOR_INPUT_BORDER  = Gosu::Color.new(0xff_334155)
  COLOR_INPUT_ACTIVE  = Gosu::Color.new(0xff_d97706)
  COLOR_ERROR         = Gosu::Color.new(0xff_ef4444)
  COLOR_SUCCESS       = Gosu::Color.new(0xff_22c55e)
  COLOR_LABEL         = Gosu::Color.new(0xff_94a3b8)

  INPUT_W = 340
  INPUT_H = 44

  def initialize(window)
    super(window)
    @mode           = MODE_LOGIN
    @username       = ''
    @password       = ''
    @active_field   = :username
    @message        = ''
    @message_color  = COLOR_ERROR
    @label_font     = Gosu::Font.new(16)
    @title_font     = Gosu::Font.new(50, bold: true)
    @welcome_font   = Gosu::Font.new(18, bold: true)
  end

  #  Draw

  def draw
    draw_background
    title = @mode == MODE_LOGIN ? 'LOGIN' : 'CRIAR CONTA'
    draw_header(title)

    center_x = @window.dw / 2
    base_y = 120

    welcome = "Bem-vindo, marinheiro! Pronto para uma nova aventura?"
    @welcome_font.draw_text(
      welcome,
      center_x - @welcome_font.text_width(welcome) / 2,
      120, 2, 1.0, 1.0, COLOR_LABEL
    )

    # Campo usuário
    user_y = base_y + 40
    draw_label("USUÁRIO", center_x - INPUT_W / 2, user_y)
    draw_input_box(@username, center_x - INPUT_W / 2, user_y + 20, @active_field == :username)

    # Campo senha
    pass_y = user_y + 84
    draw_label("SENHA", center_x - INPUT_W / 2, pass_y)
    draw_input_box('*' * @password.length, center_x - INPUT_W / 2, pass_y + 20, @active_field == :password)

    # Botão principal
    btn_label = @mode == MODE_LOGIN ? 'ENTRAR' : 'CADASTRAR'

    # Botão principal
    btn_label = @mode == MODE_LOGIN ? 'ENTRAR' : 'CADASTRAR'

    btn_x = center_x - 140
    btn_y = 335
    btn_w = 280
    btn_h = 50

    draw_btn(btn_label, btn_x, btn_y, btn_w, btn_h)

    # Desenha um contorno de foco se o botão for o campo ativo
    if @active_field == :button
      t = 3 # Espessura da borda
      @window.draw_rect(btn_x - t, btn_y - t, btn_w + t * 2, t, COLOR_INPUT_ACTIVE)
      @window.draw_rect(btn_x - t, btn_y + btn_h, btn_w + t * 2, t, COLOR_INPUT_ACTIVE)
      @window.draw_rect(btn_x - t, btn_y - t, t, btn_h + t * 2, COLOR_INPUT_ACTIVE)
      @window.draw_rect(btn_x + btn_w, btn_y - t, t, btn_h + t * 2, COLOR_INPUT_ACTIVE)
    end

    # Link de alternância
    toggle_text = @mode == MODE_LOGIN ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entrar'
    @label_font.draw_text(
      toggle_text,
      center_x - @label_font.text_width(toggle_text) / 2,
      400, 2, 1.0, 1.0, COLOR_LABEL
    )

    # Mensagem de feedback
    unless @message.empty?
      @label_font.draw_text(
        @message,
        center_x - @label_font.text_width(@message) / 2,
        440, 2, 1.0, 1.0, @message_color
      )
    end
  end

  # Input

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      handle_click
    when Gosu::KB_TAB
      @active_field = case @active_field
                      when :username then :password
                      when :password then :button
                      when :button   then :username
                      else :username
                      end
    when Gosu::KB_RETURN, Gosu::KB_ENTER
      submit
    when Gosu::KB_BACKSPACE
      if @active_field == :username
        @username.chop! unless @username.empty?
      elsif @active_field == :password
        @password.chop! unless @password.empty?
      end
    end
  end

  def update
    # Captura digitação via Gosu::TextInput
    # usamos button_down com char.
  end

  # Chamado pelo GameWindow para repassar caracteres digitados
  def receive_char(char)
    return unless char =~ /\A[[:print:]]\z/

    if @active_field == :username
      @username << char if @username.length < 24
    elsif @active_field == :password
      @password << char if @password.length < 32
    end
  end

  private

  # Helpers de desenho

  def draw_label(text, x, y)
    @label_font.draw_text(text, x, y, 2, 1.0, 1.0, COLOR_LABEL)
  end

  def draw_input_box(content, x, y, active)
    border_color = active ? COLOR_INPUT_ACTIVE : COLOR_INPUT_BORDER
    @window.draw_rect(x, y, INPUT_W, INPUT_H, COLOR_INPUT_BG)
    # bordas
    t = 2
    @window.draw_rect(x,             y,             INPUT_W, t,      border_color)
    @window.draw_rect(x,             y + INPUT_H-t, INPUT_W, t,      border_color)
    @window.draw_rect(x,             y,             t,       INPUT_H, border_color)
    @window.draw_rect(x + INPUT_W-t, y,             t,       INPUT_H, border_color)

    show_cursor = active && (Gosu.milliseconds / 500).even?
    cursor = show_cursor ? '|' : ''

    display = content + cursor
    ty = y + (INPUT_H - @btn_font.height) / 2
    @btn_font.draw_text(display, x + 12, ty, 2, 1.0, 1.0, Theme::COLOR_TEXT)
  end

  # Lógica de clique

  def handle_click
    cx = @window.dw / 2
    mx, my = @window.mx, @window.my

    base_y = 120
    user_y = base_y + 40
    user_input_y = user_y + 20

    pass_y = user_y + 84
    pass_input_y = pass_y + 20

    btn_y = 335
    btn_h = 50

    # Campos de input
    ux = cx - INPUT_W / 2
    @active_field = :username if mx.between?(ux, ux + INPUT_W) && my.between?(user_input_y, user_input_y + INPUT_H)
    @active_field = :password if mx.between?(ux, ux + INPUT_W) && my.between?(pass_input_y, pass_input_y + INPUT_H)

    # Botão principal
    if mx.between?(cx - 140, cx + 140) && my.between?(btn_y, btn_y + btn_h)
      submit
    end

    # Link de alternância
    toggle_text = @mode == MODE_LOGIN ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entrar'
    text_w = @label_font.text_width(toggle_text)

    if mx.between?(cx - text_w / 2, cx + text_w / 2) && my.between?(395, 415)
      toggle_mode
    end
  end

  def toggle_mode
    @mode    = (@mode == MODE_LOGIN) ? MODE_REGISTER : MODE_LOGIN
    @message = ''
    @password = ''
  end

  def submit
    username = @username.strip
    password = @password

    if username.empty? || password.empty?
      set_error('Preencha todos os campos.')
      return
    end

    if @mode == MODE_LOGIN
      user = @window.db.authenticate(username, password)
      if user
        set_success("Bem-vindo, #{user['username']}!")
        @window.on_login(user)
      else
        set_error('Usuário ou senha incorretos.')
      end
    else
      if password.length < 4
        set_error('Senha deve ter ao menos 4 caracteres.')
        return
      end
      user = @window.db.create_user(username, password)
      if user
        set_success("Conta criada! Entrando...")
        @window.on_login(user)
      else
        set_error('Nome de usuário já em uso.')
      end
    end
  end

  def set_error(msg)
    @message       = msg
    @message_color = COLOR_ERROR
  end

  def set_success(msg)
    @message       = msg
    @message_color = COLOR_SUCCESS
  end
end


