module TasksHelper
  # Formata data de forma amigável
  def friendly_due_date(date)
    return nil unless date
    
    today = Date.today
    diff = (date - today).to_i
    
    case diff
    when 0
      "Hoje"
    when 1
      "Amanhã"
    when 2..6
      "Em #{diff} dias"
    when -1
      "Ontem"
    when -6..-2
      "#{diff.abs} dias atrás"
    else
      date.strftime("%d/%m/%Y")
    end
  end

  # Status da tarefa baseado na data
  def task_status(task)
    return :completed if task.done
    return :pending unless task.due_date
    
    today = Date.today
    diff = (task.due_date - today).to_i
    
    case diff
    when ...-1
      :overdue  # Atrasada
    when 0
      :today    # Hoje
    when 1..3
      :soon     # Em breve
    else
      :pending  # Pendente
    end
  end

  # Classe CSS baseada no status
  def task_status_class(task)
    case task_status(task)
    when :completed
      "task-completed"
    when :overdue
      "task-overdue"
    when :today
      "task-today"
    when :soon
      "task-soon"
    else
      "task-pending"
    end
  end

  # Badge de status
  def task_status_badge(task)
    status = task_status(task)
    
    badges = {
      completed: { text: "✓ Concluída", color: "#10b981", bg: "rgba(16, 185, 129, 0.1)" },
      overdue: { text: "⚠️ Atrasada", color: "#ef4444", bg: "rgba(239, 68, 68, 0.1)" },
      today: { text: "⭐ Hoje", color: "#f59e0b", bg: "rgba(245, 158, 11, 0.1)" },
      soon: { text: "🔔 Em breve", color: "#3b82f6", bg: "rgba(59, 130, 246, 0.1)" },
      pending: { text: "📋 Pendente", color: "#6b7280", bg: "rgba(107, 114, 128, 0.1)" }
    }
    
    badge = badges[status]
    "<span style='display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; color: #{badge[:color]}; background: #{badge[:bg]};'>#{badge[:text]}</span>".html_safe
  end
end
