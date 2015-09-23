require "tennis/job"

class MyJob
  include Tennis::Job

  attr_reader :uuid

  def initialize(uuid = nil)
    @uuid = uuid
  end

  def run
  end

  def ==(other)
    other.is_a?(self.class) && other.uuid == @uuid
  end

  def job_dump
    @uuid
  end

  def self.job_load(uuid)
    new(uuid)
  end
end
