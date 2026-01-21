module ToastHelper
  # Mapeia mensagens do backend (em inglês) para chaves I18n
  # Este helper garante que todas as mensagens de toast apareçam em português
  # independente do texto definido nos controllers (que está em inglês)
  #
  # Fluxo de tradução:
  # 1. Verifica se a mensagem é uma chave I18n válida (ex: "login_success")
  # 2. Mapeia mensagens em inglês conhecidas para chaves I18n
  # 3. Tenta criar uma chave baseada no texto da mensagem
  # 4. Fallback para mensagem genérica em português
  
  FLASH_MESSAGE_MAPPING = {
    # Sessões
    'Login successful.' => 'flashes.login_success',
    'Invalid email or password.' => 'flashes.login_error',
    'Logout successful.' => 'flashes.logout_success',
    
    # Usuários
    'User created successfully. Please log in.' => 'flashes.user_create_success',
    
    # Listas
    'List created successfully.' => 'flashes.list_create_success',
    'List updated successfully.' => 'flashes.list_update_success',
    'List deleted successfully.' => 'flashes.list_delete_success',
    
    # Tarefas
    'Task created successfully' => 'flashes.task_create_success',
    'Task updated successfully' => 'flashes.task_update_success',
    'Task deleted successfully.' => 'flashes.task_delete_success',
    
    # Acesso
    'You must be logged in to access this page.' => 'flashes.access_denied'
  }.freeze

  def translate_flash_message(message, flash_type = :notice)
    return nil if message.blank?
    
    # Se a mensagem é uma chave I18n válida (formato: "palavra.palavra")
    if message.match?(/^[a-z_]+\.[a-z_]+/)
      key = message.start_with?('flashes.') ? message : "flashes.#{message}"
      return t(key) if I18n.exists?(key)
    end
    
    # Mapeia mensagem em inglês para chave I18n
    i18n_key = FLASH_MESSAGE_MAPPING[message]
    return t(i18n_key) if i18n_key && I18n.exists?(i18n_key)
    
    # Fallback: tenta encontrar uma chave similar
    # Remove pontuação e converte para snake_case
    sanitized = message.downcase.gsub(/[^a-z\s]/, '').strip.gsub(/\s+/, '_')
    possible_key = "flashes.#{sanitized}"
    return t(possible_key) if I18n.exists?(possible_key)
    
    # Último fallback: retorna mensagem genérica em português baseada no tipo
    flash_type == :alert ? t('flashes.generic_error') : t('flashes.generic_success')
  end
end
