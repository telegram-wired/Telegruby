#!/usr/bin/env ruby
# coding: utf-8
require_relative '../lib/telegram'

# Load configuration
config = Telegram::read_config('config.json')

if !config
  p "Failed to load an API token from the config..."
  exit(1)
end

token = config['token']
botname = config['name']
bot = Telegram::Bot.new(token)

def handle(bot, msg, pattern, cb)
  result = msg.body.match pattern
  if !result.nil?
    Thread.new {
      cb.call(bot, msg, result)
    }
  end
end

# Listener thread
while true
  # Collect messages from last update
  msgs = Telegram::collect_msgs(bot.get_updates)
  # Process each message
  msgs.map { |msg|
    if !msg.older_than? 120 and !msg.body.nil?
      puts msg
      handle bot, msg, /^\/echo\s+(.*)$/i, lambda { |b,m,p|
        bot.send_message(msg.chat_id, p.last.to_s)
      }
      handle bot, msg, /^\/reply\s+(.*)$/i, lambda { |b,m,p|
        bot.forward_message(msg.chat_id, p.last, msg.message_id)
      }
      handle bot, msg, /^\/forward\s+(.*)$/i, lambda { |b,m,p|
        bot.forward_message(msg.chat_id, p[0].to_i, p[1])
      }
      handle bot, msg, /^\/photo\s+(.*)$/i, lambda { |b,m,p|
        bot.send_photo(msg.chat_id, 'AgADBAAD8q4xG_t1NQNr1qCkgB1z0XsJcTAABMviIGhAD2pcVcsAAgI', true)
      }
      handle bot, msg, /^\/document\s+(.*)$/i, lambda { |b,m,p|
        bot.send_sticker(msg.chat_id, 'BQADBAADOwAD5F8pBUmCNsa7w0MtAg', true)
      }
      handle bot, msg, /^\/sticker$/i, lambda { |b,m,p|
        bot.send_photo(msg.chat_id, 'BQADBAADnisAAqSBEQQwpt5aHlqUjQI', true)
      }
      handle bot, msg, /^\/voice$/i, lambda { |b,m,p|
        bot.send_voice(msg.chat_id, 'voice.ogg')
      }
      handle bot, msg, /^\/audio$/i, lambda { |b,m,p|
        bot.send_voice(msg.chat_id, 'BQADAQADOwADzCUmCB0806CJnCuiAg', true)
      }
      handle bot, msg, /^\/location$/i, lambda { |b,m,p|
        bot.send_location(msg.chat_id, 53.37, 83.75)
      }
      handle bot, msg, /^\/action$/i, lambda { |b,m,p|
        res = bot.send_action(msg.chat_id, p.last)
        bot.send_message(msg.chat_id, res)
      }
      handle bot, msg, /^\/version$/i, lambda { |b,m,p|
        bot.send_message(msg.chat_id, "Telegruby · http://github.com/telegram-wired/telegruby")
      }
    end
  }
  # Sleep before asking for updates
  sleep 2
end