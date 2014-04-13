require 'mharris_ext'

class CaptureOut
  include FromHash
  attr_accessor :base, :pipe

  def write(str)
    base.write(str)
    pipe.write(str)
  end

  def replace_stdout!
    self.base = $stdout
    $stdout = self
  end

  def replace_stderr!
    self.base = $stderr
    $stderr = self
  end

  class << self
    def make(ops={})
      new(ops)
    end
  end
end

def stuff1
  capture_out = CaptureOut.make
  capture_err = CaptureOut.make

  pid = fork do
    capture_out.replace_stdout!
    capture_err.replace_stderr!

    exec "bundle exec rake spec"
  end

  Process.wait pid

  str = capture_out.read_from_file
  puts "STR:\n#{str}"
end

def stuff2
  r,w = IO.pipe

  capture_out = CaptureOut.make(pipe: w)
  capture_err = CaptureOut.make(pipe: w)

  pid = fork do
    r.close

    capture_out.replace_stdout!
    capture_err.replace_stderr!

    w.puts "Hello from Child to Parent"
    (1..3).each do |i|
      puts "Child #{i}"
    end
    exec "pwd"
  end

  w.close
  Process.wait pid
  puts "Pipe Output: #{r.read}"
end

class Spawn
  include FromHash
  attr_accessor :cmd, :pid
  fattr(:pipes) do
    IO.pipe
  end
  def read_pipe; pipes[0]; end
  def write_pipe; pipes[1]; end

  def start!
    self.pid = Process.spawn(cmd, out: write_pipe, err: write_pipe)
  end
end






