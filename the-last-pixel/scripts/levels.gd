extends RefCounted
## Lista central de níveis, por ordem.
## Para acrescentar um nível: crie a cena (copie Nivel_Modelo.tscn) e
## acrescente o caminho AQUI. A porta de cada nível leva ao seguinte da lista;
## a porta do último nível mostra o ecrã de vitória.

const LIST: Array[String] = [
	"res://scenes/Fase1.tscn",
	"res://scenes/Fase2.tscn",
	"res://scenes/Fase3.tscn",
]


static func first() -> String:
	return LIST[0]


static func next_after(path: String) -> String:
	var i := LIST.find(path)
	if i == -1 or i + 1 >= LIST.size():
		return ""
	return LIST[i + 1]
