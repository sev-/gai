#!/usr/local/bin/perl

# $Id:$
#
# Author	  : Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Created On	  : Tue Jun 17 14:20:28 UKD 1997
# Last Modified By: Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Last Modified On: 
# Status	  : Beta version.

do 'config.ph';

@request_result = ();

push (@request_result, "Content-type: text/html\npragma: no-cache\n\n");

&getFormData;

$mode = $FORM{'mode'} || 1;

if ($mode == 1) {
  &mainmenu;
} elsif ($mode == 2) {
  &list_users;
} elsif ($mode == 3) {
  &delete_list;
} elsif ($mode == "3.1") {
  &delete_confirm;
} elsif ($mode == "3.2") {
  &delete_actual;
} elsif ($mode == 4) {
  &add_list;
} elsif ($mode == "4.1") {
  &add_list_actual;
} elsif ($mode == 5) {
  &edit_list;
} elsif ($mode == "5.1") {
  &edit_list_editing;
} elsif ($mode == "5.2") {
  &edit_list_actual;
} elsif ($mode == "6") {
  &list_exams;
} elsif ($mode == "7") {
  &erase_data;
} elsif ($mode == "7.1") {
  &erase_confirm;
} elsif ($mode == "7.2") {
  &erase_actual;
} else {
  push (@request_result, "Still not implemented");
}

&print_HTML;

exit 0;

###########################################################################

sub mainmenu {
  push (@request_result, <<HTML);
<html>
<title>Менеджер экзаменов -- Начало</title>
<body $bodyline>

<p>Добро пожаловать в систему администрирования приема экзаменов ГАИ.<br>
Выберите нужный Вам пункт:

<p>
<ol>
  <li><a href="$manager_script?mode=2"> Просмотр текущего списка экзаменуемых</a>
  <li><a href="$manager_script?mode=3"> Удаление из текущего списка экзаменуемых</a>
  <li><a href="$manager_script?mode=4"> Добавление к текущему списку экзаменуемых</a>
  <li><a href="$manager_script?mode=5"> Исправить ошибки в ранее введенном списке</a>
  <br>
  <br>
  <li><a href="$manager_script?mode=6"> Просмотр текущих результатов сдачи экзаменов</a>
  <br>
  <br>
  <li><a href="$manager_script?mode=7"> Стирание информации о текущей сдаче экзаменов</a>
</ol>

</body>
</html>
HTML
}

sub list_users {
  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Список экзаменующихся</title>
<body $bodyline>

<table>
<ol>
EOHEAD

  &read_names;

  for $people (sort keys %names) {
    ($name, $year) = split(/\s*;\s*/, $people);
    push (@request_result, "<tr><td><li><td> $name <td>$year\n");
  }

  push (@request_result, <<EOTAIL);
</ol>
</table>
<a href="$manager_script?mode=1"> В Меню</a>
</body>
</html>
EOTAIL
}

sub delete_list {
  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Удаление экзаменующихся</title>
<body $bodyline>

<p>Выберите экзаменующихся, котроых необходимо удалить из списка.

<p>
<a href="$manager_script?mode=1"> Я ошибся. В Меню</a><p>
<form method="get" action="$manager_script">
<input type=hidden name=mode value="3.1">
EOHEAD

  &read_names;

  for $people (sort keys %names) {
    ($name, $year) = split(/\s*;\s*/, $people);
    push (@request_result, "<input type=checkbox value=y name='n$people'> $name $year<br>\n");
  }

  push (@request_result, <<EOTAIL);
<input type=submit value=" Готово ">
</form>
</body>
</html>
EOTAIL
}

sub delete_confirm {
  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Подтверждение удаления</title>
<body $bodyline>

<p>Вы Действительно уверены, что хотите удалить нижеследующих экзаменующихся
из списка?

<p>
<form method="get" action="$manager_script">
<input type=hidden name=mode value="3.2">
EOHEAD

  for $key (keys(%FORM)) {
    next unless ($key =~ /^n/);
    $tmp = $key;
    $tmp =~ s/^n//;
    $names{$tmp} = '1';
  }

  for $name (sort keys %names) {
    push (@request_result, "$name<br><input type=hidden value=y name='n$name'>\n");
  }

  push (@request_result, <<EOTAIL);
<p>
<input type=submit value=" Согласен ">
</form>
<a href="$manager_script?mode=1">Я ошибся. В Меню.</a>
</body>
</html>
EOTAIL
}

sub delete_actual {
  &read_names;

  for $key (keys(%FORM)) {
    next unless ($key =~ /^n/);
    $tmp = $key;
    $tmp =~ s/^n//;
    $names{$tmp} = 0;
  }

  &write_names;  
  &list_users;
}

sub add_list {
  push (@request_result, <<EOHTML);
<html>
<title>Менеджер экзаменов -- Добавление в список</title>
<body $bodyline>

<p><a href="$manager_script?mode=1"> Я ошибся. В Меню</a>
<p> Введите фамилию, имя, отчество и год рождения в виде <br>
    Ф И О; год, Ф И О; год, и т.д.

<form method="get" action="$manager_script">
  <center>
  <input type=hidden name=mode value="4.1">
  <textarea name=list cols=68 rows=5 wrap=virtual></textarea><br>
  <input type=submit value=" Готово ">
  </center>
</form>
</body>
</html>
EOHTML
}

sub add_list_actual {
  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Результат добавления в список</title>
<body $bodyline>

<p> Были успешно добавлены:
<table>
<ol>
EOHEAD

  &read_names;
  @success = ();
  @unsuccess = ();

  $FORM{'list'} =~ s/\s+/ /;

  @peoples = split(/\s*,\s*/, $FORM{'list'});
  for $people (@peoples) {
    ($name, $year) = split(/\s*;\s*/, $people);
    if(! defined($year)) {
      push (@unsuccess, $people);
    } else {
      push (@success, $people);
      $name =~ s/^\s+|\s+$//;
      $names{$name.';'.$year} = 1;
    }
  }
  &write_names;

  for $people (@success) {
    ($name, $year) = split(/\s*;\s*/, $people);
    push (@request_result, "<tr><td><li><td> $name <td>$year\n");
  }

  push (@request_result, <<EOMIDDLE) if (@unsuccess);
</ol>
</table>
<p>Не определен год рождения для:
<table>
<ol>
EOMIDDLE

  for $people (@unsuccess) {
    push (@request_result, "<tr><td><li> <td>$people\n");
  }

  push (@request_result, <<EOTAIL);
</ol>
</table>
<p> <a href="$manager_script?mode=1">В меню</a>
</body>
</html>
EOTAIL
}

sub edit_list {
  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Редактирование записей</title>
<body $bodyline>

<p><a href="$manager_script?mode=1"> Я ошибся. В Меню</a>
<p>Выберите экзаменующихся, где необходимо произвести изменения.

<p>
<form method="get" action="$manager_script">
<input type=hidden name=mode value="5.1">
<table>
EOHEAD

  &read_names;

  for $people (sort keys %names) {
    ($name, $year) = split(/\s*;\s*/, $people);
    push (@request_result, "<tr><td><input type=checkbox value=y name='n$people'><td> $name<td> $year<br>\n");
  }

  push (@request_result, <<EOTAIL);
</table>
<input type=submit value=" Готово ">
</form>
</body>
</html>
EOTAIL
}

sub edit_list_editing {
  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Редактирование списка</title>
<body $bodyline>

<p><a href="$manager_script?mode=1"> Я ошибся. В Меню</a>
<p> Введите фамилию, имя, отчество и год рождения в виде <br>
    Ф И О; год, Ф И О; год, и т.д.
<p>
<form method="get" action="$manager_script">
  <center>
  <input type=hidden name=mode value="5.2">
EOHEAD

  $list = "";
  for $key (keys(%FORM)) {
    next unless ($key =~ /^n/);
    $tmp = $key;
    $tmp =~ s/^n//;
    $list .= $tmp . ', ';
    push (@request_result, "  <input type=hidden name='$key' value=1>\n");
  }
  $list =~ s/, $//;
  
push (@request_result, <<EOTAIL);
  <textarea name=list cols=68 rows=5 wrap=virtual>$list</textarea><br>
  <input type=submit value=" Готово ">
  </center>
</form>
</body>
</html>
EOTAIL
}

sub edit_list_actual {
  &read_names;

# now remove all old records
  for $key (keys(%FORM)) {
    next unless ($key =~ /^n/);
    $tmp = $key;
    $tmp =~ s/^n//;
    $names{$tmp} = 0;
  }

# add'em
  $FORM{'list'} =~ s/\s+/ /;

  @peoples = split(/\s*,\s*/, $FORM{'list'});
  for $people (@peoples) {
    ($name, $year) = split(/\s*;\s*/, $people);
    $name =~ s/^\s+|\s+$//;
    $names{$name.';'.$year} = 1 if(defined($year));
  }

  &write_names;

  &list_users;
}

sub list_exams {
  if(! &read_onexams) {
    push (@request_result, <<EOHTML);
<html>
<title>Менеджер экзаменов -- Сдача экзаменов</title>
<body $bodyline>
Никто экзамены не сдает
</body>
</html>
EOHTML

  return;
  }  

  push (@request_result, <<EOHEAD);
<html>
<title>Менеджер экзаменов -- Сдача экзаменов</title>
<body $bodyline>

<table>
<ol>
<tr><td><td>ФИО <td>Дата рождения<td>билет <td>Начал сдавать <td>ответил на вопросы <td>Неправильно <td>Результат
EOHEAD

  for $p (sort keys %onexams_card) {
    if ($onexams_faults{$p} > 1) {
      if ($onexams_faults{$p} >= 100) {
        $onexams_faults{$p} -= 100;
        $res = "Вышло время";
      } else { $res = "Провалил"; }
    } else {
      @a = split(/\s+/, $onexams_replies{$p});
      if ($#a > $NUMQUESTS-1) { $res = "Сдал" }
      else { $res = "Сдает" }
    }

    ($n, $y) = split(/\s*;\s*/, $p);
    ($sec, $min, $hour, $mday, $mon, $year) = localtime($onexams_starttime{$p});
    $t = sprintf ("%02d:%02d.%02d %02d-%02d-%04d",$hour+3,$min,$sec,$mday,$mon,$year);
    push (@request_result, "<tr><td><li><td>$n<td>$y<td>$onexams_card{$p}<td>$t<td>$onexams_replies{$p}<td>$onexams_faults{$p} <td>$res\n");
  }
  push (@request_result, <<EOHEAD);
</ol>
</table>
<a href="$manager_script?mode=1"> В Меню</a>
</body>
</html>
EOHEAD
}

sub erase_data {
  push (@request_result, <<EOHTML);
<html>
<title>Менеджер экзаменов -- Стирание информации</title>
<body $bodyline>
<p>Будьте внимательны.
<p>Выберите из списка информацию, которую Вы хотите удалить. При удалении
она теряется безвозвратно.
<p><form action="$manager_script" method=get>
<ol>
<li><input type=checkbox name=onexams> Информацию о сдаче экзаменов
<li><input type=checkbox name=names> Список экзаменуемых
</ol>
<input type=submit value="Готово">
<input type=hidden name=mode value="7.1"><a href="$manager_script?mode=1"> Я ошибся. В Меню</a>
</form>

</body>
</html>
EOHTML
}

sub erase_confirm {
  $names = $FORM{names}?"checked":"";
  $onexams = $FORM{onexams}?"checked":"";
  push (@request_result, <<EOHTML);
<html>
<title>Менеджер экзаменов -- Подтверждение cтирания информации</title>
<body $bodyline>
<p>Вы действительно уверены, что хотите удалить:
<p><form action="$manager_script" method=get>
<ol>
<li><input type=checkbox name=onexams $onexams> Информацию о сдаче экзаменов
<li><input type=checkbox name=names $names> Список экзаменуемых
</ol>
После удаления информация теряется безвозвратно.<br>
<input type=submit value="Уверен">
<input type=hidden name=mode value="7.2"><a href="$manager_script?mode=1"> Я ошибся. В Меню</a>
</form>
</body>
</html>
EOHTML
}

sub erase_actual {
  if ($FORM{names}) {
    unlink($names_file) ||
    (print "Content-type: text/html\n\nCan not unlink file $names_file ($!)\n", exit 0);
  }
  if ($FORM{onexams}) {
    unlink($exams_file) ||
    (print "Content-type: text/html\n\nCan not unlink file $exams_file ($!)\n", exit 0);
  }
  push (@request_result, <<EOHTML);
<html>
<title>Менеджер экзаменов -- Сообщение о стирании</title>
<body $bodyline>
<p>Указанная Вами информация была успешно стерта
<p><a href="$manager_script?mode=1"> В Меню</a>
</body>
</html>
EOHTML
}
