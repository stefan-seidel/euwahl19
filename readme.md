# Readme

Skripte für den praktischen Teil meiner Bachelorarbeit zum Thema "Datenjournalismus".
Konkret für die Inhaltsanalyse der Wahlprogramme österreichischer Parteien zur Europawahl 2019.


## ./wordcloud

Das Skript "analyse.py" durläuft alle Parteiprogramme (Unterordner von "./corpus"), säubert und tokenisiert den Text, filtert eine Auswahl von Stoppwörtern und erstellt Wordcloudgrafiken.


## ./r 

Die ".R-Skripte" führen für jedes Programm eine Stimmungsanalyse durch. Als Pos-/Neg-Wortliste wird das "SentiWS-v1.8c"-Dictionary der Universität Leipzig verwendet. 

Im Ordner "./Sentiment Process Documentation" finden sich Konsolen-Logdateien, sowie die finalen Ergebnisse der Analyse.

------

SentiWS (SentiWS-v1.8c) 
R. Remus, U. Quasthoff & G. Heyer: SentiWS - a Publicly Available German-language Resource for Sentiment Analysis.
In: Proceedings of the 7th International Language Ressources and Evaluation (LREC'10), pp. 1168-1171, 2010
http://www.lrec-conf.org/proceedings/lrec2010/pdf/490_Paper.pdf
