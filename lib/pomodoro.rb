class Pomodoro < ActiveRecord::Base

  named_scope :successful, { :conditions => ['finished_at NOT NULL and (finished_at - started_at) >= ?', 25.minutes.ago] }
  named_scope :incomplete, { :conditions => ['finished_at NOT NULL and (finished_at - started_at) < ?', 25.minutes.ago] }
  named_scope :running, { :conditions => 'finished_at IS NULL' }

  def self.start(args = {})
    create!(:who => serialise_who(args[:who]), :started_at => Time.now)
  end

  def self.existing(who)
    find_by_who(serialise_who(who))
  end

  def display_who
    Pomodoro.deserialise_who(who).map do |p|
      p.gsub /\s?<[^>]+>/, ''
    end
  end
  
  def running?
    !finished?
  end
  
  def after_find
    int = self['interrupts'] || ""
    @interrupts = int.split(',')
  end
  
  def before_save
    @interrupts ||= []
    self[:interrupts] = @interrupts.join(',')
  end

  def interrupts
    @interrupts
  end
  
  def interrupt!
    @interrupts ||= []
    @interrupts << Time.now
    save
  end
  
  def finish!
    self.finished_at = Time.now
    save
  end
  
  def finished?
    !@finished_at.nil?
  end
  
private
  def self.serialise_who(w)
    w.to_a.join(',')
  end
  
  def self.deserialise_who(w)
    w.split(',')
  end
end