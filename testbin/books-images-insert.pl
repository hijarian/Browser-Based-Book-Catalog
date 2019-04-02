#!perl

# Скрипт для убыстрения добавления изображений книг в каталог
# Каталог книг ожидается в файле books.xml
# На вход скрипта подаётся старое название изображения, новое название изображения и часть названия книги
# В результате работы скрипт делает следующее:
#   1. находит токен book в xml-документе books.xml с дочерним элементом name, содержащим указанную часть названия, 
#   2. добавляет в него третьим дочерним элементом элемент image, 
#   3. в качестве содержимого элемента image добавляет новое название изображения, которое передано вторым аргументом
#   4. переименовывает старое изображение, которое ожидается в папке images/ и имя которого передано первым аргументом
#   5. переименовывает превью старого изображения, которое ожидается в папке images/thumbs/ и имя которого передано первым аргументом с добавлением префикса 'thumb-'
# Если часть названия, переданная третьим аргументом, не найдена, xml-документ остаётся неизменным.

use warnings;
use strict;
use utf8;
use File::Copy;
use Encode;

# Константы
my $imgfolder       = 'data/images/';
my $imgthumbfolder  = 'data/thumbnails/';
my $datafile        = 'data/books-data.xml';
my $outfile         = $datafile.'.temp';
my $imgformat       = '.jpg';
my $logfile         = 'books-image-insert.log';

# Параметры обработки
my $UTF8FS					= 1;
my $NOTRANSLIT			= 0;

# Управляющие команды
my $ordersfile      = shift || 'orders.txt';

# my $old_image_name  = shift || die "Незачем запускать без аргументов!\n"; 
# my $new_image_name  = shift; # БЕЗ РАСШИРЕНИЯ!
# my $book_name_part  = shift;

my $translatetable = {
	'а' => 'a',   'А' => 'A',
	'б' => 'b',   'Б' => 'B',
	'в' => 'v',   'В' => 'V',
	'г' => 'g',   'Г' => 'G',
	'д' => 'd',   'Д' => 'D',
	'е' => 'e',   'Е' => 'E',
	'ё' => 'yo',  'Ё' => 'YO',
	'ж' => 'zh',  'Ж' => 'ZH',
	'з' => 'z',   'З' => 'Z',
	'и' => 'i',   'И' => 'I',
	'й' => 'y',   'Й' => 'Y',
	'к' => 'k',   'К' => 'K',
	'л' => 'l',   'Л' => 'L',
	'м' => 'm',   'М' => 'M',
	'н' => 'n',   'Н' => 'N',
	'о' => 'o',   'О' => 'O',
	'п' => 'p',   'П' => 'P',
	'р' => 'r',   'Р' => 'R',
	'с' => 's',   'С' => 'S',
	'т' => 't',   'Т' => 'T',
	'у' => 'u',   'У' => 'U',
	'ф' => 'f',   'Ф' => 'F',
	'х' => 'h',   'Х' => 'H',
	'ц' => 'ts',  'Ч' => 'TS',
	'ч' => 'ch',  'Ц' => 'CH',
	'ш' => 'sh',  'Ш' => 'SH',
	'щ' => 'sch', 'Щ' => 'SCH',
	'ъ' => '`',   'Ъ' => '`', # WTF begin
	'ы' => 'i',   'Ы' => 'I',
	'ь' => '`',   'Ь' => '`',
	'э' => 'e',   'Э' => 'E', # WTF end
	'ю' => 'yu',  'Ю' => 'YU',
	'я' => 'ya',  'Я' => 'YA'
};

sub translit {
	my $instring = shift;
#	print "Начинаем транслировать строку $instring...\n";
	foreach my $cyr_letter (keys(%{$translatetable}))
		{
			my $latin_letter = $translatetable->{$cyr_letter};
#			print "Буква $cyr_letter: транслируется в $latin_letter\n";
#			print "Строка $instring была оттранслирована в ";
			$instring =~ s/$cyr_letter/$latin_letter/g;
#			print " $instring\n";
		};
	return $instring;
	}


# Открываем файл с командами
print "Открываем файл с указаниями: $ordersfile...";
open(my $orders, "<:encoding(UTF-8)", $ordersfile) || die " ошибка при открытии: $!\n";
print " открыт\n";

# Открываем лог, куда будем писать подробности о работе
print "Открываем файл отчёта: $logfile...";
open(my $log, ">:encoding(UTF-8)", $logfile) || die " ошибка при открытии: $!\n";
print " открыт\n";

# Хэш, который будет хранить указания из файла указаний в виде конструкций
# %orderlist = {
#                REGEXP_ОПИСЫВАЮЩИЙ_ИСКОМУЮ_СТРОКУ => [ СТАРОЕ_ИМЯ_ИЗОБРАЖЕНИЯ, НОВОЕ_ИМЯ_ИЗОБРАЖЕНИЯ ],
#                ...
#              }
my %orderlist;

# Для каждой команды в файле команд...
print "Получаем инструкции...";
while (<$orders>)
  {
    next if /^$/; # Нахуй пустые строки!
    chomp;        # Нахуй символ перевода строки в конце строки!
    my ($old_image_name, $new_image_name, $book_name_part) = split(/;/, $_);
    print $log $old_image_name." ; ".$new_image_name." ; ".$book_name_part."\n";
    $orderlist{$book_name_part} = [ $old_image_name, $new_image_name ];
  } # end while (<$orders>);

close($orders);
print " получено\n";
  
# Пометка, нашли ли все указанные записи
my $found_all = 0;

# Открываем входной файл и создаём временный, в который записываем измененный текст. Потом, когда будем закрываться, заменим входной файл временным.
print "Открываем исходный файл...";
open(my $in, "<:encoding(UTF-8)", $datafile) || die " ошибка при открытии: $!\n";
print " открыт\n";
print "Содаём временный файл...";
open(my $out, ">:encoding(UTF-8)", $outfile) || die " ошибка при создании: $!\n";
print " создан\n";

print"Выполняем указания...\n";
while (my $fileline = <$in>)
  {
# Каждую строчку копируем в выходной файл
    print $out $fileline;

# Если нашли нужную запись, переходим к следующей строчке
    next if $found_all;

# Работаем, только если часть названия совпала с содержимым строчки - грубый и простой способ найти xml-элемент по содержимому в хорошо отформатированном xml-файле.
    foreach my $name_part (keys(%orderlist))
      {
        if ($fileline =~ /$name_part/) # Полный пиздец в плане производительности, знаю.
          {
            print "!";
            print $log "Найдена строка $name_part во входном файле!\n";

            my $old_image_name = ${$orderlist{$name_part}}[0];
            my $new_image_name = ${$orderlist{$name_part}}[1];
						
						($new_image_name = translit($new_image_name)) unless $NOTRANSLIT;	
						
# Дописываем строчкой ниже описание элемента image
            print $out '    <image>'.$new_image_name.$imgformat.'</image>'."\n";

            my $image     = $imgfolder.$old_image_name.$imgformat;
            my $thumb     = $imgthumbfolder.'thumb-'.$old_image_name.$imgformat;
            my $newimage  = $imgfolder.$new_image_name.$imgformat;
            my $newthumb  = $imgthumbfolder.'thumb-'.$new_image_name.$imgformat;
          
						($newthumb = encode("cp1251", $newthumb)) unless $UTF8FS; # ОБЯЗАТЕЛЬНО ДЛЯ FAT32 В РУССКОЙ ЛОКАЛИ windows-1251! Названия файлов в этой FS кодируются в местной локали, а не в UTF-8.
            if ( move($thumb, $newthumb) )
              {
                print $log "Успешно переименован $thumb в $newthumb\n";
              }
            else
              {
                print $log "Ошибка при переименовании $thumb в $newthumb: $!\n";
              }
         
						($newimage = encode("cp1251", $newimage)) unless $UTF8FS; # ОБЯЗАТЕЛЬНО ДЛЯ FAT32 В РУССКОЙ ЛОКАЛИ windows-1251! Названия файлов в этой FS кодируются в местной локали, а не в UTF-8.
            if ( move($image, $newimage) ) 
              {
                print $log "Успешно переименован $image в $newimage\n";
              }
            else
              {
                print $log "Ошибка при переименовании $image в $newimage: $!\n";
              }

# Удаляем команду из списка команд для ускорения процесса поиска следующих книг                
            delete $orderlist{$name_part};
          }
  } # end foreach keys(%orderlist);
# Ставим пометку, что нашли все записи, если нашли все записи
    if (keys(%orderlist) == 0)
      {
        print $log "Нашли все записи, указанные в указаниях :) \n";
        $found_all = 1;
      }
} # end while(<$in>)

if (keys(%orderlist))
  {
    print $log "В списке указаний остались записи:\n";
    foreach my $order_left (%orderlist)
      {
        print 'x';
        print $log ${$orderlist{$order_left}}[0].';'.${$orderlist{$order_left}}[1].';'.$order_left."\n";
      }
  } # end if(keys(%orderlist))

print "\nУказания выполнены, закрываем входной и временный файлы...";
close($in) || die " ошибка при закрытии файла $datafile: $!\n";
close($out) || die " ошибка при закрытии файла $outfile: $!\n";
print " закрыты\n";

print "Создаём резервную копию входных данных...";
move($datafile, $datafile.'.old') || die ' '.$!;
print "\n$datafile сохранён как $datafile.old\n";
print "Заменяем исходный файл временным...";
move($outfile, $datafile) || die ' '.$!;
print "\n$outfile сохранён как $datafile\n";

# Всё.
print "Все операции завершены, подробности в $logfile\n";
