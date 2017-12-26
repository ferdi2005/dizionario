# Procedura di installazione del bot su una VPS
## Ubuntu
### Requisiti minimi
* VPS Ubuntu 14.04+
* 1GB di RAM
* 0,5 vCore

_La procedura di installazione è valida per una VPS vuota, senza Ruby e gems varie. Se si ha già Ruby saltare le operazioni preliminari_
### Operazioni preliminari
#### Sudoers
Se l'utente da cui si sta installando il bot non è già con permessi amministrativi dare da root o equivalente: 

`$ sudo adduser nomeutente sudo`
#### Ruby
Installiamo Ruby (se non già presente) con `$ sudo apt install ruby`. Procediamo ad aggiornare i pacchetti con `$ sudo apt upgrade`
### Installazione delle gems
Una volta compiute le operazioni preliminari, installiamo le gems necessarie al funzionamento del bot.

Partiamo con `$ sudo gem install mediawiki_api` per installare la gemma che consente la compatibilità con mediawiki.

Diamo anche il comando `$ sudo gem install telegram-bot-ruby` che installerà la gemma che consente di sfruttare le api di Telegram.
### Installazione del bot
Una volta preparato il sistema per eseguire il bot, lo cloniamo nella VPS. Se git non è installato (cosa che raramente capita) diamo `$ sudo apt-get install git`, altrimenti procediamo normalmente.

Diamo il comando `$ git clone https://github.com/ferdi2005/dizionario.git`. Poi diamo `$ cd dizionario/` e digitiamo `nano wikipedia.rb` (se non sai usare `nano` vedi [qui](https://wiki.ubuntu-it.org/Ufficio/EditorDiTesto/Nano)).

In nano modifichiamo (spostandoci con le frecce) il token del bot inserendo quello che abbiamo generato su [BotFather](http://t.me/botfather) al posto di _`INSERT_BOT_TOKEN_HERE`_.
### Esecuzione del bot
#### Impostazione dell'inline su BotFather
Su BotFather digitiamo `/setinline` e impostiamo il nostro bot per ricevere comandi inline (seguendo la procedura a schermo)
#### Si parte!
Finalmente possiamo far partire il bot! Diamo `sudo ruby wikipedia.rb`ed il nostro bot incomincerà a processare le query inline dirette alle API della wiki che usiamo.

Sotto il comando (ricordate di mantenere sempre aperta la connessione SSH se volete che il bot funzioni) usciranno tutte le query effettuate (e solo le query, non i dati di chi le fa).

**Attenzione!** Il bot, una volta chiusa la connessione, viene fermato. Se vogliamo continuare a mantenere attivo il bot possiamo usare systemd oppure, scelta consigliata, `screens` o `tmux` semplicemente digitando uno dei due si aprirà un terminale nel quale potremo digitare il comando e quello rimarrà in esecuzione continua. Ci basterà chiudere la sessione SSH.
