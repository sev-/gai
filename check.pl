#!/usr/local/bin/perl

# $Id:$
#
# Author	  : Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Created On	  : Tue Jun 17 13:11:28 UKD 1997
# Last Modified By: Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Last Modified On: 
# Status	  : Beta version.

do "config.ph";

&getFormData;

$responce = $FORM{'responce'};
$card = $FORM{'card'};
$question = $FORM{'question'};
$name = $FORM{'name'};
$pass = 1 if $FORM{'pass'} ne "";

@request_result = ();

&read_onexams;

if ((time - $FORM{'starttime'}) >= $MAXTIME) {
  $min = $MAXTIME/60;
  push (@request_result, <<EOHTML);
Content-type: text/html


<html>
<title>$name провалил экзамен</title>
<body $bodyline>
$name, Вы превысили отведенные $min минут<br>
Вы не сдали экзамен.

<p><a href="/gai-bin/pickname.pl">Готово</a>
</body>
</html>
EOHTML
  $onexams_faults{$name} += 100;
  &write_onexams;

  &print_HTML;
  exit 0;
}

if ($pass != 1) {
  open (IN, $responces_file) ||
    (print("Content-type: text/html\n\nCan not open file $responces_file ($!)\n"), exit 0);

  while (<IN>) {
    next unless /^$card\)/;
    $valid = (split)[$question];
  }
  close IN;

  $onexams_faults{$name} += 1 if ($responce != $valid);
  $onexams_replies{$name} .= " $question";
  $onexams_replies{$name} =~ s/^0\s*//;

  &write_onexams;
}

  if ($onexams_faults{$name} == 2) {
    push (@request_result, <<EOHTML);
Content-type: text/html


<html>
<title>$name провалил экзамен</title>
<body $bodyline>
$name, Вы ответили неправильно на два вопроса.<br>
Вы не сдали экзамен.

<p><a href="/gai-bin/pickname.pl">Готово</a>
</body>
</html>
EOHTML
    &print_HTML;
    exit 0;
  }

for $a (split(/\s+/, $onexams_replies{$name})) {
  $rep[$a] = 1;
}

$num = 0;
do {
  $question++;
  $num++;
  $question = 1 if $question == $NUMQUESTS+1;
} while ($rep[$question] && $num < $NUMQUESTS);

if ($num == $NUMQUESTS) {
    push (@request_result, <<EOHTML);
Content-type: text/html


<html>
<title>$name сдал экзамен</title>
<body $bodyline>
$name, Вы успешно сдали экзамен. Позовите преподавателя.

<p><a href="/gai-bin/pickname.pl">Готово</a>
</body>
</html>
EOHTML
    &print_HTML;
    exit 0;
}

print "Location: /gai-bin/cards.pl?card=$card&question=$question&mode=1&name=$FORM_{name}&starttime=$FORM{starttime}\n\n";

exit 0;
