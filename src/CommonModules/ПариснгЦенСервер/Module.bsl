#Область СлужебныеПроцедурыИФункции
Функция ВернутьТолькоЧисла(Знач ТекстовоеСодержимое) Экспорт

	ДлинаСтроки = СтрДлина(ТекстовоеСодержимое);

	ЦенаСтрокой = "";

	Для Индекс = 1 По ДлинаСтроки Цикл

		Символ = Сред(ТекстовоеСодержимое, Индекс, 1);

		Если Символ = "," Тогда

			Прервать;

		КонецЕсли;

		Если Найти("0123456789", Символ) Тогда

			ЦенаСтрокой = ЦенаСтрокой + Символ;

		КонецЕсли;

	КонецЦикла;

	Возврат Число(ЦенаСтрокой);

КонецФункции

Функция ПолучитьЦену(Магазин, Гиперссылка) Экспорт

	Цена = -1;

	СтрокиПоиска = ПолучитьСтрокиПоиска(Магазин);

	HTTPОтвет = ОбщегоНазначения.ОтправитьHTTPЗапрос(Гиперссылка);
	КодСтраницы = HTTPОтвет.ПолучитьТелоКакСтроку();

	ЧтениеHTML = Новый ЧтениеHTML;
	ЧтениеHTML.УстановитьСтроку(КодСтраницы);

	ОбъектыDOM = Новый ПостроительDOM;

	ДокументHTML = ОбъектыDOM.Прочитать(ЧтениеHTML);
	ЭлементыDOM  = ДокументHTML.ПолучитьЭлементыПоИмени(СтрокиПоиска.ИмяЭлемента);

	Для Каждого ЭлементDOM Из ЭлементыDOM Цикл

		Если ЭлементDOM.ИмяКласса = СтрокиПоиска.ИмяКласса Тогда

			НайденнаяЦена = ВернутьТолькоЧисла(ЭлементDOM.ТекстовоеСодержимое);

			Если Цена = -1 Тогда

				Цена = НайденнаяЦена;

			Иначе

				Цена = Мин(Цена, НайденнаяЦена);
				Прервать;

			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

	Возврат Цена;

КонецФункции

Функция ПолучитьСтрокиПоиска(Магазин)

	Если Магазин = Справочники.Магазины.ЛитРес Тогда

		ИмяЭлемента = "span";
		ИмяКласса   = "simple-price";

	ИначеЕсли Магазин = Справочники.Магазины.ПризрачныеМиры Тогда

		ИмяЭлемента = "span";
		ИмяКласса   = "pull-left";

	ИначеЕсли Магазин = Справочники.Магазины.Bookriver Тогда // парсит две цены, обычную и со скидкой

		ИмяЭлемента = "span";
		ИмяКласса   = "s1nq5ky_SCPrice";

	ИначеЕсли Магазин = Справочники.Магазины.Литмаркет Тогда

		ИмяЭлемента = "div";
		ИмяКласса   = "btn btn-success price-btn";

	ИначеЕсли Магазин = Справочники.Магазины.Лабиринт Тогда

		ИмяЭлемента = "span";
		ИмяКласса   = "buying-pricenew-val-number";

	ИначеЕсли Магазин = Справочники.Магазины.ЧитайГород Тогда

		ИмяЭлемента = "div";
		ИмяКласса   = "price";

	ИначеЕсли Магазин = Справочники.Магазины.Буквоед Тогда

		ИмяЭлемента = "div";
		ИмяКласса   = "oD";

	ИначеЕсли Магазин = Справочники.Магазины.Book24 Тогда

		ИмяЭлемента = "span";
		ИмяКласса   = "app-price product-sidebar-price__price";

	Иначе

		ИмяЭлемента = "";
		ИмяКласса   = "";

	КонецЕсли;

	Возврат Новый Структура("ИмяЭлемента, ИмяКласса", ИмяЭлемента, ИмяКласса);

КонецФункции
#КонецОбласти