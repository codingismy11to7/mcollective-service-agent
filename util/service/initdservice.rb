module MCollective
  module Util
    module Service
      class InitdService<Base

        def stop
          if status == 'stopped'
            msg = "Could not stop '%s' : Service is already stopped" % @service
          else
            call_initd('stop')
          end

          sleep 0.5
          {:status => status, :msg => msg}
        end

        def start
          if status == 'running'
            msg = "Could not start '%s': Service is already running" % @service
          else
            call_initd('start')
          end

          sleep 0.5
          {:status => status, :msg => msg}
        end

        def restart
          stop
          start
          sleep 0.5
          status
        end

        def status
          stat = call_initd('status')
          return 'running' if stat.include? 'is running'
          return 'stopped' if stat.include? 'is stopped'
          return 'stopped' if stat.include? 'is not running'
          raise "Unknown status: #{stat}"
        end

        def call_initd(action)
          directory = @options[:directory] || '/etc/init.d'
          initscript = File::join(directory, @service)
          raise "Cannot find #{initscript} init script" unless File.exists?(initscript)

          result = {:output => ""}
          cmd = Shell.new("#{initscript} #{action}", :stdout => result[:output])
          cmd.runcommand

          return result[:output].chomp
        end

      end
    end
  end
end
