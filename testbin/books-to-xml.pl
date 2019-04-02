#!perl
# Скрипт для перегона простого текстового каталога книг в xml-формат.
# На вход подаётся текст, в котором построчно записаны следующие данные:
#  Название книги
#  Автор книги
#  Издательство; Город; Год издания				#через запятую!
#  Код категории; Описание книги 		#через запятую!
#  Файл изображения, Количество страниц, Состояние книги	#через запятую!
# 
# Эта информация повторяется для каждой книги через две, в крайнем случае, одну пустую строку. Можно оставлять строки пустыми. Можно в качестве части строки, перечисляемой через запятую, писать прочерки -- это удобнее, чем оставлять пустыми. ЗАПЯТЫЕ СТАВИТЬ ОБЯЗАТЕЛЬНО.
#
# На выходе будет xml-документ с корневым элементом book-list, содержащий набор элементов book, каждый из которых содержит следующий набор элементов:
#  name		Название книги
#  author	Автор книги
#  publisher	Издательство
#  city		Город издания
#  year		Год издания
#  category	Категория
#  image	Путь к файлу изображения
#  description	Описание книги
#  pagenum	Количество страниц
#  condition	Состояние книги
#
use strict;
use warnings;
use utf8;

# Название подкаталога с изображениями, будет вставлено в xml как entity
my $infilename 	= shift || "data/books-data.txt";
my $outfilename = shift || "data/books-data.xml";

# Разделитель элементов информации о книге
my $SEPARATOR = /; /;

# Открываем входной файл
open (my $in, "<", $infilename) or die "Can't open $infilename: $!\n";

# Открываем выходной файл
open (my $out, ">", $outfilename) or die "Can't open $outfilename: $!\n";

# Пишем заголовок в выходной файл
print $out '<?xml version="1.0" encoding="UTF-8" ?>'."\n";
print $out "<books>\n";

# Начинаем счётчик прочитанной строки
my $linenum = 1;
# Для каждых пяти строчек входного файла выбираем из них данные и выводим в выходной документ
LINE: while(<$in>)
  {
    chomp;
    if    ($linenum == 1) 					# Название
      {
        if (/^$/) {next LINE}; # Пропускаем пустые строчки, если ждём заголовок
        print $out "  <book>\n";
        print $out "    <name>$_</name>\n";
        $linenum = 2;
      }
    elsif ($linenum == 2)					# Автор
      {
        print $out "    <author>$_</author>\n";
        $linenum = 3;
      }
    elsif ($linenum == 3)					# Издательство, город, год издания
      {
        my @data = split($SEPARATOR, $_);
        print $out "    <publisher>$data[0]</publisher>\n";
        print $out "    <city>$data[1]</city>\n";
        print $out "    <year>$data[2]</year>\n";
        $linenum = 4;
      }
    elsif ($linenum == 4)					# Категория, описание
      {
        my @data = split($SEPARATOR, $_);
        print $out "    <category>$catname{$data[0]}</category>\n";
        print $out "    <description>$data[1]</description>\n";
        $linenum = 5;
      }
    elsif ($linenum == 5)					# Кол-во страниц, состояние, изображение
      {
        my @data = split($SEPARATOR, $_);
        print $out "    <pagenum>$data[0]</pagenum>\n";
        print $out "    <condition>$data[1]</condition>\n";
        print $out "  </book>\n";
        if ($data[2]) {
        print $out "    <image>$data[2]</image>\n";
		}
      $linenum = 1;
      }
    else
      {
        # DO NOTHING 
      }
  }
print $out "</books>\n";

