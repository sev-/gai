#!/usr/local/bin/perl

# $Id:$
#
# Author	  : Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Created On	  : Tue Jun 17 14:20:28 UKD 1997
# Last Modified By: Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Last Modified On: 
# Status	  : Beta version.

do "config.ph";

srand ($$);

&getFormData;

$mode = $FORM{'mode'} || 1;

@request_result = ();

if ($mode == 1) {
  &list_users
} elsif ($mode == 2) {
  &flush_base;
} else {
  print "Content-type: text/html\n\nStill not implemented";
}

&print_HTML;

exit 0;

sub list_users {
  push (@request_result, <<EOHEAD);
Content-type: text/html
pragma: no-cache


<html>
<title>Выбор экзаменующегося</title>
<body $bodyline>

<center>
<p>Выберите свое имя из списка<br>

<form method="get" action="$pick_script">
<input type=hidden name=mode value=2>

<table>
EOHEAD

  &read_names;
  &read_onexams;

  for $p (keys %onexams_card) {
    $names{$p} = 0;
  }

  for $people (sort keys %names) {
    ($name, $year) = split(/\s*;\s*/, $people);
    if ($names{$people}) {
      push (@request_result, "<tr><td><input type=radio name=name value=\"$people\"> <td>$name <td>$year<br>\n")
    } else {
      push (@request_result, "<tr><td> <td>$name <td>$year<br>\n")
    }
  }

  push (@request_result, <<EOTAIL);
<tr><td colspan=3 align=center><input type=submit value=" Готово ">
</table>
</form>
</center>
</body>
</html>
EOTAIL
}

sub flush_base {
  &read_onexams;

  do {
    $new_card = int(rand ($NUMCARDS-1) + 1);
  } while ($onexams_chosen_card[$new_card]);

  $onexams_card{$FORM{'name'}} = $new_card;
  $onexams_replies{$FORM{'name'}} = 0;
  $onexams_faults{$FORM{'name'}} = 0;
  $onexams_starttime{$FORM{'name'}} = time;

  &write_onexams;

  $starttime = time;  
  print "Location: /gai-bin/cards.pl?card=$new_card&question=1&mode=1&name=$FORM_{name}&starttime=$onexams_starttime{$FORM{'name'}}\n\n";
}
