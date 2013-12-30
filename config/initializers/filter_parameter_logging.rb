# Be sure to restart your server when you modify this file.

#FIXME_AB: configuration files are the best place for this. If need in all envs. application.rb can be used
# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]
