#Область СлужебныеПроцедурыИФункции
// Отправить HTTPЗапрос.
// 
// Параметры:
//  Гиперссылка - Строка - Ссылка сайта
// 
// Возвращаемое значение:
//  HTTPОтвет - Ответ на HTTPЗапрос
Функция ОтправитьHTTPЗапрос(Гиперссылка) Экспорт

	ЗащищенноеСоединение = ?(Найти(Нрег(Гиперссылка), "https://") = 1, Новый ЗащищенноеСоединениеOpenSSL, Неопределено);

	ГиперссылкаБезПротокола = СтрЗаменить(Гиперссылка, "https://", "");
	ГиперссылкаБезПротокола = СтрЗаменить(ГиперссылкаБезПротокола, "http://", "");

	Позиция = Найти(ГиперссылкаБезПротокола, "/");

	Если Позиция > 0 Тогда

		Сервер = Лев(ГиперссылкаБезПротокола, Позиция - 1);
		АдресРесурса = Сред(ГиперссылкаБезПротокола, Позиция, СтрДлина(Гиперссылка));

	Иначе

		Сервер = ГиперссылкаБезПротокола;
		АдресРесурса = "/";

	КонецЕсли;

	HTTPСоединение = Новый HTTPСоединение(Сервер, , , , , 60, ЗащищенноеСоединение);
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса);

	Попытка

		HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);

	Исключение

		Ошибка = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ОтправитьСообщениеВТелеграмм(Справочники.ЧатыТелеграмм.Себе.Код, Ошибка);

	КонецПопытки;

	Возврат HTTPОтвет;

КонецФункции

// Отправить сообщение в телеграмм.
// 
// Параметры:
//  ЧатТелеграмм - Строка - ИД чата, для групп ставится дефис вначале
//  Текст - Строка - Текст сообщения
Процедура ОтправитьСообщениеВТелеграмм(ЧатТелеграмм, Текст) Экспорт

	Сервер = "api.telegram.org";
	Токен = "5428294780:AAEuJw-2ZA2C3ytOWoX4RLS1yjCm6d1RVJY";
	Страница = СтрШаблон("/bot%1/sendMessage?chat_id=%2&text=%3", Токен, ЧатТелеграмм, Текст);
	HTTPСоединение = Новый HTTPСоединение(Сервер, , , , , 30, Новый ЗащищенноеСоединениеOpenSSL);
	HTTPЗапрос = Новый HTTPЗапрос(Страница);
	HTTPСоединение.Получить(HTTPЗапрос);

КонецПроцедуры
#КонецОбласти
