require "open3"
require "pathname"

add_command 'upgrade', 'Run migrations after a package upgrade', 1 do |cmd_name|
  upgrader = UpgradePostgres96To13.new

  if upgrader.should_run?
    warn "Upgrading postgres 9.6 to 13.2"

    sv_command! "stop", "postgresql"

    upgrader.run!

    sv_command! "start", "postgresql"
  end
end

def sv_command!(cmd, name)
  run_sv_command_for_service(cmd, name).tap do |exitstatus|
    fail "could not #{cmd} #{name}: #{exitstatus.inspect}" unless exitstatus == 0
  end
end

class UpgradePostgres96To13
  BASE_DIR = Pathname.new("/opt/manifold")
  DATA_DIR = Pathname.new("/var/opt/manifold/postgresql/data")

  attr_reader :ctl
  attr_reader :data_version

  def initialize
    @data_version = detect_data_version
    @postgres_dir = BASE_DIR.join("embedded", "postgresql")
    @old_version = @postgres_dir.join("9.6.18")
    @new_version = @postgres_dir.join("13.2")

    @cur_data_dir = DATA_DIR.to_s
    @tmp_data_dir = DATA_DIR.join("..", "data.13.2").cleanpath.to_s
    @old_data_dir = DATA_DIR.join("..", "data.9.6").cleanpath.to_s

    @old_bin = @old_version.join("bin")
    @new_bin = @new_version.join("bin")
    @pg_user = "manifold-psql"
  end

  def should_run?
    data_version == "9.6"
  end

  def run!
    fail "Nothing to upgrade" unless should_run?

    run_initdb!
    run_pg_upgrade!

    FileUtils.mv @cur_data_dir, @old_data_dir, verbose: true
    FileUtils.mv @tmp_data_dir, @cur_data_dir, verbose: true
  end

  private

  def detect_data_version
    return unless DATA_DIR.exist?

    pg_version = DATA_DIR.join("PG_VERSION")

    return unless pg_version.exist?

    pg_version.read&.strip
  end

  def exec_cmd!(cmd)
    status = Open3.popen3("sudo", "-u", @pg_user, *Array(cmd), { chdir: DATA_DIR }) do |stdin, stdout, stderr, thread|
      { out: stdout, err: stderr }.each do |key, stream|
        Thread.new do
          until (raw_line = stream.gets).nil? do
            if key == :out
              puts raw_line
            else
              warn raw_line
            end
          end
        end
      end

      thread.join
      thread.value
    end

    fail "Could not run command: #{status.exitstatus}" unless status.exitstatus == 0
  end

  def run_initdb!
    cmd = [
      @new_bin.join("initdb").to_s,
      "--locale=C",
      "-D", @tmp_data_dir.to_s,
      "-E", "UTF8"
    ]

    exec_cmd! cmd
  end

  def run_pg_upgrade!
    pg_upgrade = @new_bin.join("pg_upgrade").to_s

    cmd = [
      pg_upgrade,
      "-b", @old_bin.to_s,
      "-d", @cur_data_dir,
      "-D", @tmp_data_dir,
      "-B", @new_bin.to_s
    ]

    exec_cmd! cmd
  end
end
