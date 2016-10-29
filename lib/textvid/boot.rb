require 'textvid/application'
require 'textvid/database'
require 'textvid/router'

module Textvid
  def self.main
    Application.set(:database, Database.create('textvid-db'))
    Application.set(:router, Router.new('http://localhost:4567/'))
    Application.set(:site_title, "Textvid Blog")
    Application.set(:base_url, '/')
    Application.run!
  end
end

Textvid.main
