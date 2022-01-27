module MemoryHelper
  def dashboard_years_ago(memory)
  	ago = "--"
    current_year = date_to_integer(Date.current)
    if cookies[:saved_memories] == "--"
    	return ago if memory.date == "--"
    	memory_date = memory.date.to_date
    else
    	memory_date = memory.created_at.to_date
    end
  	memory_year = date_to_integer(pst_timezone(memory_date))
  	years_ago = current_year - memory_year
  	ago = "#{ years_ago } year(s) ago"
  	return ago
  end

  def index_years_ago(memory)
    current_year = date_to_integer(Date.current)
    memory_date = memory.date.to_date
    memory_year = date_to_integer(pst_timezone(memory_date))

    years_ago = current_year - memory_year
    return "#{ years_ago } year(s) ago"
  end

  def date_to_integer(date)
  	date.strftime("%Y").to_i
  end

  def pst_timezone(date)
  	date.to_date + 8.hours
  end
end