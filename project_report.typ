
#import "@preview/grape-suite:1.0.0": exercise
#import exercise: project, task, subtask

#show: project.with(
  title: "Progetto Basi di Dati",

  university: [Università degli studi di Salerno],
  //institute: [Institute],
  //seminar: [Seminar],

  //abstract: lorem(100),
  //show-outline: true,

  author: "Rega Maristella, Scarallo Gloria, Squitieri Andrea",

  show-solutions: false,
)

#show math.equation: set text(font: "libertinus serif")

= Raccolta delle specifiche della realtà di interesse
== Descrizione
== Specifiche della realtà di interesse
== Glossario dei termini


= Progettazione concettuale della base di dati
== Schema EER
== Dizionario delle entità
== Dizionario delle relazioni
== Vincoli non esprimibili nello schema


= Definizione delle procedure per la gestione della base di dati

== Tavola dei volumi

#[
  #show table.cell: it => {
    if it.y == 0 {
      set text(white)
      strong(it)
    } else {
      it
    }
  }

  #table(
    fill: (x, y) => if y == 0 { rgb("#a02b93") } else if calc.odd(y) {
      rgb("#f2ceef")
    },
    columns: 4,
    table.header([Tavola dei volumi], [Tipo], [Volume], [Commenti]),
    [Utente], [E], [2.000.000], [],
    [Autore], [SE], [400.000], [],
    [Acquirente], [SE], [800.000], [],
    [Lavoro], [E], [4.000.000], [in media 10 opere/1 autore],
    [In Vendita], [SE], [500.000], [],
    [Privato], [SE], [1.000.000], [],
    [Pubblico], [SE], [2.500.000], [],
    [Offerta], [E], [5.000.000], [in media 10 offerte/1 lavoro in vendita],
    [Commento], [E], [90.000.000], [in media 36 commenti/1 lavoro pubblico],
    [Capitolo], [E], [60.000.000], [in media 15 capitoli/1 lavoro],
    [Lingua], [E], [142], [],
    [Tag], [E], [400.000], [],
    [PUBBLICA], [R], [4.000.000], [],
    [OFFRE], [R], [5.000.000], [],
    [PROPOSTA PER], [R], [5.000.000], [],
    [HA ACQUISTATO], [R], [1.000.000], [],
    [LIKE], [R], [250.000.000], [in media 100 like / 1 lavoro pubblico],
    [SCRIVE], [R], [90.000.000], [in media 45 commenti /1 utente],
    [HA], [R], [90.000.000], [in media 36 commenti/1 lavoro pubblico],
    [RISPONDE A],
    [R],
    [22.500.000],
    [in media 1/4 dei commenti è in risposta ad un altro commento],

    [COMPOSTO DA], [R], [60.000.000], [in media 15 capitoli/1 lavoro],
    [SCRITTO IN], [R], [4.000.000], [in media 28.170 lavori/1 lingue],
    [CLASSIFICATO DA], [R], [80.000.000], [in media 20 tag/1 lavoro],
  )
]

== Tavola delle operazioni

#[
  #show table.cell: it => {
    if it.y == 0 {
      set text(white)
      strong(it)
    } else {
      it
    }
  }

  #table(
    fill: (x, y) => if y == 0 { rgb("#145f82") } else if calc.odd(y) {
      rgb("#c0e4f5")
    },
    columns: 4,
    table.header([N], [Tavola delle operazioni], [Tipo], [Frequenza]),
    [1], [Aggiungere utente], [I], [400/gg],
    [2], [Selezionare dati utente], [I], [500.000/gg],
    [3], [Aggiungere lavoro pubblico], [I], [400/gg],
    [4], [Aggiungere lavoro in vendita], [I], [400/gg],
    [5], [Aggiungere capitolo], [I], [12.000/gg],
    [6], [Modificare capitolo], [I], [100/gg],
    [7], [Aggiungere tag ad un lavoro], [I], [3.000/gg],
    [8], [Aggiungere alias], [I], [1.000/gg],
    [9],
    [ Selezionare dati lavoro compreso il \# capitoli],
    [I],
    [1.000.000/gg],

    [10], [Elencare lavori pubblici], [I], [400.000/gg],
    [11], [Elencare lavori in vendita], [I], [300.000/gg],
    [12], [Elencare lavori in base al \# capitoli], [I], [200.000/gg],
    [13], [Elencare lavori in base alla lingua], [I], [400.000/gg],
    [14],
    [Elencare lavori in base alla data di pubblicazione],
    [I],
    [50.000/gg],

    [15], [Elencare lavori in base ad un tag], [I], [350.000/gg],
    [16],
    [ Elencare lavori pubblici in base al numero di visualizzazioni],
    [I],
    [200.000/gg],

    [17], [Selezionare contenuto capitolo], [I], [3.000.000/gg],
    [18], [Aggiungere commento], [I], [30.000/gg],
    [19], [Aggiungere like], [I], [150.000/gg],
    [20], [Fare offerta], [I], [4.000/gg],
    [21], [Acquistare lavoro (rendere lavoro privato)], [I], [400/gg],
    [22],
    [Selezionare tutti i lavori di autori anglofoni con almeno 10 capitoli],
    [B],
    [2/mm],

    [23],
    [Selezionare tutti i commenti in risposta ad un commento di tutti i lavori in francese],
    [B],
    [2/aa],
  )
]

= Progettazione logica
== Analisi delle ridondanze

Il dato ridondante è l'attributo _\#Capitoli_ dell'entità _Lavoro_,
infatti sarebbe possibile ottenere il numero di capitoli attraverso
il conteggio delle partecipazioni di un determinato Lavoro alla relazione _Lavoro_ *è composto da* _Capitolo_.

Supponendo che l’attributo abbia un peso di 2 byte e considerando che il volume dell’entità _Lavoro_ è pari a 4.000.000, il dato andrebbe ad occupare 8.000.000 byte, ovvero circa 8 MB. Per decidere se mantenere o meno il dato ridondante è necessario calcolare, per le operazioni che lo coinvolgono, la differenza nel numero di accessi con e senza quest’ultimo.

=== Tavola degli accessi

#[
  #show table.cell: it => {
    if it.y == 0 {
      set text(white)
      //strong(it)
      it
    } else {
      it
    }
  }

  #set table(
    fill: (x, y) => if y == 0 { rgb("#e87331") } else if calc.odd(y) {
      rgb("#fbe2d5")
    },
  )

  ==== Operazione 5

  #grid(
    columns: (50%, 50%),
    gutter: 3pt,
    rows: 1,
    grid.cell(
      figure(
        caption: [Calcolo con ridondanza],
        table(
          columns: 4,
          table.header(
            [T. degli accessi],
            [Tipo],
            [Accessi],
            [Tipo accesso],
          ),

          [Capitolo], [E], [1], [S],
          [Composto da], [R], [1], [S],
          [Lavoro], [E], [1], [L],
          [Lavoro], [E], [1], [S],
          table.cell(
            colspan: 4,
            [Totale=[1+(1+1+1)\*2]\*12.000/gg=*84.000/gg*],
          )
        ),
      ),
    ),
    grid.cell(
      figure(
        caption: [Calcolo senza ridondanza],
        table(
          columns: 4,
          table.header(
            [T. degli accessi],
            [Tipo],
            [Accessi],
            [Tipo accesso],
          ),

          [Capitolo], [E], [1], [S],
          [Composto da], [R], [1], [S],
          table.cell(
            colspan: 4,
            [Totale=[(1+1)\* 2]\*12.000/gg=*48.000/gg*],
          )
        ),
      ),
    ),
  )
  ==== Operazione 9
  #grid(
    columns: (50%, 50%),
    gutter: 3pt,
    rows: 1,
    grid.cell(
      figure(
        caption: [Calcolo con ridondanza],
        table(
          columns: 4,
          table.header(
            [T. degli accessi],
            [Tipo],
            [Accessi],
            [Tipo accesso],
          ),

          [Lavoro], [E], [1], [L],
          table.cell(
            colspan: 4,
            [Totale=1\*1.000.000/gg=*1.000.000/gg*],
          )
        ),
      ),
    ),
    grid.cell(
      figure(
        caption: [Calcolo senza ridondanza],
        table(
          columns: 4,
          table.header(
            [T. degli accessi],
            [Tipo],
            [Accessi],
            [Tipo accesso],
          ),

          [Lavoro], [E], [1], [L],
          [Composto da], [R], [15], [L],
          table.cell(
            colspan: 4,
            [Totale=(1+15)\*1.000.000/gg=*16.000.000/gg*],
          )
        ),
      ),
    ),
  )
  ==== Operazione 12
  #grid(
    columns: (50%, 50%),
    gutter: 3pt,
    rows: 1,
    grid.cell(
      figure(
        caption: [Calcolo con ridondanza],
        table(
          columns: 4,
          table.header(
            [T. degli accessi],
            [Tipo],
            [Accessi],
            [Tipo accesso],
          ),

          [Lavoro], [E], [4.000.000], [L],
          table.cell(
            colspan: 4,
            [Totale=4.000.000\*#box[200.000/gg]=#box[*800.000.000.000/gg*]],
          )
        ),
      ),
    ),
    grid.cell(
      figure(
        caption: [Calcolo senza ridondanza],
        table(
          columns: 4,
          table.header(
            [T. degli accessi],
            [Tipo],
            [Accessi],
            [Tipo accesso],
          ),

          [Lavoro], [E], [4.000.000], [L],
          [Composto da], [R], [60.000.000], [L],
          table.cell(
            colspan: 4,
            [Totale=(4.000.000+60.000.000)\*#box[200.000/gg]=#box[*12.800.000.000.000/gg*]],
          )
        ),
      ),
    ),
  )

]

