## Dizionario Bot per Telegram
## Derived from wikigram-tg project
## Source is distributed under the AGPL v3.0
## https://www.gnu.org/licenses/agpl-3.0.html
## Copyright (C) 2016  @LucentW
## Copyright (C) 2020 Ferdinando Traversa

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.

#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
## Contributions to the code are welcome.

require 'mediawiki_api'
require 'telegram/bot'

begin
if !File.exist? "#{__dir__}/.config"
  puts 'Inserisci il token del bot:'
  print '> '
  token = gets.chomp
  puts 'Inserisci il nome della lingua:'
  print '> '
  lang = gets.chomp
  puts 'Inserisci il codice lingua a due caratteri:'
  print '> '
  short_lang = gets.chomp
  puts "Inserisci l'username del bot con la @:"
  print '> '
  botname = gets.chomp
  File.open("#{__dir__}/.config", "w") do |file| 
    file.puts token
    file.puts lang.capitalize
    file.puts short_lang.downcase
    file.puts botname
  end
end
userdata = File.open("#{__dir__}/.config", "r").to_a
token = userdata[0].strip
$lang = userdata[1].strip
$short_lang = userdata[2].strip
$botname = userdata[3].strip
api_ep = 'https://it.wiktionary.org/w/api.php'# Mediawiki API endpoint
page_uri = "#{api_ep[0..-10]}wiki/" # Base URL for pages
$lingue = ["lingua sconosciuta", "afar", "abcaso", "malese ambonese", "accinese", "acioli", "adangme", "adighè", "afrikaans", "afrihili", "arguni", "amara", "ainu", "akan", "anakalangu", "accado", "alabama", "aleuto", "alune", "albanese tosco", "altai meridionale", "amarico", "ambai", "aragonese", "anglosassone", "apache", "mescalero-chiricahua", "arcio", "arabo", "aramaico", "mapudungun", "arapaho", "arabo najdi", "novial", "aruaco", "assamese", "asturiano", "asumboa", "lingua anuta", "lingua australe", "avaro", "avestico", "awadhi", "aymara", "azero", "baschiro", "babatana", "banda", "beluci", "bambara", "balinese", "bavarese", "basa", "batak toba", "bicolano centrale", "bannoni", "bonggi", "bielorusso", "begia", "bemba", "berbero", "bulgaro", "bihari", "bhojpuri", "bima", "biak", "bislama", "bini", "banjar", "blackfoot", "balau", "bengalese", "bantik", "tibetano", "bretone", "braj", "bosniaco", "bobot", "buginese", "bukat", "bwaidoka", "babuza", "buli", "catalano", "caddo", "caroliniano", "caraibico", "ceceno", "cebuano", "chamorro", "chibcha", "ciagataico", "chuukese", "mari", "chinook", "choctaw", "cherokee", "ciuvasce", "cheyenne", "chickasaw", "curdo centrale", "cinese mandarino", "corso", "copto", "cree", "tataro di Crimea", "crow", "ceco", "casciubico", "antico slavo ecclesiastico", "ciuvascio", "gallese", "danese", "dakota", "tedesco", "delaware", "lingua deori", "austriaco", "drehu", "dime", "dinca", "dimli", "dalmatico", "dobu", "dogri", "lusaziano inferiore", "duala", "olandese medio", "divehi", "diula", "bhutanese", "ewe", "efik", "egiziano", "greco", "griko salentino", "elamitico", "embaloh", "emiliano-romagnolo", "inglese", "inglese britannico", "inglese americano", "esperanto", "spagnolo", "spagnolo argentino", "ekspreso", "estone", "edolo", "etrusco", "basco", "evenki", "ewondo", "persiano", "fan", "fanti", "finlandese", "filippino", "ugrofinnica", "figiano", "faroese", "francese", "frisone settentrionale", "francese medio", "francese antico", "friulano", "frisone", "irlandese", "gagauzo", "gayo", "gan", "gaelico scozzese", "gedaged", "geber", "geser-gorom", "gilbertese", "galiziano", "alto tedesco medio", "guaranì", "alto tedesco antico", "gondi", "gorontalo", "gotico", "grebo", "greco antico", "ghari", "svizzero tedesco", "gujarati", "mannese", "gane", "hausa", "lingua hakka", "haida", "hawaiano", "ebraico", "herero", "hindi", "hiligayna", "himachali", "hiri motu", "hanunoo", "hoava", "hopi", "croato", "hunsrik", "lusaziano superiore", "creolo haitiano", "hitu", "ungherese", "hupa", "armeno", "interlingua", "iban", "ibanag", "igbo", "indonesiano", "interlingue", "ijo", "ilocano", "ili", "imroing", "insubre", "ido", "irarutu", "islandese", "inuktitut", "giapponese", "giapponese kana", "giapponese rōmaji", "creolo giamaicano", "lojban", "giudeo-persiano", "giudeo-arabo", "giavanese", "georgiano", " karakalpaka", "lingua cabila", "kachin", "kamba", "karen", "kanuri", "kawi", "khasi", "khotanese", "kikuyu", "kazako", "guguyimidjir", "groenlandese", "cambogiano", "canarese", "coreano", "konkani", "congolese", "kpelle", "kapingamarangi", "careliano", "kru", "kurukh", "kashmiri", "coloniese", "curdo", "kuanyama", "kusaie", "kutenai", "cornico", "kirghiso", "komi", "latino", "giudeo-spagnolo", "lahnda", "lamba", "lussemburghese", "lezgiano", "limburghese", "ligure", "livoniano", "ladino", "lombardo", "lingala", "longobardo", "laotiano", "luri settentrionale", "lituano", "lettone", "mokša", "malgascio", "marshallese", "mari orientale", "maori", "menangkabau", "macedone", "malayalam", "mongolo", "mancese", "moldavo", "mojave", "maratto", "malese", "maltese", "creek", "mirandese", "birmano", "lingue maya", "mundurukú", "naurano", "nahuatl", "cinese Min-Nan", "napoletano", "navaho", "bokmål", "nahuatl classico", "nahuatl della Huasteca centrale", "ndebele (nord)", "basso sassone", "basso sassone (secondo sass)", "basso sassone (ortografia del Münsterland)", "nepalese", "newari", "nahuatl centrale", "olandese", "fiammingo", "nynorsk", "norvegese", "norreno", "navajo", "chichewa", "occitano", "olandese antico", "ojibwa", "oromonico", "oriya", "osseto", "punjabi", "papiamento", "palauano", "tedesco della Pennsylvania", "pali", "proto-indoeuropeo", "pitcairnese", "proto-italico", "polacco", "lingua franca", "pobo", "piemontese", "praghese", "antico prusso", "provenzale antico", "pashto", "portoghese", "portoghese del Brasile", "portoghese del Portogallo", "quechua", "romanica", "rapanui", "rarotongan", "romancio", "kirundi", "romeno", "lingue romanze", "romaní", "russo", "ruandese", "sanscrito", "sacha", "sardo", "siciliano", "scozzese", "sardo sassarese", "sardo gallurese", "lappone settentrionale", "samogitico", "serbocroato", "lappone di Kildin", "singalese", "simple English", "slovacco", "sloveno", "samoano", "lappone di Inari", "shona", "somalo", "sonsorol", "albanese", "serbo", "sardo logudorese", "sranan", "sardo campidanese", "siswati", "sesotho", "sudanese", "sundanese", "sumero", "svedese", "swahili", "tamil", "telugu", "tetun", "tagico", "thailandese", "thailandese traslitterato", "turkmeno", "tagalog", "klingon", "tobiano", "tok pisin", "tupì", "turco", "tsonga", "tswana", "tataro", "tuvalu", "twi", "uiguro", "ucraino", "urdu", "usbeco", "venda", "veneto", "vepso", "vietnamita", "francone del Meno", "volapük", "votico", "võro", "vallone", "waray", "wolof", "xhosa", "pecenego", "yiddish", "yoruba", "maya yucateco", "cantonese", "zhuang", "zelandese", "cinese", "cinese semplificato", "cinese tradizionale", "zulu", "kazako in latino", "italiano"] - [$lang.downcase]
## CONFIGURATION END ##
$mw = MediawikiApi::Client.new api_ep

def search(query)
  query_search = $mw.query(list: "search", srsearch: query + " hastemplate:-#{$short_lang}-|-int-", srlimit: 5)
  hash_search = []
  query_search.data["search"].each do |result|
    hash_search << result
  end

  if query_search.data["searchinfo"]["totalhits"] == 0
    return nil
  else
    return hash_search
  end
end

def process(extract, title)
  risultati = []
  split = extract.split("\n")
  split.reject! { |r| r == ""}
  stop = false
  split.each do |s|
    if s.match?(/=+([\s\w\/\,]+)=+/)
      if ["Sillabazione", "Pronuncia", "Citazione", "Uso / Precisazioni", "Uso / precisazioni", "Etimologia / Derivazione", "Etimologia / derivazione", "Etimologia", "Derivazione", "Sinonimi", "Contrari", "Parole derivate", "Termini correlati", "Alterati", "Proverbi e modi di dire", "Traduzione", "Note / Riferimenti", "Altri progetti", "Varianti"].include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize)
        stop = true
      elsif $lingue.include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.downcase)
        stop = true
      elsif ![$lang, "Lingua unificata", "Transitivo", "Intransitivo"].include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize) && stop != true
        risultati.push("<b>#{s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize}:</b>")
      elsif ["Transitivo", "Intransitivo"].include?(s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize)
        risultati.push("(#{s.match(/=+([\s\w\/\,]+)=+/)[1].strip.downcase})")
      elsif s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize == $lang || s.match(/=+([\s\w\/\,]+)=+/)[1].strip.capitalize == "Lingua unificata"
        stop = false
      end
    end

      unless stop
        if !s.match?(/=+[\s\w\/\,]+=+/) && !s.match?(title)
          risultati.push("- " + s + ";")
        elsif s.match?(/\b#{title}\b/)
          risultati.push('<i>' + s + '</i>')
        end
      end
  end

  risultati.unshift("<b>#{title}</b>")

  return risultati
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
      case message
      when Telegram::Bot::Types::Message
      begin
        unless message.text.nil?
          text = message.text
        else
          text = message.caption
        end
      
        next if text.nil?

        if text.match?(/\/cerca(#{$botname})?\s(\w+)/i)
          query = text.match(/\/cerca(#{$botname})?\s(\w+)/i)[2]
          puts "Processing query -- #{query}"

          search = search(query)
          if search == nil
            bot.api.send_message(chat_id: message.chat.id, text: "Nessun risultato trovato sul Wikizionario!", reply_to_message_id: message.message_id)
          else
              curres = search.first
              cur_extract = $mw.query(prop: "extracts", exchars: 1200, explaintext: "1", exsectionformat: "wiki", exlimit: :max, titles: curres["title"])
              
              hash_extract = cur_extract.data["pages"]
              hash_extract.each do |_id, page|
                norm_title = curres["title"].tr(" ", "_")
                risultati = process(page["extract"], curres["title"])
                description = risultati.join("\n")
                puts description
                keyboard = Telegram::Bot::Types::InlineKeyboardButton.new(text: "Leggi la voce di dizionario completa su #{curres["title"]}", url: "#{page_uri}#{norm_title}")
                markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard)
                bot.api.send_message(chat_id: message.chat.id, text: description, parse_mode: "html", reply_markup: markup, reply_to_message_id: message.message_id)
              end
           end
        elsif text.match?(/\/start(#{$botname})?/i)
          bot.api.send_message(chat_id: message.chat.id, text: "Ciao, tramite questo bot puoi risalire alla definizione delle parole tratta dal dizionario libero di #{$lang} <a href='https://it.wiktionary.org/'>Wikizionario</a>, distribuito sotto la licenza libera <a href='https://creativecommons.org/licenses/by-sa/3.0/deed.it'>CC-BY-SA 3.0</a>. Inseriscilo nella chat che preferisci o usalo qui e usando il comando /cerca e la parola che vuoi cercare. Puoi anche usarlo in modalità inline scrivendo #{$botname} e la parola che vuoi cercare in qualsiasi chat! Segnala eventuali errori a @ferdi2005", parse_mode: "html")
        end
      rescue => e
        bot.api.send_message(chat_id: 82247861, text: "Chat: #{message.chat.username} (#{message.chat.id}) \n Errore di Telegram: #{e}") rescue puts "Errore invio messaggio segnalazione errore: #{e}"
      end
    when Telegram::Bot::Types::InlineQuery
      puts "Processing inline query -- #{message.query}"
      begin
        if !message.query.empty?
          query = message.query
          search = search(query)
          if search == nil
            results << Telegram::Bot::Types::InlineQueryResultArticle.new(
              id: 1,
              title: "Nessuna parola trovata.",
              input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: "Nessun risultato")
            )
          else
            results = []
            c = 0
            search.each do |curres|
              c += 1
              cur_extract = $mw.query(prop: "extracts", exchars: 1200, explaintext: "1", exsectionformat: "wiki", exlimit: :max, titles: curres["title"])
              
              hash_extract = cur_extract.data["pages"]
              hash_extract.each do |_id, page|
                description = process(page["extract"], curres["title"]).join("\n")
                norm_title = curres["title"].tr(" ", "_")
                results << Telegram::Bot::Types::InlineQueryResultArticle.new(
                  id: c,
                  title: curres["title"],
                  input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: description, parse_mode: "html"),
                  description: "#{description.gsub(/(<i>)|(<b>)|(<\/b>)|(<\/i>)/, "")[0..64]}...",
                  reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(
                    inline_keyboard: [Telegram::Bot::Types::InlineKeyboardButton.new(text: "Leggi la voce di dizionario completa su #{curres["title"]}", url: "#{page_uri}#{norm_title}")]
                  )
                )  
              end
            end
            bot.api.answer_inline_query(inline_query_id: message.id, results: results)
          end
        end
       rescue => e
          bot.api.send_message(chat_id: 82247861, text: "Chat: #{message.chat.username} (#{message.chat.id}) \n Errore di Telegram: #{e}") rescue puts "Errore invio messaggio segnalazione errore: #{e}"
        end
      end
    end
  end
rescue => e
  puts e
  retry
end