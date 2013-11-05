# task 02

module TaskConstants
  STATUS = { "TODO" => :todo, "CURRENT" => :current, "DONE" => :done }.freeze
  PRIORITY = { "Low" => :low, "Normal" => :normal, "High" => :high }.freeze
  STATUSES = STATUS.values.freeze
  PRIORITIES = PRIORITY.values.freeze
end

class TodoTask
  attr_accessor :status, :description, :priority, :tags

  def initialize(status, description, priority, tags)
    @status = status
    @description = description
    @priority = priority
    @tags = tags
  end

  def ==(other)
    equal = @status == other.status
    equal &= @description == other.description
    equal &= @priority == other.priority
    equal &= @tags == other.tags
  end
end

module TaskParser
  include TaskConstants

  def self.parse_task(task_string)
    attribs = task_string.split('|').map { |attribute| attribute.strip }
    tags = attribs[3].split(',').map { |tag| tag.strip }
    TodoTask.new STATUS[attribs[0]], attribs[1], PRIORITY[attribs[2]], tags
  end
end

class EnumerableList
  include Enumerable

  def each(&block)
    @list.each(&block)
  end

  def filter(criteria)
    EnumerableList.new @list.select { |item| criteria.pass? item }
  end

  def adjoin(other)
    EnumerableList.new(@list.to_a | other.to_a)
  end

  def initialize(enumerator)
    @list = enumerator
  end

  private
  attr_accessor :list
end

class TodoList < EnumerableList
  include TaskParser

  def self.parse(task_list)
    TodoList.new task_list.each_line.map { |line| TaskParser.parse_task line }
  end

  def filter(criteria)
    TodoList.new select { |task| criteria.pass? task }
  end

  def adjoin(other)
    TodoList.new(to_a | other.to_a)
  end

  def tasks_todo
    filter(Criteria.status :todo).to_a.size
  end

  def tasks_in_progress
    filter(Criteria.status :current).to_a.size
  end

  def tasks_completed
    filter(Criteria.status :done).to_a.size
  end

  def completed?
    to_a.map { |task| task.status }.all? { |stat| stat == :done }
  end
end

class Criteria
  attr_reader :criteries
  def initialize(criteria_conjunct)
    @criteries = [criteria_conjunct].flatten
  end

  def pass?(todo_task)
    @criteries.any? { |criteria_conjunct| criteria_conjunct.pass? todo_task }
  end

  def self.status(positive_status)
    Criteria.new CriteriaConjunct.new.add_status positive_status
  end

  def self.priority(positive_priority)
    Criteria.new CriteriaConjunct.new.add_priority positive_priority
  end

  def self.tags(tags_array)
    Criteria.new CriteriaConjunct.new.add_tags tags_array
  end

  def |(other)
    Criteria.new(@criteries + other.criteries)
  end

  def &(other)
    Criteria.new @criteries.product(other.criteries).map { |p| p[0] & p[1] }
  end

  def !
    acc = CriteriaConjunct.new
    acc = @criteries.map { |crit| !crit }.reduce(acc) { |a, c| a = a & c }
    @criteries = [acc]
    self
  end
end

module CriteriaInspector
  def status_unfiltered?
    @status.values.all?
  end

  def priority_unfiltered?
    @priority.values.all?
  end

  def tags_unfiltered?
    @tags.empty?
  end
end

module CriteriaOperations
  include TaskConstants

  #I know the names are bad, but I barely get into 80 symbols as it is
  def simple_conjunction(lhs, rhs)
    @status = lhs.status.merge(rhs.status) { |_, l, r| l & r }
    @priority = lhs.priority.merge(rhs.priority) { |_, l, r| l & r }
    @tags = lhs.tags.merge rhs.tags
    self
  end

  def negate_statuses
    @status.each { |key, value| @status[key] = ! value }
    self
  end

  def negate_priorities
    @priority.each { |key, value| @priority[key] = ! value }
    self
  end

  def negate_tags
    @tags.each { |key, value| @tags[key] = ! value }
    self
  end
end

class CriteriaConjunct
  include TaskConstants
  include CriteriaInspector
  include CriteriaOperations
  attr_accessor :status, :priority, :tags

  def initialize
    @status = Hash[STATUSES.zip Array.new STATUSES.size, true]
    @priority = Hash[PRIORITIES.zip Array.new PRIORITIES.size, true]
    @tags = {}
  end

  def add_status(positive_status)
    @status.each_key { |key| @status[key] = false }
    @status[positive_status] = true
    self
  end

  def add_priority(positive_priority)
    @priority.each_key { |key| @priority[key] = false }
    @priority[positive_priority] = true
    self
  end

  def add_tags(tags_array)
    tags_array.each { |tag| @tags[tag] = true }
    self
  end

  def pass?(task)
    valid = @status[task.status]
    valid &= @priority[task.priority]
    valid &= @tags.all? { |key, value| value == task.tags.include?(key) }
    valid
  end

  def &(other)
    CriteriaConjunct.new.simple_conjunction self, other
  end

  def !
    negate_statuses unless status_unfiltered?
    negate_priorities unless priority_unfiltered?
    negate_tags unless tags_unfiltered?
    self
  end
end