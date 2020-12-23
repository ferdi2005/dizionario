## Dizionario Bot per Telegram
## Derived from wikigram-tg project
## Source is distributed under the AGPL v3.0
## https://www.gnu.org/licenses/agpl-3.0.html
##    Copyright (C) 2016  @LucentW - Casa
##    Copyright (C) 2020  Ferdinando Traversa
## Contributions to the code are welcome.

require 'mediawiki_api'
require 'telegram/bot'
require 'json'
require 'byebug'

## CONFIGURATION START ##
token = 'INSERT_BOT_TOKEN_HERE' # Telegram bot API token
api_ep = 'https://it.wiktionary.org/w/api.php'# Mediawiki API endpoint
page_uri = "#{api_ep[0..-10]}wiki/" # Base URL for pages
## CONFIGURATION END ##

mw = MediawikiApi::Client.new api_ep
# bot_id = token.split(':').at(0).to_i

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      puts "Processing inline query -- #{message.query}"

      if !message.query.empty?
        query = message.query
        query_search = mw.query(list: "search", srsearch: query + ' hastemplate:"-it-"', srlimit: 5)
        hash_search = []
        query_search.data["search"].each do |result|
          hash_search << result
        end

        results = []
        if query_search.data["searchinfo"]["totalhits"] == 0
          results << Telegram::Bot::Types::InlineQueryResultArticle.new(
            id: 1,
            title: "Nessuna parola trovata.",
            input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: "Nessun risultato")
          )
        end
        counter = 1

        hash_search.each do |curres|
          cur_extract = mw.query(prop: "extracts", exchars: 1200, explaintext: "1", exsectionformat: "wiki", exlimit: :max, titles: curres["title"])
          
          hash_extract = cur_extract.data["pages"]
          hash_extract.each do |_id, page|
            norm_title = curres["title"].tr(" ", "_")
            split = page["extract"].split("\n")
            risultati = []

            split.reject! { |r| r == ""}

            split.each do |s|
              if s.match?(/=+([\s\w\/])+=+/)
                if ["Sillabazione", "Pronuncia", "Citazione", "Etimologia / Derivazione", "Etimologia / derivazione", "Etimologia", "Derivazione", "Sinonimi", "Contrari", "Parole derivate", "Termini correlati", "Alterati", "Proverbi e modi di dire", "Traduzione", "Note / Riferimenti", "Altri progetti", "Varianti"].include?(s.match(/=+([\s\w\/]+)=+/)[1].strip.capitalize)
                  @stop = true
                elsif !["Italiano", "Transitivo", "Intransitivo"].include?(s.match(/=+([\s\w\/]+)=+/)[1].strip.capitalize)
                  risultati.push("<b>#{s.match(/=+([\s\w\/]+)=+/)[1].strip.capitalize}:</b>")
                elsif ["Transitivo", "Intransitivo"].include?(s.match(/=+([\s\w\/]+)=+/)[1].strip.capitalize)
                  risultati.push("(#{s.match(/=+([\s\w\/]+)=+/)[1].strip.downcase})")
                end
              elsif s.match?(/==([\s\w\/])+==/) && s.match(/==([\s\w\/]+)==/)[1].strip.capitalize != "Italiano"
                @stop = true
              end

              unless @stop
                unless s.match?(/=+[\s\w\/]+=+/) || s.match?(page["title"])
                  risultati.push("- " + s + ";")
                end
              end
            end

            risultati.unshift("<i><b>#{curres["title"]}</b></i>")

            description = risultati.join("\n")

            results << Telegram::Bot::Types::InlineQueryResultArticle.new(
              id: counter,
              title: curres["title"],
              input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: description, parse_mode: "html"),
              description: "#{description.gsub("<i><b>", "").gsub("</i></b>", "")[0..64]}...",
              reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(
                inline_keyboard: [Telegram::Bot::Types::InlineKeyboardButton.new(
                  text: "Leggi tutte le altre informazioni su #{message.query}", url: "#{page_uri}#{norm_title}"
                )]
              )
            )
            counter = counter + 1
          end
        end
        bot.api.answer_inline_query(inline_query_id: message.id, results: results) rescue "Errore nel processare un messaggio"
      end
    end
  end
end
