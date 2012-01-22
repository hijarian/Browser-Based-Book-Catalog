// Получаем список категорий книг
const categories = {
	'Художественная литература' : [
		'Детективы',
		'Фантастика',
		'Классическая литература',
		'Сказки',
		'Для школьного возраста',
		'Поэзия',
		'Художественная литература &mdash; разное'
		],
	'Справочная литература' : [
		'Познавательные',
		'Словари',
		'Кулинария',
		'Практическая психология',
		'Оздоровление',
		'Журналистика',
		'Музыка',
		'Информационные технологии',
		'Социология',
		'Домашнее хозяйство',
		'Воспитание детей',
		'Медицина',
		'Справочники &mdash; разное'
		],
	'Философия' : [
		'Философское наследие',
		'Философия &mdash; разное'
		],
	'Школьные учебники' : [
		'Литература',
		'Русский язык',
		'Математика',
		'Физика',
		'Химия',
		'История',
		'Иностранные языки',
		],
	'Остальное' : [ 
		'Книги без категории',
		'Все книги']
	};

// Получаем URI XML-документа с данными о книгах и XSL-трансформации для вывода каталога
const xmlpath = 'data/books-data.xml';
const xslpath = 'books-table-partial.xsl';
const resultcontainer = '#catalog';
const optpaneref = '#options';
const catlistid = 'category-selector';
const parlistid = 'parameters-panel';
const selectbtnid = 'select-button';

var transform_inner = function(xmldoc, xsldoc, config) {
  // create a cross-browser XSLTProcessor - Sarissa's magic unleashed
  var processor = new XSLTProcessor();
//  alert('5. ' +  'xslt processor created' );

  processor.importStylesheet(xsldoc);

  // pass a parameters
  $.each(config.xslParams, function(param, value) {
    processor.setParameter(null, param, value);
//    alert('6x. ' + 'added parameter: ' + param + ', value ' + value);
    });

  // transform xml with xsl
  // output a result in .this
//  alert('DEBUG: '+ processor.transformToFragment(xmldoc, document));
  $(config.element).empty().append(processor.transformToFragment(xmldoc, document));
//  alert('7. transform completed');

  // Оформляем полученную таблицу с помощью jquery.dataTable
  $(config.element + ' table').dataTable({"sPaginationType": "full_numbers"});
//  alert('8. table enchanced');
}


var transform = function(settings) {
//	alert ('transform fired');
  var config = {
    element: false,
    xml: false, 
    xsl: false,
    xslParams: {}
  };

  if (settings) $.extend(config, settings);

//	alert ('options passed');

  if (!config.xml || !config.xsl){
		alert ('No xml/xsl paths provided!');
		return null;
	}	
	if (!config.element) {
		alert ('No target element provided!');
		return null;
	}

  // prepare xml
  var xmldoc = Sarissa.getDomDocument;
  xmldoc.async = false; 
//  alert('0a. xmldoc created');
  //prepare xsl
  var xsldoc = Sarissa.getDomDocument;
  xsldoc.async = false; 
//  alert('0b. xsldoc created');

  // send get request
  $.get(config.xml, function(data) { 
    // parse gotten xml
//    alert('1. ' + config.xml + ' fetched through get');
    var parser = new DOMParser();
    xmldoc = parser.parseFromString(data, 'text/xml');
//    alert('2. ' + 'parsed: ' + xmldoc);
    
    // send get request
    $.get(config.xsl, function(data) { 
      // parse gotten xsl
//      alert('3. ' + config.xsl + ' fetched through get');
      var parser = new DOMParser();
      xsldoc = parser.parseFromString(data, 'text/xml');
//      alert('4. ' + 'parsed: ' + xsldoc);
      
      // call transformation sequence -- all parts in place
      transform_inner(xmldoc, xsldoc, config);
//      alert('9. transform_inner exited');
      });
  });
}      


var place_options = function(){
		// Убираем объявление о необходимости javascript
		$('#noscript').remove();
		// Генерируем панель настроек вывода каталога
		$(optpaneref).empty();
		// Выводим селектор категорий
		$(optpaneref).append(
				'<div id="' + catlistid + '"></div>' +
		// Выводим панель параметров
				'<div id="' + parlistid + '">' +
		// Выводим кнопку для отбора книг по категории
					'<input type="button" name="select-button" id="select-button" value="Отбор" />' + 
				'</div>'
				);
		$('#select-button').button();
		// Наполняем селектор категорий
		var catlistref = optpaneref + ' #' + catlistid;
		$.each(categories, function(category_name, subcategory){
			var catstring = 
				'<h1 id="head_' + category_name + '">' +
					'<a href=".#">' + category_name + '</a>' +
				'</h1>' +
				'<div id="div_' + category_name + '">';
			$.each(subcategory, function(index, subcategory_name) {
				catstring += 
						'<input type="radio" id="radio_'+subcategory_name+'" name="category" value="' + subcategory_name + '" />' +
						'<label for="radio_'+subcategory_name+'">'+subcategory_name+'</label>';
			}); // end each (subcategory)
			catstring += '</div>';
			$(catlistref).append(catstring);
		}); // end each (categories)

		// Оформляем категории в селекторе как buttonset
		var selector = optpaneref + ' #' + catlistid + ' div';
		$(selector).each(function(){
				$(this).buttonset()
			});

		// Оформляем селектор категорий как accordion
		$(optpaneref + ' #' + catlistid).accordion();

		// Выводим чекбоксы опций
		$(optpaneref + ' #' + parlistid).prepend(
				'<input type="checkbox" id="show-images-check" name="show-images-check" checked="checked" />' +
				'<label for="show-images-check">Показывать изображения</label>'
				);
		$('#show-images-check').button();
}


// DEBUG: firing transform() on page load
		// Трансформируем XML-документ в таблицу и выводим её в div#catalog

// При загрузке документа
$().ready(function(){
	place_options();

	// При клике на кнопку запуска отбора книг из каталога
	$('#select-button').click(function(){
		var imagemode = $('#show-images-check:checked').length;
		var catname = $('input[type=radio][name=category]:checked').val();
		var mode;
		switch (catname) {
			case "Все книги": 
				mode = "all"; break;
			case "Книги без категории": 
				mode = "undef"; break;
			default : 
				mode = "category";
			};
		// Проверки на корректность входных аргументов
		imagemode = (imagemode != undefined)?imagemode:true;
		mode = (catname)?mode:"all"; 
		catname = catname?catname:"''";
		alert('click fired, imagemode: ' + imagemode + ', catname: ' + catname + ', mode: ' + mode); 
			// Трансформируем XML-документ в таблицу и выводим её в div#catalog
		transform({
			'element'	: resultcontainer,
			'xml' 		: xmlpath,
			'xsl' 		: xslpath,
			'xslParams' : {
				'show-images'	 : imagemode,
				'category' : catname,
				'selector-mode' : mode 
				}
			}); // end transform
	});	// end $('#select-button').click

}); // end $().ready(function(){})


