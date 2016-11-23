$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'textvid/setup'

textvid_app = Textvid.setup('textvid_config.yaml')
run textvid_app
