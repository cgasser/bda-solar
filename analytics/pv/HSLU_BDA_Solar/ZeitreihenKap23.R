# Beispiel aus Grundlegende Statistik mit R.pdf Kap. 23

### 23.1 Datenstrukturen

set.seed(1)
x <- rnorm(120)

# Time Series
white.noise <- ts(x)
white.noise

# Zeitpunkte die Jahre 1964 bis 1973 ansehen, für die jeweils 12 Beobachtungen vorliegen
white.noise <- ts(x, start = c(1964, 1), frequency = 12)
white.noise


# 23.1.1 Aggregation

# Besitzt eine Zeitreihe für frequency einen Wert größer als 1, so können für ganzzahlige Teiler von frequency neue aggregierte Zeitreihen erstellt werden.
# Erzeuge aus der obigen Zeitreihe white.noise eine neue Zeitreihe, deren Werte jeweils aus den Mittelwerten von 6 Monaten bestehen.

white.noise.mean <- aggregate(white.noise, nfrequency = 2, FUN = mean)


# 23.1.2 Indizierung

white.noise[32]
window(white.noise, start = c(1966,8), end = c(1966,8))


# 23.1.3 Rechnen mit Zeitreihen

set.seed(1)
x <- ts(round(rnorm(7),3), start=c(1965,1), frequency=12)
y <- ts(round(rnorm(6),3), start=c(1965,5), frequency=12)
x - y


# 23.1.4 Fehlende Werte

# Fehlende Werte in einer Zeitreihe sind problematisch, da die zugehörige Beobachtung
# nicht einfach entfernt werden kann, ohne damit die Voraussetzung der Äquidistanz der
# Beobachtungen zu verletzen.
# Beispiel. Der Zeitreihe presidents enthält für die Jahre 1945 bis 1974 vierteljährlich
# ermittelte Werte, welche die Zustimmung für den Präsidenten der USA ausdrücken.
# Finde die längste Teilreihe nicht fehlender Werte.
# Mit Hilfe der Funktion na.contiguous() kann aus einer Zeitreihe der längste Abschnitt
# ohne fehlende Werte als neue Zeitreihe erhalten werden.

na.contiguous(presidents)


# 23.1.5 Einlesen von Daten

#x <- scan(file.choose())
x <- c(365, 409, 427, 486, 509, 568, 612, 654, 699, 726, 719, 805, 868, 902, 978, 1080, 1201, 1329, 1285, 1303, 1313, 1434, 1438, 1440, 1551)
x <- ts(x, start = 1954)


# 23.1.6 Multivariate Zeitreihen

# Liegen zu denselben Zeitpunkten die Beobachtungen mehrerer Variablen vor, also mehrere
# Zeitreihen, so können diese zu einer einzelnen multivariaten Zeitreihe mittels der
# Funktionen ts.union() oder ts.intersect() zusammengefasst werden.



### 23.2 Grafische Darstellungen

# Für die grafische Darstellung von Zeitreihen gibt es zwei grundlegende Funktionen:
# plot.ts() und ts.plot().
# Ist x ein Zeitreihen-Objekt, so wird durch Aufruf von plot(x) automatisch die Funktion
# plot.ts() aktiviert. Ist x ein numerischer Vektor, so kann diese Funktion auch direkt
# mittels plot.ts(x) genutzt werden.
# Die Funktion ts.plot() erlaubt das gemeinsame Zeichnen mehrerer Zeitreihen, die unterschiedliche
# Zeitbereiche abdecken können, aber denselben Wert für frequency besitzen.
# Das ist zum Beispiel nützlich, wenn man neben eine Zeitreihe x eine weitere Reihe
# prognostizierter Werte x.dach zeichnen möchte, vgl. auch Abschnitt 24.4. Zudem ist
# es bei Angabe mehrerer Reihen nicht notwendig, den Zeichenbereich der y-Achse selbst
# zu bestimmen, sondern dieser wird so gewählt, dass alle Zeitreihen dargestellt werden
# können.



### 23.3 Glätten

# Die Glättung einer Zeitreihe wird angewendet, um längerfristige Tendenzen leichter einschätzen
# zu können. Zwei klassische Glättungsmethoden sind die Bildung gleitender
# Durchschnitte und die exponentielle Glättung.

# 23.3.1 Gleitender Durchschnitt

# In R kann für eine gegebene Zeitreihe x und einen Wert q ein einfacher gleitender Durchschnitt
# y mit Hilfe der Funktion filter() berechnet werden.

q <- 2
y <- filter(x, filter = rep(1, (2 * q + 1))/(2 * q + 1))

# Will man einen einfachen gleitenden Durchschnitt gerader Ordnung anwenden

y <- filter(x, filter = c(0.5, rep(1, (2 * q - 1)), 0.5)/(2 * q))


# 23.3.2 Exponentielle Glättung

# Ist eine Zeitreihe x1, . . . , xn gegeben und erzeugt man die Reihe y1, . . . , yn mittels
# yt = xt + byt−1, y0 := 0 ,
# für eine Zahl b, so spricht man von einem (einfachen) rekursiven Filter. Betrachtet
# man nun die Reihe xt mit
# x1 = x1, x2 = x1 − bx1, . . . , xn = xn−1 − bxn−1 ,
# und wendet den obigen rekursiven Filter auf  xt an, so ergibt sich die Reihe
# y1 = x1, yt+1 = (1 − b)xt + byt, t= 1, . . . , n − 1 .
# Wählt man b aus dem offenen Intervall (0, 1), so bezeichnet man die so erhaltene Reihe
# auch als exponentielle Glättung der ursprünglichen Reihe. Exponentielle Glättung
# kann in R mittels
# > y <- filter(x.tilde, filter = b, method = "recursive")
# erhalten werden, wenn x.tilde die oben beschriebene Reihe x1, . . . , xn bezeichnet. Mit
# > x.HW <- HoltWinters(x, alpha = (1-b), beta = FALSE, gamma = FALSE)
# > y <- x.HW$fitted[,"xhat"]
# 23.3 Glätten 241
# erhält man ebenfalls diese Reihe. Lässt man das Argument alpha weg, so wird ein Glättungsparameter
# aus den Daten geschätzt, d.h. es ist dann nicht notwendig einen Wert b
# festzulegen.


# 23.3.3 Weitere Glättungsmethoden

# Grundsätzlich können auch andere Glättungsverfahren zur Anwendung kommen. In R stehen
# etwa die Funktionen lowess(), loess(), ksmooth(), supsmu() oder smooth.spline()
# zur Verfügung. Die letztgenannte Funktion kann recht bequem eingesetzt werden, um
# fehlende Werte zu ersetzen.

# Imputation fehlender Werte
# Beispiel. Betrachte die Zeitreihe presidents und ersetze die auftauchenden fehlenden
# Werte durch geeignet prognostizierte Werte.
# Zunächst finden wir die Positionen der fehlenden Werte in der Zeitreihe.
pos.na <- which(is.na(presidents))

# Nun wenden wir die Funktion smooth.spline() an. Dafür benötigen wir Paare numerischer
# x- und y-Werte. Die Werte auf der Zeitachse können wir mittels der Funktion
# time() erzeugen.
x.time <- time(presidents)
x.time

# Nun können wir die Funktion smooth.spline() anwenden, wobei wir explizit die fehlenden
# Werte ausschließen.
x <- x.time[-pos.na]
y <- presidents[-pos.na]
xy.smooth <- smooth.spline(x,y)

# Das Zeichnen mittels
plot(presidents)
lines(xy.smooth, col = "red")

# zeigt, dass nur eine recht schwache Glättung erfolgt, so dass also beobachtete und geglättete
# Reihe recht nahe beieinander sind. Stärkere Glättungen können durch das Setzen
# eines größeren Wertes für das Argument spar erfolgen.

# Aus dem erzeugten Objekt xy.smooth können nun mit Hilfe der Funktion predict()
# die fehlenden Werte zu den entsprechenden Zeitpunkten prognostiziert werden.
pred.times <- x.time[pos.na]
pred.pres <- predict(xy.smooth, pred.times)$y
# Schließlich kann eine neue Reihe erzeugt werden, welche anstelle der fehlenden Werte die
# prognostizierten Werte enthält.
imp.presidents <- presidents
imp.presidents[pos.na] <- round(pred.pres)
# Da die Werte in der ursprünglichen Zeitreihe ganzzahlig sind, werden für die Imputation
# hier auch nur gerundete Prognosen verwendet. Zum Schluss streichen wir in der neuen
# Reihe noch den Wert zum ersten Zeitpunkt, welcher auch in der ursprünglichen Reihe
# fehlte.
imp.presidents <- window(imp.presidents, start=c(1945,2))
# Als Grund dafür mag man ansehen, dass die Unsicherheit der Prognose beim ersten Wert
# höher als bei den anderen Werten ist. Eine grafische Darstellung dieser Zeitreihe ist in
# Abbildung 23.3, oberste Grafik, gegeben.

# imputed values
plot(imp.presidents)
lines(xy.smooth, col = "red")

### 23.4 Differenzen- und Lag-Operator



### 23.5 Empirische Autokorrelationsfunktion



### 23.6 Das Periodogramm



### 23.7 Einfache Zeitreihen Modelle

# Mit der Funktion decompose() kann eine einfache Zerlegung einer Zeitreihe in Trend-,
# Saison- und Restkomponete durchgeführt werden. Die Schätzungen basieren auf gleitenden
# Durchschnitten.
# Mit der Funktion HoltWinters() kann das Modell von Holt und Winters, vgl. auch
# Schlittgen und Streitberg (2001), angewendet werden. Es beruht auf mehrfachen exponentiellen
# Glättungen. Die drei Glättungsparameter alpha, beta und gamma werden dabei
# aus den Daten geschätzt, können aber auch vom Anwender festgelegt werden.
