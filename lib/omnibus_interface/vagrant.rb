module OmnibusInterface
  class Vagrant
    def initialize
      @running_as_host = detect_host
    end

    def host?
      @running_as_host
    end

    def running?(target, &block)
      target_in_state?(target, 'running', &block)
    end

    attr_lazy_reader :states do
      parse_status!.freeze
    end

    def status(target)
      host_only!

      states[target]
    end

    def target?(target)
      host_only!

      states.key? target
    end

    def target_in_state?(target, desired_state)
      host_only!

      desired_state = desired_state.to_s

      target_state = status target

      ( target_state == desired_state ).tap do |matches|
        yield target_state if block_given? && !matches
      end
    end

    def target_in_state!(target, desired_state)
      host_only!

      target_in_state? target, desired_state do |other_state|
        raise "Target `#{target}` is not '#{desired_state}', currently: #{other_state}"
      end
    end

    def target_is_running!(target)
      target_in_state! target, 'running'
    end

    def virtualized?
      !host?
    end

    # @param [String] target
    # @return [String]
    def build_ssh_script_command(target:, &block)
      script = build_ssh_script &block

      %[vagrant ssh -c #{Shellwords.shellescape(script)} #{target}]
    end

    # @param [<String>] lines
    # @return [String]
    def build_ssh_script(*lines)
      lines.flatten!

      yield lines if block_given?

      raise "Must have at least one line" if lines.blank?

      lines.join(' && ')
    end

    private

    def detect_host
      return false if File.directory? '/vagrant'

      return true if File.which('vagrant').present?

      raise "Could not detect if we are running in a vagrant host or on vagrant"
    end

    def host_only!
      raise "This method only works when running on a vagrant host" unless host?
    end

    def parse_status!
      return {} unless host?

      lines = parse_response %x[vagrant status --machine-readable]

      lines.select(&:target_state?).each_with_object({}.with_indifferent_access) do |line, states|
        states[line.target] = line.data
      end
    end

    def parse_response(response)
      lines = response.split(/\r?\n/)

      lines.map do |raw_line|
        ResponseLine.new *raw_line.split(?,)
      end
    end

    class ResponseLine < Struct.new(:time, :target, :type, :data, :rest)
      def state?
        type == 'state'
      end

      def target?
        target.present?
      end

      def target_state?
        target? && state?
      end
    end
  end
end
