#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура СформироватьHTML(Команда)
	СформироватьHTMLНаСервере();
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаСервереБезКонтекста
Процедура СформироватьHTMLНаСервере()
	РегламентныеЗаданияСервер.СохранитьФайлНаФТП();
КонецПроцедуры
#КонецОбласти