require 'vagrant-haipa'

module VagrantPlugins
  module Haipa
    module Actions
      class ShutDown
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::shut_down')
        end

        def call(env)
          # submit shutdown droplet request
          result = @client.post("/odata/MachineSet(#{@machine.id})/Stop")

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_haipa.info.shutting_down')
          @client.wait_for_event(env, result['Id'])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

          @app.call(env)
        end
      end
    end
  end
end

