#Область СлужебныеПроцедурыИФункции
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	Процедура Заполнить() Экспорт

		Книги.Очистить();

		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Книги.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Книги КАК Книги
		|ГДЕ
		|	НЕ Книги.ПометкаУдаления
		|	И НЕ Книги.ЭтоГруппа
		|
		|УПОРЯДОЧИТЬ ПО
		|	Книги.ПорядокДляСайта";

		Книги.Загрузить(Запрос.Выполнить().Выгрузить());

	КонецПроцедуры
#КонецЕсли
#КонецОбласти