#!/usr/bin/perl
#Скрипт для переименования ссылок на изображения в каталоге. До кучи переименовывает и сами файлы. Переименование идёт с русского языка на транслит.
#На вход подаётся xml-файл каталога книг, где ищутся элементы image. Содержимое этих элементов переименовывается.
#

use warnings;
use strict;
use File::Copy;
use utf8;

my $infile = shift || 'books.xml';
my $outfile = shift || $infile;
my $image_folder = 'images/';
my $thumb_folder = 'images/thumbs/';

my $tempfile = ($infile eq $outfile)?$infile.'.temp':$outfile;

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
	print "Начинаем транслировать строку $instring...\n";
	foreach my $cyr_letter (keys(%{$translatetable}))
		{
			my $latin_letter = $translatetable->{$cyr_letter};
			print "Буква $cyr_letter: транслируется в $latin_letter\n";
			print "Строка $instring была оттранслирована в ";
			$instring =~ s/$cyr_letter/$latin_letter/g;
			print " $instring\n";
		};
	return $instring;
	}

print "Сохраняем резервную копию исходного файла... ";
copy $infile, $infile.'.bak' || print "не удалось: $!\n";
print "закончено\n";

open (my $in, "<:utf8", $infile) || die "Не могу открыть $infile: $!\n";
open (my $out, ">:utf8", $tempfile) || die "Не могу открыть $tempfile: $!\n";

while(<$in>){
	if (/<image>/)
	{
		print "Нашлось название изображения: ";
		m|(\s*<image>)(.*)(</image>)|;
		print "Разбито на $1, $2 и $3\n";
		print "$2\n";
		my $transstring = translit($2);
		print "Переименовали в $transstring\n";
		print $out $1.$transstring.$3."\n";
		print "Перемещаем $2 в $transstring... ";
		if (move($image_folder.$2, $image_folder.$transstring))
		{
			print "успешно\n";
		}
		else
		{
			print "не удалось переместить: $!\n";
		}
		print "Перемещаем 'thumb-'.$2 в 'thumb-'.$transstring... ";
		if (move($thumb_folder.'thumb-'.$2, $thumb_folder.'thumb-'.$transstring))
		{
			print "успешно\n";
		}
		else
		{
			print "не удалось переместить: $!\n";
		}
	}
	else
	{
		print $out $_;
	}
}

print "Обработан входной файл, закрываем...";
close($in);
close($out);
print " успешно\n";

print "Переименовываем $tempfile в $outfile\n";
move $tempfile, $outfile;
print "Все операции завершены\n";

