require 'yaml'

require 'textvid/application'
require 'textvid/database'
require 'textvid/router'

module Textvid
  def self.setup(config_path)
    config = YAML.load(File.read(config_path))
    Application.set(:database, Database.create(config['textvid']['database_dir']))
    Application.set(:router, Router.new(config['textvid']['base_url']))
    Application.set(:site_title, config['textvid']['site_title'])
    Application.set(:base_url, Router.new(config['textvid']['base_url']))
    Application
  end
end
