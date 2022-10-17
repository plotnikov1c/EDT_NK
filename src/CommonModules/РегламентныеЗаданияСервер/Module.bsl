#Область СлужебныеПроцедурыИФункции
Процедура АктуализироватьЦены() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КнигиТовары.Ссылка.Родитель КАК Родитель,
	|	КнигиТовары.Ссылка.НомерКниги КАК НомерКниги,
	|	КнигиТовары.Ссылка КАК Книга,
	|	КнигиТовары.Магазин КАК Магазин,
	|	КнигиТовары.ТипКниги КАК ТипКниги,
	|	КнигиТовары.Гиперссылка КАК Гиперссылка
	|ИЗ
	|	Справочник.Книги.Товары КАК КнигиТовары
	|ГДЕ
	|	НЕ КнигиТовары.Ссылка.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Родитель,
	|	НомерКниги,
	|	Книга,
	|	Магазин,
	|	ТипКниги,
	|	Гиперссылка";

	Выборка = Запрос.Выполнить().Выбрать();

	Пока Выборка.Следующий() Цикл
		
		Цена = ПариснгЦенСервер.ПолучитьЦену(Выборка.Магазин, Выборка.Гиперссылка);

		Если Цена <= 0 Тогда

			Текст = СтрШаблон("Ошибка получения цены: %1", Выборка.Гиперссылка);
			ОбщегоНазначения.ОтправитьСообщениеВТелеграмм(Справочники.ЧатыТелеграмм.Себе.Код, Текст);
			Продолжить;

		КонецЕсли;
		
		Отбор = Новый Структура("Книга, Магазин, ТипКниги");
		ЗаполнитьЗначенияСвойств(Отбор, Выборка);

		СтруктураРесурсов = РегистрыСведений.Цены.ПолучитьПоследнее( , Отбор);

		ПоследняяЦена = СтруктураРесурсов.Цена;
		
		Если Цена <> ПоследняяЦена Тогда

			МенеджерЗаписи = РегистрыСведений.Цены.СоздатьМенеджерЗаписи();
			ЗаполнитьЗначенияСвойств(МенеджерЗаписи, Выборка);
			МенеджерЗаписи.Период = ТекущаяДатаСеанса();
			МенеджерЗаписи.Цена = Цена;
			МенеджерЗаписи.Записать();

			Текст = ПолучитьТекст(Выборка, ПоследняяЦена, Цена);
			ОбщегоНазначения.ОтправитьСообщениеВТелеграмм(Справочники.ЧатыТелеграмм.Трио.Код, Текст);

		КонецЕсли;

	КонецЦикла;

	СохранитьФайлНаФТП();

КонецПроцедуры

Функция ПолучитьТекст(Выборка, ПоследняяЦена, Цена)

	Текст = СтрШаблон("‼️ У %1 [%2] на %3 изменилась цена с %4 на %5",
					  Выборка.Книга,
					  Выборка.ТипКниги,
					  Выборка.Магазин,
					  ПоследняяЦена,
					  Цена);

	Возврат Текст;

КонецФункции

Процедура СохранитьФайлНаФТП() Экспорт
	
	МассивСтрокHTML = ПолучитьМассивСтрокHTML();
	
	Соединение = Новый FTPСоединение("ftp.nov2975192.nichost.ru", // Адрес ftp сервера
									 ,                            // Порт сервера
									 "nov2975192_ftp",            // Имя пользователя
									 "AvPrPwvjfQ",                // Пароль пользователя
									 Неопределено,                // Прокси не используется
									 Истина,                      // Пассивный режим работы
									 30,                          // Таймаут (0 - без ограничений)
									 Неопределено);               // Незащищенное соединение
	
	ПутьКФайлу = ПолучитьИмяВременногоФайла("html");
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	
	Для Каждого Строка Из МассивСтрокHTML Цикл
		
		ТекстовыйДокумент.ДобавитьСтроку(Строка);
		
	КонецЦикла;
	
	ТекстовыйДокумент.Записать(ПутьКФайлу, КодировкаТекста.UTF8);
	
	Соединение.Записать(ПутьКФайлу, "novakamskaya.ru/docs/books.html");
	
	УдалитьФайлы(ПутьКФайлу);
	
КонецПроцедуры

Функция ПолучитьМассивСтрокHTML() Экспорт

	ПутьКОбложкам = Константы.ПутьКОбложкам.Получить();
	
	МассивСтрокHTML = Новый Массив;
	МассивСтрокHTML.Добавить("<h2>Наши книги</h2>");
	МассивСтрокHTML.Добавить("<div class=""container"">");
	МассивСтрокHTML.Добавить("<div class=""row"">");

	Книги = ПолучитьКниги();

	СчетчикЕщеВарианты = 1;

	Для Каждого Книга Из Книги Цикл

		НазваниеКниги = ?(Книга.НомерКниги = 0, Книга.Наименование, СтрШаблон("%1 #%2",
																			  Книга.Наименование,
																			  Книга.НомерКниги));
		
		// Цикл книг
		МассивСтрокHTML.Добавить("<div class=""col-lg-6 p-0 p-lg-2"">");
		МассивСтрокHTML.Добавить("<div class=""blocks book-card"">");
		МассивСтрокHTML.Добавить(СтрШаблон("<h1>%1</h1>", НазваниеКниги));
		
		// Цикл исполнителей
		Для Каждого Исполнитель Из Книга.Исполнители Цикл

			ВидИсполнителя = Исполнитель.ВидИсполнителя;
			Гиперссылка = Исполнитель.Гиперссылка;
			Имя = Исполнитель.Наименование;
			Текст = СтрШаблон("%1: <a href=""%2"" target=""_blank"">%3</a>", ВидИсполнителя, Гиперссылка, Имя);

			МассивСтрокHTML.Добавить("<div class=""book__body__avtor mt-1"">");
			МассивСтрокHTML.Добавить(СтрШаблон("%1", Текст));
			МассивСтрокHTML.Добавить("</div>");

		КонецЦикла;
		
		МассивСтрокHTML.Добавить("<div class=""d-flex flex-lg-wrap flex-wrap mt-4"">");
		
		Если ЗначениеЗаполнено(Книга.Обложка) Тогда

			МассивСтрокHTML.Добавить("<div class=""book-card-img pe-0 pe-lg-4"">");

			Обложка = СтрШаблон("<img src=""%1"" alt=""Обложка книги: %2"">",
								ПутьКОбложкам + Книга.Обложка,
								Книга.Наименование);

			МассивСтрокHTML.Добавить(СтрШаблон("%1", Обложка));
			МассивСтрокHTML.Добавить("</div>");

		КонецЕсли;
		
		МассивСтрокHTML.Добавить("<div class=""book-card-description"">");
		МассивСтрокHTML.Добавить(СтрШаблон("%1", Книга.Аннотация));
		МассивСтрокHTML.Добавить("</div>");
		МассивСтрокHTML.Добавить("</div>");
		
		МассивСтрокHTML.Добавить("<div class=""book-card-meta d-flex mt-3"">");
		ГодИзданияHTML = СтрШаблон("<span><strong>Год издания: </strong>%1</span>", Формат(Книга.ГодИздания, "ЧГ=0;"));
		МассивСтрокHTML.Добавить(СтрШаблон("%1", ГодИзданияHTML));

		Если ЗначениеЗаполнено(Книга.Объем) Тогда

			ОбъемHTML = СтрШаблон("<span><strong>Объем: </strong>%1 стр.</span>", Формат(Книга.Объем, "ЧГ=0;"));
			МассивСтрокHTML.Добавить(СтрШаблон("%1", ОбъемHTML));

		КонецЕсли;
		
		МассивСтрокHTML.Добавить("</div>");
		
		Если Книга.БумажнаяКнига.Количество() Или Книга.ЭлектроннаяКнига.Количество() Или Книга.Аудиокнига.Количество() Тогда

			МассивСтрокHTML.Добавить("<hr>");

			ЗаполнитьКарточкуПокупки(МассивСтрокHTML, Книга.БумажнаяКнига, "Купить бумажную книгу", СчетчикЕщеВарианты);
			ЗаполнитьКарточкуПокупки(МассивСтрокHTML, Книга.ЭлектроннаяКнига, "Электронные книги", СчетчикЕщеВарианты);
			ЗаполнитьКарточкуПокупки(МассивСтрокHTML, Книга.Аудиокнига, "Аудиокниги", СчетчикЕщеВарианты);

		КонецЕсли;

		МассивСтрокHTML.Добавить("</div>");
		МассивСтрокHTML.Добавить("</div>");

	КонецЦикла;

	МассивСтрокHTML.Добавить("</div>");
	МассивСтрокHTML.Добавить("</div>");
	
	Возврат МассивСтрокHTML;
	
КонецФункции

Процедура ЗаполнитьКарточкуПокупки(МассивСтрокHTML, Карточка, Заголовок, СчетчикЕщеВарианты)

	Если Карточка.Количество() Тогда

		МассивСтрокHTML.Добавить("<div class=""book-card-price mt-3"">");
		МассивСтрокHTML.Добавить(СтрШаблон("<p>%1</p>", Заголовок));
		
		СчетчикСтрок = 1;
		НужноСвернутьСтроки = Ложь;

		Для Каждого Элемент Из Карточка Цикл
			
			Если СчетчикСтрок = 4 Тогда
				
				МассивСтрокHTML.Добавить("<div class=""accordion accordion-flush"" id=""add-3"">");
				МассивСтрокHTML.Добавить("<div class=""accordion-item"">");
				МассивСтрокHTML.Добавить(СтрШаблон("<div id=""open-%1"" class=""accordion-collapse collapse"" aria-labelledby=""b-1"" data-bs-parent=""#add-3"">",
												   СчетчикЕщеВарианты));
				МассивСтрокHTML.Добавить("<div class=""accordion-body p-0"">");
				
				НужноСвернутьСтроки = Истина;
				
			КонецЕсли;

			Магазин = СтрШаблон("<div><img class=""shop-logo"" src=""%1"" alt="""">%2</div><div>%3<span> ₽</span></div>",
								Элемент.МагазинЛоготип,
								Элемент.МагазинНаименование,
								Элемент.Цена);

			МассивСтрокHTML.Добавить(СтрШаблон("<a href=""%1"" target=""_blank"">%2</a>", Элемент.Гиперссылка, Магазин));
			
			СчетчикСтрок = СчетчикСтрок + 1;
			
		КонецЦикла;
		
		Если НужноСвернутьСтроки Тогда

			МассивСтрокHTML.Добавить("</div>");
			МассивСтрокHTML.Добавить("</div>");

			МассивСтрокHTML.Добавить("<h2 class=""accordion-header pt-2 pb-0"" id=""b-1"">");
			МассивСтрокHTML.Добавить("<button class=""accordion-button collapsed p-0 text-end"" type=""button""");
			МассивСтрокHTML.Добавить(СтрШаблон("data-bs-toggle=""collapse"" data-bs-target=""#open-%1"" aria-expanded=""false""",
											   СчетчикЕщеВарианты));
			МассивСтрокHTML.Добавить("aria-controls=""flush-collapseOne"">Ещё варианты");
			МассивСтрокHTML.Добавить("</button>");
			МассивСтрокHTML.Добавить("</h2>");

			МассивСтрокHTML.Добавить("</div>");
			МассивСтрокHTML.Добавить("</div>");

			СчетчикЕщеВарианты = СчетчикЕщеВарианты + 1;

		КонецЕсли;

		МассивСтрокHTML.Добавить("</div>");
		
	КонецЕсли;
	
КонецПроцедуры

// Получить книги.
// 
// Возвращаемое значение:
//  ТаблицаЗначений - Получить книги
Функция ПолучитьКниги()

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Книги.Ссылка КАК Ссылка,
	|	Книги.Наименование КАК Наименование,
	|	Книги.НомерКниги КАК НомерКниги,
	|	Книги.Обложка КАК Обложка,
	|	Книги.Объем,
	|	Книги.ГодИздания,
	|	Книги.Аннотация,
	|	Книги.ПорядокДляСайта
	|ПОМЕСТИТЬ Книги
	|ИЗ
	|	Справочник.Книги КАК Книги
	|ГДЕ
	|	НЕ Книги.ПометкаУдаления
	|	И НЕ Книги.ЭтоГруппа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КнигиИсполнители.Ссылка КАК Книга,
	|	КнигиИсполнители.Исполнитель КАК Ссылка,
	|	КнигиИсполнители.Исполнитель.Наименование КАК Наименование,
	|	КнигиИсполнители.Исполнитель.ВидИсполнителя КАК ВидИсполнителя,
	|	КнигиИсполнители.Исполнитель.Гиперссылка КАК Гиперссылка
	|ПОМЕСТИТЬ Исполнители
	|ИЗ
	|	Справочник.Книги.Исполнители КАК КнигиИсполнители
	|ГДЕ
	|	КнигиИсполнители.Ссылка В
	|		(ВЫБРАТЬ
	|			Книги.Ссылка
	|		ИЗ
	|			Книги КАК Книги)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЦеныСрезПоследних.Книга,
	|	ЦеныСрезПоследних.ТипКниги,
	|	ЦеныСрезПоследних.Магазин,
	|	ЦеныСрезПоследних.Цена,
	|	ЦеныСрезПоследних.Гиперссылка,
	|	ЦеныСрезПоследних.Магазин.Логотип КАК МагазинЛоготип,
	|	ЦеныСрезПоследних.Магазин.Наименование
	|ПОМЕСТИТЬ Цены
	|ИЗ
	|	РегистрСведений.Цены.СрезПоследних(, Книга В
	|		(ВЫБРАТЬ
	|			Книги.Ссылка
	|		ИЗ
	|			Книги КАК Книги)) КАК ЦеныСрезПоследних";
	
	ПакетСПромежуточнымиДанными = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	
	СхемаЗапроса = Новый СхемаЗапроса;
	СхемаЗапроса.УстановитьТекстЗапроса(Запрос.Текст);
	ПакетЗапросов = СхемаЗапроса.ПакетЗапросов;
	
	ИндексыПакетов = Новый Структура();
	
	Для Каждого Пакет Из ПакетЗапросов Цикл
		
		ИндексыПакетов.Вставить(Пакет.ТаблицаДляПомещения, ПакетЗапросов.Индекс(Пакет));
		
	КонецЦикла;
	
	Книги = ПакетСПромежуточнымиДанными[ИндексыПакетов.Книги].Выгрузить();
	Книги.Сортировать("ПорядокДляСайта");
	Исполнители = ПакетСПромежуточнымиДанными[ИндексыПакетов.Исполнители].Выгрузить();
	Цены = ПакетСПромежуточнымиДанными[ИндексыПакетов.Цены].Выгрузить();
	Цены.Сортировать("Цена");
	
	Книги.Колонки.Добавить("Исполнители", Новый ОписаниеТипов("Массив"));
	Книги.Колонки.Добавить("БумажнаяКнига", Новый ОписаниеТипов("Массив"));
	Книги.Колонки.Добавить("ЭлектроннаяКнига", Новый ОписаниеТипов("Массив"));
	Книги.Колонки.Добавить("Аудиокнига", Новый ОписаниеТипов("Массив"));
	
	Для Каждого Книга Из Книги Цикл
		
		Книга.Исполнители = Исполнители.НайтиСтроки(Новый Структура("Книга", Книга.Ссылка));
		
		Отбор = Новый Структура("Книга, ТипКниги", Книга.Ссылка, Перечисления.ТипКниги.БумажнаяКнига);
		Книга.БумажнаяКнига = Цены.НайтиСтроки(Отбор);
		
		Отбор = Новый Структура("Книга, ТипКниги", Книга.Ссылка, Перечисления.ТипКниги.ЭлектроннаяКнига);
		Книга.ЭлектроннаяКнига = Цены.НайтиСтроки(Отбор);
		
		Отбор = Новый Структура("Книга, ТипКниги", Книга.Ссылка, Перечисления.ТипКниги.Аудиокнига);
		Книга.Аудиокнига = Цены.НайтиСтроки(Отбор);
		
	КонецЦикла;

	Возврат Книги;

КонецФункции
#КонецОбласти