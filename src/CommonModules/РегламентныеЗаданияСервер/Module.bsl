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
		
		// Стоит защита, код обернут в js
		Если Выборка.Магазин = Справочники.Магазины.OZON Или Выборка.Магазин = Справочники.Магазины.СберМегаМаркет Тогда
			
			Продолжить;
			
		КонецЕсли;

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

//	СохранитьФайлНаФТП();

КонецПроцедуры

Функция ПолучитьТекст(Выборка, ПоследняяЦена, Цена)

	Текст = СтрШаблон("‼ У %1 [%2] на %3 изменилась цена с %4 на %5",
					  Выборка.Книга,
					  Выборка.ТипКниги,
					  Выборка.Магазин,
					  ПоследняяЦена,
					  Цена);

	Возврат Текст;

КонецФункции

Процедура СохранитьФайлНаФТП()
	
	HTMLФайл = СформироватьИЗаписатьHTML();
	
КонецПроцедуры

Функция СформироватьИЗаписатьHTML() Экспорт
	
	МассивHTML = Новый Массив();
	МассивHTML.Добавить("<section id=""books"">");
	МассивHTML.Добавить("	<h2>Наши книги</h2>");
	МассивHTML.Добавить("	<div class=""container"">");
	МассивHTML.Добавить("		<div class=""row"">");
	
	Книги = ПолучитьКниги();
	
	Для Каждого Книга Из Книги Цикл
		
		НазваниеКниги = ?(Книга.КнигаНомерКниги = 0, Книга.КнигаНаименование, СтрШаблон("%1 #%2",
																						Книга.КнигаНаименование,
																						Книга.КнигаНомерКниги));
		
		// Цикл книг
		МассивHTML.Добавить("			<div class=""col-lg-6 p-0 p-lg-2"">");
		МассивHTML.Добавить("				<div class=""blocks book-card"">");
		МассивHTML.Добавить(СтрШаблон("					<h1>%1</h1>", НазваниеКниги));
		
		// Цикл исполнителей
		Для Каждого Исполнитель Из Книга.Исполнители Цикл
			
			ВидИсполнителя = Исполнитель.ИсполнительВидИсполнителя;
			Гиперссылка = Исполнитель.ИсполнительГиперссылка;
			Имя = Исполнитель.ИсполнительНаименование;
			Текст = СтрШаблон("%1: <a href=""%2"" target=""_blank"">%3</a>", ВидИсполнителя, Гиперссылка, Имя);
			
			МассивHTML.Добавить("					<div class=""book__body__avtor mt-1"">");
			МассивHTML.Добавить(СтрШаблон("						%1", Текст));
			МассивHTML.Добавить("					</div>");
			
		КонецЦикла;
		
		МассивHTML.Добавить("					<div class=""d-flex flex-lg-wrap flex-wrap mt-4"">");
		МассивHTML.Добавить("						<div class=""book-card-img pe-0 pe-lg-4"">");
		
		Обложка = СтрШаблон("<img src=""%1"" alt=""Обложка книги: %2"">", Книга.КнигаОбложка, Книга.КнигаНаименование);
		
		МассивHTML.Добавить(СтрШаблон("							%1", Обложка));							
		МассивHTML.Добавить("						</div>");
		МассивHTML.Добавить("						<div class=""book-card-description"">");
		
		МассивHTML.Добавить("						</div>");
		
		МассивHTML.Добавить("					</div>");

		МассивHTML.Добавить("				</div>");
		МассивHTML.Добавить("			</div>");

	КонецЦикла;
                
    МассивHTML.Добавить("		</div>");
	МассивHTML.Добавить("	</div>");
	МассивHTML.Добавить("</section>");
	
//	ДокументHTML = "";
	//TODO: Реализация
КонецФункции

// Получить книги.
// 
// Возвращаемое значение:
//  ТаблицаЗначений - Получить книги
Функция ПолучитьКниги()

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Книги.Ссылка КАК Ссылка,
	|	Книги.Наименование КАК КнигаНаименование,
	|	Книги.НомерКниги КАК КнигаНомерКниги,
	|	Книги.Обложка КАК КнигаОбложка
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
	|	КнигиИсполнители.Исполнитель,
	|	КнигиИсполнители.Исполнитель.Наименование,
	|	КнигиИсполнители.Исполнитель.ВидИсполнителя,
	|	КнигиИсполнители.Исполнитель.Гиперссылка
	|ПОМЕСТИТЬ Исполнители
	|ИЗ
	|	Справочник.Книги.Исполнители КАК КнигиИсполнители
	|ГДЕ
	|	КнигиИсполнители.Ссылка В
	|		(ВЫБРАТЬ
	|			Книги.Ссылка
	|		ИЗ
	|			Книги КАК Книги)";
	
	ПакетСПромежуточнымиДанными = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	
	СхемаЗапроса = Новый СхемаЗапроса;
	СхемаЗапроса.УстановитьТекстЗапроса(Запрос.Текст);
	ПакетЗапросов = СхемаЗапроса.ПакетЗапросов;
	
	СтруктураВТ = Новый Структура();
	
	Для Каждого Пакет Из ПакетЗапросов Цикл
		
		СтруктураВТ.Вставить(Пакет.ТаблицаДляПомещения, ПакетЗапросов.Индекс(Пакет));
		
	КонецЦикла;
	
	Книги = ПакетСПромежуточнымиДанными[СтруктураВТ.Книги].Выгрузить();
	Исполнители = ПакетСПромежуточнымиДанными[СтруктураВТ.Исполнители].Выгрузить();
	
	Книги.Колонки.Добавить("Исполнители", Новый ОписаниеТипов("Массив"));
	
	Для Каждого Книга Из Книги Цикл
		
		ПараметрыОтбора = Новый Структура("Книга", Книга.Ссылка);
		Книга.Исполнители = Исполнители.НайтиСтроки(ПараметрыОтбора);
		
	КонецЦикла;

	Возврат Книги;

КонецФункции
#КонецОбласти