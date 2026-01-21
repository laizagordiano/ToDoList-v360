module ListsHelper
  # Calcula progresso da lista
  def list_progress(list)
    total = list.tasks.count
    return 0 if total.zero?
    
    completed = list.tasks.where(done: true).count
    ((completed.to_f / total) * 100).round
  end

  # Cor da barra de progresso baseado no percentual
  def progress_color(percentage)
    case percentage
    when 0..25
      "linear-gradient(90deg, #ef4444 0%, #f87171 100%)"
    when 26..50
      "linear-gradient(90deg, #f59e0b 0%, #fbbf24 100%)"
    when 51..75
      "linear-gradient(90deg, #3b82f6 0%, #60a5fa 100%)"
    when 76..99
      "linear-gradient(90deg, #8b5cf6 0%, #a78bfa 100%)"
    else
      "linear-gradient(90deg, #10b981 0%, #34d399 100%)"
    end
  end

  # Cores disponíveis para listas
  def list_colors
    {
      default: { primary: "#667eea", secondary: "#764ba2", name: "Roxo" },
      blue: { primary: "#3b82f6", secondary: "#2563eb", name: "Azul" },
      green: { primary: "#10b981", secondary: "#059669", name: "Verde" },
      orange: { primary: "#f59e0b", secondary: "#d97706", name: "Laranja" },
      red: { primary: "#ef4444", secondary: "#dc2626", name: "Vermelho" },
      pink: { primary: "#ec4899", secondary: "#db2777", name: "Rosa" },
      teal: { primary: "#14b8a6", secondary: "#0d9488", name: "Turquesa" }
    }
  end

  # Obtém gradiente da lista
  def list_gradient(list)
    color_key = list.color&.to_sym || :default
    colors = list_colors[color_key] || list_colors[:default]
    "linear-gradient(135deg, #{colors[:primary]} 0%, #{colors[:secondary]} 100%)"
  end
end
