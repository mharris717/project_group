module ProjectGroup
  module RunLog
    def run_log_dir
      File.expand_path("~/.project_group/run_logs")
    end

    def delete_run_log!(proj)
      f = "#{run_log_dir}/#{proj.short_name}.txt"
      `rm #{f}` if FileTest.exist?(f)

      f = "#{run_log_dir}/success.txt"
      puts "Append to #{f}"
      File.append "#{run_log_dir}/success.txt","#{proj.short_name}\n"
    end

    def write_run_log!(proj,message)
      `mkdir -p #{run_log_dir}`
      f = "#{run_log_dir}/#{proj.short_name}.txt"
      File.create f, message
    end

    def clear_run_logs!
      `mkdir -p #{run_log_dir}`

      Dir["#{run_log_dir}/*.txt"].each do |f|
        `rm #{f}`
      end

      File.create "#{run_log_dir}/success.txt",""
    end
  end

  class Reach
    include FromHash
    include RunLog
    attr_accessor :group, :command
    def projects
      group.ordered_singles
    end

    fattr(:results) { {} }

    def run_proj(proj)
      res = proj.eci(command)
      results[proj] = {success: true, time: Time.now, result: res, project: proj}
      delete_run_log! proj
    rescue => exp
      results[proj] = {success: false, time: Time.now, result: exp, project: proj}
      write_run_log! proj, exp.message
    end

    def not_yet_run
      projects.reject { |x| results[x] }
    end

    def failed
      results.values.select { |x| x[:success] == false }.sort_by { |x| x[:time] }.map { |x| x[:project] }
    end

    def succeeded
      results.values.select { |x| x[:success] == true }.sort_by { |x| x[:time] }.map { |x| x[:project] }
    end

    def next_projects
      if not_yet_run.size > 0
        not_yet_run
      else
        failed
      end
    end

    def run_once!
      next_projects.each do |proj|
        puts "Running #{proj.short_name}"
        run_proj(proj)
        puts to_s
      end
    end

    def run!
      clear_run_logs!
      puts to_s

      while next_projects.size > 0
        run_once!
        if next_projects.size > 0
          puts "Enter to Continue: "
          STDIN.gets.tap { |x| exit if x.to_s.strip == 'exit' }
        end
      end
    end
          
    def to_s
      strs = []
      strs << "\n\n\nSTART--------------"

      failed.each do |proj|
        message = results[proj][:result].message
        strs << "#{proj.short_name}: #{message}"
      end

      strs << "Succeeded: " + succeeded.map { |x| x.short_name }.join(",") if succeeded.size > 0
      strs << "Failed: " + failed.map { |x| x.short_name }.join(",") if failed.size > 0
      strs << "Not Run: " + not_yet_run.map { |x| x.short_name }.join(",") if not_yet_run.size > 0

      strs << "END-------------\n\n\n"

      strs.join("\n")
    end
  end

  register_plugin("reachs", level: :group) do |group,ops|
    cmd = ops[:remaining_args].join(" ")
    reach = Reach.new(group: group, command: cmd)
    reach.run!
  end
end

