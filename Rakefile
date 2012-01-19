#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

RAILS_ROOT = File.expand_path('../spec/dummy_rails_app', __FILE__)
require File.expand_path('../spec/dummy_rails_app/config/application', __FILE__)

Bundler::GemHelper.install_tasks
Mist::Application.load_tasks
