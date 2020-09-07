extends Label

var phrases = [
	"Сорян, неудачно получилось",
	"Ты пытался",
	"Война. Умерли.",
	":с",
	"Поражение",
	"Ох, это наверно было больно",
	"В следующий раз точно получится",
	"Давай еще раз, я верю в тебя",
	"Ты справишься",
	"Война поглотила вас",
	"Последний удар был роковым, оставив неизгладимый отпечаток в истории. Все было кончено",
	"Бедная понька :с",
	"Если ты видишь этот текст, значит, тебя убили",
	"Жестокая смерть для бедной поняхи",
	"Совершенно внезапно, но вполне закономерно",
	"Надо было добавить настройку уровней сложности",
	"Эх, теперь все заново :с",
	"Смерть неотвратима. Кроме этой, здесь ты можешь перезагрузиться",
	"Привет, я экран смерти, приятно познакомиться  с:",
]

var phrases_eng = [
	"Sorry, bad luck :c",
	"You tried",
	":c",
	"Lose",
	"Oh, it must have hurt",
	"You will do it next time",
	"Lets try again, I believe in you",
	"You can do it",
	"War, dealth and ponies",
	"The last hit was fatal, it was over",
	"Poor little pony :c",
	"If you see this text, you probably were killed",
	"Such cruel dealth for poor little pony",
	"Quite suddenly, but quite naturally",
	"Ah, now it's all over again :c",
	"Death is inevitable. Besides this one, you can reboot here",
	"Hi, I'm dealth screen, nice to meet you c:",
	"I had to add a difficulty level setting",
	"T_T"
]

func _ready():
	randomize()
	
	if G.english:
		var phraseI = randi() % phrases_eng.size()
		text = phrases_eng[phraseI]
	else:
		var phraseI = randi() % phrases.size()
		text = phrases[phraseI]
