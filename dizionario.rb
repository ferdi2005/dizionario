## Dizionario Bot per Telegram
## Derived from wikigram-tg project
## Source is distributed under the AGPL v3.0
## https://www.gnu.org/licenses/agpl-3.0.html
##    Copyright (C) 2016  @LucentW - Casa
##    Copyright (C) 2020  Ferdinando Traversa
## Contributions to the code are welcome.

require 'mediawiki_api'
require 'telegram/bot'

## CONFIGURATION START ##
token = 'INSERT_TOKEN_HERE' # Telegram bot API token
api_ep = 'https://it.wiktionary.org/w/api.php'# Mediawiki API endpoint
page_uri = "#{api_ep[0..-10]}wiki/" # Base URL for pages
## CONFIGURATION END ##

mw = MediawikiApi::Client.new api_ep

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts message.text
    unless message.text.nil?
      text = message.text
    else
      text = message.caption
    end
  
    next if text.nil?

    if text.match?(/\/cerca(@dizionariorobot)?\s(\w+)/)
      query = text.match(/\/cerca(@dizionariorobot)?\s(\w+)/)[2]
      puts "Processing query -- #{query}"

        query_search = mw.query(list: "search", srsearch: query + ' hastemplate:"-it-"', srlimit: 5)
        hash_search = []
        query_search.data["search"].each do |result|
          hash_search << result
        end

        results = []
        if query_search.data["searchinfo"]["totalhits"] == 0
          bot.api.send_message(chat_id: message.chat.id, text: "Nessun risultato trovato sul Wikizionario!")
        else
          curres = hash_search.first
          cur_extract = mw.query(prop: "extracts", exchars: 1200, explaintext: "1", exsectionformat: "wiki", exlimit: :max, titles: curres["title"])
          
          hash_extract = cur_extract.data["pages"]
          hash_extract.each do |_id, page|
            norm_title = curres["title"].tr(" ", "_")
            split = page["extract"].split("\n")
            risultati = []

            split.reject! { |r| r == ""}

            split.each do |s|
              if s.match?(/=+([\s\w\/])+=+/)
                if ["Sillabazione", "Pronuncia", "Citazione", "Etimologia / Derivazione", "Etimologia / derivazione", "Etimologia", "Derivazione", "Sinonimi", "Contrari", "Parole derivate", "Termini correlati", "Alterati", "Proverbi e modi di dire", "Traduzione", "Note / Riferimenti", "Altri progetti", "Varianti"].include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize)
                  @stop = true
                elsif !["Italiano", "Transitivo", "Intransitivo"].include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize)
                  risultati.push("<b>#{s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize}:</b>")
                elsif ["Transitivo", "Intransitivo"].include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize)
                  risultati.push("(#{s.match(/=+([\s\w\/\,]+)=+/)[1].strip.downcase})")
                end
              end

              unless @stop
                if !s.match?(/=+[\s\w\/\,]+=+/) && !s.match?(curres["title"])
                  risultati.push("- " + s + ";")
                elsif s.match?(curres["title"])
                  risultati.push('<i>' + s + '</i>')
                end
              end
            end

            risultati.unshift("<b>#{curres["title"]}</b>")
            

            description = risultati.join("\n")
            puts description
            keyboard = Telegram::Bot::Types::InlineKeyboardButton.new(text: "Leggi la voce di dizionario completa su #{curres["title"]}", url: "#{page_uri}#{curres["title"]}")
            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard)
            bot.api.send_message(chat_id: message.chat.id, text: description, parse_mode: "html", reply_markup: markup)
          end
        end
        elsif text.match?(/\/start(@dizionariorobot)?/)
        bot.api.send_message(chat_id: message.chat.id, text: "Ciao, tramite questo bot puoi risalire alla definizione delle parole tratta dal dizionario libero <a href='https://it.wiktionary.org/'>Wikizionario!</a> distribuito sotto la licenza libera <a href='https://creativecommons.org/licenses/by-sa/3.0/deed.it'>CC-BY-SA 3.0</a>. Inseriscilo nella chat che preferisci o usalo qui e usando il comando /cerca e la parola che vuoi cercare. Segnala eventuali errori a @ferdi2005", parse_mode: "html")
      end
  end
end
