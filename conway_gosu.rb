# Gosu übernimmt die gesamte anzeige und update magie mit SDL2 im C/C++ land, wir müssen nur noch sagen, was wohin soll
require 'gosu'

# Macht man so, sagt die Doku ^^
class MainWindow < Gosu::Window

  # Ein Quadrat hat 20x20 Pixel
  CELL_SIZE = 20
  # Und einen 5 Pixel rand drumrum
  BORDER = 5

  # Initialize wird ausgeführt, wenn in Zeile 192 mit MainWindow.new ein neues MainWindow Objekt erstellt wird
  def initialize(map_width, map_height)
    # Die seed_map methode ist am ende der klasse erklärt
    # Sie gibt ein zweidimensionales Array unserer Zellen zurück
    # Beispiel : seed_map(3,3) gibt =>
    #[
    #  [ false, true, true ],
    #  [ false, true, true ],
    #  [ false, false, true],
    #]    
    @map = seed_map map_width, map_height
    # Die bildschrimgröße in pixeln bekommen wir, wenn wir die Zellengröße mal unserer logischen map_größe multiplizieren und die Border addieren
    # Gefühlt müsste es (CELL_SIZE + Border) * map_width sein, aber Trial and Error hat ergeben, dass dem nicht so ist :P
    screen_width = CELL_SIZE * map_width + BORDER
    screen_height = CELL_SIZE * map_height + BORDER
    # Hier geben wir die errechneten daten an Gosu weiter, damit es auch tatsächlich so ein Fenster Baut
    super screen_width, screen_height, false, 100
    # Und das fenster soll den titel "Conways Game of Life" tragen
    self.caption = "Conways Game of Life"
  end

  # Die update Methode wird jeden 'tick' einmal aufgerufen (60/sekunde GLAUBE ich)
  def update
    # for eitire map wird gleich erklärt
    # es führt auf jedenfall den block für jedes element der logischen map einmal aus ^^
    for_entire_map do |x,y|
      # live ist die tatsächliche implementation von Conways regeln (auch weiter unten)
      live x,y
    end
  end

  # draw wird nach update aufgerufen (also auch 60/sec)
  def draw
    for_entire_map do |x,y|
      # auch weiter unten, sorry, evtl mach ich nachher noch zeillennummern rein, wenn ich mit den kommentaren fertig bin und die feststehen
      draw_rect x,y
    end
  end

  # Alles ab hier ist 'private'
  # private methoden können von ausserhalb der klasse nicht aufgerufen werden
  private

  def for_entire_map(&block)
    # verschachtelte schleifen :D frag jan, damit kennt der sich aus :D
    # @map ist ist die Karte aus Zeile 17-21
    # sie besteht aus @map.size Zeilen, die entsprechend @map[0].size zeilen haben
    # (das @map array enthält @map.size Arrays (die zeilen) die jeweils @map[0].size (die spalten) groß sind)
    @map.size.times do |map_y|
      # in map_y ist also der aktuelle Zeilen-Index
      @map[0].size.times do |map_x|
        # und in map_x der aktuelle Spalten-Index
        # block.call führt den block aus und übergibt unser x und y als parameter
        # (wenn man genau hinschaut, hat der block in Zeile 37 zwei block variablen (|x,y| why hat das so schön rutsche gennant ^^))
        block.call map_x,map_y
      end
    end
  end

  # draw_rect nimmt X/Y Koordinaten auf der logischen Map und malt an der entprechenden stelle im Fenster ein entsprechendes Quadrat
  def draw_rect(map_x,map_y)
    # Wir berechnen den Oberen Linken Punkt des Quadrates, das wir zeichnen wollen
    # (ALLE Grafiksysteme die ich kenne, haben ein Koordinatensystem in dem die Obere Linke Ecke der Punkt 0,0 ist und die untere rechte z.B. 800,600)
    # Für unsere Karte wäre das
    # 0,0 0,1 0,2
    # 1,0 1,1 1,2
    # 2,0 2,1 2,2
    x = map_x * CELL_SIZE + BORDER
    y = map_y * CELL_SIZE + BORDER
    size = CELL_SIZE
    # Zeile 17-21 : unsere map besteht aus true/false werten, sonst nichts
    # frage ? ja : nein
    # schreibweise ist einfach kurz für
    # if frage then
    #   ja
    # else
    #   nein
    # end
    # und 0xffffffff ist einfach weiß und 0 entsprechend schwarz ^^
    # da unten steht also
    # if @map[map_y][map_x] == true then
    #   0xffffffff
    # else
    #   0x00000000
    # end
    color = @map[map_y][map_x] ? 0xffffffff : 0x00000000
    # draw_quad kommt von gosu und nimmt 4 punkte und füllt sie mit einer farbe
    # (oder 4 verschieden und macht dann gradienten *thriller*)
    draw_quad x,y,color,\
              x+size,y,color,\
              x,y+size,color,\
              x+size,y+size,color
  end

  # DAS HIER ist eigentlich conways game of live
  def live(map_x,map_y)
    # count_alive_neighbours wird gleich als nächste methode erklärt ^^
    alive_neighbours = count_alive_neighbours map_x,map_y
    alive = @map[map_y][map_x]
    # Nachdem wir jetzt wissen ob die zelle lebt und wieviele lebende nachbarn sie hat, können wir entscheiden, was mit ihr passiert
    # Sollte sie bereits glücklich vor sich hinleben
    if alive then
      case
      # UND weniger als zwei lebende nachbarn haben
      when alive_neighbours < 2
        # stirbt sie eines jämmerlichen todes
        @map[map_y][map_x] = false

      # Wenn sie allerdings lebt und 2-3 lebende nachbarn hat
      when (2..3).cover?(alive_neighbours)
        # Darf sie weiterleben (das ist auch die einzige bedingung in der sie weiterlebt, harte welt)

      # Und wenn sie Lebt und das mehr als drei ihrer nachbarn auch tuen wird einer davon wegen überbevölkerung kriminell
      when alive_neighbours > 3
        # Und wir haben wieder ein Massaker bei dem unsere arme Zelle leider (diesmal aber von vorne massakriert) als blutendes wrack auf der strecke des Lebens bleibt :D
        @map[map_y][map_x] = false
      end
    else
      # Sollte sie allerdings bereits tot sein UND EXAKT drei lebende nachbarn haben
      if alive_neighbours == 3 then
        # Wird sie wieder zum leben erweckt. HALLELUJAH ! 
        @map[map_y][map_x] = true
        alive = true
      end
    end
    # am ende teilen wir dem aufrufer den aktuellen status der Zelle mit
    alive
  end

  def count_alive_neighbours(map_x,map_y)
    # Das sind die 'Nachbarn' einer Zelle, die zu beobachtende Zelle ist der freie platz in der mitte
    neighbours = [
      [-1, 1],[0, 1],[1, 1],
      [-1, 0],       [1, 0],
      [-1,-1],[0,-1],[1,-1]
    ]

    # Für jedes der kleinen zwei-zahlen arrays da oben führen wir den Block aus
    neighbours.map do |mod_x,mod_y|
      # wir 'addieren' die coordinaten aus dem zwei-zahlen array zu denen der gefragten zelle
      x = map_x + mod_x
      y = map_y + mod_y
      # prüfen, ob sie noch teil der logischen map sind (mach dir selber den logik krampf, das mach ich wenn, dann live ^^)
      if (x >= 0 && y >= 0) && (x < @map[0].size && y < @map.size) then
        # Wenn sie innerhalb der map sind, schauen wir nach, ob die zelle noch lebt
        @map[y][x]
      else
        # Andernfalls werten wir die unendliche leere, die ausserhalb unserer map herrscht einfach mal als tot
        false
      end
    end.count(true) # wenn wir fertig sind, zählen wir einfach wieviele lebendige dabei waren
  end

  # seed_map baut die map und initialisiert sie mit einer zufälligen verteilung von tot und lebendig
  def seed_map(width, height)
    # leeres array, damit wir nachher << benutzen können
    ret = []
    height.times do
      ret << []
      width.times do
        # rand(2) gibt zufällig 1 oder 2 zurück
        ret[-1] << (rand(2) == 1) ? true : false
      end
    end
    # hey guck mal, hier hab ich mal was mit return zurückgegeben, wie das normale menschen tuen :D
    return ret
  end

end

# wir prüfen ob zwei zahlen an das skript übergeben wurden
begin
  Float ARGV[0]
  Float ARGV[1]
rescue
  puts "Script takes to numbers for map width and height as parameters"
  puts "Got : #{ARGV}"
  exit 1
end
# Dann erstellen wir ein neues MainWindow Objekt
window = MainWindow.new Float(ARGV[0]).to_i, Float(ARGV[1]).to_i

# Und starten die Party
window.show
